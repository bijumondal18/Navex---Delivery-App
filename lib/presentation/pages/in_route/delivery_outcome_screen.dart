import 'package:flutter/material.dart';

import '../../../core/themes/app_sizes.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class DeliveryOutcomeArgs {
  final String optionKey;
  final String title;

  const DeliveryOutcomeArgs({required this.optionKey, required this.title});
}

class DeliveryOutcomeScreen extends StatefulWidget {
  final String optionKey;
  final String title;

  const DeliveryOutcomeScreen({
    super.key,
    required this.optionKey,
    required this.title,
  });

  @override
  State<DeliveryOutcomeScreen> createState() => _DeliveryOutcomeScreenState();
}

class _DeliveryOutcomeScreenState extends State<DeliveryOutcomeScreen> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _notesController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          widget.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.kDefaultPadding),
        children: [
          Row(
            spacing: AppSizes.kDefaultPadding,
            children: [
              Expanded(
                child: Card(
                  elevation: AppSizes.elevationMedium,
                  shadowColor: Theme.of(context).shadowColor.withAlpha(100),
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSizes.cardCornerRadius,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.kDefaultPadding),
                    child: Row(
                      spacing: AppSizes.kDefaultPadding / 2,
                      children: [
                        Icon(Icons.edit),
                        Text(
                          'Add Signature',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  elevation: AppSizes.elevationMedium,
                  shadowColor: Theme.of(context).shadowColor.withAlpha(100),
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSizes.cardCornerRadius,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.kDefaultPadding),
                    child: Row(
                      spacing: AppSizes.kDefaultPadding / 2,
                      children: [
                        Icon(Icons.camera_alt),
                        Text(
                          'Add Photo',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.kDefaultPadding),
          AppTextField(
            type: AppTextFieldType.text,
            controller: _nameController,
            hint: 'Recipient Name',
          ),
          const SizedBox(height: AppSizes.kDefaultPadding),
          AppTextField(
            type: AppTextFieldType.text,
            controller: _notesController,
            hint: 'Notes',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.kDefaultPadding*2,
            ),
            child: PrimaryButton(
              label: 'Submit',
              fullWidth: true,
              onPressed: () {},
              size: ButtonSize.lg,
            ),
          ),
        ],
      ),
    );
  }
}
