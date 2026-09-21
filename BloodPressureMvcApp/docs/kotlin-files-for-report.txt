# Листинг основных Kotlin-файлов

## MainActivity.kt

```kotlin
package com.example.bloodpressuremvc

import android.content.Context
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import com.example.bloodpressuremvc.controller.PressureController
import com.example.bloodpressuremvc.model.PressureInput
import com.example.bloodpressuremvc.model.PressureModel
import com.example.bloodpressuremvc.model.PressureState
import com.example.bloodpressuremvc.view.InputDialogFragment
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale

class MainActivity : AppCompatActivity(), InputDialogFragment.Listener {
    private val model = PressureModel()
    private val controller = PressureController(model)
    private val dateFormatter = DateTimeFormatter.ofPattern("dd.MM.yyyy", Locale("ru"))

    private lateinit var lastDataTextView: TextView
    private lateinit var idealPressureTextView: TextView
    private lateinit var currentPressureTextView: TextView
    private lateinit var assessmentTextView: TextView

    private val stateListener: (PressureState) -> Unit = ::render

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        lastDataTextView = findViewById(R.id.lastDataTextView)
        idealPressureTextView = findViewById(R.id.idealPressureTextView)
        currentPressureTextView = findViewById(R.id.currentPressureTextView)
        assessmentTextView = findViewById(R.id.assessmentTextView)

        findViewById<Button>(R.id.inputButton).setOnClickListener {
            InputDialogFragment
                .newInstance(lastInput())
                .show(supportFragmentManager, "InputDialog")
        }

        model.addListener(stateListener)
        loadSavedInput()?.let(controller::onInputConfirmed)
    }

    override fun onDestroy() {
        model.removeListener(stateListener)
        super.onDestroy()
    }

    override fun onPressureInput(input: PressureInput) {
        controller.onInputConfirmed(input)
    }

    private fun render(state: PressureState) {
        when (state) {
            PressureState.Empty -> {
                lastDataTextView.text = "Данные еще не введены"
                idealPressureTextView.text = "Идеальное давление: -"
                currentPressureTextView.text = "Текущее давление: -"
                assessmentTextView.text = "Оценка: -"
            }

            is PressureState.Ready -> {
                val input = state.input
                val result = state.result
                saveInput(input)
                lastDataTextView.text = "Последний ввод: ${input.birthDate.format(dateFormatter)}, ${formatWeight(input.weightKg)} кг, ${input.systolic}/${input.diastolic}"
                idealPressureTextView.text = "Идеальное давление: ${result.idealSystolic}/${result.idealDiastolic} мм рт. ст. для ${result.age} лет"
                currentPressureTextView.text = "Текущее давление: ${input.systolic}/${input.diastolic} мм рт. ст."
                assessmentTextView.text = "Оценка: ${result.assessment.title}"
            }

            is PressureState.Error -> {
                showError(state.message)
            }
        }
    }

    private fun lastInput(): PressureInput? {
        return when (val state = model.state) {
            is PressureState.Ready -> state.input
            is PressureState.Error -> state.lastInput
            PressureState.Empty -> null
        }
    }

    private fun showError(message: String) {
        AlertDialog.Builder(this)
            .setTitle("Ошибка")
            .setMessage(message)
            .setPositiveButton("ОК", null)
            .show()
    }

    private fun saveInput(input: PressureInput) {
        getPreferences(Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_BIRTH_DATE, input.birthDate.toString())
            .putFloat(KEY_WEIGHT, input.weightKg.toFloat())
            .putInt(KEY_SYSTOLIC, input.systolic)
            .putInt(KEY_DIASTOLIC, input.diastolic)
            .apply()
    }

    private fun loadSavedInput(): PressureInput? {
        val preferences = getPreferences(Context.MODE_PRIVATE)
        val birthDate = preferences.getString(KEY_BIRTH_DATE, null)?.let(LocalDate::parse) ?: return null
        val weight = preferences.getFloat(KEY_WEIGHT, -1f).toDouble()
        val systolic = preferences.getInt(KEY_SYSTOLIC, -1)
        val diastolic = preferences.getInt(KEY_DIASTOLIC, -1)

        return PressureInput(birthDate, weight, systolic, diastolic)
    }

    private fun formatWeight(weight: Double): String {
        return if (weight % 1.0 == 0.0) {
            weight.toInt().toString()
        } else {
            String.format(Locale.US, "%.1f", weight)
        }
    }

    companion object {
        private const val KEY_BIRTH_DATE = "birthDate"
        private const val KEY_WEIGHT = "weight"
        private const val KEY_SYSTOLIC = "systolic"
        private const val KEY_DIASTOLIC = "diastolic"
    }
}
```

