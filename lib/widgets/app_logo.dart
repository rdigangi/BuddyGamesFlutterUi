import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double width;
  final double height;
  final double titleSize;
  final bool showTitle;

  const AppLogo({
    super.key,
    this.width = 120,
    this.height = 120,
    this.titleSize = 28,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: width,
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.broken_image_outlined,
              size: width > height ? height : width,
              color: Colors.grey,
            );
          },
        ),
        if (showTitle) ...[
          const SizedBox(height: 12),
          Text(
            'Game Results',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}