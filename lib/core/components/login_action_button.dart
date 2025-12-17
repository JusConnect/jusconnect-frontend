import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jusconnect/features/auth/presentation/providers/auth_provider.dart';
import 'package:jusconnect/features/auth/presentation/providers/auth_state.dart';
import 'package:jusconnect/features/auth/presentation/widgets/login_button.widget.dart';
import 'package:jusconnect/shared/themes/light_theme.dart';

class LoginActionButton extends ConsumerWidget {
  const LoginActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(authProvider);

    if (loginState is AuthLoadingState) {
      return loadingIndicator;
    }

    if (loginState is AuthSuccessState) {
      return authenticatedIcon(context);
    }

    return loginButton(ref);
  }

  Widget loginButton(WidgetRef ref) => LoginButton();

  Widget get loadingIndicator => Center(
    child: Padding(
      padding: const .all(10),
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: AppColors.accentColor,
          strokeWidth: 2,
        ),
      ),
    ),
  );

  Widget authenticatedIcon(BuildContext context) => Center(
    child: InkWell(
      onTap: () => Navigator.pushNamed(context, '/profile'),
      child: Padding(
        padding: const .all(10),
        child: const CircleAvatar(
          backgroundImage: NetworkImage(
            'https://avatars.githubusercontent.com/u/96757198',
          ),
        ),
      ),
    ),
  );
}
