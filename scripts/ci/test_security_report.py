import json
import unittest

from security_report import assess_report, render_summary


def scan_result(*, vulnerabilities=None, secrets=None, target="tests/fixture.txt"):
    result = {"Target": target, "Class": "lang-pkgs", "Type": "fixture"}
    if vulnerabilities is not None:
        result["Vulnerabilities"] = vulnerabilities
    if secrets is not None:
        result["Secrets"] = secrets
    return {
        "SchemaVersion": 2,
        "ArtifactName": "fixture",
        "ArtifactType": "filesystem",
        "Results": [result],
    }


class SecurityReportTests(unittest.TestCase):
    def assess(self, document, outcome="success"):
        return assess_report(document, outcome, version="test-revision")

    def test_secret_match_fails_without_exposing_match_or_line_data(self):
        marker = "synthetic-secret-value-do-not-display"
        document = json.dumps(
            scan_result(
                vulnerabilities=[],
                secrets=[
                    {
                        "RuleID": "generic-api-key",
                        "Match": marker,
                        "StartLine": 17,
                        "Code": {"Lines": [{"Number": 17, "Content": marker}]},
                    }
                ],
            )
        )

        report, exit_code = self.assess(document)
        rendered = json.dumps(report) + render_summary(report)

        self.assertEqual(exit_code, 1)
        self.assertEqual(report["status"], "failed")
        self.assertEqual(report["evidence"]["secrets_detected"], 1)
        self.assertEqual(
            report["evidence"]["secret_findings"],
            [{"rule_id": "generic-api-key", "target": "tests/fixture.txt", "count": 1}],
        )
        self.assertEqual(report["code"], "SECURITY.SECRET_DETECTED")
        self.assertNotIn(marker, rendered)
        self.assertNotIn('"StartLine"', rendered)
        self.assertNotIn('"Number"', rendered)
        self.assertNotIn('"Match"', rendered)
        self.assertIn("generic-api-key", rendered)
        self.assertIn("tests/fixture.txt", rendered)
        self.assertIn("matched values and line numbers omitted", rendered)

    def test_unsafe_secret_target_is_redacted_from_diagnostics(self):
        unsafe_targets = (
            "../../private-marker/token.txt",
            "/private-marker/token.txt",
            r"C:\private-marker\token.txt",
            "folder/../../private-marker/token.txt",
            "folder\nprivate-marker/token.txt",
        )
        for index, target in enumerate(unsafe_targets):
            with self.subTest(target_kind=index):
                report, _ = self.assess(
                    json.dumps(
                        scan_result(
                            vulnerabilities=[],
                            secrets=[
                                {
                                    "RuleID": "generic-api-key",
                                    "Match": "synthetic-marker",
                                }
                            ],
                            target=target,
                        )
                    )
                )

                self.assertEqual(
                    report["evidence"]["secret_findings"][0]["target"], "redacted"
                )
                self.assertNotIn("private-marker", json.dumps(report))

    def test_relative_windows_secret_target_is_normalized(self):
        report, _ = self.assess(
            json.dumps(
                scan_result(
                    vulnerabilities=[],
                    secrets=[
                        {"RuleID": "generic-api-key", "Match": "synthetic-marker"}
                    ],
                    target=r".\tests\fixture.txt",
                )
            )
        )

        self.assertEqual(
            report["evidence"]["secret_findings"][0]["target"], "tests/fixture.txt"
        )

    def test_secret_findings_are_aggregated_sorted_and_bounded(self):
        secrets = [{"RuleID": f"generic-api-key-{index:02d}"} for index in range(21)]
        secrets.append({"RuleID": "generic-api-key-00"})
        report, _ = self.assess(
            json.dumps(scan_result(vulnerabilities=[], secrets=secrets))
        )
        findings = report["evidence"]["secret_findings"]

        self.assertEqual(report["evidence"]["secrets_detected"], 22)
        self.assertEqual(len(findings), 20)
        self.assertEqual(findings[0]["rule_id"], "generic-api-key-00")
        self.assertEqual(findings[0]["count"], 2)
        self.assertEqual(findings[-1]["rule_id"], "generic-api-key-19")
        self.assertTrue(report["evidence"]["secret_findings_truncated"])
        self.assertIn(
            "Additional secret finding locations were omitted", render_summary(report)
        )

    def test_invalid_secret_rule_id_is_replaced_with_unknown(self):
        report, _ = self.assess(
            json.dumps(
                scan_result(
                    vulnerabilities=[],
                    secrets=[
                        {"RuleID": {"private-marker": "value"}, "Match": "marker"}
                    ],
                )
            )
        )

        self.assertEqual(report["evidence"]["secret_findings"][0]["rule_id"], "unknown")
        self.assertNotIn("private-marker", json.dumps(report))

    def test_high_and_critical_vulnerabilities_fail_closed(self):
        document = json.dumps(
            scan_result(
                vulnerabilities=[
                    {
                        "VulnerabilityID": "CVE-2099-0001",
                        "Severity": "HIGH",
                        "PkgName": "fixture-package",
                    },
                    {
                        "VulnerabilityID": "CVE-2099-0002",
                        "Severity": "CRITICAL",
                        "PkgName": "fixture-package",
                    },
                ],
                secrets=[],
            )
        )

        report, exit_code = self.assess(document)

        self.assertEqual(exit_code, 1)
        self.assertEqual(report["status"], "failed")
        self.assertEqual(report["evidence"]["vulnerabilities"]["high"], 1)
        self.assertEqual(report["evidence"]["vulnerabilities"]["critical"], 1)
        self.assertEqual(report["code"], "SECURITY.HIGH_OR_CRITICAL_VULNERABILITY")

    def test_medium_and_low_vulnerabilities_are_advisories(self):
        document = json.dumps(
            scan_result(
                vulnerabilities=[
                    {
                        "VulnerabilityID": "CVE-2099-0003",
                        "Severity": "MEDIUM",
                        "PkgName": "fixture-package",
                    },
                    {
                        "VulnerabilityID": "CVE-2099-0004",
                        "Severity": "LOW",
                        "PkgName": "fixture-package",
                    },
                    {
                        "VulnerabilityID": "TEST-UNKNOWN-1",
                        "Severity": "UNKNOWN",
                        "PkgName": "fixture-package",
                    },
                ],
                secrets=[],
            )
        )

        report, exit_code = self.assess(document)

        self.assertEqual(exit_code, 0)
        self.assertEqual(report["status"], "passed")
        self.assertEqual(report["evidence"]["vulnerabilities"]["medium"], 1)
        self.assertEqual(report["evidence"]["vulnerabilities"]["low"], 1)
        self.assertEqual(report["evidence"]["vulnerabilities"]["unknown"], 1)
        self.assertEqual(len(report["evidence"]["advisories"]), 3)
        self.assertIn("MEDIUM: 1", render_summary(report))
        self.assertIn("LOW: 1", render_summary(report))

    def test_malformed_scanner_output_is_not_verified(self):
        for document in (
            "{not-json",
            json.dumps({"unexpected": []}),
            json.dumps({"Results": {}}),
        ):
            with self.subTest(document=document):
                report, exit_code = self.assess(document)
                self.assertNotEqual(exit_code, 0)
                self.assertEqual(report["status"], "not_verified")
                self.assertEqual(report["code"], "SECURITY.SCAN_OUTPUT_INVALID")

    def test_scanner_not_run_or_failed_does_not_pass(self):
        valid_empty_scan = json.dumps(scan_result(vulnerabilities=[], secrets=[]))
        for outcome in ("skipped", "failure", "cancelled"):
            with self.subTest(outcome=outcome):
                report, exit_code = self.assess(valid_empty_scan, outcome=outcome)
                self.assertNotEqual(exit_code, 0)
                expected_status = "not_verified" if outcome == "skipped" else "failed"
                self.assertEqual(report["status"], expected_status)
                self.assertEqual(
                    report["code"],
                    "SECURITY.SCAN_NOT_VERIFIED"
                    if outcome == "skipped"
                    else "SECURITY.SCANNER_FAILED",
                )

    def test_empty_successful_scan_passes(self):
        report, exit_code = self.assess(
            json.dumps(scan_result(vulnerabilities=[], secrets=[]))
        )

        self.assertEqual(exit_code, 0)
        self.assertEqual(report["status"], "passed")
        self.assertEqual(report["evidence"]["secrets_detected"], 0)

    def test_incomplete_trivy_document_without_schema_version_is_not_verified(self):
        report, exit_code = self.assess(json.dumps({"SchemaVersion": 2, "Results": []}))

        self.assertNotEqual(exit_code, 0)
        self.assertEqual(report["status"], "not_verified")

    def test_invalid_scan_reports_safe_validation_reason(self):
        report, exit_code = self.assess(
            json.dumps(
                {
                    "SchemaVersion": 2,
                    "Results": [],
                    "SyntheticSecretMarker": "do-not-report-this-value",
                }
            )
        )

        self.assertNotEqual(exit_code, 0)
        self.assertEqual(
            report["evidence"]["output_validation"], "artifact_name_invalid"
        )
        self.assertNotIn("do-not-report-this-value", json.dumps(report))

    def test_trivy_null_results_representation_is_a_valid_empty_scan(self):
        report, exit_code = self.assess(
            json.dumps(
                {
                    "SchemaVersion": 2,
                    "ArtifactName": "fixture",
                    "ArtifactType": "filesystem",
                    "Results": None,
                }
            )
        )

        self.assertEqual(exit_code, 0)
        self.assertEqual(report["status"], "passed")

    def test_trivy_repository_artifact_type_is_valid_for_git_checkout_scans(self):
        scan = scan_result(vulnerabilities=[], secrets=[])
        scan["ArtifactType"] = "repository"

        report, exit_code = self.assess(json.dumps(scan))

        self.assertEqual(exit_code, 0)
        self.assertEqual(report["status"], "passed")
        self.assertEqual(report["evidence"]["output_validation"], "valid")

    def test_unhashable_artifact_types_fail_closed_with_sanitized_reason(self):
        for artifact_type in ([], {}):
            with self.subTest(artifact_type=type(artifact_type).__name__):
                scan = scan_result(vulnerabilities=[], secrets=[])
                scan["ArtifactType"] = artifact_type

                report, exit_code = self.assess(json.dumps(scan))

                self.assertEqual(exit_code, 1)
                self.assertEqual(report["status"], "not_verified")
                self.assertEqual(
                    report["evidence"]["output_validation"], "artifact_type_invalid"
                )

    def test_report_uses_the_shared_diagnostic_contract_fields(self):
        report, _ = self.assess(json.dumps(scan_result(vulnerabilities=[], secrets=[])))

        self.assertEqual(
            set(report),
            {
                "schema",
                "service",
                "version",
                "phase",
                "status",
                "code",
                "cause_status",
                "evidence",
                "possible_causes",
                "recommended_actions",
            },
        )
        self.assertEqual(
            set(report["evidence"]),
            {
                "scanner",
                "scanner_status",
                "output_validation",
                "secret_scanner_self_test",
                "secrets_detected",
                "secret_findings",
                "secret_findings_truncated",
                "vulnerabilities",
                "blocking_vulnerabilities",
                "advisories",
            },
        )
        self.assertEqual(
            report["evidence"]["secret_scanner_self_test"], "not_applicable"
        )


if __name__ == "__main__":
    unittest.main()
