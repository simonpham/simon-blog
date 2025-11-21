import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:simon/features/auth/view_models/auth_view_models.dart';

class LoginFrame extends StatefulWidget {
  const LoginFrame({
    super.key,
  });

  @override
  State<LoginFrame> createState() => _LoginFrameState();
}

class _LoginFrameState extends State<LoginFrame> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ValueNotifier<bool> _isPasswordVisibleNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Spacing.d16,
        horizontal: Spacing.d16,
      ),
      width: Spacing.d12 * 6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InputText(
            controller: _emailController,
            label: 'Username',
            keyboardType: TextInputType.emailAddress,
          ),
          Spacing.v16,
          ValueListenableBuilder<bool>(
            valueListenable: _isPasswordVisibleNotifier,
            builder: (context, isPasswordVisible, child) {
              return InputText(
                controller: _passwordController,
                label: 'Password',
                obscureText: !isPasswordVisible,
              );
            },
          ),
          Spacing.v24,
          Button(
            variant: ButtonVariant.primary,
            label: 'Login',
            onPressed: () => _handleLogin(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      context.toastError('Please enter username and password');
      return;
    }

    final model = context.read<AuthViewModel>();
    final failure = await model.login(email, password);

    if (failure is UnauthorizedFailure) {
      context.toastError('Invalid username or password');
      return;
    }

    if (failure != null) {
      context.toastError(failure.message);
      return;
    }

    context.toast('Login successful', type: MessageType.success);
    context.navigator.pop();
  }
}
