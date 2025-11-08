part of '../status_bar.dart';

class StatusBarCenterContent extends StatelessWidget {
  final ValueChanged<StatusBarAction> onAction;

  const StatusBarCenterContent({
    super.key,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [],
      ),
    );
  }
}
