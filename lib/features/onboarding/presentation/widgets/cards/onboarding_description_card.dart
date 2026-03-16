import 'package:flutter/material.dart';

class OnboardingDescriptionCard extends StatelessWidget {
  final String title;
  final String descriptionText1;
  final String descriptionText2;

  const OnboardingDescriptionCard({
    super.key,
    required this.title,
    required this.descriptionText1,
    this.descriptionText2 = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Stack(
            children: [
              // Linker Balken
              Positioned(
                left: 0,
                top: 14,
                bottom: 130,
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(descriptionText1),
                    if (descriptionText2 != '') ...[
                      const SizedBox(height: 8),
                      Text(descriptionText2),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
