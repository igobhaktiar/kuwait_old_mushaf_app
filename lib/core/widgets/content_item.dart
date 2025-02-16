import 'package:flutter/material.dart';

class ContentItem extends StatelessWidget {
  final String title;
  final String body;
  const ContentItem({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //title
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(
          height: 5,
        ),
        //content as text
        Text(
          body,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
