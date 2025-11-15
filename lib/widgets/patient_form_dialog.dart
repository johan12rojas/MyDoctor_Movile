//componentes visuales de flutter
import 'package:flutter/material.dart';

//para formatear fechas
import 'package:intl/intl.dart';

//modelo del paciente
import '../models/patient_model.dart';

//servicio que maneja los datos del paciente
import '../services/data_service.dart';

//widget principal

// este widget muestra un formulario emergente
// para agregar o editar la informacion de un paciente
class PatientFormDialog extends StatefulWidget {
  final PatientModel? patient;
  const PatientFormDialog({super.key, this.patient});

  @override
  State<PatientFormDialog> createState() => _PatientFormDialogState();
}

//estado del formulario
class _PatientFormDialogState extends State<PatientFormDialog> {

  // controladores de texto para capturar lo que escribe el usuario
  final cedula = TextEditingController();
  final nombre = TextEditingController();
  final apellido = TextEditingController();
  final telefono = TextEditingController();
  final email = TextEditingController();
  final motivo = TextEditingController();
  int? _entidadSeleccionada;
  String? _procedimientoSeleccionado;
  DateTime? fecha; //fecha de nacimiento del paciente
  bool _isSaving = false;

  // metodo inistate
  // se ejecuta una sola vez cuando se abre el formulario
  // si el paciente ya existe se llenan los campos con sus datos
  @override
  void initState() {
    super.initState();
    if (widget.patient != null) {
      cedula.text = widget.patient!.cedula;
      nombre.text = widget.patient!.nombre;
      apellido.text = widget.patient!.apellido;
      telefono.text = widget.patient!.telefono;
      email.text = widget.patient!.email;
      fecha = widget.patient!.fechaNacimiento;
      motivo.text = widget.patient!.motivoConsulta;
      _entidadSeleccionada = widget.patient!.entidadId;
      _procedimientoSeleccionado = widget.patient!.procedimiento;
    }
  }

  @override
  void dispose() {
    cedula.dispose();
    nombre.dispose();
    apellido.dispose();
    telefono.dispose();
    email.dispose();
    motivo.dispose();
    super.dispose();
  }

  //interfaz visual
  @override
  Widget build(BuildContext context) {
    final epsOptions = DataService.entidadesEps;
    final procOptions = DataService.procedimientos;
    return AlertDialog(
      //titulo del formulario
      title: Text(widget.patient == null ? 'Agregar Paciente' : 'Editar Paciente'),

      //contenido del formulario
      content: SingleChildScrollView(
        child: Column(
          children: [

            // campo de cédula (ahora visible siempre)
            TextField(
              controller: cedula,
              decoration: InputDecoration(labelText: 'Cédula'),
              keyboardType: TextInputType.number,
            ),

            // campos de texto para el resto de datos
            TextField(controller: nombre, decoration: InputDecoration(labelText: 'Nombre')),
            TextField(controller: apellido, decoration: InputDecoration(labelText: 'Apellido')),
            TextField(controller: telefono, decoration: InputDecoration(labelText: 'Teléfono')),
            TextField(controller: email, decoration: InputDecoration(labelText: 'Correo electrónico')),

            SizedBox(height: 8),

            // boton para seleccionar la fecha de nacimiento
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: fecha ?? DateTime(1990),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => fecha = picked);
              },

              // muestra la fecha elegida o el texto por defecto
              child: Text(
                fecha == null
                    ? 'Seleccionar fecha de nacimiento'
                    : 'Fecha: ${DateFormat('yyyy-MM-dd').format(fecha!)}',
              ),
            ),

            // campo para escribir el motivo de consulta
            TextField(controller: motivo, decoration: InputDecoration(labelText: 'Motivo de consulta')),

            SizedBox(height: 8),

            // nuevos campos entidad y procedimiento (obligatorios)
            SizedBox(
              width: double.infinity,
              child: DropdownButtonFormField<int>(
                value: _entidadSeleccionada,
                items: epsOptions
                    .map(
                      (e) => DropdownMenuItem(
                        value: e['id'] as int,
                        child: Text('${e['nombre']} (${e['tipo']})'),
                      ),
                    )
                    .toList(),
                onChanged:
                    epsOptions.isEmpty ? null : (val) => setState(() => _entidadSeleccionada = val),
                decoration: const InputDecoration(labelText: 'Entidad EPS'),
                hint: Text(epsOptions.isEmpty ? 'Cargando...' : 'Selecciona una EPS'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: DropdownButtonFormField<String>(
                value: _procedimientoSeleccionado,
                items: procOptions
                    .map(
                      (p) => DropdownMenuItem(
                        value: p['nombre'] as String,
                        child: Text(p['nombre'] as String),
                      ),
                    )
                    .toList(),
                onChanged: procOptions.isEmpty
                    ? null
                    : (val) => setState(() => _procedimientoSeleccionado = val),
                decoration: const InputDecoration(labelText: 'Procedimiento'),
                hint: Text(procOptions.isEmpty ? 'Cargando...' : 'Selecciona un procedimiento'),
              ),
            ),

            SizedBox(height: 8),
            Text(
              '* campos obligatorios',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),

      //botones para el formulario
      actions: [
        //boton para cerrar el formulario sin guardar
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),

        // Botón para guardar el paciente
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSubmit,
          child: Text(_isSaving ? 'Guardando...' : 'Guardar'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (cedula.text.isEmpty ||
        nombre.text.isEmpty ||
        apellido.text.isEmpty ||
        telefono.text.isEmpty ||
        email.text.isEmpty ||
        fecha == null ||
        _entidadSeleccionada == null ||
        _procedimientoSeleccionado == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Completa todos los campos requeridos')));
      return;
    }

    final entidadNombre = DataService.entidadesEps
        .firstWhere(
          (e) => e['id'] == _entidadSeleccionada,
          orElse: () => {'nombre': ''},
        )['nombre']
        ?.toString();

    final patient = PatientModel(
      cedula: cedula.text.trim(),
      nombre: nombre.text.trim(),
      apellido: apellido.text.trim(),
      telefono: telefono.text.trim(),
      email: email.text.trim(),
      fechaNacimiento: fecha!,
      motivoConsulta: motivo.text.trim(),
      entidad: entidadNombre,
      entidadId: _entidadSeleccionada,
      procedimiento: _procedimientoSeleccionado,
      fechaAtencion: widget.patient?.fechaAtencion,
      estadoPago: widget.patient?.estadoPago ?? 'Pendiente',
      metodoPago: widget.patient?.metodoPago,
      fechaPago: widget.patient?.fechaPago,
    );

    setState(() => _isSaving = true);
    final success = widget.patient == null
        ? await DataService.addPatient(patient)
        : await DataService.updatePatient(patient);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el paciente. Intenta nuevamente.')),
      );
    }
  }
}

