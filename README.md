# Auto Form Validate

A Flutter package that provides automatic form validation with smart focus management and input formatting capabilities.

## Features

- 🎯 **Smart Focus Management**: Automatically focuses on the first field with validation errors
- 📝 **Input Formatting**: Support for custom masks and formatters
- 🔄 **Dynamic Validation**: Real-time validation with automatic error tracking
- 🎨 **Flexible Integration**: Works with both custom widgets and standard TextFormField
- 🛡️ **Null Safety**: Fully null-safe implementation

## Quick Start

### Using AutoTextFormField (Recommended)

```dart
import 'package:auto_form_validate/auto_form_validate.dart';

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AutoTextFormField(
            formController: PhoneFormController(),
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          AutoTextFormField(
            formController: EmailFormController(),
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                print('Form submitted successfully!');
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class PhoneFormController extends FormController {
  @override
  String? Function(String? value)? get validator => (value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    return null;
  };

  @override
  List<String> get formaters => [
    "(##) ####-####",
  ];

  @override
  TextInputType? get textInputType => TextInputType.phone;
}

class EmailFormController extends FormController {
  @override
  String? Function(String? value)? get validator => (value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  };

  @override
  TextInputType? get textInputType => TextInputType.emailAddress;
}
```

### Using Standard TextFormField

```dart
import 'package:auto_form_validate/auto_form_validate.dart';

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _focusNode1 = FocusNode();
  final _focusNode2 = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            focusNode: _focusNode1,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) => NameFormController().helper.validate(
              value: value,
              focusNode: _focusNode1,
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            focusNode: _focusNode2,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            validator: (value) => EmailFormController().helper.validate(
              value: value,
              focusNode: _focusNode2,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                print('Form submitted successfully!');
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    super.dispose();
  }
}

class NameFormController extends FormController {
  @override
  String? Function(String? value)? get validator => (value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  };
}
```

## FormController Configuration

### Basic Validation

```dart
class BasicFormController extends FormController {
  @override
  String? Function(String? value)? get validator => (value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  };
}
```

### Email Validation

```dart
class EmailFormController extends FormController {
  @override
  String? Function(String? value)? get validator => (value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  };

  @override
  TextInputType? get textInputType => TextInputType.emailAddress;
}
```

### Phone Number with Mask

```dart
class PhoneFormController extends FormController {
  @override
  String? Function(String? value)? get validator => (value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  };

  @override
  List<String> get formaters => [
    "(##) ####-####",
    "(##) #####-####",
  ];

  @override
  TextInputType? get textInputType => TextInputType.phone;
}
```

### Custom Regex Filter

```dart
class CustomFormController extends FormController {
  @override
  String? Function(String? value)? get validator => (value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  };

  @override
  RegExp get regexFilter => RegExp(r'[a-zA-Z0-9]'); // Only alphanumeric
}
```

## Advanced Features

### Multiple Masks

```dart
class AdvancedFormController extends FormController {
  @override
  List<String> get formaters => [
    "####-####",      // 8 digits
    "####-#####",     // 9 digits
    "####-######",    // 10 digits
  ];

  @override
  String? Function(String? value)? get validator => (value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  };
}
```

### Custom Formatters

```dart
class CustomFormatterController extends FormController {
  @override
  List<TextInputFormatter> get customFormatters => [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
    LengthLimitingTextInputFormatter(10),
  ];

  @override
  String? Function(String? value)? get validator => (value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  };
}
```

## Creating Custom Components

### Creating Your Own TextFormField Implementation

You can create your own custom text field widget that uses the same focus management logic as `AutoTextFormField`. Here's how to implement a `MyTextFormField`:

```dart
import 'package:flutter/material.dart';
import 'package:auto_form_validate/auto_form_validate.dart';

class MyTextFormField extends StatefulWidget {
  final String? Function(String?)? validator;
  final String? initialValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FormController? formController;
  final void Function(String)? onChanged;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;

  const MyTextFormField({
    super.key,
    this.validator,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.formController,
    this.onChanged,
    this.decoration,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  late final FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.formController?.helper.prepareFocusNode(widget.focusNode);
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    super.dispose();
  }

  String? Function(String?)? _validator() {
    if (widget.validator != null) return widget.validator;
    if (widget.formController != null && _focusNode != null) {
      return (v) => widget.formController?.helper.validate(value: v, focusNode: _focusNode);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: _validator(),
      initialValue: widget.initialValue,
      controller: widget.controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      inputFormatters: widget.formController?.helper.buildFormatters(),
      keyboardType: widget.keyboardType ?? widget.formController?.textInputType,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      decoration: widget.decoration,
    );
  }
}
```

### Using Your Custom TextFormField

```dart
class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          MyTextFormField(
            formController: PhoneFormController(),
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          MyTextFormField(
            formController: EmailFormController(),
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                print('Form submitted successfully!');
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class PhoneFormController extends FormController {
  @override
  String? Function(String? value)? get validator => (value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    return null;
  };

  @override
  List<String> get formaters => [
    "(##) ####-####",
  ];

  @override
  TextInputType? get textInputType => TextInputType.phone;
}

class EmailFormController extends FormController {
  @override
  String? Function(String? value)? get validator => (value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  };

  @override
  TextInputType? get textInputType => TextInputType.emailAddress;
}
```

This implementation shows how to create your own `MyTextFormField` that has the same smart focus management as `AutoTextFormField`. The key parts are:

1. **FocusNode Management**: Using `prepareFocusNode()` from the FormController
2. **Validator Integration**: Passing the focusNode to the validate method
3. **FormController Integration**: Using the helper methods for formatting and validation
4. **Same API**: Maintaining the same interface as AutoTextFormField

## API Reference

### FormController

| Property | Type | Description |
|----------|------|-------------|
| `validator` | `String? Function(String? value)?` | Validation function |
| `regexFilter` | `RegExp` | Allowed characters filter |
| `formaters` | `List<String>` | Input masks |
| `textInputType` | `TextInputType?` | Keyboard type |
| `customFormatters` | `List<TextInputFormatter>` | Custom input formatters |

### AutoTextFormField

| Property | Type | Description |
|----------|------|-------------|
| `formController` | `FormController?` | Form controller instance |
| `focusNode` | `FocusNode?` | Custom focus node |
| `validator` | `String? Function(String?)?` | Custom validator |

### Methods

| Method | Description |
|--------|-------------|
| `validate({String? value, required FocusNode focusNode})` | Validates and manages focus |
| `prepareFocusNode(FocusNode? focusNode)` | Prepares focus node |
| `resetErrorTracking()` | Resets error tracking state |

## How It Works

1. **Error Tracking**: The system maintains a list of fields with validation errors
2. **Smart Focus**: When validation fails, it automatically focuses on the first field with an error
3. **Dynamic Updates**: As errors are resolved, the focus moves to the next field with an error
4. **Clean State**: After focusing, the error list is cleared for the next validation cycle

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

<div align="center">

### 🎉 **Happy Coding with Auto Form Validadte!** 🎉

*Transform your Flutter app into a scalable, modular masterpiece* ✨

<div style={{textAlign: 'center', margin: '2rem 0'}}>
  <a href="https://github.com/eduardohr-muniz/auto_form_validate/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=eduardohr-muniz/auto_form_validate" alt="Contributors" />
  </a>
  <p style={{marginTop: '1rem', fontSize: '0.9rem', color: 'var(--ifm-color-emphasis-600)'}}>
    <strong>Made with <a href="https://contrib.rocks" target="_blank">contrib.rocks</a></strong>
  </p>
</div>

</div>

---