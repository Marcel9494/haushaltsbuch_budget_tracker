import 'package:flutter/material.dart';

class ImportInfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> paragraphs;

  const ImportInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.paragraphs,
    this.iconColor = Colors.cyanAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            for (final String paragraph in paragraphs) ...[
              const SizedBox(height: 10.0),
              Text(paragraph),
            ],
          ],
        ),
      ),
    );
  }
}
