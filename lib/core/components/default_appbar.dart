import 'package:flutter/material.dart';
import 'package:jusconnect/core/components/login_action_button.dart';

class DefaultAppbar extends StatelessWidget implements PreferredSizeWidget {
  final bool showActions;

  const DefaultAppbar({super.key, this.showActions = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        "JusConnect",
        style: TextStyle(fontWeight: .w900, fontSize: 24),
      ),
      centerTitle: true,
      shadowColor: Colors.black87,
      elevation: 4,
      actions: showActions ? [LoginActionButton()] : null,
      leading: Navigator.canPop(context) ? BackButton() : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
