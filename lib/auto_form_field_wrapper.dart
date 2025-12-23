import 'package:flutter/material.dart';
import 'form_controller.dart';

/// A generic form field wrapper that can wrap any widget and add validation.
///
/// This widget can be used to add validation to any widget (checkbox, dropdown, etc.)
/// and display error messages below the widget when validation fails.
///
/// Example usage with checkbox:
/// ```dart
/// AutoFormFieldWrapper<bool?>(
///   formController: CheckboxController(),
///   builder: (field, didChange) => Checkbox(
///     value: _isChecked,
///     onChanged: (value) {
///       setState(() => _isChecked = value);
///       didChange(value); // Automatically calls field.didChange
///     },
///   ),
/// )
/// ```
///
/// Example usage with dropdown:
/// ```dart
/// AutoFormFieldWrapper<MyEnum?>(
///   formController: DropdownController(),
///   builder: (field, didChange) => DropdownButton<MyEnum>(
///     value: _selectedValue,
///     items: [...],
///     onChanged: (value) {
///       setState(() => _selectedValue = value);
///       didChange(value); // Automatically calls field.didChange
///     },
///   ),
/// )
/// ```
class AutoFormFieldWrapper<T> extends FormField<T> {
  /// The form controller that handles validation
  final CustomFormController<T>? formController;

  /// Custom focus node
  final FocusNode? focusNode;

  final Widget Function(String errorText)? errorWidget;

  AutoFormFieldWrapper({
    super.key,
    this.formController,
    String? Function(T? value)? validator,
    required Widget Function(FormFieldState<T> field, void Function(T? value) didChange) builder,
    this.focusNode,
    super.initialValue,
    this.errorWidget,
    super.autovalidateMode,
  }) : super(
          validator: (value) {
            // Use custom validator if provided, otherwise use formController
            if (validator != null) {
              return validator(value);
            }
            if (formController != null) {
              // Use the helper's validate method if focusNode is provided
              if (focusNode != null) {
                return formController.helper.validate(
                  value: value,
                  focusNode: focusNode,
                );
              }
              // Otherwise just use the validator directly
              return formController.validator?.call(value);
            }
            return null;
          },
          builder: (FormFieldState<T> field) {
            final errorText = field.errorText;

            // Prepare focus node if formController is provided
            FocusNode? preparedFocusNode;
            if (formController != null && focusNode != null) {
              preparedFocusNode = formController.helper.prepareFocusNode(focusNode);
            } else {
              preparedFocusNode = focusNode;
            }

            // Helper function that automatically calls didChange
            void didChange(T? value) {
              field.didChange(value);
            }

            return Focus(
              focusNode: preparedFocusNode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  builder(field, didChange),
                  if (errorText != null) //
                    errorWidget?.call(errorText) ?? _DefaultErrorWidget(errorText: errorText),
                ],
              ),
            );
          },
        );
}

class _DefaultErrorWidget extends StatelessWidget {
  final String errorText;
  const _DefaultErrorWidget({required this.errorText});

  @override
  Widget build(BuildContext context) {
    // Get the error style from InputDecorationTheme, same as TextFormField
    final theme = Theme.of(context);
    final inputDecorationTheme = theme.inputDecorationTheme;
    final errorStyle = inputDecorationTheme.errorStyle;

    // Use the same padding as InputDecoration
    final errorMaxLines = inputDecorationTheme.errorMaxLines;

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Text(
        errorText,
        style: errorStyle ??
            TextStyle(
              color: theme.colorScheme.error,
              fontSize: 12,
            ),
        maxLines: errorMaxLines,
      ),
    );
  }
}
