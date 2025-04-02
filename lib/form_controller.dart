import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

Timer? _timer;
bool _alreadyFocus = false;

/// Manages form validation and input formatting for a specific form.
///
/// - **[validator]**: A function that validates input values. Returns a string error message or null for valid input.
/// - **[regexFilter]**: A regular expression that defines allowed characters for input validation.
/// - **[formatters]**: A list of string masks used to format input strings, such as phone numbers or dates.
/// - **[textInputType]**: Specifies the type of keyboard input for text fields, such as email address, phone number, or regular text.
/// Example usage:
/// ```dart
/// class MyFormController extends FormController {
///    Example: Define a validator function
///   @override
///   String? Function(String? value)? get validator => (value) {
///     if (value == null || value.isEmpty) {
///       return 'This field cannot be empty';
///     }
///     return null; // Valid input
///   };
///
///    //Example: Define a regular expression filter
///   @override
///   RegExp get regexFilter => RegExp(r'[a-zA-Z0-9]');
///
///    //Example: Define a list of formatters for input masking
///   @override
///   List<String> get formatters => [
///     "(##) ####-####", // Example phone number mask
///   ];
///
///   Example: Define the type of keyboard input for text fields
///   @override
///   TextInputType? get textInputType => TextInputType.number;
/// }
/// ```
///
abstract class FormController {
  late final helper = FormControllerHelper(this);

  /// [validator]
  /// A function that validates the input value.
  ///
  /// By default, this returns `null`, indicating that there is no validation.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// String? Function(String? value)? get validator => (value) {
  ///   if (value == null || value.isEmpty) {
  ///     return 'This field cannot be empty';
  ///   }
  ///   if (value.length < 3) {
  ///     return 'Must be at least 3 characters long';
  ///   }
  ///   return null; // Valid input
  /// };
  /// ```
  ///
  /// This validator function can be customized to perform various checks
  /// (e.g., non-empty validation, length checks, pattern matching, etc.).
  ///
  String? Function(String? value)? get validator => null;

  /// [regexFilter]
  /// A regular expression that defines the allowed characters for input.
  ///
  /// By default, this allows any combination of letters and numbers.
  ///
  /// Example:
  /// ```dart
  /// RegExp(r'[a-zA-Z0-9]'); // input: "abc123" | output: "abc123"
  /// ```
  ///
  /// To allow only numbers:
  ///
  /// Example:
  /// ```dart
  /// RegExp(r'[0-9]'); // input: "abc123" | output: "123"
  /// ```
  ///
  /// This regular expression can be adjusted to restrict the input to specific character sets
  /// (e.g., alphanumeric only, letters and numbers with hyphens, etc.).
  ///
  RegExp get regexFilter => RegExp(r'[\s\S]');

  /// [formaters]
  /// A string mask to format input strings.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// List<String> get formaters => ["(##) ####-####"];
  /// //input = "1122334455" | Output: "(11) 2233-4455"
  ///
  /// ```
  /// This example demonstrates how to define and use a string mask for formatting input strings,
  /// such as phone numbers, dates, or other structured data.
  List<String> get formaters => [];

  /// [textInputType]
  /// Specifies the type of keyboard input for text fields.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// TextInputType? get textInputType => TextInputType.number;; // Number example
  /// ```
  ///
  /// This property determines the type of keyboard that will be displayed on the screen
  /// when the user focuses on a text field, such as numeric, email address, phone number,
  /// or regular text input.
  ///
  TextInputType? get textInputType => null;

  /// Custom text input formatters.
  List<TextInputFormatter> get customFormatters => [];

  static bool isEmpty(String? value) => value == null || value.trim().isEmpty;
}

class FormControllerHelper {
  FormControllerHelper(this.formController);
  final FormController formController;

  FocusNode? _focusNode;

  List<TextInputFormatter>? _masks;
  MaskTextInputFormatter? get mask => _masks?.first as MaskTextInputFormatter;
  List<String> _formaters = [];
  String _currentMask = '';

