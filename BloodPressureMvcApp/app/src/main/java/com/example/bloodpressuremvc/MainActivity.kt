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
