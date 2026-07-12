import 'package:flutter/material.dart';
import '../../core/constants/categories.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../features/startup_profile/data/startup_repository.dart';
import '../../features/startup_profile/models/startup.dart';
import '../../features/startup_profile/models/verification_status.dart';
import '../auth/logout_confirmation.dart';

class StartupProfileView extends StatefulWidget {
  final Startup startup;
  const StartupProfileView({super.key, required this.startup});

  @override
  State<StartupProfileView> createState() => _StartupProfileViewState();
}

class _StartupProfileViewState extends State<StartupProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _websiteController;
  late String _category;
  bool _isSaving = false;
  String? _error;

  final _repository = StartupRepository();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.startup.name);
    _descriptionController = TextEditingController(text: widget.startup.description);
    _websiteController = TextEditingController(text: widget.startup.website);
    _category = widget.startup.category;
  }

  @override
  void didUpdateWidget(covariant StartupProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep fields in sync if the startup doc changes elsewhere while this
    // screen is mounted (e.g. re-decided by an admin).
    if (oldWidget.startup != widget.startup) {
      _nameController.text = widget.startup.name;
      _descriptionController.text = widget.startup.description;
      _websiteController.text = widget.startup.website;
      _category = widget.startup.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await _repository.updateProfile(
        startupId: widget.startup.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        website: _websiteController.text.trim(),
      );
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated.')),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _error = e.toString();
      });
    }
  }

  (Color, Color) get _statusColors {
    switch (widget.startup.status) {
      case VerificationStatus.pending:
        return (AppColors.warning, AppColors.warningBg);
      case VerificationStatus.verified:
        return (AppColors.success, AppColors.successBg);
      case VerificationStatus.rejected:
        return (AppColors.error, AppColors.errorBg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = _statusColors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusBadge(label: widget.startup.status.name, foreground: fg, background: bg),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Startup name'),
              validator: (v) => Validators.required(v, field: 'Startup name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (v) => Validators.required(v, field: 'Description'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: kCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(labelText: 'Website or social link'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 28),
            PrimaryButton(label: 'Save changes', isLoading: _isSaving, onPressed: _save),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => confirmAndLogOut(context),
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
