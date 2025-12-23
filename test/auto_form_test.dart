// ignore_for_file: deprecated_member_use

import 'package:auto_form_validate/form_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// FormController de teste sem formatters, apenas com regexFilter
class OnlyNumbersController extends FormController {
  @override
  String? Function(String? value)? get validator => (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      };

  @override
  TextInputType? get textInputType => TextInputType.number;

  @override
  RegExp get regexFilter => RegExp(r'[0-9]');

  // Não define formatters - isso é o que causa o bug
}

// FormController de teste com formatters
class PhoneController extends FormController {
  @override
  String? Function(String? value)? get validator => (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      };

  @override
  List<String> get formaters => [
        "(##) ####-####",
      ];

  @override
  TextInputType? get textInputType => TextInputType.number;

  @override
  RegExp get regexFilter => RegExp(r'[0-9]');
}

void main() {
  group('FormController - regexFilter sem formatters', () {
    test('Deve aplicar regexFilter quando não há formatters', () {
      final controller = OnlyNumbersController();
      final formatters = controller.helper.buildFormatters();

      // Deve retornar uma lista com FilteringTextInputFormatter
      expect(formatters, isNotEmpty);
      expect(formatters.length, 1);
      expect(formatters.first, isA<FilteringTextInputFormatter>());
    });

    test('Deve filtrar apenas números quando não há formatters', () {
      final controller = OnlyNumbersController();
      final formatters = controller.helper.buildFormatters();

      // Simula input com letras e números
      final textController = TextEditingController(text: '');
      final oldValue = textController.value;
      const newValue = TextEditingValue(text: 'abc123def456');

      // Aplica o formatter
      final result = formatters.first.formatEditUpdate(oldValue, newValue);

      // Deve filtrar apenas números
      expect(result.text, '123456');
    });

    test('Deve aceitar apenas números válidos', () {
      final controller = OnlyNumbersController();
      final formatters = controller.helper.buildFormatters();

      final testCases = [
        {'input': 'abc', 'expected': ''},
        {'input': '123', 'expected': '123'},
        {'input': '12a34b56', 'expected': '123456'},
        {'input': '!@#\$%123', 'expected': '123'},
        {'input': '   123   ', 'expected': '123'},
      ];

      for (var testCase in testCases) {
        const oldValue = TextEditingValue(text: '');
        final newValue = TextEditingValue(text: testCase['input'] as String);
        final result = formatters.first.formatEditUpdate(oldValue, newValue);
        expect(result.text, testCase['expected'], reason: 'Input: ${testCase['input']} deveria resultar em ${testCase['expected']}');
      }
    });

    test('Deve cachear formatters para reutilização', () {
      final controller = OnlyNumbersController();

      // Primeira chamada
      final formatters1 = controller.helper.buildFormatters();

      // Segunda chamada - deve retornar o mesmo objeto cacheado
      final formatters2 = controller.helper.buildFormatters();

      // Verifica se é a mesma instância (cacheado)
      expect(identical(formatters1, formatters2), true);
    });
  });

  group('FormController - regexFilter com formatters', () {
    test('Deve aplicar formatters quando definidos', () {
      final controller = PhoneController();
      final formatters = controller.helper.buildFormatters();

      expect(formatters, isNotEmpty);
      expect(formatters.length, 1);
    });

    test('Deve formatar telefone corretamente', () {
      final controller = PhoneController();
      final formatted = controller.formatValue(value: '1122334455');

      expect(formatted, '(11) 2233-4455');
    });
  });

  group('FormController - validação', () {
    test('Deve validar campo vazio como inválido', () {
      final controller = OnlyNumbersController();
      final error = controller.validator?.call('');

      expect(error, 'This field is required');
    });

    test('Deve validar campo com valor como válido', () {
      final controller = OnlyNumbersController();
      final error = controller.validator?.call('123');

      expect(error, null);
    });
  });
}
