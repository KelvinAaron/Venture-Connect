import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/role_card.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/auth/models/user_role.dart';

// for when users sign-up with google
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole _selectedRole = UserRole.student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final needsRole = state is AuthNeedsRoleSelection ? state : null;
            final isSubmitting = needsRole?.isSubmitting ?? false;
            final error = needsRole?.error;
            final name = needsRole?.name.trim() ?? '';

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name.isEmpty ? 'One more step' : 'Welcome, ${name.split(' ').first}',
                    style: AppTextStyles.headline,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tell us who you are so we can set up the right experience.',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: RoleCard(
                          label: 'Student',
                          description: 'Looking for internships',
                          icon: Icons.school_outlined,
                          selected: _selectedRole == UserRole.student,
                          onTap: () => setState(() => _selectedRole = UserRole.student),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RoleCard(
                          label: 'Startup',
                          description: 'Posting opportunities',
                          icon: Icons.rocket_launch_outlined,
                          selected: _selectedRole == UserRole.startup,
                          onTap: () => setState(() => _selectedRole = UserRole.startup),
                        ),
                      ),
                    ],
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error, style: const TextStyle(color: AppColors.error)),
                  ],
                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: 'Continue',
                    isLoading: isSubmitting,
                    onPressed: () => context.read<AuthBloc>().add(
                          AuthRoleSelectionSubmitted(_selectedRole),
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
