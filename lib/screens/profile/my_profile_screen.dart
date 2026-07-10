import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/initials_avatar.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/primary_button.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/profile_cubit.dart';
import '../../features/auth/bloc/profile_state.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/models/app_user.dart';

/// Body-only widget embedded by StudentHomeScreen's "Profile" tab.
class MyProfileView extends StatelessWidget {
  final String uid;
  const MyProfileView({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(AuthRepository(), uid: uid),
      child: const _MyProfileBody(),
    );
  }
}

class _MyProfileBody extends StatefulWidget {
  const _MyProfileBody();

  @override
  State<_MyProfileBody> createState() => _MyProfileBodyState();
}

class _MyProfileBodyState extends State<_MyProfileBody> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();
  final _interestsController = TextEditingController();
  bool _hydrated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  void _hydrate(AppUser user) {
    if (_hydrated) return;
    _hydrated = true;
    _nameController.text = user.name;
    _bioController.text = user.bio;
    _skillsController.text = user.skills.join(', ');
    _interestsController.text = user.interests.join(', ');
  }

  List<String> _parseList(String text) =>
      text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileCubit>().save(
          name: _nameController.text.trim(),
          skills: _parseList(_skillsController.text),
          interests: _parseList(_interestsController.text),
          bio: _bioController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        final user = state.user;
        if (state.isLoading || user == null) return const LoadingView();
        _hydrate(user);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: InitialsAvatar(name: user.name, radius: 36)),
                const SizedBox(height: 8),
                Center(child: Text(user.email, style: AppTextStyles.bodyMuted)),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (v) => Validators.required(v, field: 'Name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'About you'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _skillsController,
                  decoration: const InputDecoration(
                    labelText: 'Skills',
                    hintText: 'Comma-separated, e.g. Flutter, UX Design',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _interestsController,
                  decoration: const InputDecoration(
                    labelText: 'Interests',
                    hintText: 'Comma-separated, e.g. Fintech, Climate',
                  ),
                ),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Save changes', isLoading: state.isSaving, onPressed: _save),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
                    icon: const Icon(Icons.logout),
                    label: const Text('Log out'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
