import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../utils/image_utils.dart';

class UserProfileButton extends StatelessWidget {
  const UserProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = DataService.usuarioActual;

    final photoBytes = decodeBase64Image(usuario?.fotoBase64);
    final initials = usuario != null && usuario.nombre.isNotEmpty && usuario.apellido.isNotEmpty
        ? '${usuario.nombre[0].toUpperCase()}${usuario.apellido[0].toUpperCase()}'
        : '?';

    return PopupMenuButton<int>(
      tooltip: 'Ver datos del usuario',
      position: PopupMenuPosition.under, // se abre debajo del icono
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) {
        if (usuario == null) {
          return [
            const PopupMenuItem(
              child: Text('No hay usuario logueado'),
            ),
          ];
        }
        return [
          PopupMenuItem(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre: ${usuario.nombre} ${usuario.apellido}'),
                Text('Correo: ${usuario.email}'),
                Text('Telefono: ${usuario.telefono}'),
                Text('Cédula: ${usuario.cedula}'),
                Text('Especialización: ${usuario.especializacion}'),
                Text(
                  'Nacimiento: ${usuario.fechaNacimiento.day}/${usuario.fechaNacimiento.month}/${usuario.fechaNacimiento.year}',
                ),
              ],
            ),
          ),
        ];
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.blue,
          backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
          child: photoBytes == null
              ? Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
