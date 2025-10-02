import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

List<FocusNode> _errorFocusNodes = [];

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

class _Mask {
  final String maskImmutable;
  final String mask;

  _Mask({
    required this.maskImmutable,
    required this.mask,
  });

  _Mask copyWith({
    String? mask,
  }) {
    return _Mask(
      maskImmutable: maskImmutable,
      mask: mask ?? this.mask,
    );
  }

  @override
  String toString() {
    return 'maskImmutable: $maskImmutable, mask: $mask';
  }
}

class FormControllerHelper {
  FormControllerHelper(this.formController);
  final FormController formController;

  FocusNode? _focusNode;

  List<TextInputFormatter>? _masks;
  MaskTextInputFormatter? get mask => _masks?.first as MaskTextInputFormatter;
  List<_Mask> _formaters = [];
  _Mask _currentMask = _Mask(maskImmutable: '', mask: '');

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

    _formaters = formController.formaters.map((e) => _Mask(maskImmutable: e, mask: e)).toList();

    _formaters.sort((a, b) {
      final initialLength = (initialValue ?? '').replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').length;
      final aClean = a.maskImmutable.replaceAll(RegExp(r'[^#]'), '');
      final bClean = b.maskImmutable.replaceAll(RegExp(r'[^#]'), '');

      if (aClean.length < initialLength && bClean.length >= initialLength) return 1;
      if (aClean.length >= initialLength && bClean.length < initialLength) return -1;
      return aClean.length.compareTo(bClean.length);
    });

    if (_formaters.length > 1) {
      for (var i = _formaters.length - 2; i >= 0; i--) {
        // _formaters[i] = '${_formaters[i]}#';
        _formaters[i] = _formaters[i].copyWith(mask: '${_formaters[i].mask}#');
      }
    }

    if (_formaters.isEmpty) {
      _masks = [
        FilteringTextInputFormatter.allow(formController.regexFilter),
      ];
      return _masks!;
    }

    _currentMask = _formaters.first;
    _masks = [
      MaskTextInputFormatter(
        mask: _formaters.first.mask,
        filter: {
          '#': formController.textInputType == TextInputType.number ? RegExp('[0-9]') : formController.regexFilter,
        },
      )
    ];

    return _masks;
  }

  String formatValue({required String value}) {
    final formatters = buildFormatters(initialValue: value);
    if (formatters.isEmpty) return value;
    return maskUltisToString(value, formatters.first);
  }

  String maskUltisToString(String? value, TextInputFormatter? mask) {
    if (mask == null) return value ?? '';
    final controller = TextEditingController(text: value);
    controller.value = mask.formatEditUpdate(controller.value, controller.value);
    final result = controller.text;
    controller.dispose();
    return result;
  }

  String? validate({String? value, required FocusNode focusNode}) {
    final error = formController.validator?.call(value);
    // Usa o focusNode passado ou o padrão
    final targetFocusNode = focusNode;
    _requestFocusOnError(isError: error, focusNode: targetFocusNode);
    return error;
  }

  String _cleanMask(String mask) {
    return mask.replaceAll(RegExp(r'[^#]'), '');
  }

  String _cleanValue(String value) {
    return value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }

  String? updateMask({required String value, required TextEditingController controller, required RegExp regexFilter, TextInputType? textInputType}) {
    // Extrair apenas números e letras do value
    final valueClean = _cleanValue(value);

    final nextMask = _formaters.firstWhereOrNull((mask) {
      final maskHashtags = _cleanMask(mask.maskImmutable);
      return maskHashtags.length > _cleanMask(_currentMask.maskImmutable).length;
    });

    final previousMask = _formaters.firstWhereOrNull((mask) {
      final maskHashtags = _cleanMask(mask.maskImmutable);
      return _cleanMask(_currentMask.maskImmutable).length > maskHashtags.length;
    });

    if (nextMask != null) {
      if (valueClean.length > _cleanMask(_currentMask.maskImmutable).length) {
        _currentMask = nextMask;
        final newValue = mask!.updateMask(
          mask: nextMask.mask,
          filter: {"#": textInputType != null && textInputType == TextInputType.number ? RegExp(r'[0-9]') : regexFilter},
        );
        Future.microtask(() => controller.value = newValue);
        return newValue.text;
      }
    }

    if (previousMask != null) {
      final previousMaskHashtags = _cleanMask(previousMask.maskImmutable);
      if (valueClean.length == previousMaskHashtags.length) {
        _currentMask = previousMask;
        final newValue = mask!.updateMask(
          mask: previousMask.mask,
          filter: {"#": textInputType != null && textInputType == TextInputType.number ? RegExp(r'[0-9]') : regexFilter},
        );
        Future.microtask(() => controller.value = newValue);
        return newValue.text;
      }
    }
    return null;
  }

  FocusNode prepareFocusNode(FocusNode? focusNode) {
    _focusNode ??= focusNode ?? FocusNode();
    return _focusNode!;
  }

  void resetErrorTracking() {
    _errorFocusNodes.clear();
  }

  void _requestFocusOnError({required String? isError, required FocusNode? focusNode}) {
    if (focusNode == null) return;

    if (isError != null) {
      if (!_errorFocusNodes.contains(focusNode)) {
        _errorFocusNodes.add(focusNode);
      }
    } else {
      _errorFocusNodes.remove(focusNode);
    }

    if (_errorFocusNodes.isNotEmpty) {
      final firstErrorNode = _errorFocusNodes.first;

      Future.microtask(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (firstErrorNode.canRequestFocus) {
            if (firstErrorNode.context != null) {
              FocusScope.of(firstErrorNode.context!).unfocus();
            }
            firstErrorNode.requestFocus();
            _errorFocusNodes.clear();
          }
        });
      });
    }
  }
}

extension FormControllerExtension on FormController {
  String formatValue({required String value}) {
    return helper.maskUltisToString(value, helper.buildFormatters(initialValue: value).first);
  }

  void resetErrorTracking() {
    helper.resetErrorTracking();
  }
}
