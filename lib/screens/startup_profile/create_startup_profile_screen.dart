import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/categories.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/primary_button.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/startup_profile/bloc/startup_profile_bloc.dart';
import '../../features/startup_profile/bloc/startup_profile_event.dart';
import '../../features/startup_profile/bloc/startup_profile_state.dart';

class CreateStartupProfileScreen extends StatefulWidget {
  const CreateStartupProfileScreen({super.key});

  @override
  State<CreateStartupProfileScreen> createState() => _CreateStartupProfileScreenState();
}

class _CreateStartupProfileScreenState extends State<CreateStartupProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  String _category = kCategories.first;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<StartupProfileBloc>().add(
          StartupProfileSubmitted(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _category,
            website: _websiteController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up your startup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<StartupProfileBloc, StartupProfileState>(
          builder: (context, state) {
            final isSubmitting = state is StartupProfileNotCreated && state.isSubmitting;
            final error = state is StartupProfileNotCreated ? state.error : null;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This unlocks opportunity posting once an ALU admin verifies your startup.',
                      style: AppTextStyles.bodyMuted,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Startup name'),
                      validator: (v) => Validators.required(v, field: 'Startup name'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'What does your startup do?'),
                      validator: (v) => Validators.required(v, field: 'Description'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: kCategories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _category = v ?? _category),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(
                        labelText: 'Website or social link (optional)',
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(error, style: const TextStyle(color: AppColors.error)),
                    ],
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: 'Submit for verification',
                      isLoading: isSubmitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
