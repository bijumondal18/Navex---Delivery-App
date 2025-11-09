import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

import '../../../core/themes/app_sizes.dart';
import '../../widgets/primary_button.dart';

class SignaturePadScreen extends StatefulWidget {
  const SignaturePadScreen({super.key});

  @override
  State<SignaturePadScreen> createState() => _SignaturePadScreenState();
}

class _SignaturePadScreenState extends State<SignaturePadScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportPenColor: Colors.black,
  );

  Future<void> _submit() async {
    final bytes = await _controller.toPngBytes();
    if (bytes == null || bytes.isEmpty) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes, flush: true);

    if (!mounted) return;
    Navigator.of(context).pop(file);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Signature',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.kDefaultPadding),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
                  color: surface,
                  border: Border.all(
                    color: surface.withValues(alpha: 0.6),
                  ),
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppSizes.cardCornerRadius),
                  child: Signature(
                    controller: _controller,
                    backgroundColor: surface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.kDefaultPadding),
            SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.cardCornerRadius),
                        ),
                        side: BorderSide(color: primary),
                      ),
                      onPressed: () => _controller.clear(),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.kDefaultPadding),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Submit',
                      onPressed: _submit,
                      fullWidth: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
