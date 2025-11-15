class PatientModel {
  final String cedula;
  final String nombre;
  final String apellido;
  final String telefono;
  final String email;
  final DateTime fechaNacimiento;
  final String motivoConsulta;
  final String? entidad;
  final int? entidadId;
  final String? procedimiento;
  final DateTime? fechaAtencion;
  final String? estadoPago;
  final String? metodoPago;
  final DateTime? fechaPago;

  const PatientModel({
    required this.cedula,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.email,
    required this.fechaNacimiento,
    required this.motivoConsulta,
    this.entidad,
    this.entidadId,
    this.procedimiento,
    this.fechaAtencion,
    this.estadoPago,
    this.metodoPago,
    this.fechaPago,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    return PatientModel(
      cedula: json['cedula']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      email: json['correo']?.toString() ?? json['email']?.toString() ?? '',
      fechaNacimiento:
          parseDate(json['fecha_nacimiento'] ?? json['fechaNacimiento']) ?? DateTime.now(),
      motivoConsulta: json['motivo_consulta']?.toString() ?? '',
      entidad: json['entidad']?.toString(),
      entidadId: json['entidad_eps_id'] as int? ??
          (json['entidad_eps_id'] != null
              ? int.tryParse(json['entidad_eps_id'].toString())
              : null),
      procedimiento: json['procedimiento']?.toString(),
      fechaAtencion: parseDate(json['fecha_atencion'] ?? json['fechaAtencion']),
      estadoPago: json['estado_pago']?.toString(),
      metodoPago: json['metodo_pago']?.toString(),
      fechaPago: parseDate(json['fecha_pago'] ?? json['fechaPago']),
    );
  }

  Map<String, dynamic> toJson() {
    final cedulaEntero = int.tryParse(cedula);
    final telefonoEntero = int.tryParse(telefono);
    return {
      'cedula': cedulaEntero ?? cedula,
      'tipo_doc': 'CC',
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefonoEntero ?? telefono,
      'correo': email,
      'estado': 'Activo',
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'motivo_consulta': motivoConsulta,
      'entidad_eps_id': entidadId,
      'procedimiento': procedimiento,
      'fecha_atencion': fechaAtencion?.toIso8601String(),
      'estado_pago': estadoPago,
      'metodo_pago': metodoPago,
      'fecha_pago': fechaPago?.toIso8601String(),
    };
  }

  PatientModel copyWith({
    String? cedula,
    String? nombre,
    String? apellido,
    String? telefono,
    String? email,
    DateTime? fechaNacimiento,
    String? motivoConsulta,
    String? entidad,
    int? entidadId,
    String? procedimiento,
    DateTime? fechaAtencion,
    String? estadoPago,
    String? metodoPago,
    DateTime? fechaPago,
  }) {
    return PatientModel(
      cedula: cedula ?? this.cedula,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      motivoConsulta: motivoConsulta ?? this.motivoConsulta,
      entidad: entidad ?? this.entidad,
      entidadId: entidadId ?? this.entidadId,
      procedimiento: procedimiento ?? this.procedimiento,
      fechaAtencion: fechaAtencion ?? this.fechaAtencion,
      estadoPago: estadoPago ?? this.estadoPago,
      metodoPago: metodoPago ?? this.metodoPago,
      fechaPago: fechaPago ?? this.fechaPago,
    );
  }
}

