part of '../status_bar.dart';

class StatusBarRightContent extends StatelessWidget {
  const StatusBarRightContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        PostStatusWidget(),
      ],
    );
  }
}