## PressureController.kt

```kotlin
package com.example.bloodpressuremvc.controller

import com.example.bloodpressuremvc.model.PressureInput
import com.example.bloodpressuremvc.model.PressureModel

class PressureController(private val model: PressureModel) {
    fun onInputConfirmed(input: PressureInput) {
        model.submit(input)
    }
}
```

## PressureModel.kt

```kotlin
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
```

## InputDialogFragment.kt

```kotlin
package com.example.bloodpressuremvc.view

import android.app.Dialog
import android.os.Bundle
import android.view.LayoutInflater
import android.widget.EditText
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.DialogFragment
import com.example.bloodpressuremvc.R
import com.example.bloodpressuremvc.model.PressureInput
import java.time.DateTimeException
import java.time.LocalDate

class InputDialogFragment : DialogFragment() {
    interface Listener {
        fun onPressureInput(input: PressureInput)
    }

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val view = LayoutInflater.from(requireContext()).inflate(R.layout.dialog_input, null)
        val dayEditText = view.findViewById<EditText>(R.id.dayEditText)
        val monthEditText = view.findViewById<EditText>(R.id.monthEditText)
        val yearEditText = view.findViewById<EditText>(R.id.yearEditText)
        val weightEditText = view.findViewById<EditText>(R.id.weightEditText)
        val systolicEditText = view.findViewById<EditText>(R.id.systolicEditText)
        val diastolicEditText = view.findViewById<EditText>(R.id.diastolicEditText)

        restoreLastInput(dayEditText, monthEditText, yearEditText, weightEditText, systolicEditText, diastolicEditText)

        val dialog = AlertDialog.Builder(requireContext())
            .setTitle("Ввод данных")
            .setView(view)
            .setNegativeButton("Отмена", null)
            .setPositiveButton("Сохранить", null)
            .create()

        dialog.setOnShowListener {
            dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener {
                val input = parseInput(dayEditText, monthEditText, yearEditText, weightEditText, systolicEditText, diastolicEditText)
                if (input == null) {
                    Toast.makeText(requireContext(), "Заполните все поля корректными числами", Toast.LENGTH_SHORT).show()
                } else {
                    (activity as? Listener)?.onPressureInput(input)
                    dismiss()
                }
            }
        }

        return dialog
    }

    private fun parseInput(
        dayEditText: EditText,
        monthEditText: EditText,
        yearEditText: EditText,
        weightEditText: EditText,
        systolicEditText: EditText,
        diastolicEditText: EditText
    ): PressureInput? {
        val day = dayEditText.text.toString().toIntOrNull() ?: return null
        val month = monthEditText.text.toString().toIntOrNull() ?: return null
        val year = yearEditText.text.toString().toIntOrNull() ?: return null
        val weight = weightEditText.text.toString().replace(',', '.').toDoubleOrNull() ?: return null
        val systolic = systolicEditText.text.toString().toIntOrNull() ?: return null
        val diastolic = diastolicEditText.text.toString().toIntOrNull() ?: return null

        return try {
            PressureInput(LocalDate.of(year, month, day), weight, systolic, diastolic)
        } catch (_: DateTimeException) {
            null
        }
    }
}
```

## Вспомогательные классы модели

```kotlin
data class PressureInput(
    val birthDate: LocalDate,
    val weightKg: Double,
    val systolic: Int,
    val diastolic: Int
)

data class PressureResult(
    val age: Int,
    val idealSystolic: Int,
    val idealDiastolic: Int,
    val assessment: PressureAssessment
)

enum class PressureAssessment(val title: String) {
    LOW("пониженное"),
    NORMAL("норма"),
    HIGH("повышенное")
}

sealed class PressureState {
    data object Empty : PressureState()
    data class Ready(val input: PressureInput, val result: PressureResult) : PressureState()
    data class Error(val message: String, val lastInput: PressureInput?) : PressureState()
}
```
