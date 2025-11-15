import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart';
import '../models/patient_model.dart';
import '../widgets/sidebar_menu.dart';
import '../widgets/user_profile_button.dart';
import '../services/export_service.dart';
import '../widgets/app_background.dart';

class PagosScreen extends StatefulWidget {
  const PagosScreen({super.key});

  @override
  State<PagosScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PagosScreen> {
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  DateTime? _fechaPago;

  String? _metodoPago;
  PatientModel? _pacienteSeleccionado;
  int? _entidadSeleccionada;
  String? _procedimientoSeleccionado;

  final df = DateFormat('yyyy-MM-dd');
  bool _isSaving = false;

  void _seleccionarPaciente(PatientModel paciente) {
    setState(() {
      _pacienteSeleccionado = paciente;
      _cedulaController.text = paciente.cedula;
      _nombreController.text = '${paciente.nombre} ${paciente.apellido}';
      _procedimientoSeleccionado = paciente.procedimiento;
      _entidadSeleccionada = paciente.entidadId;
    });
  }

  Future<void> _registrarPago() async {
    if (_pacienteSeleccionado == null ||
        _valorController.text.isEmpty ||
        _entidadSeleccionada == null ||
        _procedimientoSeleccionado == null ||
        _fechaPago == null ||
        _metodoPago == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    final valor = double.tryParse(_valorController.text.replaceAll(',', '.'));
    if (valor == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresa un valor válido')));
      return;
    }

    final entidadNombre = DataService.entidadesEps
        .firstWhere(
          (e) => e['id'] == _entidadSeleccionada,
          orElse: () => {'nombre': ''},
        )['nombre']
        ?.toString();

    setState(() => _isSaving = true);
    final success = await DataService.registrarPago(
      cedula: _pacienteSeleccionado!.cedula,
      valorTotal: valor,
      metodoPago: _metodoPago!,
      entidad: entidadNombre ?? '',
      fechaPago: _fechaPago!,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo registrar el pago')),
      );
      return;
    }

    await DataService.refreshPatients();
    if (!mounted) return;
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pago registrado para ${_nombreController.text}')),
    );

    _valorController.clear();
    _fechaPago = null;
    _metodoPago = null;
    setState(() {});
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombreController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1100;
    final pacientes = DataService.patients;
    final epsOptions = DataService.entidadesEps;
    final procOptions = DataService.procedimientos;
    final entidadValue = epsOptions.any((e) => e['id'] == _entidadSeleccionada)
        ? _entidadSeleccionada
        : null;
    final procedimientoValue =
        procOptions.any((p) => p['nombre'] == _procedimientoSeleccionado)
        ? _procedimientoSeleccionado
        : null;

    return Scaffold(
      drawer: isWide ? null : const SidebarMenu(),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Image.asset('lib/imgs/logomydoctor.png', height: 28),
            const SizedBox(width: 10),
            const Text('Gestión de Pagos'),
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pacientes y estado de pago',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Cédula')),
                                    DataColumn(label: Text('Paciente')),
                                    DataColumn(label: Text('Procedimiento')),
                                    DataColumn(label: Text('Estado de pago')),
                                    DataColumn(label: Text('Método')),
                                    DataColumn(label: Text('Fecha pago')),
                                    DataColumn(label: Text('Acción')),
                                  ],
                                  rows: pacientes
                                      .map(
                                        (p) => DataRow(
                                          cells: [
                                            DataCell(Text(p.cedula)),
                                            DataCell(
                                              Text('${p.nombre} ${p.apellido}'),
                                            ),
                                            DataCell(
                                              Text(p.procedimiento ?? '—'),
                                            ),
                                            DataCell(
                                              Chip(
                                                label: Text(
                                                  p.estadoPago ?? 'Pendiente',
                                                ),
                                                backgroundColor:
                                                    (p.estadoPago ??
                                                            'Pendiente') ==
                                                        'Pagado'
                                                    ? Colors.green.shade100
                                                    : Colors.orange.shade100,
                                                labelStyle: TextStyle(
                                                  color:
                                                      (p.estadoPago ??
                                                              'Pendiente') ==
                                                          'Pagado'
                                                      ? Colors.green.shade800
                                                      : Colors.orange.shade800,
                                                ),
                                              ),
                                            ),
                                            DataCell(Text(p.metodoPago ?? '—')),
                                            DataCell(
                                              Text(
                                                p.fechaPago != null
                                                    ? df.format(p.fechaPago!)
                                                    : '—',
                                              ),
                                            ),
                                            DataCell(
                                              TextButton.icon(
                                                icon: const Icon(
                                                  Icons.point_of_sale,
                                                ),
                                                label: const Text('Registrar'),
                                                onPressed: () {
                                                  _seleccionarPaciente(p);
                                                  _fechaPago = DateTime.now();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Selecciona un paciente',
                                  border: OutlineInputBorder(),
                                ),
                                value: _pacienteSeleccionado?.cedula,
                                items: pacientes
                                    .map(
                                      (p) => DropdownMenuItem(
                                        value: p.cedula,
                                        child: Text(
                                          '${p.cedula} - ${p.nombre} ${p.apellido}',
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  final paciente = pacientes.firstWhere(
                                    (p) => p.cedula == value,
                                    orElse: () => pacientes.first,
                                  );
                                  _seleccionarPaciente(paciente);
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _nombreController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre del paciente',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _cedulaController,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Cédula',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Procedimiento',
                                  border: OutlineInputBorder(),
                                ),
                                value: procedimientoValue,
                                items: procOptions
                                    .map(
                                      (proc) => DropdownMenuItem(
                                        value: proc['nombre'] as String,
                                        child: Text(proc['nombre'] as String),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) => setState(
                                  () => _procedimientoSeleccionado = val,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _valorController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Valor a pagar',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                  labelText: 'Entidad',
                                  border: OutlineInputBorder(),
                                ),
                                value: entidadValue,
                                items: epsOptions
                                    .map(
                                      (ent) => DropdownMenuItem(
                                        value: ent['id'] as int,
                                        child: Text(
                                          '${ent['nombre']} (${ent['tipo']})',
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _entidadSeleccionada = val),
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Método de pago',
                                  border: OutlineInputBorder(),
                                ),
                                value: _metodoPago,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Efectivo',
                                    child: Text('Efectivo'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Transferencia',
                                    child: Text('Transferencia'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Tarjeta',
                                    child: Text('Tarjeta'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Otro',
                                    child: Text('Otro'),
                                  ),
                                ],
                                onChanged: (value) =>
                                    setState(() => _metodoPago = value),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Fecha de pago',
                                        border: OutlineInputBorder(),
                                      ),
                                      child: Text(
                                        _fechaPago != null
                                            ? df.format(_fechaPago!)
                                            : 'Selecciona una fecha',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.calendar_today),
                                    label: const Text('Elegir'),
                                    onPressed: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2100),
                                      );
                                      if (picked != null) {
                                        setState(() => _fechaPago = picked);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.save),
                                label: Text(
                                  _isSaving
                                      ? 'Registrando...'
                                      : 'Registrar Pago',
                                ),
                                onPressed: _isSaving ? null : _registrarPago,
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.table_view),
                                label: const Text('Exportar pagos'),
                                onPressed: () async {
                                  final pagosRealizados = DataService.patients
                                      .where((p) => p.estadoPago == 'Pagado')
                                      .toList();

                                  if (pagosRealizados.isEmpty) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No hay pagos registrados aún',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  await ExportService.exportPatientsToCsv(
                                    pagosRealizados,
                                  );

                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Archivo de pagos generado con éxito',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
