// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:navex/core/themes/app_sizes.dart';
//
// final ImagePicker _picker = ImagePicker();
//
// void showImagePickerBottomSheet({required BuildContext context}) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(
//         top: Radius.circular(AppSizes.cardCornerRadius),
//       ),
//     ),
//     builder: (context) {
//       return SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: AppSizes.kDefaultPadding),
//           child: Wrap(
//             children: [
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   margin: const EdgeInsets.only(
//                     bottom: AppSizes.kDefaultPadding / 1.5,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade400,
//                     borderRadius: BorderRadius.circular(
//                       AppSizes.cardCornerRadius,
//                     ),
//                   ),
//                 ),
//               ),
//               ListTile(
//                 leading: Icon(
//                   Icons.camera_alt_outlined,
//                   color: Theme.of(context).colorScheme.surfaceContainer,
//                 ),
//                 title: Text(
//                   'Take a photo',
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//                 onTap: () async {
//                   final pickedFile = await _picker.pickImage(
//                     source: ImageSource.camera,
//                     imageQuality: 85,
//                   );
//                   if (pickedFile != null) {
//                     File image = File(pickedFile.path);
//                     // ✅ Handle the selected image here
//                     // e.g. uploadImage(image);
//                   }
//                   if (context.mounted) Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 leading: Icon(
//                   Icons.photo_library_outlined,
//                   color: Theme.of(context).colorScheme.surfaceContainer,
//                 ),
//                 title: Text(
//                   'Choose from gallery',
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//                 onTap: () async {
//                   final pickedFile = await _picker.pickImage(
//                     source: ImageSource.gallery,
//                     imageQuality: 85,
//                   );
//                   if (pickedFile != null) {
//                     File image = File(pickedFile.path);
//                     // ✅ Handle the selected image here
//                     // e.g. uploadImage(image);
//                   }
//                   if (context.mounted) Navigator.pop(context);
//                 },
//               ),
//               const SizedBox(height: 8),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
