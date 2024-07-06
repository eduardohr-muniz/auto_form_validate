
# ✅ AUTO FORM VALIDATE ❌
## Streamlining Form Management and Input Handling
Auto Form  validate simplifies form management in Flutter applications by providing intuitive input handling and validation.

It ensures seamless integration with Flutter's form widgets, enhancing user input experiences while maintaining robust validation and formatting functionalities.

With Auto Form, managing forms becomes straightforward, accelerating development and ensuring data integrity throughout your application.

Streamline your Flutter app's form management with Auto Form for enhanced productivity and user satisfaction.

## Installation

```bash
flutter pub add auto_form_validate
```
##### or
This will add a line like this to your package's pubspec.yaml (and run an implicit flutter pub get):
dependencies:
```bash
auto_form_validate: ^1.0.0
```
# Start
1. Create class and **extends** by **FormController**
> The FormController extension will provide you with these getters

**validator:** A function that validates input values. Returns a string error message or null for valid input.
**regexFilter:** A regular expression that defines allowed characters for input validation.
**formatters:** A list of string masks used to format input strings, such as phone numbers or dates.
**textInputType:** Specifies the type of keyboard input for text fields, such as email address, phone

#### Class Example
```dart
import 'package:auto_form_validate/form_controller.dart';

class PhoneMandatory extends FormController {
  PhoneMandatory(super.context);

  @override
  String? Function(String? value)? get validator => (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      };

  @override
  List<String> get formaters => ["(##) ####-####"];

  @override
  TextInputType? get textInputType => TextInputType.number;

  @override
  RegExp get regexFilter => RegExp(r'[0-9]');
}
```
#### Page Form Example
 >Place a **Form** as the parent of your form, when validating the form everything will work correctly if you use the **AutoFormFild** passing the **formController** as in the example below
```dart
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  String phone = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoForm Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              AutoFormFild(
                formController: PhoneMandatory(context),
                onChanged: (value) => phone = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      log("Phone: $phone ✅");
                    }
                  },
                  child: const Text("Validate")),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Contributions

<a href="https://github.com/eduardohr-muniz/auto_form_validate/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=eduardohr-muniz/auto_form_validate" />
</a>

Made with [contrib.rocks](https://contrib.rocks).

