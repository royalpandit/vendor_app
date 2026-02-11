import 'package:flutter/material.dart';

class CustomStepper extends StatelessWidget {
  final int currentStep;
  final ValueChanged<int> onStepChanged;

  const CustomStepper({
    Key? key,
    required this.currentStep,
    required this.onStepChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Horizontal progress line
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(4, (index) {
              return StepDot(
                isActive: index == currentStep,
                isCompleted: index < currentStep,
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
        // Step labels can go here
      ],
    );
  }
}

class StepDot extends StatelessWidget {
  final bool isActive;
  final bool isCompleted;
  const StepDot({
    Key? key,
    required this.isActive,
    required this.isCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define the color of the dot based on the state
    Color dotColor;
    if (isCompleted) {
      dotColor = Colors.pink; // Completed step color (pink)
    } else if (isActive) {
      dotColor = Colors.pink.shade200; // Active step color (light pink)
    } else {
      dotColor = Colors.grey.shade300; // Inactive step color (light gray)
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      width: 100, // Width of the dot
      height: 4, // Height of the dot
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: dotColor,
      ),
    );
  }
}


/*
class CustomStepper extends StatelessWidget {
  final int currentStep;
  final ValueChanged<int> onStepChanged;

  const CustomStepper({
    Key? key,
    required this.currentStep,
    required this.onStepChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Horizontal progress line
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(4, (index) {  // Hardcoded for 4 steps
              return StepLine(
                isActive: index == currentStep,
                isCompleted: index < currentStep,
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
        // Step labels

      ],
    );
  }
}

class StepLine extends StatelessWidget {
  final bool isActive;
  final bool isCompleted;
  const StepLine({
    Key? key,
    required this.isActive,
    required this.isCompleted,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Define the color of the line based on the state
    Color lineColor;
    if (isCompleted) {
      lineColor = Colors.pink; // Completed step color (pink)
    } else if (isActive) {
      lineColor = Colors.pink.shade200; // Active step color (light pink)
    } else {
      lineColor = Colors.grey.shade300; // Inactive step color (light gray)
    }

    return Container(
      width: 150,
      height: 4,
      color: lineColor,
    );
  }
}
*/

class StepLabel extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCompleted;

  const StepLabel({
    Key? key,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color textColor;
    if (isCompleted) {
      textColor = Colors.pink; // Completed step color (pink)
    } else if (isActive) {
      textColor = Colors.pink.shade200; // Active step color (light pink)
    } else {
      textColor = Colors.grey.shade400; // Inactive step color (light gray)
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}