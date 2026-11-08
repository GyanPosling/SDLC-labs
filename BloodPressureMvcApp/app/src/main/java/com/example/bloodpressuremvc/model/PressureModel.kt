package com.example.bloodpressuremvc.model

import java.time.LocalDate
import java.time.Period
import kotlin.math.roundToInt

class PressureModel {
    private val listeners = mutableSetOf<(PressureState) -> Unit>()

    var state: PressureState = PressureState.Empty
        private set(value) {
            field = value
            listeners.forEach { listener -> listener(value) }
        }

    fun addListener(listener: (PressureState) -> Unit) {
        listeners += listener
        listener(state)
    }

    fun removeListener(listener: (PressureState) -> Unit) {
        listeners -= listener
    }

    fun submit(input: PressureInput, today: LocalDate = LocalDate.now()) {
        val error = validate(input, today)
        state = if (error == null) {
            PressureState.Ready(input, calculate(input, today))
        } else {
            PressureState.Error(error, previousInput())
        }
    }

    private fun previousInput(): PressureInput? {
        return (state as? PressureState.Ready)?.input ?: (state as? PressureState.Error)?.lastInput
    }

    private fun validate(input: PressureInput, today: LocalDate): String? {
        val age = Period.between(input.birthDate, today).years
        return when {
            input.birthDate.isAfter(today) -> "Дата рождения не может быть в будущем"
            age !in 1..120 -> "Возраст должен быть от 1 до 120 лет"
            input.weightKg !in 2.0..300.0 -> "Вес должен быть от 2 до 300 кг"
            input.systolic !in 50..260 -> "Верхнее давление должно быть от 50 до 260"
            input.diastolic !in 30..180 -> "Нижнее давление должно быть от 30 до 180"
            input.diastolic >= input.systolic -> "Нижнее давление должно быть меньше верхнего"
            else -> null
        }
    }

    private fun calculate(input: PressureInput, today: LocalDate): PressureResult {
        val age = Period.between(input.birthDate, today).years
        val idealSystolic = (109 + 0.5 * age + 0.1 * input.weightKg).roundToInt()
        val idealDiastolic = (63 + 0.1 * age + 0.15 * input.weightKg).roundToInt()
        val assessment = when {
            input.systolic > idealSystolic + 10 || input.diastolic > idealDiastolic + 7 -> PressureAssessment.HIGH
            input.systolic < idealSystolic - 10 || input.diastolic < idealDiastolic - 7 -> PressureAssessment.LOW
            else -> PressureAssessment.NORMAL
        }

        return PressureResult(age, idealSystolic, idealDiastolic, assessment)
    }
}
