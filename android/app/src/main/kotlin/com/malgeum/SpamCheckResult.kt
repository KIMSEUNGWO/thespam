package com.malgeum

class SpamCheckResult(
    val phoneNumber : String,
    val type : String
) {

    fun toJson(): String {
        return """
            { "phoneNumber" : "$phoneNumber", "type" : "$type" }
        """.trimIndent()
    }


}