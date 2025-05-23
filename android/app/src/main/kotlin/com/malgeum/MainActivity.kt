package com.malgeum

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Build
import android.telecom.TelecomManager
import android.provider.Settings
import android.app.role.RoleManager
import android.util.Log
import android.app.ActivityManager
import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import android.net.Uri
import androidx.annotation.RequiresApi
import com.malgeum.blocked.BlockedRepository
import com.malgeum.service.ServiceUtil

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.malgeum/call_detection"

    private var pendingPermissionResult: MethodChannel.Result? = null
    private val REQUEST_PERMISSIONS_CODE = 1003
    private val REQUEST_OVERLAY_PERMISSION = 1004
    private val REQUEST_CALL_SCREENING_ROLE = 1001

    @RequiresApi(Build.VERSION_CODES.N)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        super.configureFlutterEngine(flutterEngine)

        BlockedRepository.setupChannel(flutterEngine.dartExecutor.binaryMessenger, context)


        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "initializeCallScreening" -> {
                        Log.d("MainActivity", "initializeCallScreening 호출됨")
                        requestCallScreeningRole()
                        result.success(true)
                    }
                    "permissionCheck" -> {
                        Log.d("MainActivity", "권한 상태 확인 요청됨")
                        try {
                            val permissionResults = permissionCheck();
                            Log.d("MainActivity", "권한 상태: $permissionResults")
                            result.success(permissionResults)
                        } catch (e: Exception) {
                            Log.e("MainActivity", "권한 확인 오류: ${e.message}")
                            result.error("PERMISSION_CHECK_ERROR", e.message, null)
                        }
                    }
                    "requestPermissions" -> {
                        pendingPermissionResult = result
                        requestRuntimePermissions()
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
                    "stopCallDetectionService" -> {
                        Log.d("MainActivity", "통화 감지 서비스 중지 요청됨")
                        try {
                            val serviceIntent = Intent(this@MainActivity, CallDetectionService::class.java)
                            stopService(serviceIntent)
                            Log.d("MainActivity", "통화 감지 서비스 중지 완료")
                            result.success(true)
                        } catch (e: Exception) {
                            Log.e("MainActivity", "통화 감지 서비스 중지 오류: ${e.message}")
                            result.error("SERVICE_ERROR", e.message, null)
                        }
                    }
                    "isCallDetectionServiceRunning" -> {
                        val isServiceRunning = ServiceUtil.isDetectServiceRunning(context)
                        Log.d("MainActivity", "통화 감지 서비스 실행 상태: $isServiceRunning")
                        result.success(isServiceRunning)
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

    @RequiresApi(Build.VERSION_CODES.O)
    private fun permissionCheck(): HashMap<String, Boolean> {
        val permissionResults = HashMap<String, Boolean>()

        // READ_PHONE_STATE 권한 확인
        permissionResults["READ_PHONE_STATE"] = ContextCompat.checkSelfPermission(
            context, Manifest.permission.READ_PHONE_STATE
        ) == PackageManager.PERMISSION_GRANTED

        // READ_CALL_LOG 권한 확인
        permissionResults["READ_CALL_LOG"] = ContextCompat.checkSelfPermission(
            context, Manifest.permission.READ_CALL_LOG
        ) == PackageManager.PERMISSION_GRANTED

        // ANSWER_PHONE_CALLS 권한 확인
        permissionResults["ANSWER_PHONE_CALLS"] = ContextCompat.checkSelfPermission(
            context, Manifest.permission.ANSWER_PHONE_CALLS
        ) == PackageManager.PERMISSION_GRANTED

        // ANSWER_PHONE_CALLS 권한 확인
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) { // Android 14 이상
            permissionResults["FOREGROUND_SERVICE"] = ContextCompat.checkSelfPermission(
                context, Manifest.permission.FOREGROUND_SERVICE_PHONE_CALL
            ) == PackageManager.PERMISSION_GRANTED
        } else { // Android 14 미만
            permissionResults["FOREGROUND_SERVICE"] = ContextCompat.checkSelfPermission(
                context, Manifest.permission.FOREGROUND_SERVICE
            ) == PackageManager.PERMISSION_GRANTED
        }

        // 통화 스크리닝 권한 여부
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            permissionResults["ROLE_CALL_SCREENING"] = getSystemService(RoleManager::class.java).isRoleHeld(RoleManager.ROLE_CALL_SCREENING)
        }

        // OVERLAY 권한 확인
        permissionResults["ACTION_MANAGE_OVERLAY_PERMISSION"] = Settings.canDrawOverlays(this)

        return permissionResults;
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

        when (requestCode) {
            REQUEST_CALL_SCREENING_ROLE -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    val roleManager = getSystemService(RoleManager::class.java)
                    val hasRole = roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)

                    if (hasRole) {
                        Log.d("MainActivity", "통화 스크리닝 역할 승인됨")
                        // 오버레이 권한 확인으로 진행
                        if (!Settings.canDrawOverlays(this)) {
                            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
                            startActivityForResult(intent, REQUEST_OVERLAY_PERMISSION)
                        } else {
                            // 모든 권한 승인됨
                            pendingPermissionResult?.success(true)
                            pendingPermissionResult = null
                        }
                    } else {
                        Log.d("MainActivity", "통화 스크리닝 역할 거부됨")
                        pendingPermissionResult?.success(false)
                        pendingPermissionResult = null
                    }
                }
            }
            REQUEST_OVERLAY_PERMISSION -> {
                if (Settings.canDrawOverlays(this)) {
                    Log.e("MainActivity", "!!!!! 오버레이 권한 승인됨 !!!!!")
                    pendingPermissionResult?.success(true)
                    pendingPermissionResult = null
                } else {
                    Log.e("MainActivity", "!!!!! 오버레이 권한 거부됨 !!!!!")
                    pendingPermissionResult?.success(false)
                    pendingPermissionResult = null
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        Log.d("MainActivity", "onResume - 서비스 상태 확인")

        // 서비스 시작 상태 로그
        val isServiceRunning = ServiceUtil.isDetectServiceRunning(context)
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


    private fun checkAllPermissions() {
        Log.d("MainActivity", "권한 상태 확인:")
        Log.d("MainActivity", "READ_PHONE_STATE: ${checkPermission(Manifest.permission.READ_PHONE_STATE)}")
        Log.d("MainActivity", "READ_CALL_LOG: ${checkPermission(Manifest.permission.READ_CALL_LOG)}")
        Log.d("MainActivity", "ANSWER_PHONE_CALLS: ${checkPermission(Manifest.permission.ANSWER_PHONE_CALLS)}")
        Log.d("MainActivity", "CALL_PHONE: ${checkPermission(Manifest.permission.CALL_PHONE)}")
        Log.d("MainActivity", "FOREGROUND_SERVICE_PHONE_CALL: ${checkPermission(Manifest.permission.FOREGROUND_SERVICE_PHONE_CALL)}")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(RoleManager::class.java)
            val isRoleHeld = roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)
            Log.d("MainActivity", "ROLE_CALL_SCREENING: $isRoleHeld")
        }
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
        checkAllPermissions()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val requiredPermissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) { // Android 14 이상
                arrayOf(
                    Manifest.permission.READ_PHONE_STATE,
                    Manifest.permission.READ_CALL_LOG,
                    Manifest.permission.CALL_PHONE,
                    Manifest.permission.ANSWER_PHONE_CALLS,
                    Manifest.permission.FOREGROUND_SERVICE_PHONE_CALL
                )
            } else {
                arrayOf(
                    Manifest.permission.READ_PHONE_STATE,
                    Manifest.permission.READ_CALL_LOG,
                    Manifest.permission.CALL_PHONE,
                    Manifest.permission.ANSWER_PHONE_CALLS,
                    Manifest.permission.FOREGROUND_SERVICE
                )
            }

            val permissionsToRequest = requiredPermissions.filter {
                ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
            }.toTypedArray()

            if (permissionsToRequest.isNotEmpty()) {
                Log.e("MainActivity", "!!!!! 권한 요청 중 !!!!!")
                requestPermissions(permissionsToRequest, REQUEST_PERMISSIONS_CODE)
            } else {
                Log.e("MainActivity", "!!!!! 모든 필요 권한 이미 승인됨 !!!!!")
                checkAdditionalPermissions()
            }
        } else {
            // API 23 미만은 권한 체크 필요 없음
            pendingPermissionResult?.success(true)
            pendingPermissionResult = null
        }
    }

    // 추가 권한 (역할, 오버레이) 확인 및 요청
    private fun checkAdditionalPermissions() {
        var needsAdditionalPermissions = false

        // 역할 확인
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(RoleManager::class.java)
            val hasScreeningRole = roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)

            if (!hasScreeningRole) {
                Log.d("MainActivity", "ROLE CALL SCREENING 설정 필요")
                needsAdditionalPermissions = true
                val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
                startActivityForResult(intent, REQUEST_CALL_SCREENING_ROLE)
                return
            }
        }

        // 오버레이 권한 확인
        if (!Settings.canDrawOverlays(this)) {
            Log.e("MainActivity", "!!!!! 오버레이 권한 없음 → 설정화면 이동 !!!!!")
            needsAdditionalPermissions = true
            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
            startActivityForResult(intent, REQUEST_OVERLAY_PERMISSION)
            return
        }

        // 모든 권한이 있으면 성공 반환
        if (!needsAdditionalPermissions) {
            pendingPermissionResult?.success(true)
            pendingPermissionResult = null
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == REQUEST_PERMISSIONS_CODE) {
            // 권한 요청 결과 확인
            val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }

            if (allGranted) {
                Log.e("MainActivity", "!!!!! 모든 권한 승인됨 !!!!!")
                // 추가 권한 확인으로 진행
                checkAdditionalPermissions()
            } else {
                Log.e("MainActivity", "!!!!! 일부 권한 거부됨 !!!!!")
                // 필수 권한이 거부된 경우 사용자에게 알림
                showPermissionSettingsDialog()
                pendingPermissionResult?.success(false)
                pendingPermissionResult = null
            }
        }
    }

    private fun showPermissionSettingsDialog() {
        // Flutter로 권한 설정 다이얼로그 표시 요청
        MethodChannelHandler.methodChannel?.invokeMethod("showPermissionDialog", null)
    }
}