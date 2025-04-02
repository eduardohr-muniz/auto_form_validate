import 'package:example/main.dart';
import 'package:flutter/material.dart';

import 'package:auto_form_validate/auto_form_validate.dart';

class TabPage1 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const TabPage1({
    super.key,
    required this.formKey,
  });

  @override
  State<TabPage1> createState() => _TabPage1State();
}

class _TabPage1State extends State<TabPage1> {
  // final controllerEC = TextEditingController(text: '1297364368');
  final controllerEC = TextEditingController(text: '32074826000109');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('tab 1'),
      ),
      body: Form(
        key: widget.formKey,
        child: AutoTextFormField(
          controller: controllerEC,
          decoration: const InputDecoration(labelText: 'CPF'),
          formController: CpfCnpjValidator(),
        ),
      ),
    );
  }
}
