package com.experiencia.experiencia_movil

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createMcAlertChannel()
    }

    /**
     * HU-18: crea el canal de notificaciones de alta prioridad que usa el backend
     * (`channel_id = mc_alerts`) para que las alertas del Asistente MC aparezcan como aviso flotante.
     */
    private fun createMcAlertChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            "mc_alerts",
            "Alertas del maestro de ceremonias",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Avisos cuando la atención del público cae de forma sostenida"
            enableVibration(true)
        }
        getSystemService(NotificationManager::class.java)?.createNotificationChannel(channel)
    }
}
