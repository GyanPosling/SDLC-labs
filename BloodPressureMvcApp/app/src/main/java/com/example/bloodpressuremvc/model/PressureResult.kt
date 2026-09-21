package com.example.bloodpressuremvc.model

data class PressureResult(
    val age: Int,
    val idealSystolic: Int,
    val idealDiastolic: Int,
    val assessment: PressureAssessment
)
