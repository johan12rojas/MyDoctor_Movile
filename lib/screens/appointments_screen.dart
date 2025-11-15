import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//modelo de cita (si aún no tienes uno, puedes crearlo igual que los modelos de paciente y usuario)
import '../models/appointment_model.dart';

//menu lateral
import '../widgets/sidebar_menu.dart';

//boton de perfil del usuario
import '../widgets/user_profile_button.dart';

//pantalla que muestra la lista de citas
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  //controlador para el texto de búsqueda
  final searchController = TextEditingController();

  //formato de fecha
  final df = DateFormat('yyyy-MM-dd');

  //lista simulada de citas (puedes reemplazarla con DataService más adelante)
  List<AppointmentModel> appointments = [
    AppointmentModel(
      numeroCita: '1',
      fechaCita: DateTime(2025, 10, 20),
      hora: '10:00 AM',
      cedulaPaciente: '1001',
      nombrePaciente: 'Juliana',
      apellidoPaciente: 'Amaya',
      observaciones: 'Dolor de cabeza',
      tipoCita: 'Consulta',
      estado: 'Pendiente',
      fechaRegistro: DateTime(2025, 10, 18),
    ),
    AppointmentModel(
      numeroCita: '2',
      fechaCita: DateTime(2025, 10, 22),
      hora: '02:30 PM',
      cedulaPaciente: '1002',
      nombrePaciente: 'Melany',
      apellidoPaciente: 'Sepulveda',
      observaciones: 'Chequeo general',
      tipoCita: 'Procedimiento',
      estado: 'Atendido',
      fechaRegistro: DateTime(2025, 10, 19),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    //filtra las citas según lo que se escriba en la barra de búsqueda
    final filteredAppointments = appointments.where((c) {
      final query = searchController.text.toLowerCase();

      // convierte el nombre del paciente a minúsculas
      final nombre = c.nombrePaciente.toLowerCase();

      // convierte el apellido del paciente a minúsculas
      final apellido = c.apellidoPaciente.toLowerCase();

      // convierte la cédula del paciente a minúsculas
      final cedula = c.cedulaPaciente.toLowerCase();


      //retorna true si alguno de los campos contiene el texto buscado
      return nombre.contains(query) ||
          apellido.contains(query) ||
          cedula.contains(query);
    }).toList();

    return Scaffold(
      drawer: SidebarMenu(), //menu lateral
      appBar: AppBar(
        title: Text('Citas Médicas'),
        leading: UserProfileButton(), //botón de perfil en la esquina
      ),

      //cuerpo principal de la pantalla
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //titulo principal
            Text('Lista de Citas',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),

            //barra de búsqueda
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre, apellido o cédula',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                //actualiza la vista cada vez que cambia el texto
                setState(() {});
              },
            ),
            SizedBox(height: 16),

            //tabla que muestra la lista de citas
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('N° Cita')),
                    DataColumn(label: Text('Fecha')),
                    DataColumn(label: Text('Hora')),
                    DataColumn(label: Text('Cédula Paciente')),
                    DataColumn(label: Text('Nombre')),
                    DataColumn(label: Text('Apellido')),
                    DataColumn(label: Text('Observaciones')),
                    DataColumn(label: Text('Tipo')),
                    DataColumn(label: Text('Estado')),
                    DataColumn(label: Text('Fecha Registro')),
                    DataColumn(label: Text('Acciones')),
                  ],

                  //crea una fila por cada cita filtrada
                  rows: filteredAppointments.map((c) {
                    return DataRow(cells: [

                      // muestra el número de cita
                      DataCell(Text(c.numeroCita)),

                      // muestra la fecha de la cita
                      DataCell(Text(df.format(c.fechaCita))),

                      // muestra la hora
                      DataCell(Text(c.hora)),

                      // muestra la cédula del paciente
                      DataCell(Text(c.cedulaPaciente)),

                      // muestra el nombre del paciente
                      DataCell(Text(c.nombrePaciente)),

                      // muestra el apellido del paciente
                      DataCell(Text(c.apellidoPaciente)),

                      // muestra observaciones de la cita
                      DataCell(Text(c.observaciones)),

                      // muestra el tipo de cita (consulta o procedimiento)
                      DataCell(Text(c.tipoCita)),

                      // muestra el estado de la cita
                      DataCell(Text(c.estado)),

                      DataCell(Text(df.format(c.fechaRegistro))),
                      DataCell(Row(
                        children: [
                          //boton editar
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.orange),
                            onPressed: () {

                              //logica para editar cita
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Editar cita ${c.numeroCita} en desarrollo'),
                                ),
                              );
                            },
                          ),
                          //boton eliminar
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text('Confirmar eliminación'),
                                  content: Text(
                                      '¿Deseas eliminar la cita ${c.numeroCita}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          appointments.remove(c);
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
