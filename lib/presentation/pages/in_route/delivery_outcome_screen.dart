import 'package:flutter/material.dart';

import '../../../core/themes/app_sizes.dart';
import '../../widgets/app_dropdown_button.dart';
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
  String? _selectedFailureReason;
  static const _failureReasons = [
    'Recipient unavailable/ No answer',
    'Recipient changed his/her address',
    'Refused delivery',
    'Access issue',
    'Missing package',
    'Payment required',
    'Package damaged',
    'Delivery timeframe missed',
    'Incorrect address on maps',
    'Incorrect package',
    'Animal interference',
    'Weather/ Road condition',
    'Other',
  ];

  bool get _shouldSkipSignature =>
      widget.optionKey == 'mailbox' || widget.optionKey == 'safe_place';
  bool get _isFailureFlow => widget.optionKey == 'failed';

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
              if (!_shouldSkipSignature && !_isFailureFlow)
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.edit),
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
                                              mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt),
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
          if (_isFailureFlow) ...[
            AppDropdownButton<String>(
              label: 'Failure Reason',
              hint: 'Select failure reason',
              items: _failureReasons,
              selectedItem: _selectedFailureReason,
              getLabel: (value) => value,
              onChanged: (value) {
                setState(() => _selectedFailureReason = value);
              },
              required: true,
            ),
            const SizedBox(height: AppSizes.kDefaultPadding),
          ],
          if (!_shouldSkipSignature && !_isFailureFlow) ...[
            AppTextField(
              type: AppTextFieldType.text,
              controller: _nameController,
              hint: 'Recipient Name',
            ),
            const SizedBox(height: AppSizes.kDefaultPadding),
          ],
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
