// OverlayView.kt
package com.example.spam2

import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.TextView
import androidx.annotation.RequiresApi

class OverlayView(private val context: Context) {

    private var overlayView: View? = null
    private var windowManager: WindowManager? = null

    @RequiresApi(Build.VERSION_CODES.M)
    fun showOverlay(phoneNumber: String) {
        if (overlayView != null) return  // 이미 떠 있으면 안 띄움

        val inflater = LayoutInflater.from(context)
        overlayView = inflater.inflate(R.layout.overlay_notification, null)

        // 전화번호 & 스팸 텍스트 설정
        overlayView?.findViewById<TextView>(R.id.phone_number)?.text = phoneNumber
        overlayView?.findViewById<TextView>(R.id.spam_text)?.text = "스팸 전화로 의심됩니다"

        // 닫기 버튼
        overlayView?.findViewById<ImageView>(R.id.close_button)?.setOnClickListener {
            removeOverlay()
        }

        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        else
            WindowManager.LayoutParams.TYPE_PHONE

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        )

        params.gravity = Gravity.TOP
        params.y = 100

        windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        windowManager?.addView(overlayView, params)
    }

    fun removeOverlay() {
        if (overlayView != null && windowManager != null) {
            windowManager?.removeView(overlayView)
            overlayView = null
        }
    }
}
