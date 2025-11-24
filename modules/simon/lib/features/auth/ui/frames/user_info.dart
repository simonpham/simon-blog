import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simon/simon.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthViewModel model) => model.user);
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Spacing.d16,
        horizontal: Spacing.d16,
      ),
      width: Spacing.d12 * 6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleText(
            'Welcome ${user?.displayName ?? ''}',
          ),
          Spacing.v16,
          Spacing.v24,
          SizedBox(
            height: Spacing.d36,
            child: Button(
              variant: ButtonVariant.primary,
              padding: EdgeInsets.symmetric(
                vertical: Spacing.d4,
              ),
              label: 'Logout',
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
