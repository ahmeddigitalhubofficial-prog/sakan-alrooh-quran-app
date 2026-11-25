import 'package:material_ui/material_ui.dart';

class CustomSafeArea extends StatelessWidget {
  final Widget child;

  const CustomSafeArea({
    super.key,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SafeArea(
      child: child,
    );
  }
}
