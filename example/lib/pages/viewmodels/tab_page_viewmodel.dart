import 'package:flutter/material.dart';

class TabPageViewmodel {
  static const int qtyTabs = 3;

  late final formkesy = List.generate(qtyTabs, (index) => GlobalKey<FormState>());

  GlobalKey<FormState> getFormKey(int index) {
    return formkesy[index];
  }

  int? validateUntil(int index) {
    for (int i = 0; i < index; i++) {
      if (!formkesy[i].currentState!.validate()) {
        return i;
      }
    }
    return null;
  }

  int? validateAll() {
    final pageReturn = validateUntil(qtyTabs - 1);
    if (pageReturn != null) return pageReturn;
    return null;
  }
}
