## 2.1.2

- Update documentation for `AutoFormFieldWrapper` with new `didChange` callback API
- Improve README examples to reflect simplified API usage

## 2.1.1

- Add `autovalidateMode` support to `AutoFormFieldWrapper<T>`
- Simplify `AutoFormFieldWrapper` builder API: now receives `didChange` callback that automatically calls `field.didChange()`
- Improved developer experience: no need to manually call `field.didChange()` - just use the provided `didChange` callback

## 2.1.0

- Add `CustomFormController<T>` for generic validation of any type (dropdowns, checkboxes, etc.)
- Add `AutoFormFieldWrapper<T>` to wrap any widget and add validation with Material Design error styling
- Error messages now use Material Design theme styling consistent with TextFormField
- Support for validating non-text form fields (checkboxes, dropdowns, date pickers, etc.)

## 2.0.4

- Fix FormController required when passing a controller, now it can be null

## 2.0.3

- Fix regex filter

## 2.0.2

- Fix auto dispose focusNode

## 2.0.1

- Implement dynamic mask switching based on alphanumeric characters and hashtags
- Add `_Mask` class to handle immutable and mutable mask versions
- Improve mask comparison logic using `_cleanValue()` and `_cleanMask()` methods

## 1.0.5

- Fix onChange AutoTextFormField

## 1.0.4

- Add extension formatValue

## 1.0.3

- Add support for external packages ui

## 0.0.1

- TODO: Describe initial release.
