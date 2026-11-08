package com.example.bloodpressuremvc.model

import java.time.LocalDate

data class PressureInput(
    val birthDate: LocalDate,
    val weightKg: Double,
    val systolic: Int,
    val diastolic: Int
)
