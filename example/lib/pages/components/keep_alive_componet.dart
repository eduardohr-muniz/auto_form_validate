import 'package:flutter/material.dart';

class KeepAliveComponet extends StatefulWidget {
  final Widget child;
  const KeepAliveComponet({
    super.key,
    required this.child,
  });

  @override
  State<KeepAliveComponet> createState() => _KeepAliveComponetState();
}

class _KeepAliveComponetState extends State<KeepAliveComponet> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
