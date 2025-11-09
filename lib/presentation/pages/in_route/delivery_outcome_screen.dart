import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _picker = ImagePicker();
  final List<File> _photos = [];
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
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.gallery) {
      final List<XFile> pickedList = await _picker.pickMultiImage(
        imageQuality: 85,
      );
      if (pickedList.isNotEmpty) {
        setState(() {
          _photos.addAll(pickedList.map((xfile) => File(xfile.path)));
        });
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _photos.add(File(picked.path));
      });
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.cardCornerRadius),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.kDefaultPadding,
            ),
            child: Wrap(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(
                      bottom: AppSizes.kDefaultPadding / 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(
                        AppSizes.cardCornerRadius,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt_outlined,
                    color:
                        Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    'Take a photo',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color:
                        Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    'Choose from gallery',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(AppSizes.cardCornerRadius),
                  onTap: _showImagePickerBottomSheet,
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
              ),
            ],
          ),
          const SizedBox(height: AppSizes.kDefaultPadding),
          if (_photos.isNotEmpty) ...[
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSizes.kDefaultPadding / 2),
                itemBuilder: (context, index) {
                  final file = _photos[index];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSizes.cardCornerRadius),
                        child: Image.file(
                          file,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _photos.removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.kDefaultPadding),
          ],
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
