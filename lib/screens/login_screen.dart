//FUNCIONAMIENTO GENERAL:

//LoginScreen es la pantalla inicial de la app, donde el usuario 
//puede iniciar sesión o registrarse.

//Usa AnimatedSwitcher para alternar entre los dos 
//formularios con animación.

//DataService gestiona los datos (probablemente una
// lista en memoria o una base de datos local).

//Si el login es exitoso, se navega a HomeScreen 
//con Navigator.pushReplacement().

//Si el registro es correcto, se agrega el nuevo 
//usuario al sistema y se vuelve automáticamente al login.

//Se usan TextEditingController para leer los valores 
//ingresados por el usuario.

//Los SnackBar sirven para mostrar mensajes cortos 
//(errores o confirmaciones).





//importa el paquete base para construir interfaces en Flutter
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

//importa el servicio que maneja los datos de usuarios, login, etc
import '../services/data_service.dart';

//modelo de datos de los usuarios
import '../models/user_model.dart';
import '../theme/app_colors.dart';

//pantalla a la que se navega luego del login
import 'home_screen.dart';

//clase principal del login osea la pantalla de inicio sesion
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

//se maneja la logica y estado dinamico de la ui
class _LoginScreenState extends State<LoginScreen> {
  
  //estos son los controladores de textos
  //sirven para acceder y manipular el texto que del usuario
  //escribe en los textfields

  //para el login
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  //controladores para los campos del registro
  final _regCedulaController = TextEditingController();
  final _regNombreController = TextEditingController();
  final _regApellidoController = TextEditingController();
  final _regEmailController = TextEditingController();
  DateTime? _regFechaSeleccionada;
  String? _especializacionSeleccionada;
  final List<String> _especializaciones = const [
    'Medicina General',
    'Odontología',
    'Fisioterapia',
    'Pediatría',
    'Ginecología',
    'Nutrición',
  ];
  final _regTelefonoController = TextEditingController();
  final _regPasswordController = TextEditingController();

  // Variable para alternar entre login y registro y 
  //se maneja como una variable booleana
  bool mostrarRegistro = false;
  bool _isAuthenticating = false;
  bool _isRegistering = false;
  final ImagePicker _picker = ImagePicker();
  Uint8List? _regFotoPreview;
  String? _regFotoBase64;

