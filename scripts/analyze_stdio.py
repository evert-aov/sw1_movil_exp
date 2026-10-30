"""Consulta el analizador Dart por su protocolo stdio sin modificar configuración del usuario."""
import argparse
import json
import shutil
import sys
from pathlib import Path
import selectors
import subprocess
import tempfile
import time

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--dart-sdk', type=Path, help='SDK que contiene bin/dartaotruntime y sus snapshots')
args = parser.parse_args()
executable = shutil.which('dart')
if args.dart_sdk is None and executable is None:
    raise SystemExit('Configura --dart-sdk o instala Dart.')
sdk = args.dart_sdk or Path(executable).resolve().parents[1]
root = Path(__file__).resolve().parents[1]
if not (sdk/'bin/snapshots/analysis_server_aot.dart.snapshot').exists():
    raise SystemExit('No se encontró el snapshot del analizador; configura --dart-sdk.')
with tempfile.TemporaryDirectory(prefix='experiencia-analysis-') as cache:
    process = subprocess.Popen([str(sdk/'bin/dartaotruntime'), str(sdk/'bin/snapshots/analysis_server_aot.dart.snapshot'), '--client-id=codex', '--cache='+cache], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, bufsize=1)
    def send(value):
        process.stdin.write(json.dumps(value)+'\n'); process.stdin.flush()
    send({'id':'status','method':'server.setSubscriptions','params':{'subscriptions':['STATUS']}})
    send({'id':'roots','method':'analysis.setAnalysisRoots','params':{'included':[str(root)],'excluded':[str(root/'build'),str(root/'.dart_tool')]}})
    selector=selectors.DefaultSelector()
    selector.register(process.stdout,selectors.EVENT_READ,'stdout')
    selector.register(process.stderr,selectors.EVENT_READ,'stderr')
    errors={};stderr=[];active=False;done=False;protocol_errors=[];roots_acknowledged=False
    limit=time.monotonic()+45
    while time.monotonic()<limit and process.poll() is None:
        for key,_ in selector.select(timeout=0.2):
            line=key.fileobj.readline()
            if not line:
                selector.unregister(key.fileobj);continue
            if key.data=='stderr':stderr.append(line.strip());continue
            try:event=json.loads(line)
            except ValueError:continue
            if 'error' in event:protocol_errors.append(event)
            if event.get('id') == 'roots' and 'error' not in event:roots_acknowledged=True
            if event.get('event')=='analysis.errors':
                params=event['params'];errors[params['file']]=params['errors']
            if event.get('event')=='server.error':protocol_errors.append(event)
            if event.get('event')=='server.status':
                analyzing=event.get('params',{}).get('analysis',{}).get('isAnalyzing')
                if analyzing is True:active=True
                if active and roots_acknowledged and analyzing is False:done=True
        if done:break
    if process.poll() is None:
        send({'id':'shutdown','method':'server.shutdown'})
    try:process.communicate(timeout=5)
    except subprocess.TimeoutExpired:process.kill();process.communicate()
    diagnostics=[]
    for file,items in errors.items():
        for item in items:
            diagnostics.append({'file':file.replace(str(root)+'/',''),'severity':item['severity'],'message':item['message'],'line':item['location']['startLine']})
    report={'completed':done,'diagnostics':diagnostics,'protocol_errors':protocol_errors,'stderr':stderr}
    Path('/tmp/experiencia-dart-analysis.json').write_text(json.dumps(report,ensure_ascii=False,indent=2))
    print(json.dumps(report,ensure_ascii=False,indent=2))

raise SystemExit(0 if done and not diagnostics and not protocol_errors and not stderr else 1)
