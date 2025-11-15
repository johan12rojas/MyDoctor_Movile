import 'dart:html' as html;
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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
    'Estado Pago'
  ];

  final data = [
    headers,
    ...patients.map((p) => [
          p.cedula,
          p.nombre,
          p.apellido,
          p.telefono,
          p.email,
          DateFormat('yyyy-MM-dd').format(p.fechaNacimiento),
          p.entidad ?? '',
          p.procedimiento ?? '',
          p.motivoConsulta,
          p.fechaAtencion != null
              ? DateFormat('yyyy-MM-dd').format(p.fechaAtencion!)
              : '',
          p.estadoPago ?? 'Pendiente',
        ])
  ];

  final csv = const ListToCsvConverter(
    fieldDelimiter: ';',
    textDelimiter: '"',
    eol: '\n',
  ).convert(data);

  final bytes = Uint8List.fromList(csv.codeUnits);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'reporte_pacientes.csv')
    ..click();
  html.Url.revokeObjectUrl(url);
}

Future<void> exportPatientsToPdfImpl(List<PatientModel> patients) async {
  final pdf = pw.Document();
  final df = DateFormat('yyyy-MM-dd');

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      build: (context) => [
        pw.Center(
          child: pw.Text(
            'Reporte de Pacientes',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Table.fromTextArray(
          headers: const [
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
            'Estado Pago'
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
          cellAlignment: pw.Alignment.center,
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
        ),
      ],
    ),
  );

  final bytes = await pdf.save();
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'reporte_pacientes.pdf')
    ..click();
  html.Url.revokeObjectUrl(url);
}



