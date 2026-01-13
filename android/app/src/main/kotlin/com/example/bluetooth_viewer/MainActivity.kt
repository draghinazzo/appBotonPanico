package com.example.botonMPN

import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "volume_channel"
    private lateinit var methodChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
    }

    override fun onKeyUp(keyCode: Int, event: KeyEvent?): Boolean {
        if (::methodChannel.isInitialized && event != null) {
            val duration = event.eventTime - event.downTime
            if (duration >= 1000) {
                when (keyCode) {
                    KeyEvent.KEYCODE_VOLUME_UP -> {
                        methodChannel.invokeMethod("volumeUp", null)
                        return true
                    }
                    KeyEvent.KEYCODE_VOLUME_DOWN -> {
                        methodChannel.invokeMethod("volumeDown", null)
                        return true
                    }
                }
            }
        }
        return super.onKeyUp(keyCode, event)
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        // bloquea el volumen para que no se muestre el panel
        return when (keyCode) {
            KeyEvent.KEYCODE_VOLUME_UP,
            KeyEvent.KEYCODE_VOLUME_DOWN -> true
            else -> super.onKeyDown(keyCode, event)
        }
    }
}
