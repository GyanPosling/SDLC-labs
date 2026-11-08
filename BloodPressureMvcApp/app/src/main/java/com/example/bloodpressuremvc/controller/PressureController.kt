package com.example.bloodpressuremvc.controller

import com.example.bloodpressuremvc.model.PressureInput
import com.example.bloodpressuremvc.model.PressureModel

class PressureController(private val model: PressureModel) {
    fun onInputConfirmed(input: PressureInput) {
        model.submit(input)
    }
}
