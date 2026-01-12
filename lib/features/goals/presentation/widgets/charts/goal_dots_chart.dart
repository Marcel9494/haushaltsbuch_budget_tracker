import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class GoalDotsChart extends StatefulWidget {
  const GoalDotsChart({super.key});

  @override
  State<GoalDotsChart> createState() => _GoalDotsChartState();
}

class _GoalDotsChartState extends State<GoalDotsChart> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160.0,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: GridView.count(
                crossAxisCount: 20,
                physics: const AlwaysScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 2,
                childAspectRatio: 1.0,
                children: List.generate(100, (index) {
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 300),
                    columnCount: 20,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: Container(
                          height: 2.0,
                          width: 2.0,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.cyanAccent,
                              width: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              children: [
                Text('20 %'),
                SizedBox(height: 2.0),
                Text('40 %'),
                SizedBox(height: 1.0),
                Text('60 %'),
                Text('80 %'),
                SizedBox(height: 1.0),
                Text('100 %'),
              ],
            ),
          )
        ],
      ),
    );
  }
}
