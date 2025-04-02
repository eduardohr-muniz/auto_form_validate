import 'package:example/main.dart';
import 'package:flutter/material.dart';

import 'package:auto_form_validate/auto_form_validate.dart';

class TabPage2 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const TabPage2({
    super.key,
    required this.formKey,
  });

  @override
  State<TabPage2> createState() => _TabPage2State();
}

class _TabPage2State extends State<TabPage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('tab 2'),
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
