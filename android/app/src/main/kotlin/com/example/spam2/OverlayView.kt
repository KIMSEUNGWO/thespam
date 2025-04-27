// OverlayView.kt
package com.example.spam2

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.util.Log
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.TextView
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat

class OverlayView private constructor(private val context: Context) {

    companion object {
        @SuppressLint("StaticFieldLeak")
        @Volatile
        private var INSTANCE: OverlayView? = null

        fun getInstance(context: Context): OverlayView {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: OverlayView(context.applicationContext).also { INSTANCE = it }
            }
        }
    }

    private var overlayView: View? = null
    private var windowManager: WindowManager? = null

    @RequiresApi(Build.VERSION_CODES.M)
    fun showOverlay(phoneNumber: String, type: String = "NONE") {
        if (overlayView != null) return  // 이미 떠 있으면 안 띄움

        val inflater = LayoutInflater.from(context)
        overlayView = inflater.inflate(R.layout.overlay_notification, null)

        // 전화번호 설정
        overlayView?.findViewById<TextView>(R.id.phone_number)?.text = phoneNumber

        // 배경색 및 아이콘 설정
        val overlayRoot = overlayView?.findViewById<View>(R.id.overlay_root)
        val iconView = overlayView?.findViewById<ImageView>(R.id.icon_view)

        if (type == "SPAM") {
            // 스팸인 경우
            overlayRoot?.setBackgroundColor(ContextCompat.getColor(context, R.color.red))
            iconView?.setImageResource(R.drawable.ic_warning)
            overlayView?.findViewById<TextView>(R.id.info_text)?.text = "보이스피싱"
        } else {
            // 스팸이 아닌 경우
            overlayRoot?.setBackgroundColor(ContextCompat.getColor(context, R.color.green))

            // 타입에 따라 아이콘 변경
            when (type) {
                "BANK" -> {
                    iconView?.setImageResource(R.drawable.ic_bank)
                    overlayView?.findViewById<TextView>(R.id.info_text)?.text = "신한은행"
                }
                else -> {
                    iconView?.setImageResource(R.drawable.ic_phone)
                    overlayView?.findViewById<TextView>(R.id.info_text)?.text = "일반 전화"
                }
            }
        }

        // 닫기 버튼
        overlayView?.findViewById<ImageView>(R.id.close_button)?.setOnClickListener {
            removeOverlay()
        }

        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        else
            WindowManager.LayoutParams.TYPE_PHONE

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT
        )

        // 화면 중앙에 위치시키기
        params.gravity = Gravity.CENTER
        // width를 화면 크기보다 작게 설정 (양쪽 마진 20픽셀)
        val displayMetrics = context.resources.displayMetrics
        params.width = displayMetrics.widthPixels - 40 // 양쪽 마진 각각 20픽셀
        params.height = WindowManager.LayoutParams.WRAP_CONTENT

        windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        windowManager?.addView(overlayView, params)
    }

    fun removeOverlay() {
        try {
            Log.d("OverlayView", "Remove Overlay !!!")
            if (overlayView != null && windowManager != null) {
                windowManager?.removeView(overlayView)
                overlayView = null
            }
        } catch (e: Exception) {
            Log.e("OverlayView", "Error removing overlay: ${e.message}")
            // 오류 발생 시 참조 초기화
            overlayView = null
            windowManager = null
        }
    }
}