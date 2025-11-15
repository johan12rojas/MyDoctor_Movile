import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';
import '../services/data_service.dart';
import '../theme/app_colors.dart';
import '../utils/image_utils.dart';
import '../widgets/app_background.dart';
import '../widgets/sidebar_menu.dart';
import '../widgets/user_profile_button.dart';

class ConfiguracionScreen extends StatefulWidget {
  final UserModel usuario;

  const ConfiguracionScreen({super.key, required this.usuario});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  late TextEditingController nombreCtrl;
  late TextEditingController apellidoCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController cedulaCtrl;
  late TextEditingController especializacionCtrl;
  late TextEditingController telefonoCtrl;
  late TextEditingController passwordCtrl;
  DateTime? fechaNacimiento;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _fotoPreview;
  String? _fotoBase64;

  @override
  void initState() {
    super.initState();
    final user = widget.usuario;
    nombreCtrl = TextEditingController(text: user.nombre);
    apellidoCtrl = TextEditingController(text: user.apellido);
    emailCtrl = TextEditingController(text: user.email);
    cedulaCtrl = TextEditingController(text: user.cedula);
    especializacionCtrl = TextEditingController(text: user.especializacion);
    telefonoCtrl = TextEditingController(text: user.telefono);
    passwordCtrl = TextEditingController(text: user.password);
    fechaNacimiento = user.fechaNacimiento;
    _fotoBase64 = user.fotoBase64;
    _fotoPreview = decodeBase64Image(user.fotoBase64);
  }

  Future<void> guardarCambios() async {
    if (nombreCtrl.text.isEmpty ||
        apellidoCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        cedulaCtrl.text.isEmpty ||
        especializacionCtrl.text.isEmpty ||
        telefonoCtrl.text.isEmpty ||
        passwordCtrl.text.isEmpty ||
        fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    final nuevoUsuario = UserModel(
      cedula: cedulaCtrl.text,
      nombre: nombreCtrl.text,
      apellido: apellidoCtrl.text,
      email: emailCtrl.text,
      fechaNacimiento: fechaNacimiento!,
      especializacion: especializacionCtrl.text,
      telefono: telefonoCtrl.text,
      password: passwordCtrl.text,
      fotoBase64: _fotoBase64,
    );

    setState(() => _isSaving = true);
    final success = await DataService.updateUserRemote(nuevoUsuario);
    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Datos actualizados correctamente' : 'No se pudieron guardar los cambios',
        ),
        backgroundColor: success ? Colors.green : Colors.redAccent,
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _fotoPreview = bytes;
      _fotoBase64 = base64Encode(bytes);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1100;
    return Scaffold(
      drawer: isWide ? null : const SidebarMenu(),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Image.asset('lib/imgs/logomydoctor.png', height: 28),
            const SizedBox(width: 10),
            const Text('Configuración de Usuario'),
          ],
        ),
        actions: const [UserProfileButton()],
      ),
      body: AppBackground(
        child: Row(
          children: [
            if (isWide)
              const SizedBox(width: 260, child: SidebarMenu(isDrawer: false)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Container(
                    width: 600,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const Text(
                            'Editar información personal',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            backgroundImage: _fotoPreview != null ? MemoryImage(_fotoPreview!) : null,
                            child: _fotoPreview == null
                                ? const Icon(Icons.person_outline, size: 46, color: AppColors.primary)
                                : null,
                          ),
                          TextButton.icon(
                            onPressed: _pickPhoto,
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: Text(_fotoBase64 == null ? 'Agregar foto (opcional)' : 'Cambiar foto'),
                          ),
                          const SizedBox(height: 10),
                          _campo('Nombre', nombreCtrl),
                          _campo('Apellido', apellidoCtrl),
                          _campo('Correo electrónico', emailCtrl),
                          _campo('Cédula', cedulaCtrl, enabled: false),
                          _campo('Especialización', especializacionCtrl),
                          _campo('Teléfono', telefonoCtrl),
                          _campo('Contraseña', passwordCtrl, obscure: true),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                fechaNacimiento == null
                                    ? 'Fecha de nacimiento: no seleccionada'
                                    : 'Fecha de nacimiento: ${fechaNacimiento!.day}/${fechaNacimiento!.month}/${fechaNacimiento!.year}',
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: fechaNacimiento ?? DateTime(1990, 1, 1),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedDate != null) {
                                    setState(() => fechaNacimiento = pickedDate);
                                  }
                                },
                                child: const Text('Cambiar'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(_isSaving ? 'Guardando...' : 'Guardar cambios'),
                              onPressed: _isSaving ? null : guardarCambios,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController ctrl,
      {bool obscure = false, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.blue.shade50,
        ),
      ),
    );
  }
}
