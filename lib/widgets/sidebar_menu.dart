import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../screens/citas_screen.dart';
import '../screens/configuracion_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/pagos_screen.dart';
import '../services/data_service.dart';
import '../theme/app_colors.dart';
import '../utils/image_utils.dart';

class SidebarMenu extends StatelessWidget {
  final bool isDrawer;
  const SidebarMenu({super.key, this.isDrawer = true});

  @override
  Widget build(BuildContext context) {
    final usuario = DataService.usuarioActual;
    final menuContent = _MenuContent(usuario: usuario);

    if (isDrawer) {
      return Drawer(
        elevation: 8,
        child: menuContent,
      );
    }

    return Drawer(
      elevation: 0,
      child: menuContent,
    );
  }
}

class _MenuContent extends StatelessWidget {
  final UserModel? usuario;
  const _MenuContent({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _Header(usuario: usuario),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _MenuTile(
                  icon: Icons.home_rounded,
                  label: 'Inicio',
                  onTap: () => _navigate(context, const HomeScreen()),
                ),
                _MenuTile(
                  icon: Icons.event_note_rounded,
                  label: 'Citas',
                  onTap: () => _navigate(context, const CitasScreen()),
                ),
                _MenuTile(
                  icon: Icons.payments_rounded,
                  label: 'Pagos',
                  onTap: () => _navigate(context, const PagosScreen()),
                ),
                _MenuTile(
                  icon: Icons.medical_information_rounded,
                  label: 'Historial clínico',
                  onTap: () => Navigator.pushNamed(context, '/historial_clinico'),
                ),
                const SizedBox(height: 8),
                const Divider(),
                _MenuTile(
                  icon: Icons.settings_rounded,
                  label: 'Configuración',
                  onTap: () {
                    if (usuario != null) {
                      _navigate(context, ConfiguracionScreen(usuario: usuario!));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No hay usuario logueado.')),
                      );
                    }
                  },
                ),
                _MenuTile(
                  icon: Icons.logout,
                  label: 'Cerrar sesión',
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.of(context).pop();
                    DataService.logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _Header extends StatelessWidget {
  final UserModel? usuario;
  const _Header({this.usuario});

  @override
  Widget build(BuildContext context) {
    final photoBytes = decodeBase64Image(usuario?.fotoBase64);
    final initials = usuario != null && usuario!.nombre.isNotEmpty && usuario!.apellido.isNotEmpty
        ? '${usuario!.nombre[0].toUpperCase()}${usuario!.apellido[0].toUpperCase()}'
        : 'MD';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(28),
          bottomLeft: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: Colors.white,
            backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
            child: photoBytes == null
                ? Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          const Text(
            'MYDOCTOR',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            usuario != null ? 'Dr. ${usuario!.nombre} ${usuario!.apellido}' : 'Sin usuario',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(label),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

