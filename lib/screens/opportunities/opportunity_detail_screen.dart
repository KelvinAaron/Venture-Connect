import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../features/applications/bloc/apply_cubit.dart';
import '../../features/applications/bloc/apply_state.dart';
import '../../features/applications/data/application_repository.dart';
import '../../features/applications/models/application_status.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/auth/models/user_role.dart';
import '../../features/opportunities/models/opportunity.dart';
import '../bookmarks/bookmark_button.dart';

class OpportunityDetailScreen extends StatelessWidget {
  final Opportunity opportunity;
  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isStudent = authState is AuthAuthenticated && authState.user.role == UserRole.student;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunity details'),
        actions: [
          if (isStudent) BookmarkButton(opportunityId: opportunity.id),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(opportunity.title, style: AppTextStyles.headline),
              const SizedBox(height: 4),
              Text(opportunity.startupName, style: AppTextStyles.bodyMuted),
              const SizedBox(height: 8),
              _Tag(opportunity.category),
              const SizedBox(height: 16),
              if (opportunity.commitment.isNotEmpty)
                _DetailRow(icon: Icons.schedule, label: '${opportunity.commitment} hrs/week'),
              if (opportunity.location.isNotEmpty)
                _DetailRow(icon: Icons.place_outlined, label: opportunity.location),
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Posted ${DateFormatter.relative(opportunity.createdAt)}',
              ),
              const SizedBox(height: 16),
              Text('About', style: AppTextStyles.subtitle),
              const SizedBox(height: 8),
              Text(opportunity.description, style: AppTextStyles.body),
              if (opportunity.skillsRequired.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Skills required', style: AppTextStyles.subtitle),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: opportunity.skillsRequired.map((s) => _Tag(s)).toList(),
                ),
              ],
              if (isStudent) ...[
                const SizedBox(height: 32),
                _ApplySection(
                  opportunity: opportunity,
                  studentUid: authState.user.uid,
                  studentName: authState.user.name,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplySection extends StatelessWidget {
  final Opportunity opportunity;
  final String studentUid;
  final String studentName;

  const _ApplySection({
    required this.opportunity,
    required this.studentUid,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ApplyCubit(
        ApplicationRepository(),
        opportunity: opportunity,
        studentUid: studentUid,
        studentName: studentName,
      ),
      child: _ApplySectionBody(questions: opportunity.customQuestions),
    );
  }
}

class _ApplySectionBody extends StatefulWidget {
  final List<String> questions;
  const _ApplySectionBody({required this.questions});

  @override
  State<_ApplySectionBody> createState() => _ApplySectionBodyState();
}

class _ApplySectionBodyState extends State<_ApplySectionBody> {
  final _formKey = GlobalKey<FormState>();
  late final List<TextEditingController> _answerControllers;

  @override
  void initState() {
    super.initState();
    _answerControllers = widget.questions.map((_) => TextEditingController()).toList();
  }

  @override
  void dispose() {
    for (final controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (widget.questions.isNotEmpty && !_formKey.currentState!.validate()) return;
    final answers = <String, String>{
      for (var i = 0; i < widget.questions.length; i++)
        widget.questions[i]: _answerControllers[i].text.trim(),
    };
    context.read<ApplyCubit>().apply(answers: answers);
  }

  (Color, Color) _statusColors(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return (AppColors.info, AppColors.infoBg);
      case ApplicationStatus.underReview:
        return (AppColors.warning, AppColors.warningBg);
      case ApplicationStatus.interview:
        return (AppColors.accent, AppColors.accentLight);
      case ApplicationStatus.accepted:
        return (AppColors.success, AppColors.successBg);
      case ApplicationStatus.rejected:
        return (AppColors.error, AppColors.errorBg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ApplyCubit, ApplyState>(
      listener: (context, state) {
        if (state is ApplyError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is ApplyLoading) {
          return const SizedBox(
            height: 52,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary),
              ),
            ),
          );
        }
        if (state is ApplyApplied) {
          final (fg, bg) = _statusColors(state.application.status);
          return Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              const Text('You applied — status:', style: AppTextStyles.body),
              const SizedBox(width: 8),
              StatusBadge(label: state.application.status.label, foreground: fg, background: bg),
            ],
          );
        }

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.questions.isNotEmpty) ...[
                Text('Application questions', style: AppTextStyles.subtitle),
                const SizedBox(height: 12),
                for (var i = 0; i < widget.questions.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: _answerControllers[i],
                      maxLines: 3,
                      decoration: InputDecoration(labelText: widget.questions[i]),
                      validator: (v) => Validators.required(v, field: 'This'),
                    ),
                  ),
              ],
              PrimaryButton(
                label: 'Apply now',
                isLoading: state is ApplyInProgress,
                onPressed: () => _submit(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(label, style: AppTextStyles.caption),
    );
  }
}
