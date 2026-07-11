import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/categories.dart';
import '../../core/constants/locations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
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
  late final TextEditingController _skillsController;
  late String _category;
  late String _location;
  final List<TextEditingController> _questionControllers = [];
  final List<FocusNode> _questionFocusNodes = [];

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _descriptionController = TextEditingController(text: existing?.description ?? '');
    _commitmentController = TextEditingController(text: existing?.commitment ?? '');
    _skillsController = TextEditingController(text: existing?.skillsRequired.join(', ') ?? '');
    _category = existing?.category ?? kCategories.first;
    final existingLocation = existing?.location;
    _location = (existingLocation != null && kLocations.contains(existingLocation))
        ? existingLocation
        : kLocations.first;
    for (final question in existing?.customQuestions ?? const <String>[]) {
      _questionControllers.add(TextEditingController(text: question));
      _questionFocusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _commitmentController.dispose();
    _skillsController.dispose();
    for (final controller in _questionControllers) {
      controller.dispose();
    }
    for (final node in _questionFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    final focusNode = FocusNode();
    setState(() {
      _questionControllers.add(TextEditingController());
      _questionFocusNodes.add(focusNode);
    });
    // Requesting focus after the new field has actually been laid out makes
    // Flutter's built-in "scroll the focused field into view" behavior
    // bring it above the keyboard — otherwise, with enough questions
    // already added, a newly appended field can land below the visible
    // viewport with nothing to prompt a scroll to it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) focusNode.requestFocus();
    });
  }

  void _removeQuestion(int index) => setState(() {
        _questionControllers[index].dispose();
        _questionControllers.removeAt(index);
        _questionFocusNodes[index].dispose();
        _questionFocusNodes.removeAt(index);
      });

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final questions = _questionControllers
        .map((c) => c.text.trim())
        .where((q) => q.isNotEmpty)
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
        location: _location,
        isOpen: true,
        customQuestions: questions,
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
        location: _location,
        isOpen: existing.isOpen,
        customQuestions: questions,
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
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
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Commitment (hrs/week)',
                      hintText: 'e.g. 5',
                    ),
                    validator: (v) => Validators.required(v, field: 'Commitment'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _location,
                    decoration: const InputDecoration(labelText: 'Location'),
                    items: kLocations
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (v) => setState(() => _location = v ?? _location),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _skillsController,
                    decoration: const InputDecoration(
                      labelText: 'Skills required',
                      hintText: 'Comma-separated, e.g. Flutter, Dart, Firebase',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Application questions (optional)', style: AppTextStyles.subtitle),
                  const SizedBox(height: 4),
                  Text(
                    'Ask applicants anything you want answered up front — shown when a '
                    'student applies.',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < _questionControllers.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _questionControllers[i],
                              focusNode: _questionFocusNodes[i],
                              decoration: InputDecoration(labelText: 'Question ${i + 1}'),
                              validator: (v) => Validators.required(v, field: 'Question'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppColors.textSecondary),
                            onPressed: () => _removeQuestion(i),
                          ),
                        ],
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: _addQuestion,
                    icon: const Icon(Icons.add),
                    label: const Text('Add question'),
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
