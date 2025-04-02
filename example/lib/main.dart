import 'dart:developer';

import 'package:auto_form_validate/auto_form_validate.dart';
import 'package:example/pages/tabs_form_page.dart';
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
        '/tabs': (context) => const TabsFormPage(),
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
              //👋
              AutoTextFormField(
                decoration: const InputDecoration(labelText: 'Document BR'),
                formController: CpfCnpjValidator(),
                controller: phoneEC,
                onChanged: (value) => phone = value,
              ),

              AutoTextFormField(
                decoration: const InputDecoration(labelText: 'Text Mandatory*'),
                formController: Mandatory(),
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
