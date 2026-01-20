import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';

/// Dialog for selecting an SSH host to connect to.
///
/// Shows a list of configured SSH hosts from the database.
/// Returns the selected [SshHost] or null if cancelled.
class SshHostSelector extends StatefulWidget {
  const SshHostSelector({super.key});

  /// Shows the SSH host selector dialog and returns the selected host.
  static Future<SshHost?> show(BuildContext context) async {
    return showDialog<SshHost>(
      context: context,
      builder: (context) => const SshHostSelector(),
    );
  }

  @override
  State<SshHostSelector> createState() => _SshHostSelectorState();
}

class _SshHostSelectorState extends State<SshHostSelector> {
  @override
  void initState() {
    super.initState();
    // Load SSH hosts if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<SshHostBloc>().state;
      if (state is! SshHostLoaded) {
        context.read<SshHostBloc>().add(SshHostLoad());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select SSH Host'),
      content: SizedBox(
        width: double.maxFinite,
        child: BlocBuilder<SshHostBloc, SshHostState>(
          builder: (context, state) {
            if (state is SshHostInitial) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is SshHostError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load SSH hosts',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(state.error.toString()),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<SshHostBloc>().add(SshHostLoad());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final hosts = (state as SshHostLoaded).sshHosts;

            if (hosts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dns_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No SSH hosts configured',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('Add SSH hosts in Settings > SSH Host Management'),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: hosts.length,
              itemBuilder: (context, index) {
                final host = hosts[index];
                return ListTile(
                  leading: const Icon(Icons.dns),
                  title: Text(host.host ?? host.hostname ?? 'SSH Host'),
                  subtitle: Text(
                    '${host.username ?? 'user'}@${host.hostname ?? 'unknown'}:${host.port ?? 22}',
                  ),
                  onTap: () => Navigator.of(context).pop(host),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
