package com.malgeum.model

import com.malgeum.R

enum class PhoneType(val color: Int, val image: Int) {
    UNKNOWN(R.color.grey, R.drawable.symbol_unknown),
    SAFE(R.color.green, R.drawable.symbol_safe),
    SPAM(R.color.red, R.drawable.symbol_warning),
}