
//definicion de la clase UserModel que representa a un doctor o usuario del sistema
class UserModel {
  final String cedula;
  final String nombre;
  final String apellido;
  final String email;
  final DateTime fechaNacimiento;
  final String especializacion;
  final String telefono;
  final String password;
  final String? fotoBase64;

//constructor de la clase
//el uso de required hace que todos los campos sean obligatorios al crear una instancia
  UserModel({
    required this.cedula,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.fechaNacimiento,
    required this.especializacion,
    required this.telefono,
    required this.password,
    this.fotoBase64,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json, {
    String passwordFallback = '',
  }) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return UserModel(
      cedula: json['cedula']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fechaNacimiento: parseDate(json['fecha_nacimiento'] ?? json['fechaNacimiento']),
      especializacion: json['especializacion']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      password: passwordFallback,
      fotoBase64: json['foto_base64'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cedula': cedula,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'especializacion': especializacion,
      'telefono': telefono,
      'password': password,
      'foto_base64': fotoBase64,
    };
  }

  UserModel copyWith({
    String? nombre,
    String? apellido,
    String? email,
    DateTime? fechaNacimiento,
    String? especializacion,
    String? telefono,
    String? password,
    String? fotoBase64,
  }) {
    return UserModel(
      cedula: cedula,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      especializacion: especializacion ?? this.especializacion,
      telefono: telefono ?? this.telefono,
      password: password ?? this.password,
      fotoBase64: fotoBase64 ?? this.fotoBase64,
    );
  }
}

