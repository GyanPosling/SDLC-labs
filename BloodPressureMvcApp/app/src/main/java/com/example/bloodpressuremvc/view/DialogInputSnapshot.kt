package com.example.bloodpressuremvc.view

import java.io.Serializable

data class DialogInputSnapshot(
    val day: Int,
    val month: Int,
    val year: Int,
    val weightKg: Double,
    val systolic: Int,
    val diastolic: Int
) : Serializable
