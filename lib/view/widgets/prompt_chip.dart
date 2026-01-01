import 'package:flutter/material.dart';
import '../../models/prompt_model.dart';

class PromptChip extends StatelessWidget {
  final PromptModel prompt;
  final VoidCallback onTap;

  const PromptChip({
    super.key,
    required this.prompt,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (prompt.iconType) {
      case IconType.sparkle:
        return Icons.auto_awesome;
      case IconType.check:
        return Icons.check_circle_outline;
      case IconType.refresh:
        return Icons.refresh;
      case IconType.summary:
        return Icons.summarize;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(),
              size: 18,
              color: Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              prompt.title,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
