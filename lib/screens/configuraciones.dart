import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/alert_helper.dart';
import '../../main.dart';
import '../l10n/app_localizations.dart';

class ConfiguracionesPage extends StatefulWidget {
  const ConfiguracionesPage({super.key});

  @override
  State<ConfiguracionesPage> createState() => _ConfiguracionesPageState();
}

class _ConfiguracionesPageState extends State<ConfiguracionesPage> {
  double _radio = 100; // Valor inicial
  bool _notificacionesActivas = true;
  bool _modoOscuro = true;
  String _idioma = 'es'; // español por defecto
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarConfiguraciones();
  }

  Future<void> _cargarConfiguraciones() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _radio = prefs.getDouble('radio_alerta') ?? 100;
      _notificacionesActivas = prefs.getBool('notificaciones') ?? true;
      _modoOscuro = prefs.getBool('modo_oscuro') ?? true;
      _idioma = prefs.getString('language') ?? 'es';
      darkModeNotifier.value = _modoOscuro;
      _cargando = false;
    });
  }

  Future<void> _guardarConfiguraciones() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('radio_alerta', _radio);
    await prefs.setBool('notificaciones', _notificacionesActivas);
    await prefs.setBool('modo_oscuro', _modoOscuro);
    await prefs.setString('language', _idioma);
    darkModeNotifier.value = _modoOscuro;
    localeNotifier.value = Locale(_idioma, '');

    if (mounted) {
      final theme = Theme.of(context);
      final dorado = theme.colorScheme.secondary;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: dorado,
          content: Text(
            l10n.settingsSaved,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      );
    }
  }

  void _cerrarSesion(BuildContext context) {
    final theme = Theme.of(context);
    final dorado = theme.colorScheme.secondary;
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(l10n.logout, style: TextStyle(color: dorado)),
        content: Text(
          l10n.logoutConfirm,
          style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel, style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: dorado),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.logoutSuccess)),
              );
            },
            child: Text(l10n.logout, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary
          )
        ),
      );
    }

    final theme = Theme.of(context);
    final dorado = theme.colorScheme.secondary;
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          l10n.settings,
          style: theme.appBarTheme.titleTextStyle ?? TextStyle(
            color: dorado, 
            fontWeight: FontWeight.bold
          )
        ),
        centerTitle: true,
        iconTheme: theme.appBarTheme.iconTheme ?? IconThemeData(color: dorado),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado del usuario
            Container(
              decoration: BoxDecoration(
                color: dorado.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage('android/assets/avatar.png'),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.user,
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color ?? Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      Text(
                        l10n.userEmail,
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.black54, 
                          fontSize: 14
                        )
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Tarjeta: Radio de alerta
            _buildCard(
              title: l10n.alertRadius,
              icon: Icons.radar,
              content: Column(
                children: [
                  Slider(
                    value: _radio,
                    min: 50,
                    max: 1000,
                    divisions: 19,
                    activeColor: dorado,
                    label: "${_radio.round()} m",
                    onChanged: (value) {
                      setState(() {
                        _radio = value;
                      });
                    },
                  ),
                  Text(
                    "${_radio.round()} ${l10n.meters}",
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color ?? Colors.black),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tarjeta: Notificaciones
            _buildCard(
              title: l10n.notifications,
              icon: Icons.notifications_active,
              content: SwitchListTile(
                activeThumbColor: dorado,
                activeTrackColor: dorado.withValues(alpha: 0.5),
                inactiveThumbColor: theme.brightness == Brightness.dark 
                    ? Colors.grey.shade400 
                    : Colors.grey.shade600,
                inactiveTrackColor: theme.brightness == Brightness.dark 
                    ? Colors.grey.shade700 
                    : Colors.grey.shade300,
                title: Text(
                  l10n.enableNotifications,
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color ?? Colors.black)
                ),
                value: _notificacionesActivas,
                onChanged: (value) async {
                  setState(() => _notificacionesActivas = value);
                  if (value) {
                    await AlertHelper.showInfoAlert(
                      'ZonAlert', 
                      l10n.notificationsEnabled
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.notificationsDisabled)),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            // Tarjeta: Modo oscuro
            _buildCard(
              title: l10n.darkMode,
              icon: Icons.dark_mode,
              content: SwitchListTile(
                activeThumbColor: dorado,
                activeTrackColor: dorado.withValues(alpha: 0.5),
                inactiveThumbColor: theme.brightness == Brightness.dark 
                    ? Colors.grey.shade400 
                    : Colors.grey.shade600,
                inactiveTrackColor: theme.brightness == Brightness.dark 
                    ? Colors.grey.shade700 
                    : Colors.grey.shade300,
                title: Text(
                  l10n.enableDarkMode, 
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color ?? Colors.black)
                ),
                value: _modoOscuro,
                onChanged: (value) {
                  setState(() {
                    _modoOscuro = value;
                    darkModeNotifier.value = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // Tarjeta: Idioma
            _buildCard(
              title: l10n.language,
              icon: Icons.language,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.selectLanguage,
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ?? Colors.black54,
                      fontSize: 14
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: _idioma,
                    isExpanded: true,
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color ?? Colors.black),
                    dropdownColor: theme.cardColor,
                    items: [
                      DropdownMenuItem(
                        value: 'es',
                        child: Row(
                          children: [
                            const Text('🇪🇸', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 10),
                            Text(l10n.spanish),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Row(
                          children: [
                            const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 10),
                            Text(l10n.english),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _idioma = value;
                          localeNotifier.value = Locale(value, '');
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Botones de acción
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _guardarConfiguraciones,
                    icon: const Icon(Icons.save),
                    label: Text(l10n.saveChanges),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dorado,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40, 
                        vertical: 15
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => _cerrarSesion(context),
                    icon: Icon(
                      Icons.logout, 
                      color: theme.textTheme.bodyMedium?.color ?? Colors.black
                    ),
                    label: Text(
                      l10n.logout,
                      style: TextStyle(color: theme.textTheme.bodyMedium?.color ?? Colors.black)
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: dorado, width: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40, 
                        vertical: 15
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    final theme = Theme.of(context);
    final dorado = theme.colorScheme.secondary;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: dorado),
              const SizedBox(width: 10),
              Text(title,
                  style: TextStyle(
                      color: dorado,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }
}
