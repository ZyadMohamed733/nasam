import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/di/injection_container.dart';
import '../../core/services/websocket_service.dart';

class NasamAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NasamAppBar({
    super.key,
    required this.title,
    this.showLeading = true,
    this.actions,
  });

  final String title;
  final bool showLeading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    
    // Resolve the WebSocketService from DI
    final wsService = getIt<WebSocketService>();

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(width: AppSizes.p8),
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
                    color: _getConnectionColor(state),
                    boxShadow: [
                      BoxShadow(
                        color: _getConnectionColor(state).withValues(alpha: 0.4),
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
      elevation: 0.5,
      shadowColor: Theme.of(context).colorScheme.outline,
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: showLeading
          ? IconButton(
              icon: Icon(
                Icons.menu_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            )
          : null,
      actions: actions,
    );
  }

  Color _getConnectionColor(WsConnectionState state) {
    switch (state) {
      case WsConnectionState.connected:
        return AppColors.success;
      case WsConnectionState.connecting:
        return AppColors.warning;
      case WsConnectionState.disconnected:
      case WsConnectionState.error:
        return AppColors.error;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);
}
