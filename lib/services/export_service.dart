import '../models/patient_model.dart';
import 'export_service_stub.dart'
    if (dart.library.html) 'export_service_web.dart'
    if (dart.library.io) 'export_service_io.dart';

/// API única para exportar pacientes aunque la implementación dependa
/// de la plataforma (web vs. móvil/escritorio).
class ExportService {
  static Future<void> exportPatientsToCsv(List<PatientModel> patients) =>
      exportPatientsToCsvImpl(patients);

  static Future<void> exportPatientsToPdf(List<PatientModel> patients) =>
      exportPatientsToPdfImpl(patients);
}
