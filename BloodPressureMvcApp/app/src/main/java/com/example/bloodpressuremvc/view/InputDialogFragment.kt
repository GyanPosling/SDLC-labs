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

    private fun restoreLastInput(
        dayEditText: EditText,
        monthEditText: EditText,
        yearEditText: EditText,
        weightEditText: EditText,
        systolicEditText: EditText,
        diastolicEditText: EditText
    ) {
        val input = arguments?.getSerializable(ARG_INPUT) as? DialogInputSnapshot ?: return
        dayEditText.setText(input.day.toString())
        monthEditText.setText(input.month.toString())
        yearEditText.setText(input.year.toString())
        weightEditText.setText(input.weightKg.toString())
        systolicEditText.setText(input.systolic.toString())
        diastolicEditText.setText(input.diastolic.toString())
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

    companion object {
        private const val ARG_INPUT = "input"

        fun newInstance(lastInput: PressureInput?): InputDialogFragment {
            return InputDialogFragment().apply {
                if (lastInput != null) {
                    arguments = Bundle().apply {
                        putSerializable(
                            ARG_INPUT,
                            DialogInputSnapshot(
                                lastInput.birthDate.dayOfMonth,
                                lastInput.birthDate.monthValue,
                                lastInput.birthDate.year,
                                lastInput.weightKg,
                                lastInput.systolic,
                                lastInput.diastolic
                            )
                        )
                    }
                }
            }
        }
    }
}
