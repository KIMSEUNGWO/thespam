package com.malgeum

class Phone(
    var phoneId: Long,
    val phoneNumber : String,
    val description : String,
    val type : PhoneType
) {

    fun toJson(): String {
        return """
            { "phoneId" : $phoneId, "phoneNumber" : "$phoneNumber", "description" : "$description" "type" : "${type.name}" }
        """.trimIndent()
    }

}