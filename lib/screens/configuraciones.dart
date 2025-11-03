import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/alert_helper.dart';

class ConfiguracionesPage extends StatefulWidget {
  const ConfiguracionesPage({super.key});

  @override
  State<ConfiguracionesPage> createState() => _ConfiguracionesPageState();
}

class _ConfiguracionesPageState extends State<ConfiguracionesPage> {
  double _radio = 100; // Valor inicial
  bool _notificacionesActivas = true;
  bool _modoOscuro = false;
  bool _cargando = true;

  final Color azulOscuro = const Color(0xFF142535);
  final Color dorado = const Color(0xFFE9AE5D);
  final Color blanco = Colors.white;

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
      _modoOscuro = prefs.getBool('modo_oscuro') ?? false;
      _cargando = false;
    });
  }

  Future<void> _guardarConfiguraciones() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('radio_alerta', _radio);
    await prefs.setBool('notificaciones', _notificacionesActivas);
    await prefs.setBool('modo_oscuro', _modoOscuro);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: dorado,
          content: const Text(
            'Configuraciones guardadas ✅',
            style: TextStyle(color: Colors.black87),
          ),
        ),
      );
    }
  }

  void _cerrarSesion() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: azulOscuro,
        title: Text("Cerrar sesión", style: TextStyle(color: dorado)),
        content: const Text(
          "¿Seguro que deseas cerrar sesión?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: dorado),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sesión cerrada exitosamente.")),
              );
            },
            child: const Text("Cerrar sesión", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    return Scaffold(
      backgroundColor: azulOscuro,
      appBar: AppBar(
        backgroundColor: azulOscuro,
        elevation: 0,
        title: Text('Configuraciones',
            style: TextStyle(color: dorado, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: IconThemeData(color: dorado),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado del usuario
            Container(
              decoration: BoxDecoration(
                color: dorado.withOpacity(0.1),
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
                    children: const [
                      Text("Usuario ZonAlert",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      Text("usuario@correo.com",
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Tarjeta: Radio de alerta
            _buildCard(
              title: "Radio de alerta",
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
                    "${_radio.round()} metros",
                    style: TextStyle(color: blanco),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tarjeta: Notificaciones
            _buildCard(
              title: "Notificaciones",
              icon: Icons.notifications_active,
              content: SwitchListTile(
                activeColor: dorado,
                title: const Text("Activar notificaciones",
                    style: TextStyle(color: Colors.white)),
                value: _notificacionesActivas,
                onChanged: (value) async {
                  setState(() => _notificacionesActivas = value);
                  if (value) {
                    await AlertHelper.showInfoAlert(
                        'ZonAlert', 'Notificaciones activadas correctamente');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notificaciones desactivadas')),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            // Tarjeta: Modo oscuro
            _buildCard(
              title: "Modo oscuro",
              icon: Icons.dark_mode,
              content: SwitchListTile(
                activeColor: dorado,
                title:
                    const Text("Activar modo oscuro", style: TextStyle(color: Colors.white)),
                value: _modoOscuro,
                onChanged: (value) {
                  setState(() => _modoOscuro = value);
                },
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
                    label: const Text('Guardar cambios'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dorado,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _cerrarSesion,
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text('Cerrar sesión',
                        style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: dorado, width: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C3C50),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
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
