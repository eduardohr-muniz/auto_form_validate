import 'package:example/main.dart';
import 'package:flutter/material.dart';

import 'package:auto_form_validate/auto_form_validate.dart';

class TabPage3 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const TabPage3({
    super.key,
    required this.formKey,
  });

  @override
  State<TabPage3> createState() => _TabPage3State();
}

class _TabPage3State extends State<TabPage3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('tab 3'),
      ),
      body: Form(
        key: widget.formKey,
        child: AutoTextFormField(
          formController: Mandatory(),
        ),
      ),
    );
  }
}
