package com.example.spam2

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.telecom.TelecomManager
import android.provider.Settings
import android.app.role.RoleManager
import android.util.Log
import android.app.ActivityManager
import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat
import android.net.Uri

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.spam2/call_detection"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "initializeCallScreening" -> {
                        android.util.Log.d("MainActivity", "initializeCallScreening 호출됨")
                        requestCallScreeningRole()
                        result.success(true)
                    }
                    "checkSpamNumber" -> {
                        val phoneNumber = call.arguments as String
                        // 여기서 실제 서버 API 호출하여 스팸 여부 확인
                        // 예시로 간단하게 구현
                        val isSpam = phoneNumber.endsWith("8635") // 예시: 8635로 끝나는 번호는 스팸
                        Log.d("MainActivity", "isSpam : ${isSpam}")
                        result.success(isSpam)
                    }
                    "startCallDetectionService" -> {
                        Log.d("MainActivity", "통화 감지 서비스 시작 요청됨")
                        try {
                            val serviceIntent = Intent(this@MainActivity, CallDetectionService::class.java)
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                startForegroundService(serviceIntent)
                            } else {
                                startService(serviceIntent)
                            }
                            Log.d("MainActivity", "통화 감지 서비스 시작 요청 완료")
                            result.success(true)
                        } catch (e: Exception) {
                            Log.e("MainActivity", "통화 감지 서비스 시작 오류: ${e.message}")
                            result.error("SERVICE_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

            // CallScreenService에서 사용할 수 있도록 채널 참조 저장
            CallScreenService.methodChannel = this
            // MethodChannelHandler에도 채널 저장
            MethodChannelHandler.methodChannel = this
        }
    }


    private fun requestCallScreeningRole() {
        // 권한 상태 확인
        checkAllPermissions()
        // 런타임 권한 요청
        requestRuntimePermissions()
        // 통화 스크리닝 서비스 상태 확인
        checkCallScreeningService()

        Log.d("MainActivity", "requestCallScreeningRole 실행")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            Log.d("MainActivity", "ROLE CALL SCREENING 설정")
            val roleManager = getSystemService(RoleManager::class.java)
            val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
            startActivityForResult(intent, 1001)
        } else {
            // API 29 미만에서는 기본 전화 앱 설정으로 이동
            Log.d("MainActivity", "API 29 미만 기본 전화 앱 설정")
            val intent = Intent(TelecomManager.ACTION_CHANGE_DEFAULT_DIALER)
                .putExtra(TelecomManager.EXTRA_CHANGE_DEFAULT_DIALER_PACKAGE_NAME, packageName)
            startActivityForResult(intent, 1002)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        Log.d("MainActivity", "onActivityResult 호출됨: requestCode=$requestCode, resultCode=$resultCode")

        if (requestCode == 1001) {
            if (resultCode == RESULT_OK) {
                Log.d("MainActivity", "통화 스크리닝 권한 승인됨")
            } else {
                Log.d("MainActivity", "통화 스크리닝 권한 거부됨")
            }
        }

        if ((requestCode == 1001 || requestCode == 1002) && resultCode == RESULT_OK) {
            // 권한 획득 성공, 필요한 추가 초기화 작업 수행
        }
    }

    override fun onResume() {
        super.onResume()
        Log.d("MainActivity", "onResume - 서비스 상태 확인")

        // 서비스 시작 상태 로그
        val isServiceRunning = isServiceRunning(CallDetectionService::class.java)
        Log.d("MainActivity", "서비스 실행 중: $isServiceRunning")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(RoleManager::class.java)
            val isRoleHeld = roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)
            Log.e("MainActivity", "!!!!! 통화 스크리닝 역할 보유 여부: $isRoleHeld !!!!!")

            val telecomManager = getSystemService(Context.TELECOM_SERVICE) as TelecomManager
            val defaultDialerPackage = telecomManager.defaultDialerPackage
            Log.e("MainActivity", "!!!!! 기본 전화 앱: $defaultDialerPackage !!!!!")
        }
    }

    private fun isServiceRunning(serviceClass: Class<*>): Boolean {
        val manager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        return manager.getRunningServices(Integer.MAX_VALUE)
            .any { it.service.className == serviceClass.name }
    }

    private fun checkAllPermissions() {
        Log.d("MainActivity", "권한 상태 확인:")
        Log.d("MainActivity", "READ_PHONE_STATE: ${checkPermission(Manifest.permission.READ_PHONE_STATE)}")
        Log.d("MainActivity", "READ_CALL_LOG: ${checkPermission(Manifest.permission.READ_CALL_LOG)}")
        Log.d("MainActivity", "ANSWER_PHONE_CALLS: ${checkPermission(Manifest.permission.ANSWER_PHONE_CALLS)}")
        Log.d("MainActivity", "CALL_PHONE: ${checkPermission(Manifest.permission.CALL_PHONE)}")
    }

    private fun checkPermission(permission: String): String {
        return if (ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED) {
            "허용됨"
        } else {
            "거부됨"
        }
    }

    private fun checkCallScreeningService() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(RoleManager::class.java)
            val isRoleHeld = roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)
            Log.d("MainActivity", "통화 스크리닝 역할 보유 여부: $isRoleHeld")
        }
    }

    private fun requestRuntimePermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val requiredPermissions = arrayOf(
                Manifest.permission.READ_PHONE_STATE,
                Manifest.permission.READ_CALL_LOG,
                Manifest.permission.ANSWER_PHONE_CALLS
            )

            val permissionsToRequest = requiredPermissions.filter {
                ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
            }.toTypedArray()

            if (permissionsToRequest.isNotEmpty()) {
                Log.e("MainActivity", "!!!!! 권한 요청 중 !!!!!")
                requestPermissions(permissionsToRequest, 1003)
            } else {
                Log.e("MainActivity", "!!!!! 모든 필요 권한 이미 승인됨 !!!!!")
            }

            // 오버레이 권한 추가 체크
            if (!Settings.canDrawOverlays(this)) {
                Log.e("MainActivity", "!!!!! 오버레이 권한 없음 → 설정화면 이동 !!!!!")
                val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
                startActivityForResult(intent, 1004)
            } else {
                Log.e("MainActivity", "!!!!! 오버레이 권한 이미 있음 !!!!!")
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == 1003) {
            // 권한 요청 결과 확인
            val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }

            if (allGranted) {
                Log.e("MainActivity", "!!!!! 모든 권한 승인됨 !!!!!")
            } else {
                Log.e("MainActivity", "!!!!! 일부 권한 거부됨 !!!!!")
                // 필수 권한이 거부된 경우 사용자에게 알림
                showPermissionSettingsDialog()
            }

            if (Settings.canDrawOverlays(this)) {
                Log.e("MainActivity", "!!!!! 오버레이 권한 허용됨 !!!!!")
            } else {
                Log.e("MainActivity", "!!!!! 오버레이 권한 거부됨 !!!!!")
            }
        }
    }

    private fun showPermissionSettingsDialog() {
        // Flutter로 권한 설정 다이얼로그 표시 요청
        MethodChannelHandler.methodChannel?.invokeMethod("showPermissionDialog", null)
    }
}