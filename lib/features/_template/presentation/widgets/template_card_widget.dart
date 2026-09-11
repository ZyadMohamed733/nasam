import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/template_entity.dart';

class TemplateCardWidget extends StatelessWidget {
  const TemplateCardWidget({super.key, required this.entity, this.onTap});

  final TemplateEntity entity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(entity.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSizes.p8),
          Text(
            entity.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
