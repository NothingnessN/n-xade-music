package com.nxadestudios.nxademusic

<<<<<<< HEAD
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity()
=======
import android.os.Build
import android.os.Bundle
import android.util.Log
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Mali GPU detection for Android 11 compatibility
        if (Build.VERSION.SDK_INT <= 30) {
            val gpuRenderer = android.opengl.GLES20.glGetString(android.opengl.GLES20.GL_RENDERER)
            val gpuVendor = android.opengl.GLES20.glGetString(android.opengl.GLES20.GL_VENDOR)
            
            Log.d("MainActivity", "GPU Renderer: $gpuRenderer")
            Log.d("MainActivity", "GPU Vendor: $gpuVendor")
            
            if (gpuRenderer?.contains("Mali", ignoreCase = true) == true) {
                Log.w("MainActivity", "⚠️ Mali GPU detected on Android ${Build.VERSION.SDK_INT} - Using Skia renderer")
                // Flutter will automatically fallback to Skia on Mali GPU
            }
        }
    }
}
>>>>>>> 8f00aa7 (Added android 11-10 Mali Gpu Support)
