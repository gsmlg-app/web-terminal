import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_session_bloc/web_session_bloc.dart';

/// A small status indicator for the web server.
class WebServerStatusIndicator extends StatelessWidget {
  /// Size of the indicator.
  final double size;

  const WebServerStatusIndicator({
    super.key,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WebSessionBloc, WebSessionState>(
      builder: (context, state) {
        final color = state.serverRunning ? Colors.green : Colors.grey;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: state.serverRunning
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}

/// A badge showing pending session count.
class PendingSessionsBadge extends StatelessWidget {
  final Widget child;

  const PendingSessionsBadge({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WebSessionBloc, WebSessionState>(
      builder: (context, state) {
        if (!state.hasPendingSessions) {
          return child;
        }

        return Badge(
          label: Text('${state.pendingSessions.length}'),
          child: child,
        );
      },
    );
  }
}
