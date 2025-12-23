// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:auto_form_validate/auto_form_validate.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoForm Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const HomePage(),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  String phone = '';
  final phoneEC = TextEditingController();
  bool? isChecked = false;

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
            spacing: 20,
            children: [
              //👋
              // AutoTextFormField(
              //   decoration: const InputDecoration(labelText: 'Document BR'),
              //   formController: CpfCnpjValidator(),
              //   controller: phoneEC,
              //   onChanged: (value) => phone = value,
              // ),

              AutoTextFormField(
                decoration: const InputDecoration(labelText: 'Text Mandatory*'),
                formController: Mandatory(),
                onChanged: (value) {
                  phone = value;
                },
              ),
              AutoTextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number*'),
                formController: PhoneValidator(),
                controller: phoneEC,
              ),
              AutoTextFormField(
                decoration: const InputDecoration(labelText: 'Only Numbers*'),
                formController: OnlyNumbersValidator(),
              ),
              const SizedBox(height: 20),
              // Exemplo com Checkbox usando CustomFormController
              AutoFormFieldWrapper<bool?>(
                formController: CheckboxRequiredValidator(),
                builder: (field) => Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          isChecked = value;
                        });
                        field.didChange(value);
                      },
                    ),
                    Text(
                      'Accept terms and conditions',
                      style: field.errorText != null ? const TextStyle(color: Colors.amber) : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      log("Phone: $phone ✅");
                      log("Checkbox: $isChecked ✅");
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

class CpfCnpjValidator extends FormController {
  @override
  String? Function(String? value)? get validator => (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      };

  @override
  List<String> get formaters => [
        "###.###.###-##",
        "##.###.###/####-##",
      ];

  @override
  TextInputType? get textInputType => TextInputType.number;

  @override
  RegExp get regexFilter => RegExp(r'[0-9]');
}

class Mandatory extends FormController {
  @override
  String? Function(String? value)? get validator => (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      };
}

class PhoneValidator extends FormController {
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
        "(##)# ####-####",
      ];

  @override
  TextInputType? get textInputType => TextInputType.number;

  @override
  RegExp get regexFilter => RegExp(r'[0-9]');
}

class OnlyNumbersValidator extends FormController {
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
}

// Exemplo de CustomFormController para Checkbox
class CheckboxRequiredValidator extends CustomFormController<bool?> {
  @override
  String? Function(bool? value)? get validator => (value) {
        if (value == null || value == false) {
          return 'You must accept the terms';
        }
        return null;
      };
}
