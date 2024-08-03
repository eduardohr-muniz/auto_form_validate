import 'dart:async';
import 'dart:ui';
import 'package:auto_form_validate/auto_form_validate.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

bool _alreadyFocus = false;
Timer? _timer;

/// Manages form validation and input formatting for a specific form.
///
/// - **[validator]**: A function that validates input values. Returns a string error message or null for valid input.
/// - **[regexFilter]**: A regular expression that defines allowed characters for input validation.
/// - **[formatters]**: A list of string masks used to format input strings, such as phone numbers or dates.
/// - **[textInputType]**: Specifies the type of keyboard input for text fields, such as email address, phone number, or regular text.
/// Example usage:
/// ```dart
/// class MyFormController extends FormController {
///   // Example: Define a validator function
///   @override
///   String? Function(String? value)? get validator => (value) {
///     if (value == null || value.isEmpty) {
///       return 'This field cannot be empty';
///     }
///     return null; // Valid input
///   };
///
///   // Example: Define a regular expression filter
///   @override
///   RegExp get regexFilter => RegExp(r'[a-zA-Z0-9]');
///
///   // Example: Define a list of formatters for input masking
///   @override
///   List<String> get formatters => [
///     "(##) ####-####", // Example phone number mask
///   ];
///
///   // Example: Define the type of keyboard input for text fields
///   @override
///   TextInputType? get textInputType => TextInputType.number;
/// }
/// ```
///
abstract class FormController {
  BuildContext context;
  FormController(this.context);

  FocusNode? _focusNode;

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
  RegExp get regexFilter => RegExp(r'[a-zA-Z0-9]');

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
  ///
  List<String> get formaters => [];

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

  List<TextInputFormatter>? _buildTextInputFormatters() {
    List<String> formaters = this.formaters;
    formaters.sort((a, b) => a.length.compareTo(b.length));
    if (formaters.isEmpty) return null;
    return [
      MaskTextInputFormatter(
        mask: formaters.first,
        filter: {"#": textInputType != null && textInputType == TextInputType.number ? RegExp(r'[0-9]') : regexFilter},
      )
    ];
  }

  static String _maskUltisToString(String? value, TextInputFormatter? mask) {
    if (mask == null) return value ?? "";
    TextInputFormatter? textInputFormatter;
    // final lenght = value.length;
    textInputFormatter = mask;
    // try {
    //   if (mask.onlenghtMaskChange != null && lenght >= mask.onlenghtMaskChange!) textInputFormatter = mask.inpuFormatters![1];
    // } catch (_) {
    //   textInputFormatter = mask.inpuFormatters![0];
    // }
    final ec = TextEditingController(text: value);
    ec.value = textInputFormatter.formatEditUpdate(ec.value, ec.value);
    final result = ec.text;
    ec.dispose();
    return result;
  }

  String? _validate(String? value) {
    String? error;
    error = validator?.call(value);
    _requestFocusOnError(isError: error, focusNode: _focusNode);
    return error;
  }

  FocusNode? _getFocusNode(FocusNode? focusNode) {
    if (_focusNode != null) return _focusNode;
    _focusNode = focusNode ?? FocusNode();
    return _focusNode;
  }

  static void _requestFocusOnError({required String? isError, required FocusNode? focusNode}) {
    if (_alreadyFocus == false && isError != null) {
      _alreadyFocus = true;
      focusNode?.requestFocus();
    }
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 100), () {
      _alreadyFocus = false;
    });
  }
}

class AutoTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool autofocus;
  final bool readOnly;
  final bool? showCursor;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool onTapAlwaysCalled;
  final void Function(PointerDownEvent)? onTapOutside;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final bool? ignorePointers;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final Color? cursorErrorColor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool? enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final Widget? Function(BuildContext, {required int currentLength, required bool isFocused, required int? maxLength})? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final AutovalidateMode? autovalidateMode;
  final ScrollController? scrollController;
  final String? restorationId;
  final bool enableIMEPersonalizedLearning;
  final MouseCursor? mouseCursor;
  final Widget Function(BuildContext, EditableTextState)? contextMenuBuilder;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final TextMagnifierConfiguration? magnifierConfiguration;
  final UndoHistoryController? undoController;
  final void Function(String, Map<String, dynamic>)? onAppPrivateCommand;
  final bool? cursorOpacityAnimates;
  final BoxHeightStyle selectionHeightStyle;
  final BoxWidthStyle selectionWidthStyle;
  final DragStartBehavior dragStartBehavior;
  final ContentInsertionConfiguration? contentInsertionConfiguration;
  final WidgetStatesController? statesController;
  final Clip clipBehavior;
  final bool scribbleEnabled;
  final bool canRequestFocus;
  final FormController? formController;

  const AutoTextFormField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.decoration,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.style,
    this.strutStyle,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.autofocus = false,
    this.readOnly = false,
    this.showCursor,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLengthEnforcement,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onTapAlwaysCalled = false,
    this.onTapOutside,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.enabled,
    this.ignorePointers,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.cursorErrorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection,
    this.selectionControls,
    this.buildCounter,
    this.scrollPhysics,
    this.autofillHints,
    this.autovalidateMode,
    this.scrollController,
    this.restorationId,
    this.mouseCursor,
    this.contextMenuBuilder,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
    this.undoController,
    this.onAppPrivateCommand,
    this.cursorOpacityAnimates,
    this.selectionHeightStyle = BoxHeightStyle.tight,
    this.selectionWidthStyle = BoxWidthStyle.tight,
    this.dragStartBehavior = DragStartBehavior.start,
    this.contentInsertionConfiguration,
    this.statesController,
    this.clipBehavior = Clip.hardEdge,
    this.scribbleEnabled = true,
    this.canRequestFocus = true,
    this.enableIMEPersonalizedLearning = true,
    this.formController,
  });

  @override
  State<AutoTextFormField> createState() => _AutoTextFormFieldState();
}

class _AutoTextFormFieldState extends State<AutoTextFormField> {
  late final FocusNode? _focusNode;

  @override
  void initState() {
    _focusNode = widget.formController?._getFocusNode(widget.focusNode) ?? widget.focusNode;
    super.initState();
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      initialValue: () {
        if (widget.formController != null && widget.formController!.formaters.isNotEmpty) {
          return FormController._maskUltisToString(widget.initialValue, widget.formController!._buildTextInputFormatters()![0]);
        }
        return widget.initialValue;
      }(),
      focusNode: _focusNode,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType ?? widget.formController?.textInputType,
      textCapitalization: widget.textCapitalization,
      textInputAction: widget.textInputAction,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textDirection: widget.textDirection,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      showCursor: widget.showCursor,
      obscuringCharacter: widget.obscuringCharacter,
      obscureText: widget.obscureText,
      autocorrect: widget.autocorrect,
      smartDashesType: widget.smartDashesType,
      smartQuotesType: widget.smartQuotesType,
      enableSuggestions: widget.enableSuggestions,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      onTapOutside: widget.onTapOutside,
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onFieldSubmitted,
      onSaved: widget.onSaved,
      validator: widget.validator ?? widget.formController?._validate,
      inputFormatters: widget.inputFormatters ?? widget.formController?._buildTextInputFormatters(),
      enabled: widget.enabled,
      ignorePointers: widget.ignorePointers,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorColor: widget.cursorColor,
      cursorOpacityAnimates: widget.cursorOpacityAnimates,
      cursorErrorColor: widget.cursorErrorColor,
      keyboardAppearance: widget.keyboardAppearance,
      scrollPadding: widget.scrollPadding,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      selectionControls: widget.selectionControls,
      buildCounter: widget.buildCounter,
      scrollPhysics: widget.scrollPhysics,
      autofillHints: widget.autofillHints,
      autovalidateMode: widget.autovalidateMode,
      scrollController: widget.scrollController,
      restorationId: widget.restorationId,
      mouseCursor: widget.mouseCursor,
      contextMenuBuilder: widget.contextMenuBuilder,
      spellCheckConfiguration: widget.spellCheckConfiguration,
      magnifierConfiguration: widget.magnifierConfiguration,
      undoController: widget.undoController,
      onAppPrivateCommand: widget.onAppPrivateCommand,
      selectionHeightStyle: widget.selectionHeightStyle,
      selectionWidthStyle: widget.selectionWidthStyle,
      dragStartBehavior: widget.dragStartBehavior,
      contentInsertionConfiguration: widget.contentInsertionConfiguration,
      statesController: widget.statesController,
      clipBehavior: widget.clipBehavior,
      scribbleEnabled: widget.scribbleEnabled,
      canRequestFocus: widget.canRequestFocus,
      enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
    );
  }
}
