package com.malgeum.blocked

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import com.malgeum.model.Phone
import com.malgeum.model.PhoneType
import com.malgeum.model.RecordType
import io.flutter.plugin.common.BinaryMessenger

object BlockedRepository {

    private const val CHANNEL_NAME = "com.malgeum/blocked_number"

    var methodChannel: MethodChannel? = null

    // MethodChannel 초기화 함수
    fun setupChannel(binaryMessenger: BinaryMessenger, context: Context) {
        Log.d("BlockedRepository", "BlockedRepository 초기화")
        if (methodChannel == null) {
            methodChannel = MethodChannel(binaryMessenger, CHANNEL_NAME)
            Log.d("BlockedRepository", "Method channel 설정 완료: $CHANNEL_NAME")
        }

        MethodChannel(binaryMessenger, CHANNEL_NAME).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "syncBlockedNumbers" -> {
                        Log.d("BlockedRepository", "syncBlockedNumbers 메소드 호출")
                        BlockedService.getInstance(context).forceReload();
                        result.success(true)
                    }
                }

            }
        }
    }

    fun loadBlockedNumbers(callback: (List<Phone>?) -> Unit) {
        methodChannel?.invokeMethod("loadBlockedNumbers", null, object : MethodChannel.Result {
            override fun success(result: Any?) {
                try {
                    Log.d("BlockedRepository", result.toString())
                    if (result is List<*>) {
                        val phoneList = mutableListOf<Phone>()

                        for (item in result) {
                            if (item is Map<*, *>) {
                                // Map을 Phone 객체로 변환
                                val phoneNumber = item["phoneNumber"] as? String ?: ""
                                val type = item["type"] as? String ?: "UNKNOWN"
                                val description = item["description"] as? String ?: ""
                                val phoneId = (item["phoneId"] as? Number)?.toLong() ?: 0L

                                val phoneType = try {
                                    PhoneType.valueOf(type)
                                } catch (e: Exception) {
                                    PhoneType.UNKNOWN
                                }

                                phoneList.add(Phone(
                                    phoneId = phoneId,
                                    phoneNumber = phoneNumber,
                                    type = phoneType,
                                    description = description
                                ))
                            }
                        }

                        callback(phoneList)
                    } else {
                        Log.e("MethodChannelHandler", "Unexpected result type: ${result?.javaClass}")
                        callback(null)
                    }
                } catch (e: Exception) {
                    Log.e("MethodChannelHandler", "Error parsing result: ${e.message}")
                    callback(null)
                }
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                Log.e("MethodChannelHandler", "Error loading blocked numbers: $errorCode - $errorMessage")
                callback(null)
            }

            override fun notImplemented() {
                Log.e("MethodChannelHandler", "Method not implemented")
                callback(null)
            }
        })
    }

    fun appendBlockedNumber(phone : Phone) {
        methodChannel?.invokeMethod("appendBlockedNumber", phone)
    }

    fun addRecord(phone : Phone, type : RecordType, isBlocked: Boolean, seconds : Int) {
        val data = mapOf(
            "phone" to mapOf(
                "phoneId" to phone.phoneId,
                "phoneNumber" to phone.phoneNumber,
                "description" to phone.description,
                "type" to phone.type.name
            ),
            "recordType" to type.name,
            "isBlocked" to isBlocked,
            "seconds" to seconds
        )
        methodChannel?.invokeMethod("addBlockedRecord", data)
    }


}