package com.malgeum

import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL

class ApiServer {

    companion object {

        const val BASE_URL = "http://10.0.2.2:8080/api/v1"
//        const val BASE_URL = "http://3.38.190.123/health"

        fun spamCheck(phoneNumber: String): Phone {
//            val apiUrl = "$BASE_URL/spam";
            val apiUrl = "$BASE_URL/phone?phone=$phoneNumber";
            val url = URL(apiUrl)
            val connection = url.openConnection() as HttpURLConnection

            try {
                // HTTP 요청 설정
                connection.requestMethod = "GET"
                connection.setRequestProperty("Content-Type", "application/json")
                connection.doOutput = true

                // 요청 본문 작성
//                val jsonInput = JSONObject()
//                jsonInput.put("phoneNumber", phoneNumber)
//
                val outputStream = connection.outputStream
//                outputStream.write(jsonInput.toString().toByteArray())
                outputStream.close()

                // 응답 읽기
                val responseCode = connection.responseCode

                if (responseCode == HttpURLConnection.HTTP_OK) {
                    val inputStream = connection.inputStream
                    val reader = BufferedReader(InputStreamReader(inputStream))
                    val response = StringBuilder()
                    var line: String?

                    while (reader.readLine().also { line = it } != null) {
                        response.append(line)
                    }
                    reader.close()

                    // JSON 응답 파싱
                    val jsonResponse = JSONObject(response.toString())

                    val phoneId = jsonResponse.getLong("phoneId");
                    val description = jsonResponse.getString("description");
                    val type = PhoneType.valueOf(jsonResponse.getString("type"));

                    // Flutter에 전달할 맵 생성
                    return Phone(phoneId, phoneNumber, description, type)
                } else {
                    // 에러 응답
                    return Phone(0, phoneNumber, "알 수 없는 번호", PhoneType.UNKNOWN);
                }
            } catch (e: Exception) {
                return Phone(0, phoneNumber, "알 수 없는 번호", PhoneType.UNKNOWN);
            } finally {
                connection.disconnect()
            }
        }
    }
}