  List<TextInputFormatter> buildFormatters({String? initialValue}) {
    if (_masks != null) return _masks!;
    _buildTextInputFormatters(initialValue: initialValue);
    return _masks ?? [];
  }

  List<TextInputFormatter>? _buildTextInputFormatters({String? initialValue}) {
    if (_masks != null && _masks!.isNotEmpty) return _masks;

    if (formController.customFormatters.isNotEmpty) {
      _masks = formController.customFormatters;
      return formController.customFormatters;
    }

    _formaters = formController.formaters;

    _formaters.sort((a, b) {
      final initialLength = (initialValue ?? '').replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').length;
      final aClean = a.replaceAll(RegExp(r'[^#]'), '');
      final bClean = b.replaceAll(RegExp(r'[^#]'), '');

      if (aClean.length < initialLength && bClean.length >= initialLength) return 1;
      if (aClean.length >= initialLength && bClean.length < initialLength) return -1;
      return aClean.length.compareTo(bClean.length);
    });

    if (_formaters.length > 1) {
      for (var i = _formaters.length - 2; i >= 0; i--) {
        _formaters[i] = '${_formaters[i]}#';
      }
    }

    if (_formaters.isEmpty) {
      return [
        FilteringTextInputFormatter.allow(formController.regexFilter),
      ];
    }

    _currentMask = _formaters.first;
    _masks = [
      MaskTextInputFormatter(
        mask: _formaters.first,
        filter: {
          '#': formController.textInputType == TextInputType.number ? RegExp('[0-9]') : formController.regexFilter,
        },
      )
    ];

    return _masks;
  }

  String formatValue({required String value}) {
    return _maskUltisToString(value, buildFormatters(initialValue: value).first);
  }

  static String _maskUltisToString(String? value, TextInputFormatter? mask) {
    if (mask == null) return value ?? '';
    final controller = TextEditingController(text: value);
    controller.value = mask.formatEditUpdate(controller.value, controller.value);
    final result = controller.text;
    controller.dispose();
    return result;
  }

  String? validate(String? value) {
    final error = formController.validator?.call(value);
    _requestFocusOnError(isError: error, focusNode: _focusNode);
    return error;
  }

  void updateMask({required String value, required TextEditingController controller, required RegExp regexFilter, TextInputType? textInputType}) {
    final List<int> lenghts = _formaters.map((e) => e.length).toList();
    if (lenghts.any((e) => value.length < e) == false) return;

    final updatedMask = _formaters.firstWhere((mask) => mask.length > value.length, orElse: () => '');

    if (value.length - 1 == _formaters.first.length && _currentMask != _formaters.first) {
      _currentMask = _formaters.first;
      controller.value = mask!.updateMask(
        mask: _formaters.first,
        filter: {
          "#": textInputType != null && textInputType == TextInputType.number ? RegExp(r'[0-9]') : regexFilter
        },
      );

      return;
    }

    if (updatedMask.isEmpty || updatedMask == _currentMask) return;

    if (value.length < updatedMask.length) {
      _currentMask = updatedMask;
      controller.value = mask!.updateMask(
        mask: updatedMask,
        filter: {
          "#": textInputType != null && textInputType == TextInputType.number ? RegExp(r'[0-9]') : regexFilter
        },
      );
      return;
    }
  }

  FocusNode? prepareFocusNode(FocusNode? focusNode) {
    _focusNode ??= focusNode ?? FocusNode();
    return _focusNode;
  }

  void _requestFocusOnError({required String? isError, required FocusNode? focusNode}) {
    if (!_alreadyFocus && isError != null) {
      _alreadyFocus = true;
      Future.delayed(const Duration(milliseconds: 100), () {
        focusNode?.requestFocus();
      });
    }
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 100), () {
      _alreadyFocus = false;
    });
  }
}
