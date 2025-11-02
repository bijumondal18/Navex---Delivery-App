import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navex/core/themes/app_sizes.dart';
import 'package:navex/data/models/state_details.dart';
import 'package:navex/presentation/widgets/app_dropdown_button.dart';
import 'package:navex/presentation/widgets/app_text_field.dart';
import 'package:navex/presentation/widgets/primary_button.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../bloc/auth_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _zipController;

  StateDetails? selectedState;
  List<StateDetails> items = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _zipController = TextEditingController();

    context.read<AuthBloc>().add(FetchUserProfileEvent());
    context.read<AuthBloc>().add(FetchStateListEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Edit Profile",
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: AppColors.white),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is FetchUserProfileStateLoaded) {
            _nameController.text = state.profileResponse.user?.name ?? '';
            _emailController.text = state.profileResponse.user?.email ?? '';
            _phoneController.text =
                state.profileResponse.user?.driver?.phone ?? '';
            _addressController.text =
                state.profileResponse.user?.driver?.address ?? '';
            _bioController.text = state.profileResponse.user?.driver?.bio ?? '';

            final stateDetails =
                state.profileResponse.user?.driver?.stateDetails;
            if (stateDetails != null) {
              selectedState = stateDetails;
            }
          }

          if (state is FetchStateListStateLoaded) {
            setState(() {
              items = state.stateList;

              if (selectedState != null) {
                final match = items.firstWhere(
                      (item) => item.id == selectedState!.id,
                  orElse: () => items.first,
                );
                selectedState = match;
              }
            });
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(AppSizes.kDefaultPadding),
            children: [
              AppTextField(
                type: AppTextFieldType.text,
                controller: _nameController,
                hint: 'Your Name',
              ),
              const SizedBox(height: AppSizes.kDefaultPadding),
              AppTextField(
                type: AppTextFieldType.email,
                controller: _emailController,
                readOnly: true,
                hint: 'Email Address',
              ),
              const SizedBox(height: AppSizes.kDefaultPadding),
              AppTextField(
                type: AppTextFieldType.mobile,
                controller: _phoneController,
                hint: 'Phone Number',
              ),
              const SizedBox(height: AppSizes.kDefaultPadding),
              AppTextField(
                type: AppTextFieldType.text,
                controller: _addressController,
                hint: 'Address',
              ),
              const SizedBox(height: AppSizes.kDefaultPadding),
              AppDropdownButton(
                items: items,
                selectedItem: selectedState,
                onChanged: (value) {
                  setState(() {
                    selectedState = value;
                  });
                },
                hint: 'Select State',
                getLabel: (state) => state.state.toString(),
              ),
              const SizedBox(height: AppSizes.kDefaultPadding),
              AppTextField(
                type: AppTextFieldType.text,
                controller: _cityController,
                hint: 'City',
              ),
              const SizedBox(height: AppSizes.kDefaultPadding),
              AppTextField(
                type: AppTextFieldType.mobile,
                controller: _zipController,
                hint: 'Zip Code',
              ),
              const SizedBox(height: AppSizes.kDefaultPadding),
              AppTextField(
                type: AppTextFieldType.address,
                controller: _bioController,
                hint: 'Bio',
              ),
              const SizedBox(height: AppSizes.kDefaultPadding * 2),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is UpdateProfileStateLoaded) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${state.commonResponse.message}',
                          style: Theme.of(context).textTheme.labelLarge!
                              .copyWith(color: AppColors.white),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainer,
                      ),
                    );
                  }
                  if (state is UpdateProfileStateFailed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.error,
                          style: Theme.of(context).textTheme.labelLarge!
                              .copyWith(color: AppColors.white),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is UpdateProfileStateLoading) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  return PrimaryButton(
                    label: 'Update',
                    fullWidth: true,
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        UpdateProfileEvent(
                          name: _nameController.text.trim().toString(),
                          email: _emailController.text.trim().toString(),
                          address: _addressController.text.trim().toString(),
                          bio: _bioController.text.trim().toString(),
                          zipCode: _zipController.text.trim().toString(),
                          phoneNumber: _phoneController.text.trim().toString(),
                          city: _cityController.text.trim().toString(),
                          stateId: selectedState?.id.toString()
                        ),
                      );
                    },
                    size: ButtonSize.lg,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
