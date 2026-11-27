import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_app_bar.dart';

class BaseScreen extends StatelessWidget {
  final String title;

  final Widget child;

  final List<Widget>? actions;

  const BaseScreen({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        actions: actions,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16.w,
            16.h,
            16.w,
            120.h,
          ),
          child: child,
        ),
      ),
    );
  }
}
