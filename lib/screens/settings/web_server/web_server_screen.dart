import 'package:app_adaptive_widgets/app_adaptive_widgets.dart';
import 'package:app_locale/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terminal_settings/terminal_settings.dart';
import 'package:web_terminal/destinations.dart';
import 'package:web_terminal/screens/settings/_setting_config.dart';
import 'package:web_terminal/screens/settings/settings_screen.dart';

/// Screen for managing web server settings.
class WebServerScreen extends StatefulWidget {
  static const name = 'web-server';
  static const path = 'web-server';

  const WebServerScreen({super.key});

  @override
  State<WebServerScreen> createState() => _WebServerScreenState();
}

class _WebServerScreenState extends State<WebServerScreen> {
  static const String _listenIpKey = 'web_server_listen_ip';
  static const String _portKey = 'web_server_port';
  static const String _sslKey = 'web_server_ssl';

  bool _loaded = false;
  String _listenIp = '127.0.0.1';
  int _port = 8080;
  bool _useSsl = false;

  SharedPreferences get _prefs => context.read<SharedPreferences>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _listenIp = _prefs.getString(_listenIpKey) ?? '127.0.0.1';
    _port = _prefs.getInt(_portKey) ?? 8080;
    _useSsl = _prefs.getBool(_sslKey) ?? false;
    _loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    const String title = 'Web Server';

    return AppAdaptiveScaffold(
      selectedIndex: Destinations.indexOf(
        const Key(SettingsScreen.name),
        context,
      ),
      destinations: Destinations.navs(context),
      onSelectedIndexChange: (idx) => Destinations.changeHandler(idx, context),
      body: (context) => SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverAppBar(title: Text(title)),
            SliverFillRemaining(
              child: SettingsList(sections: [_buildConfigSection(context)]),
            ),
          ],
        ),
      ),
      largeBody: (context) => const SafeArea(
        child: RootSettingList(config: rootSettingListConfig),
      ),
      largeSecondaryBody: (context) => SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverAppBar(
              title: Text(title),
              automaticallyImplyLeading: false,
            ),
            SliverFillRemaining(
              child: SettingsList(sections: [_buildConfigSection(context)]),
            ),
          ],
        ),
      ),
    );
  }

  SettingsSection _buildConfigSection(BuildContext context) {
    return SettingsSection(
      title: const Text('Configuration'),
      tiles: <SettingsTile>[
        SettingsTile.navigation(
          leading: const Icon(Icons.settings_ethernet),
          title: const Text('Listen IP'),
          value: Text(_listenIp),
          onPressed: (_) => _editListenIp(context),
        ),
        SettingsTile.navigation(
          leading: const Icon(Icons.numbers),
          title: const Text('Port'),
          value: Text('$_port'),
          onPressed: (_) => _editPort(context),
        ),
        SettingsTile.switchTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('Use SSL'),
          description: const Text('Enable HTTPS for web clients'),
          initialValue: _useSsl,
          onToggle: (value) {
            _prefs.setBool(_sslKey, value);
            setState(() {
              _useSsl = value;
            });
          },
        ),
      ],
    );
  }

  Future<void> _editListenIp(BuildContext context) async {
    final controller = TextEditingController(text: _listenIp);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Listen IP'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '127.0.0.1'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.close),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) {
      return;
    }

    _prefs.setString(_listenIpKey, result);
    setState(() {
      _listenIp = result;
    });
  }

  Future<void> _editPort(BuildContext context) async {
    final controller = TextEditingController(text: '$_port');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Port'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '8080'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.close),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );

    if (result == null) {
      return;
    }

    final value = int.tryParse(result);
    if (value == null || value <= 0) {
      return;
    }

    _prefs.setInt(_portKey, value);
    setState(() {
      _port = value;
    });
  }
}
