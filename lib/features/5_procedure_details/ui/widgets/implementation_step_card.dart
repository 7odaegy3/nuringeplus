import 'package:flutter/material.dart';
import 'package:nursingplus/core/database/sqflite_service.dart';

class ImplementationStepCard extends StatelessWidget {
  final Implementation implementation;
  final bool isExpanded;
  final VoidCallback onTap;

  const ImplementationStepCard({
    super.key,
    required this.implementation,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  'الخطوة ${implementation.stepNumber}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle: Text(implementation.description),
                trailing: RotatedBox(
                  quarterTurns: isExpanded ? 2 : 0,
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ),
              if (isExpanded) ...[
                if (implementation.rational != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.science),
                            const SizedBox(width: 8),
                            Text(
                              'السبب العلمي',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(implementation.rational!),
                      ],
                    ),
                  ),
                if (implementation.hint != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb),
                            const SizedBox(width: 8),
                            Text(
                              'تلميح',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(implementation.hint!),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
