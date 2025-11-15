import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/patient_model.dart';

Future<void> exportPatientsToCsvImpl(List<PatientModel> patients) async {
  final headers = [
    'Cédula',
    'Nombre',
    'Apellido',
    'Teléfono',
    'Correo',
    'Fecha Nacimiento',
    'Entidad',
    'Procedimiento',
    'Motivo Consulta',
    'Fecha Atención',
    'Estado Pago',
    'Método Pago',
  ];

  final df = DateFormat('yyyy-MM-dd');
  final rows = [
    headers,
    ...patients.map(
      (p) => [
        p.cedula,
        p.nombre,
        p.apellido,
        p.telefono,
        p.email,
        df.format(p.fechaNacimiento),
        p.entidad ?? '',
        p.procedimiento ?? '',
        p.motivoConsulta,
        p.fechaAtencion != null ? df.format(p.fechaAtencion!) : '',
        p.estadoPago ?? 'Pendiente',
        p.metodoPago ?? '',
      ],
    ),
  ];

  final csv = const ListToCsvConverter(
    fieldDelimiter: ';',
    textDelimiter: '"',
    eol: '\n',
  ).convert(rows);

  final file = XFile.fromData(
    utf8.encode(csv),
    name: 'reporte_pacientes.csv',
    mimeType: 'text/csv',
  );

  await Share.shareXFiles(
    [file],
    subject: 'Reporte de pacientes',
    text: 'Adjunto encontrarás el reporte de pacientes.',
  );
}

Future<void> exportPatientsToPdfImpl(List<PatientModel> patients) async {
  final pdf = pw.Document();
  final df = DateFormat('yyyy-MM-dd');

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      build: (context) => [
        pw.Text(
          'Reporte de Pacientes',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Table.fromTextArray(
          headers: [
            'Cédula',
            'Nombre',
            'Apellido',
            'Teléfono',
            'Correo',
            'Fecha Nac.',
            'Entidad',
            'Procedimiento',
            'Motivo Consulta',
            'Fecha Atención',
            'Estado Pago',
          ],
          data: patients.map((p) {
            return [
              p.cedula,
              p.nombre,
              p.apellido,
              p.telefono,
              p.email,
              df.format(p.fechaNacimiento),
              p.entidad ?? '',
              p.procedimiento ?? '',
              p.motivoConsulta,
              p.fechaAtencion != null ? df.format(p.fechaAtencion!) : '',
              p.estadoPago ?? 'Pendiente',
            ];
          }).toList(),
        ),
      ],
    ),
  );

  final bytes = await pdf.save();
  await Printing.sharePdf(bytes: bytes, filename: 'reporte_pacientes.pdf');
}

