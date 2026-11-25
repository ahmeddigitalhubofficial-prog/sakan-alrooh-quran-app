import 'package:material_ui/material_ui.dart';

class EmptyState extends StatelessWidget {
  final String text;

  const EmptyState({
    super.key,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Text(text),
    );
  }
}
