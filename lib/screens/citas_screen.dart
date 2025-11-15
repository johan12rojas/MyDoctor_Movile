





//importa el paquete principal de flutter para para construir widgets
import 'package:flutter/material.dart';

//libreria intl para las fechas
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';

//importa la estructura de datos usada en la pantalla
import '../services/data_service.dart';

//este import es un servicio que actua como fuente de datos central
//es como un CRUD para citas y pacientes
import '../widgets/sidebar_menu.dart';

//importa el widget del menu lateral para la navegacion
import '../widgets/user_profile_button.dart';

//importa el modelo de paciente para crear uno si la cita pertenece a un
//nuevo paciente
import '../models/patient_model.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';



//pantalla de gestion para las citas medicas
//aqui se puso un statefulwidget por que la lista de citas y los controles de
//busqueda y formulario cambian dinamicamente
class CitasScreen extends StatefulWidget {
  const CitasScreen({super.key});

  @override
  State<CitasScreen> createState() => _CitasScreenState();
}

class _CitasScreenState extends State<CitasScreen> {

  //lista que tendra las citas filtradas para mostrar la ui
  //se inicializa
  List<AppointmentModel> citasFiltradas = [];
  final TextEditingController searchController = TextEditingController();
  final df = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    citasFiltradas = DataService.citas;
  }

  void filtrarCitas(String query) {
    setState(() {
      query = query.toLowerCase();
      citasFiltradas = DataService.citas.where((c) {
        return c.nombrePaciente.toLowerCase().contains(query) ||
            c.apellidoPaciente.toLowerCase().contains(query) ||
            c.cedulaPaciente.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<bool?> mostrarFormularioCita({AppointmentModel? cita}) async {
    final numeroCtrl = TextEditingController(
      text: cita?.numeroCita ?? DataService.generarNumeroCitaLocal(),
    );
    final nombreCtrl = TextEditingController(text: cita?.nombrePaciente ?? '');
    final apellidoCtrl = TextEditingController(text: cita?.apellidoPaciente ?? '');
    final cedulaCtrl = TextEditingController(text: cita?.cedulaPaciente ?? '');
    final observacionesCtrl = TextEditingController(text: cita?.observaciones ?? '');
    DateTime? fechaSeleccionada = cita?.fechaCita ?? DateTime.now();
    String? horaSeleccionada = cita?.hora;
    String? tipoSeleccionado = cita?.tipoCita ?? 'Consulta';
    String? estadoSeleccionado = cita?.estado ?? 'Pendiente';

    return showDialog<bool>(
      context: context,
      builder: (_) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
          void completarPacienteConCedula(String cedula) {
            final paciente = DataService.buscarPacientePorCedula(cedula.trim());
            if (paciente != null) {
              nombreCtrl.text = paciente.nombre;
              apellidoCtrl.text = paciente.apellido;
            }
          }

          Future<void> saveAppointment() async {
            if (numeroCtrl.text.isEmpty ||
                nombreCtrl.text.isEmpty ||
                apellidoCtrl.text.isEmpty ||
                cedulaCtrl.text.isEmpty ||
                fechaSeleccionada == null ||
                horaSeleccionada == null ||
                tipoSeleccionado == null ||
                estadoSeleccionado == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Por favor completa todos los campos')),
              );
              return;
            }

            final existeConflicto = DataService.citas.any((c) =>
                c.hora == horaSeleccionada &&
                c.fechaCita == fechaSeleccionada &&
                c.id != cita?.id);
            if (existeConflicto) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Esa hora ya está ocupada, elige otro momento')),
              );
              return;
            }

            final nuevaCita = AppointmentModel(
              id: cita?.id,
              numeroCita: numeroCtrl.text,
              fechaCita: fechaSeleccionada!,
              hora: horaSeleccionada!,
              cedulaPaciente: cedulaCtrl.text,
              nombrePaciente: nombreCtrl.text,
              apellidoPaciente: apellidoCtrl.text,
              observaciones: observacionesCtrl.text,
              tipoCita: tipoSeleccionado!,
              estado: estadoSeleccionado!,
              fechaRegistro: cita?.fechaRegistro ?? DateTime.now(),
            );

            setModalState(() => isSaving = true);
            final success = cita == null
                ? await DataService.addAppointment(nuevaCita)
                : await DataService.updateAppointment(nuevaCita);
            setModalState(() => isSaving = false);
            if (!success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No se pudo guardar la cita')),
              );
              return;
            }

            final existePaciente = DataService.patients.any(
              (p) => p.cedula == cedulaCtrl.text.trim(),
            );

            if (!existePaciente) {
              final nuevoPaciente = PatientModel(
                cedula: cedulaCtrl.text.trim(),
                nombre: nombreCtrl.text.trim(),
                apellido: apellidoCtrl.text.trim(),
                telefono: '',
                email: '',
                fechaNacimiento: DateTime(2000, 1, 1),
                motivoConsulta: observacionesCtrl.text.trim(),
                entidad: '',
                procedimiento: tipoSeleccionado ?? '',
                fechaAtencion: fechaSeleccionada!,
                estadoPago: 'Pendiente',
              );
              await DataService.addPatient(nuevoPaciente);
            }

            setState(() => citasFiltradas = DataService.citas);
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(cita == null ? 'Cita agregada correctamente' : 'Cita actualizada correctamente')),
            );
          }

            return AlertDialog(
          title: Text(cita == null ? 'Agregar Cita' : 'Editar Cita'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: numeroCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Número de Cita',
                    suffixIcon: const Icon(Icons.lock),
                    helperText: cita == null ? 'Se genera automáticamente' : null,
                  ),
                ),
                TextField(controller: nombreCtrl, decoration: InputDecoration(labelText: 'Nombre del Paciente')),
                TextField(controller: apellidoCtrl, decoration: InputDecoration(labelText: 'Apellido del Paciente')),
                TextField(
                  controller: cedulaCtrl,
                  decoration: const InputDecoration(labelText: 'Cédula'),
                  keyboardType: TextInputType.number,
                  onChanged: completarPacienteConCedula,
                ),
                SizedBox(height: 10),
                Text('Fecha:', style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: fechaSeleccionada ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate != null) {
                      setModalState(() => fechaSeleccionada = pickedDate);
                    }
                  },
                  child: Text(
                    fechaSeleccionada != null
                        ? df.format(fechaSeleccionada!)
                        : 'Seleccionar fecha',
                  ),
                ),
                SizedBox(height: 10),
                Text('Hora:', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: horaSeleccionada,
                  hint: Text('Seleccionar hora'),
                  items: [
                    ...List.generate(5, (i) => '0${7 + i}:00'),
                    ...['14:00', '15:00', '16:00', '17:00']
                  ].map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                  onChanged: (val) => setModalState(() => horaSeleccionada = val),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: observacionesCtrl,
                  decoration: const InputDecoration(labelText: 'Observaciones'),
                  maxLines: 3,
                ),
                SizedBox(height: 10),
                Text('Tipo de Cita:', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text('Consulta'),
                      selected: tipoSeleccionado == 'Consulta',
                      onSelected: (val) => setModalState(() => tipoSeleccionado = 'Consulta'),
                    ),
                    ChoiceChip(
                      label: Text('Procedimiento'),
                      selected: tipoSeleccionado == 'Procedimiento',
                      onSelected: (val) => setModalState(() => tipoSeleccionado = 'Procedimiento'),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text('Estado:', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Pendiente'),
                      selected: estadoSeleccionado == 'Pendiente',
                      onSelected: (_) => setModalState(() => estadoSeleccionado = 'Pendiente'),
                    ),
                    ChoiceChip(
                      label: const Text('Atendido'),
                      selected: estadoSeleccionado == 'Atendido',
                      onSelected: (_) => setModalState(() => estadoSeleccionado = 'Atendido'),
                    ),
                    ChoiceChip(
                      label: const Text('Cancelado'),
                      selected: estadoSeleccionado == 'Cancelado',
                      onSelected: (_) => setModalState(() => estadoSeleccionado = 'Cancelado'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
            ElevatedButton(
              onPressed: isSaving ? null : saveAppointment,
              child: Text(isSaving
                  ? 'Guardando...'
                  : cita == null
                      ? 'Guardar'
                      : 'Actualizar'),
            ),
          ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1100;
    return Scaffold(
      drawer: isWide ? null : const SidebarMenu(),
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Image.asset('lib/imgs/logomydoctor.png', height: 28),
            const SizedBox(width: 10),
            const Text('Citas médicas'),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Gestión de Citas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Crear cita'),
                        onPressed: () => mostrarFormularioCita(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchController,
                    onChanged: filtrarCitas,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      labelText: 'Buscar cita',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Número')),
                            DataColumn(label: Text('Fecha')),
                            DataColumn(label: Text('Hora')),
                            DataColumn(label: Text('Cédula')),
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Apellido')),
                            DataColumn(label: Text('Tipo')),
                            DataColumn(label: Text('Estado')),
                            DataColumn(label: Text('Observaciones')),
                            DataColumn(label: Text('Acciones')),
                          ],
                          rows: citasFiltradas.map((c) {
                            return DataRow(
                              cells: [
                                DataCell(Text(c.numeroCita)),
                                DataCell(Text(df.format(c.fechaCita))),
                                DataCell(Text(c.hora)),
                                DataCell(Text(c.cedulaPaciente)),
                                DataCell(Text(c.nombrePaciente)),
                                DataCell(Text(c.apellidoPaciente)),
                                DataCell(Text(c.tipoCita)),
                                DataCell(Text(c.estado)),
                                DataCell(Text(c.observaciones)),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                                      onPressed: () => mostrarFormularioCita(cita: c),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Confirmar eliminación'),
                                            content: Text('¿Deseas eliminar la cita ${c.numeroCita}?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Cancelar'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: const Text('Eliminar'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          final eliminado = await DataService.deleteAppointment(c);
                                          if (!mounted) return;
                                          if (eliminado) {
                                            setState(() => citasFiltradas = DataService.citas);
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                  content: Text('No se pudo eliminar la cita.')),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}
