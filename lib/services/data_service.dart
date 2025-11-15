
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/appointment_model.dart';
import '../models/patient_model.dart';
import '../models/user_model.dart';

/// Servicio centralizado que ahora consume el backend Node + MySQL.
class DataService {
  static String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api', // reemplaza con la IP de tu PC al usar un celular real
  );

  static final http.Client _client = http.Client();
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };

  static final List<UserModel> _usuarios = [];
  static List<PatientModel> _pacientes = [];
  static List<AppointmentModel> _citas = [];
  static List<Map<String, dynamic>> _entidadesEps = [];
  static List<Map<String, dynamic>> _procedimientos = [];
  static UserModel? _usuarioActual;

  static Future<void> initialize() async {
    await Future.wait([
      _loadPacientes(),
      _loadCitas(),
      _loadCatalogos(),
    ]);
  }

  static Uri _uri(String path) => Uri.parse('$baseUrl$path');

  // --- Sesión ---
  static UserModel? get usuarioActual => _usuarioActual;

  static Future<UserModel?> login(String email, String password) async {
    try {
      final response = await _client.post(
        _uri('/auth/login'),
        headers: _jsonHeaders,
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = UserModel.fromJson(data, passwordFallback: password);
        _usuarioActual = user;
        return user;
      }
    } catch (error) {
      debugPrint('Error al iniciar sesión: $error');
    }

    // Fallback a la lista local por compatibilidad con el registro temporal.
    try {
      final user = _usuarios.firstWhere((u) => u.email == email && u.password == password);
      _usuarioActual = user;
      return user;
    } catch (_) {
      return null;
    }
  }

  static void logout() => _usuarioActual = null;

  static void actualizarUsuario(UserModel nuevoUsuario) {
    _usuarioActual = nuevoUsuario;
    final index = _usuarios.indexWhere((u) => u.cedula == nuevoUsuario.cedula);
    if (index != -1) {
      _usuarios[index] = nuevoUsuario;
    }
  }

  // Registro local (solo para demo)
  static List<UserModel> get usuarios => _usuarios;

  static Future<bool> registerUserRemote(UserModel user) async {
    try {
      final response = await _client.post(
        _uri('/users'),
        headers: _jsonHeaders,
        body: jsonEncode(user.toJson()),
      );
      if (response.statusCode == 201) {
        _usuarios.add(user);
        return true;
      } else {
        debugPrint('Error registrando usuario: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      debugPrint('Error registrando usuario: $error');
    }
    return false;
  }

  static Future<bool> updateUserRemote(UserModel user) async {
    try {
      final response = await _client.put(
        _uri('/users/${user.cedula}'),
        headers: _jsonHeaders,
        body: jsonEncode(user.toJson()),
      );
      if (response.statusCode == 200) {
        _usuarioActual = user;
        final index = _usuarios.indexWhere((u) => u.cedula == user.cedula);
        if (index != -1) {
          _usuarios[index] = user;
        }
        return true;
      } else {
        debugPrint('Error actualizando usuario: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      debugPrint('Error actualizando usuario: $error');
    }
    return false;
  }

  // --- Pacientes ---
  static List<PatientModel> get patients => _pacientes;
  static List<Map<String, dynamic>> get entidadesEps => _entidadesEps;
  static List<Map<String, dynamic>> get procedimientos => _procedimientos;

  static Future<void> refreshPatients() => _loadPacientes();

  static Future<void> _loadPacientes() async {
    try {
      final response = await _client.get(_uri('/pacientes'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _pacientes = data.map((json) => PatientModel.fromJson(json)).toList();
        _hydrateAppointmentsWithPatients();
      }
    } catch (error) {
      debugPrint('Error cargando pacientes: $error');
    }
  }

  static Future<bool> addPatient(PatientModel patient) async {
    try {
      final response = await _client.post(
        _uri('/pacientes'),
        headers: _jsonHeaders,
        body: jsonEncode(patient.toJson()),
      );
      if (response.statusCode == 201) {
        await _loadPacientes();
        return true;
      } else {
        debugPrint(
          'Error creando paciente: ${response.statusCode} ${response.body}',
        );
      }
    } catch (error) {
      debugPrint('Error creando paciente: $error');
    }
    return false;
  }

  static Future<bool> updatePatient(PatientModel updated) async {
    try {
      final response = await _client.put(
        _uri('/pacientes/${updated.cedula}'),
        headers: _jsonHeaders,
        body: jsonEncode(updated.toJson()),
      );
      if (response.statusCode == 200) {
        await _loadPacientes();
        return true;
      } else {
        debugPrint(
          'Error actualizando paciente: ${response.statusCode} ${response.body}',
        );
      }
    } catch (error) {
      debugPrint('Error actualizando paciente: $error');
    }
    return false;
  }

  static Future<bool> deletePatient(String cedula) async {
    try {
      final response = await _client.delete(_uri('/pacientes/$cedula'));
      if (response.statusCode == 200) {
        await _loadPacientes();
        return true;
      }
    } catch (error) {
      debugPrint('Error eliminando paciente: $error');
    }
    return false;
  }

  // --- Citas ---
  static List<AppointmentModel> get citas => _citas;

  static Future<void> refreshAppointments() => _loadCitas();

  static Future<void> _loadCitas() async {
    try {
      final response = await _client.get(_uri('/citas'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _citas = data.map((json) => AppointmentModel.fromJson(json)).toList();
        _hydrateAppointmentsWithPatients();
      }
    } catch (error) {
      debugPrint('Error cargando citas: $error');
    }
  }

  static Future<bool> addAppointment(AppointmentModel appointment) async {
    final payload = {
      'numero_cita': appointment.numeroCita,
      'cedula': appointment.cedulaPaciente,
      'fecha_cita': appointment.fechaCita.toIso8601String(),
      'hora': appointment.hora,
      'observaciones': appointment.observaciones,
      'tipo_cita': appointment.tipoCita,
      'estado': appointment.estado,
      'fecha_registro': appointment.fechaRegistro.toIso8601String(),
    };
    try {
      final response = await _client.post(
        _uri('/citas'),
        headers: _jsonHeaders,
        body: jsonEncode(payload),
      );
      if (response.statusCode == 201) {
        await _loadCitas();
        return true;
      }
    } catch (error) {
      debugPrint('Error creando cita: $error');
    }
    return false;
  }

  static Future<bool> updateAppointment(AppointmentModel updated) async {
    if (updated.id == null) return false;
    final payload = {
      'numero_cita': updated.numeroCita,
      'cedula': updated.cedulaPaciente,
      'fecha_cita': updated.fechaCita.toIso8601String(),
      'hora': updated.hora,
      'observaciones': updated.observaciones,
      'tipo_cita': updated.tipoCita,
      'estado': updated.estado,
      'fecha_registro': updated.fechaRegistro.toIso8601String(),
    };
    try {
      final response = await _client.put(
        _uri('/citas/${updated.id}'),
        headers: _jsonHeaders,
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        await _loadCitas();
        return true;
      }
    } catch (error) {
      debugPrint('Error actualizando cita: $error');
    }
    return false;
  }

  static Future<bool> deleteAppointment(AppointmentModel appointment) async {
    if (appointment.id == null) return false;
    try {
      final response = await _client.delete(_uri('/citas/${appointment.id}'));
      if (response.statusCode == 200) {
        await _loadCitas();
        return true;
      }
    } catch (error) {
      debugPrint('Error eliminando cita: $error');
    }
    return false;
  }

  static Future<bool> registrarPago({
    required String cedula,
    required double valorTotal,
    required String metodoPago,
    required String entidad,
    required DateTime fechaPago,
    int? idCita,
  }) async {
    final cedulaInt = int.tryParse(cedula);
    if (cedulaInt == null) return false;
    final payload = {
      'id_cita': idCita,
      'cedula': cedulaInt,
      'valor_total': valorTotal,
      'metodo_pago': metodoPago,
      'entidad': entidad,
      'fecha_pago': fechaPago.toIso8601String(),
    };
    try {
      final response = await _client.post(
        _uri('/pagos'),
        headers: _jsonHeaders,
        body: jsonEncode(payload),
      );
      if (response.statusCode == 201) {
        await _loadPacientes();
        return true;
      }
    } catch (error) {
      debugPrint('Error registrando pago: $error');
    }
    return false;
  }

  static void _hydrateAppointmentsWithPatients() {
    if (_pacientes.isEmpty || _citas.isEmpty) return;
    final Map<String, PatientModel> pacientesMap = {
      for (final p in _pacientes) p.cedula: p,
    };
    _citas = _citas
        .map((cita) {
          final paciente = pacientesMap[cita.cedulaPaciente];
          if (paciente == null) return cita;
          return cita.copyWith(
            nombrePaciente: paciente.nombre,
            apellidoPaciente: paciente.apellido,
          );
        })
        .toList();
  }

  // --- Historial local (mantiene el comportamiento anterior) ---
  static List<Map<String, dynamic>> historiales = [];

  static void addHistorial(Map<String, dynamic> historial) {
    historiales.add(historial);
  }

  static Future<void> _loadCatalogos() async {
    try {
      final epsRes = await _client.get(_uri('/catalogos/eps'));
      if (epsRes.statusCode == 200) {
        _entidadesEps = List<Map<String, dynamic>>.from(jsonDecode(epsRes.body));
      }
      final procRes = await _client.get(_uri('/catalogos/procedimientos'));
      if (procRes.statusCode == 200) {
        _procedimientos = List<Map<String, dynamic>>.from(jsonDecode(procRes.body));
      }
    } catch (error) {
      debugPrint('Error cargando catálogos: $error');
    }
  }

  static PatientModel? buscarPacientePorCedula(String cedula) {
    try {
      return _pacientes.firstWhere((p) => p.cedula == cedula);
    } catch (_) {
      return null;
    }
  }

  static String generarNumeroCitaLocal() {
    if (_citas.isEmpty) return '1';
    final numeros = _citas
        .map((c) => int.tryParse(c.numeroCita))
        .where((value) => value != null)
        .cast<int>()
        .toList();
    if (numeros.isEmpty) return '1';
    numeros.sort();
    return (numeros.last + 1).toString();
  }

}

 
 
 