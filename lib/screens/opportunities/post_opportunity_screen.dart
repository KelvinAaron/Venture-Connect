import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/categories.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/primary_button.dart';
import '../../features/opportunities/bloc/post_opportunity_cubit.dart';
import '../../features/opportunities/bloc/post_opportunity_state.dart';
import '../../features/opportunities/data/opportunity_repository.dart';
import '../../features/opportunities/models/opportunity.dart';
import '../../features/startup_profile/models/startup.dart';

/// Handles both creating a new posting and editing an existing one — pass
/// [existing] to edit.
class PostOpportunityScreen extends StatelessWidget {
  final Startup startup;
  final Opportunity? existing;

  const PostOpportunityScreen({super.key, required this.startup, this.existing});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PostOpportunityCubit(OpportunityRepository()),
      child: _PostOpportunityForm(startup: startup, existing: existing),
    );
  }
}

class _PostOpportunityForm extends StatefulWidget {
  final Startup startup;
  final Opportunity? existing;
  const _PostOpportunityForm({required this.startup, this.existing});

  @override
  State<_PostOpportunityForm> createState() => _PostOpportunityFormState();
}

class _PostOpportunityFormState extends State<_PostOpportunityForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _commitmentController;
  late final TextEditingController _locationController;
  late final TextEditingController _skillsController;
  late String _category;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _descriptionController = TextEditingController(text: existing?.description ?? '');
    _commitmentController = TextEditingController(text: existing?.commitment ?? '');
    _locationController = TextEditingController(text: existing?.location ?? '');
    _skillsController = TextEditingController(text: existing?.skillsRequired.join(', ') ?? '');
    _category = existing?.category ?? kCategories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _commitmentController.dispose();
    _locationController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final cubit = context.read<PostOpportunityCubit>();
    final existing = widget.existing;
    if (existing == null) {
      cubit.create(Opportunity(
        id: '',
        startupId: widget.startup.id,
        startupName: widget.startup.name,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        skillsRequired: skills,
        commitment: _commitmentController.text.trim(),
        location: _locationController.text.trim(),
        isOpen: true,
      ));
    } else {
      cubit.update(Opportunity(
        id: existing.id,
        startupId: existing.startupId,
        startupName: existing.startupName,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        skillsRequired: skills,
        commitment: _commitmentController.text.trim(),
        location: _locationController.text.trim(),
        isOpen: existing.isOpen,
        createdAt: existing.createdAt,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit opportunity' : 'Post an opportunity')),
      body: SafeArea(
        child: BlocListener<PostOpportunityCubit, PostOpportunityState>(
          listener: (context, state) {
            if (state is PostOpportunitySuccess) {
              Navigator.of(context).pop();
            } else if (state is PostOpportunityFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) => Validators.required(v, field: 'Title'),
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
                    items: kCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v ?? _category),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _commitmentController,
                    decoration: const InputDecoration(
                      labelText: 'Commitment',
                      hintText: 'e.g. Part-time (5-10 hrs/week)',
                    ),
                    validator: (v) => Validators.required(v, field: 'Commitment'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      hintText: 'e.g. Remote, On-campus, Kigali',
                    ),
                    validator: (v) => Validators.required(v, field: 'Location'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _skillsController,
                    decoration: const InputDecoration(
                      labelText: 'Skills required',
                      hintText: 'Comma-separated, e.g. Flutter, Dart, Firebase',
                    ),
                  ),
                  const SizedBox(height: 28),
                  BlocBuilder<PostOpportunityCubit, PostOpportunityState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        label: _isEditing ? 'Save changes' : 'Post opportunity',
                        isLoading: state is PostOpportunitySubmitting,
                        onPressed: _submit,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
