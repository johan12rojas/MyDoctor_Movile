//Este archivo define un formulario emergente ventana modal tipo dialogo
//que permite crear o editar una cita medica en la aplicacion
//se usa dentro de otras pantallas  cuando el usuario 
//quiere agregar una nueva cita o modificar una existente

//Este código es el formulario inteligente del sistema de gestion de
// citas médicas, es la interfaz que conecta al usuario con la logica
// de almacenamiento de las citas





import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../services/data_service.dart';

class AppointmentFormDialog extends StatefulWidget {
  final AppointmentModel? appointment;
  const AppointmentFormDialog({this.appointment});

  @override
  State<AppointmentFormDialog> createState() => _AppointmentFormDialogState();
}

class _AppointmentFormDialogState extends State<AppointmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numeroCtl = TextEditingController();
  final _cedulaCtl = TextEditingController();
  final _nombreCtl = TextEditingController();
  final _apellidoCtl = TextEditingController();
  final _horaCtl = TextEditingController();
  final _observacionesCtl = TextEditingController();
  String _tipo = 'Consulta';
  String _estado = 'Pendiente';
  DateTime? _fecha;

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      final a = widget.appointment!;
      _numeroCtl.text = a.numeroCita;
      _cedulaCtl.text = a.cedulaPaciente;
      _nombreCtl.text = a.nombrePaciente;
      _apellidoCtl.text = a.apellidoPaciente;
      _horaCtl.text = a.hora;
      _observacionesCtl.text = a.observaciones;
      _tipo = a.tipoCita;
      _estado = a.estado;
      _fecha = a.fechaCita;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.appointment == null ? 'Nueva Cita' : 'Editar Cita'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _numeroCtl,
                decoration: const InputDecoration(labelText: 'Número de Cita'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _cedulaCtl,
                decoration: const InputDecoration(labelText: 'Cédula del Paciente'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _nombreCtl,
                decoration: const InputDecoration(labelText: 'Nombre del Paciente'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _apellidoCtl,
                decoration: const InputDecoration(labelText: 'Apellido del Paciente'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _horaCtl,
                decoration: const InputDecoration(labelText: 'Hora (HH:MM)'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              DropdownButtonFormField(
                value: _tipo,
                items: ['Consulta', 'Procedimiento']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _tipo = v!),
                decoration: const InputDecoration(labelText: 'Tipo de Cita'),
              ),
              DropdownButtonFormField(
                value: _estado,
                items: ['Pendiente', 'Finalizado', 'Cancelado']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _estado = v!),
                decoration: const InputDecoration(labelText: 'Estado'),
              ),
              TextFormField(
                controller: _observacionesCtl,
                decoration: const InputDecoration(labelText: 'Observaciones'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _fecha = picked);
                },
                child: Text(_fecha == null
                    ? 'Seleccionar Fecha'
                    : 'Fecha: ${DateFormat('dd/MM/yyyy').format(_fecha!)}'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            // Validar campos vacíos
            if (!_formKey.currentState!.validate() || _fecha == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Por favor, completa todos los campos.')),
              );
              return;
            }

            // Verificar hora duplicada
            final mismaHora = DataService.citas.any((cita) =>
                cita.fechaCita == _fecha &&
                cita.hora.trim() == _horaCtl.text.trim() &&
                cita != widget.appointment);

            if (mismaHora) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Esa hora ya está en uso. Elige otro momento.')),
              );
              return;
            }

            final newAppointment = AppointmentModel(
              numeroCita: _numeroCtl.text.trim(),
              fechaCita: _fecha!,
              hora: _horaCtl.text.trim(),
              cedulaPaciente: _cedulaCtl.text.trim(),
              nombrePaciente: _nombreCtl.text.trim(),
              apellidoPaciente: _apellidoCtl.text.trim(),
              tipoCita: _tipo,
              estado: _estado,
              observaciones: _observacionesCtl.text.trim(),
              fechaRegistro: DateTime.now(),
            );

            if (widget.appointment == null) {
              DataService.addAppointment(newAppointment);
            } else {
              DataService.updateAppointment(newAppointment);
            }

            Navigator.pop(context, true);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

