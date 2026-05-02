import 'package:flutter/material.dart';

class EventCardShimmer extends StatelessWidget {
  const EventCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      physics:     const NeverScrollableScrollPhysics(),
      shrinkWrap:  true,
      itemCount:   5,
      itemBuilder: (_, __) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                _ShimmerBox(width: 60, height: 18, theme: theme),
                const SizedBox(width: 8),
                _ShimmerBox(width: 50, height: 18, theme: theme),
              ]),
              const SizedBox(height: 12),
              _ShimmerBox(width: double.infinity, height: 14, theme: theme),
              const SizedBox(height: 6),
              _ShimmerBox(width: 220, height: 13, theme: theme),
              const SizedBox(height: 10),
              _ShimmerBox(width: 100, height: 11, theme: theme),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.width, required this.height, required this.theme});
  final double width;
  final double height;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) => Container(
    width:  width,
    height: height,
    decoration: BoxDecoration(
      color:        theme.colorScheme.onSurface.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}
