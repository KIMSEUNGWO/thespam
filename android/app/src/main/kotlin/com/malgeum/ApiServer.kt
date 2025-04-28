package com.malgeum

import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL

class ApiServer {

    companion object {

        const val BASE_URL = "http://3.38.190.123/health"

        fun spamCheck(phoneNumber: String): SpamCheckResult {
//            val apiUrl = "$BASE_URL/spam";
            val apiUrl = "$BASE_URL/health";
            val url = URL(apiUrl)
            val connection = url.openConnection() as HttpURLConnection

            try {
                // HTTP 요청 설정
                connection.requestMethod = "GET"
                connection.setRequestProperty("Content-Type", "application/json")
                connection.doOutput = true

                // 요청 본문 작성
                val jsonInput = JSONObject()
                jsonInput.put("phoneNumber", phoneNumber)

                val outputStream = connection.outputStream
                outputStream.write(jsonInput.toString().toByteArray())
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
                    val type = jsonResponse.getString("type")

                    // Flutter에 전달할 맵 생성
                    return SpamCheckResult(phoneNumber, type)
                } else {
                    // 에러 응답
                    return SpamCheckResult(phoneNumber, "NONE")
                }
            } catch (e: Exception) {
                return SpamCheckResult(phoneNumber, "NONE")
            } finally {
                connection.disconnect()
            }
        }
    }
}