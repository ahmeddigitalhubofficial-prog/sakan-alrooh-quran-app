import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuickActionsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> actions;

  const QuickActionsGrid({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14.w,
        mainAxisSpacing: 14.h,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (
        context,
        index,
      ) {
        final action = actions[index];

        return GestureDetector(
          onTap: action['onTap'],
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                22.r,
              ),
              gradient: LinearGradient(
                colors: [
                  action['color'],
                  action['color'].withOpacity(
                    0.6,
                  ),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  action['icon'],
                  color: Colors.white,
                  size: 34.sp,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  action['title'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
