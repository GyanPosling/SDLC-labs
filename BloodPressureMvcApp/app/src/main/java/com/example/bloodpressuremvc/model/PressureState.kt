package com.example.bloodpressuremvc.model

sealed class PressureState {
    data object Empty : PressureState()
    data class Ready(val input: PressureInput, val result: PressureResult) : PressureState()
    data class Error(val message: String, val lastInput: PressureInput?) : PressureState()
}
