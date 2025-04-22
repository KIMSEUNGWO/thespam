package com.example.spam2

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Build
import android.telecom.TelecomManager
import android.provider.Settings
import android.app.role.RoleManager

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.spam2/call_detection"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "initializeCallScreening" -> {
                        requestCallScreeningRole()
                        result.success(true)
                    }
                    "checkSpamNumber" -> {
                        val phoneNumber = call.arguments as String
                        // 여기서 실제 서버 API 호출하여 스팸 여부 확인
                        // 예시로 간단하게 구현
                        val isSpam = phoneNumber.endsWith("1234") // 예시: 1234로 끝나는 번호는 스팸
                        result.success(isSpam)
                    }
                    else -> result.notImplemented()
                }
            }

            // CallScreenService에서 사용할 수 있도록 채널 참조 저장
            CallScreenService.methodChannel = this
        }
    }

    private fun requestCallScreeningRole() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(RoleManager::class.java)
            val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
            startActivityForResult(intent, 1001)
        } else {
            // API 29 미만에서는 기본 전화 앱 설정으로 이동
            val intent = Intent(TelecomManager.ACTION_CHANGE_DEFAULT_DIALER)
                .putExtra(TelecomManager.EXTRA_CHANGE_DEFAULT_DIALER_PACKAGE_NAME, packageName)
            startActivityForResult(intent, 1002)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if ((requestCode == 1001 || requestCode == 1002) && resultCode == RESULT_OK) {
            // 권한 획득 성공, 필요한 추가 초기화 작업 수행
        }
    }
}
