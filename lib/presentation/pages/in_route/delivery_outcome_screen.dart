import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../bloc/route_bloc.dart';
import '../../widgets/app_dropdown_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import 'signature_pad_screen.dart';

class DeliveryOutcomeArgs {
  final String optionKey;
  final String title;
  final String routeId;
  final String waypointId;
  final double? lat;
  final double? long;

  const DeliveryOutcomeArgs({
    required this.optionKey,
    required this.title,
    required this.routeId,
    required this.waypointId,
    this.lat,
    this.long,
  });
}

class DeliveryOutcomeScreen extends StatefulWidget {
  final String optionKey;
  final String title;
  final String routeId;
  final String waypointId;
  final double? lat;
  final double? long;

  const DeliveryOutcomeScreen({
    super.key,
    required this.optionKey,
    required this.title,
    required this.routeId,
    required this.waypointId,
    this.lat,
    this.long,
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
  bool _isSubmitting = false;
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

  // Map optionKey to deliver_to value
  int? get _deliverToValue {
    switch (widget.optionKey) {
      case 'third_party':
        return 1;
      case 'mailbox':
        return 2;
      case 'safe_place':
        return 3;
      case 'other':
        return 4;
      case 'recipient':
        return null; // Recipient doesn't need deliver_to
      default:
        return null;
    }
  }

  // Get delivery_type: 1=Success, 2=Failed
  int get _deliveryType => _isFailureFlow ? 2 : 1;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _notesController = TextEditingController();
  }

  Future<void> _handleSubmit() async {
    // Validate failure reason if failed
    if (_isFailureFlow && _selectedFailureReason == null) {
      SnackBarHelper.showError('Please select a failure reason', context: context);
      return;
    }

    // Validate images - at least one image (photo or signature) is required
    if (_photos.isEmpty) {
      SnackBarHelper.showError('Please add at least one photo or signature', context: context);
      return;
    }

    // Validate recipient name - required when not in failure flow and not skipping signature
    if (!_isFailureFlow && !_shouldSkipSignature) {
      final recipientName = _nameController.text.trim();
      if (recipientName.isEmpty) {
        SnackBarHelper.showError('Please enter recipient name', context: context);
        return;
      }
    }

    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      // Get current location if not provided
      double lat = widget.lat ?? 0.0;
      double long = widget.long ?? 0.0;

      if (lat == 0.0 || long == 0.0) {
        try {
          final position = await Geolocator.getCurrentPosition();
          lat = position.latitude;
          long = position.longitude;
        } catch (e) {
          // If location unavailable, use default or show error
          if (mounted) {
            SnackBarHelper.showError('Unable to get current location', context: context);
            setState(() => _isSubmitting = false);
            return;
          }
        }
      }

      // Get current date and time
      final now = DateTime.now();
      final deliveryDate = DateTimeUtils.getFormattedPickedDate(now);
      final deliveryTime = DateTimeUtils.getFormattedTime(now);

      // Separate signature from other images
      File? signature;
      final deliveryImages = <File>[];
      for (var photo in _photos) {
        if (photo.path.contains('signature_')) {
          signature = photo;
        } else {
          deliveryImages.add(photo);
        }
      }

      // Get notes (separate from failure reason)
      String notes = _notesController.text.trim();

      // Get failure reason (only for failed deliveries)
      String? failureReason;
      if (_isFailureFlow && _selectedFailureReason != null) {
        failureReason = _selectedFailureReason;
      }

      // Dispatch the event
      if (mounted) {
        context.read<RouteBloc>().add(
              MarkDeliveryEvent(
                deliveryRouteId: widget.routeId,
                deliveryWaypointId: widget.waypointId,
                lat: lat,
                long: long,
                deliveryType: _deliveryType,
                deliveryDate: deliveryDate,
                deliveryTime: deliveryTime,
                deliveryImages: deliveryImages,
                signature: signature,
                notes: notes.isEmpty ? null : notes,
                reason: failureReason,
                recipientName: _nameController.text.trim().isEmpty
                    ? null
                    : _nameController.text.trim(),
                deliverTo: _deliverToValue,
              ),
            );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        SnackBarHelper.showError('Error: ${e.toString()}', context: context);
      }
    }
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
                    color: Theme.of(context).colorScheme.primary,
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
                    color: Theme.of(context).colorScheme.primary,
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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      AppSizes.cardCornerRadius,
                    ),
                    onTap: () async {
                      final signature = await Navigator.of(context).push<File?>(
                        MaterialPageRoute(
                          builder: (_) => const SignaturePadScreen(),
                        ),
                      );
                      if (signature != null && mounted) {
                        setState(() {
                          _photos.removeWhere((file) => file.path.contains('signature_'));
                          _photos.add(signature);
                        });
                      }
                    },
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
                ),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    AppSizes.cardCornerRadius,
                  ),
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
                        borderRadius: BorderRadius.circular(
                          AppSizes.cardCornerRadius,
                        ),
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
                              color: Colors.black.withValues(alpha: 0.6),
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
              required: true,
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
              vertical: AppSizes.kDefaultPadding * 2,
            ),
            child: BlocListener<RouteBloc, RouteState>(
              listenWhen: (prev, curr) =>
                  curr is MarkDeliveryStateLoading ||
                  curr is MarkDeliveryStateLoaded ||
                  curr is MarkDeliveryStateFailed,
              listener: (context, state) {
                if (state is MarkDeliveryStateLoading) {
                  setState(() => _isSubmitting = true);
                } else if (state is MarkDeliveryStateLoaded) {
                  setState(() => _isSubmitting = false);
                  SnackBarHelper.showSuccess(
                    state.response.message ?? 'Delivery marked successfully',
                    context: context,
                  );
                  Navigator.of(context).pop(true); // Return success
                } else if (state is MarkDeliveryStateFailed) {
                  setState(() => _isSubmitting = false);
                  SnackBarHelper.showError(state.error, context: context);
                }
              },
              child: PrimaryButton(
                label: 'Submit',
                fullWidth: true,
                onPressed: _isSubmitting ? null : _handleSubmit,
                size: ButtonSize.lg,
                isLoading: _isSubmitting,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
