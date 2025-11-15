class AppointmentModel {
  final int? id;
  final String numeroCita;
  final DateTime fechaCita;
  final String hora;
  final String cedulaPaciente;
  final String nombrePaciente;
  final String apellidoPaciente;
  final String observaciones;
  final String tipoCita;
  final String estado;
  final DateTime fechaRegistro;

  AppointmentModel({
    this.id,
    required this.numeroCita,
    required this.fechaCita,
    required this.hora,
    required this.cedulaPaciente,
    required this.nombrePaciente,
    required this.apellidoPaciente,
    required this.observaciones,
    required this.tipoCita,
    required this.estado,
    required this.fechaRegistro,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value, {DateTime? fallback}) {
      if (value == null) return fallback ?? DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? (fallback ?? DateTime.now());
    }

    return AppointmentModel(
      id: json['id_cita'] as int? ?? json['id'] as int?,
      numeroCita: json['numero_cita']?.toString() ?? json['numeroCita']?.toString() ?? '',
      fechaCita: parseDate(json['fecha_cita'] ?? json['fechaCita']),
      hora: json['hora']?.toString() ?? '',
      cedulaPaciente: json['cedula']?.toString() ?? json['cedulaPaciente']?.toString() ?? '',
      nombrePaciente: json['nombrePaciente']?.toString() ??
          json['nombre_paciente']?.toString() ??
          json['nombre']?.toString() ??
          '',
      apellidoPaciente: json['apellidoPaciente']?.toString() ??
          json['apellido_paciente']?.toString() ??
          json['apellido']?.toString() ??
          '',
      observaciones: json['observaciones']?.toString() ?? '',
      tipoCita: json['tipo_cita']?.toString() ?? json['tipoCita']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      fechaRegistro: parseDate(
        json['fecha_registro'] ?? json['fechaRegistro'],
        fallback: DateTime.now(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_cita': id,
      'numero_cita': numeroCita,
      'cedula': cedulaPaciente,
      'fecha_cita': fechaCita.toIso8601String(),
      'hora': hora,
      'observaciones': observaciones,
      'tipo_cita': tipoCita,
      'estado': estado,
      'fecha_registro': fechaRegistro.toIso8601String(),
    };
  }

  AppointmentModel copyWith({
    int? id,
    String? numeroCita,
    DateTime? fechaCita,
    String? hora,
    String? cedulaPaciente,
    String? nombrePaciente,
    String? apellidoPaciente,
    String? observaciones,
    String? tipoCita,
    String? estado,
    DateTime? fechaRegistro,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      numeroCita: numeroCita ?? this.numeroCita,
      fechaCita: fechaCita ?? this.fechaCita,
      hora: hora ?? this.hora,
      cedulaPaciente: cedulaPaciente ?? this.cedulaPaciente,
      nombrePaciente: nombrePaciente ?? this.nombrePaciente,
      apellidoPaciente: apellidoPaciente ?? this.apellidoPaciente,
      observaciones: observaciones ?? this.observaciones,
      tipoCita: tipoCita ?? this.tipoCita,
      estado: estado ?? this.estado,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }
}

