import 'package:example/pages/components/keep_alive_componet.dart';
import 'package:example/pages/components/tab_page_1.dart';
import 'package:example/pages/components/tab_page_2.dart';
import 'package:example/pages/components/tab_page_3.dart';
import 'package:example/pages/viewmodels/tab_page_viewmodel.dart';
import 'package:flutter/material.dart';

class TabsFormPage extends StatefulWidget {
  const TabsFormPage({super.key});

  @override
  State<TabsFormPage> createState() => _TabsFormPageState();
}

class _TabsFormPageState extends State<TabsFormPage> with SingleTickerProviderStateMixin {
  late final TabController tabController;
  final viewmodel = TabPageViewmodel();
  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Tab 1'),
            Tab(text: 'Tab 2'),
            Tab(text: 'Tab 3'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                KeepAliveComponet(child: TabPage1(formKey: viewmodel.getFormKey(0))),
                KeepAliveComponet(child: TabPage2(formKey: viewmodel.getFormKey(1))),
                KeepAliveComponet(child: TabPage3(formKey: viewmodel.getFormKey(2))),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final pagereturn = viewmodel.validateAll();
              if (pagereturn != null) {
                tabController.animateTo(pagereturn);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All forms are valid')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Some forms are invalid')));
              }
            },
            child: const Text('Validate All'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: const Text('go home'),
          ),
        ],
      ),
    );
  }
}
