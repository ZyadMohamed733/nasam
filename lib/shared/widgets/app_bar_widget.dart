import 'package:flutter/material.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/services/websocket_service.dart';

class NasamAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NasamAppBar({
    super.key,
    this.title,
    required this.wsService,
    this.showLeading = true,
    this.actions,
  });

  /// Optional: the design's auth screens carry a back affordance and no title.
  /// When present it is centred.
  final String? title;

  /// Injected rather than resolved from getIt inside build(), so the bar is
  /// testable with a fake socket.
  final WebSocketService wsService;

  final bool showLeading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(title!, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(width: AppSizes.p8),
          ],
          // Connection Status Indicator
          StreamBuilder<WsConnectionState>(
            stream: wsService.connectionState,
            initialData: WsConnectionState.disconnected,
            builder: (context, snapshot) {
              final state = snapshot.data ?? WsConnectionState.disconnected;
              return Tooltip(
                message: 'WebSocket: ${state.name.toUpperCase()}',
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _connectionColor(context, state),
                    boxShadow: [
                      BoxShadow(
                        color: _connectionColor(
                          context,
                          state,
                        ).withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      centerTitle: true,
      toolbarHeight: AppSizes.appBarHeight,
      elevation: 0.5,
      shadowColor: Theme.of(context).colorScheme.outline,
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: showLeading
          ? IconButton(
              icon: Icon(
                AppIcons.menu,
                size: AppIconSize.medium.value,
                color: context.semanticColors.iconPrimary,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            )
          : null,
      actions: actions,
    );
  }

  Color _connectionColor(BuildContext context, WsConnectionState state) {
    switch (state) {
      case WsConnectionState.connected:
        return context.semanticColors.successText;
      case WsConnectionState.connecting:
        return context.semanticColors.warningText;
      case WsConnectionState.disconnected:
      case WsConnectionState.error:
        return context.colorScheme.error;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);
}