  // Método para mostrar mensajes en pantalla
  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickRegisterPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _regFotoPreview = bytes;
      _regFotoBase64 = base64Encode(bytes);
    });
  }





  //funcion para que sirva el hp login
  Future<void> _login() async {
    final email = _loginEmailController.text.trim();//agarra datos de los controladores y quita espacios innecesaarios
    final password = _loginPasswordController.text.trim();


     //valida si los campos estan vacios
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Por favor llena todos los campos');
      return;}

    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);
    UserModel? user;
    try {
      user = await DataService.login(email, password);
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }

     //si encuentra un usuario valido
    if (!mounted) return;

    if (user != null) {
      _showSnackBar('Inicio de sesión exitoso');
      //permite el acceso a la pantalla principal home y reemplaza la actual del login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );

      //si el correo o contraseña no coinciden
    } else {
      _showSnackBar('Correo o contraseña incorrectos');
    }
  }//fin de la funcion login







  //funcion registro
  Future<void> _register() async {

    //esto debe agarrar los datos del formulario del formulario de
    //registro de nuevo usuario
    final cedula = _regCedulaController.text.trim();
    final nombre = _regNombreController.text.trim();
    final apellido = _regApellidoController.text.trim();
    final email = _regEmailController.text.trim();
    final fechaNacimiento = _regFechaSeleccionada;
    final especializacion = _especializacionSeleccionada;
    final telefono = _regTelefonoController.text.trim();
    final password = _regPasswordController.text.trim();
     

      // Valida y verifica si algún campo esta vacio
    if ([cedula, nombre, apellido, email, telefono, password].any((e) => e.isEmpty) ||
        fechaNacimiento == null ||
        especializacion == null) {
      _showSnackBar('Por favor complete todos los campos');
      return;
    }
    

     //crea un nuevo objeto de usuario
    final nuevoUsuario = UserModel(
      cedula: cedula,
      nombre: nombre,
      apellido: apellido,
      email: email,
      fechaNacimiento: fechaNacimiento,
      especializacion: especializacion,
      telefono: telefono,
      password: password,
      fotoBase64: _regFotoBase64,
    );
    
    setState(() => _isRegistering = true);
    final success = await DataService.registerUserRemote(nuevoUsuario);
    if (!mounted) return;
    setState(() => _isRegistering = false);

    if (success) {
      _showSnackBar('Usuario registrado correctamente');
      setState(() {
        mostrarRegistro = false;
      });
      _regCedulaController.clear();
      _regNombreController.clear();
      _regApellidoController.clear();
      _regTelefonoController.clear();
      _regEmailController.clear();
      _regFechaSeleccionada = null;
      _especializacionSeleccionada = null;
      _regPasswordController.clear();
      _regFotoPreview = null;
      _regFotoBase64 = null;
    } else {
      _showSnackBar('No se pudo registrar el usuario. Intenta nuevamente.');
    }
  }//fin del metodo de registro de nuevo usuario





  //aqui empezare el interfaz principal
  //en este apartado se contruyo el interfaz principal
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0B73FF);
    const Color overlayTop = Color.fromRGBO(255, 255, 255, 0.96);
    const Color overlayBottom = Color.fromRGBO(255, 255, 255, 0.9);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/imgs/fondoapp.png'),
            fit: BoxFit.cover,
          ),
        ),
          child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                overlayTop,
                overlayBottom,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: mostrarRegistro
                    ? _buildRegisterForm(primaryColor)
                    : _buildLoginForm(primaryColor),
              ),
            ),
          ),
        ),
      ),
    );
  }


  // formulario para el login
  Widget _buildLoginForm(Color primaryColor) {
    return SizedBox(
      key: const ValueKey('login'),
      width: 380,
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  Image.asset('lib/imgs/logomydoctor.png', height: 70),
                  const SizedBox(height: 16),
                  Text(
                    'Bienvenido a MY DOCTOR',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ingresa tus credenciales para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _loginEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: const Icon(Icons.alternate_email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _loginPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAuthenticating ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    _isAuthenticating ? 'Ingresando...' : 'Iniciar sesión',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => mostrarRegistro = true),
                child: const Text('¿No tienes cuenta? Regístrate aquí'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  

  //formulario para el registro
  Widget _buildRegisterForm(Color primaryColor) {
    return SizedBox(
      key: const ValueKey('register'),
      width: 420,
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
          child: Column(
            children: [
              Text(
                'Crea tu cuenta profesional',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          backgroundImage:
                              _regFotoPreview != null ? MemoryImage(_regFotoPreview!) : null,
                          child: _regFotoPreview == null
                              ? const Icon(Icons.person_add_alt_1, size: 40, color: AppColors.primary)
                              : null,
                        ),
                        TextButton.icon(
                          onPressed: _pickRegisterPhoto,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: Text(_regFotoBase64 == null ? 'Agregar foto (opcional)' : 'Cambiar foto'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _registroField(controller: _regCedulaController, label: 'Cédula', icon: Icons.badge_outlined),
                  const SizedBox(height: 12),
                  _registroField(controller: _regNombreController, label: 'Nombre', icon: Icons.person_outline),
                  const SizedBox(height: 12),
                  _registroField(controller: _regApellidoController, label: 'Apellido', icon: Icons.person),
                  const SizedBox(height: 12),
                  _registroField(
                      controller: _regTelefonoController,
                      label: 'Teléfono',
                      icon: Icons.call_outlined,
                      keyboard: TextInputType.phone),
                  const SizedBox(height: 12),
                  _registroField(
                      controller: _regEmailController,
                      label: 'Correo electrónico',
                      icon: Icons.alternate_email,
                      keyboard: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fecha de nacimiento', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _seleccionarFechaNacimiento,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _regFechaSeleccionada == null
                                    ? 'Selecciona una fecha'
                                    : DateFormat('dd/MM/yyyy').format(_regFechaSeleccionada!),
                              ),
                              const Icon(Icons.calendar_today, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Especialización',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    initialValue: _especializacionSeleccionada,
                    items: _especializaciones
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _especializacionSeleccionada = val),
                  ),
                  const SizedBox(height: 12),
                  _registroField(
                    controller: _regPasswordController,
                    label: 'Contraseña',
                    icon: Icons.lock_outline,
                    obscure: true,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isRegistering ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(_isRegistering ? 'Registrando...' : 'Completar registro'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => mostrarRegistro = false),
                child: const Text('¿Ya tienes cuenta? Inicia sesión aquí'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _registroField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Future<void> _seleccionarFechaNacimiento() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _regFechaSeleccionada ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime(DateTime.now().year - 18, 12, 31),
    );
    if (picked != null) {
      setState(() => _regFechaSeleccionada = picked);
    }
  }
}
