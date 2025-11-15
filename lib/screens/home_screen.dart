//FUNCIONAMIENTO GENERAL:

//AppBar + Drawer/Sidebar	Navegación general de la app y acceso al perfil.

//Campo de búsqueda	Permite filtrar pacientes por cualquier campo visible (nombre, cédula, email, etc.).

//Tabla de pacientes (DataTable)	Muestra todos los registros con sus datos principales.

//Botones de acción	- Agregar paciente: abre un diálogo (PatientFormDialog) para registrar nuevos.

// Excel: genera un archivo .csv.

//PDF: crea un reporte imprimible con la lista.

//Editar / Eliminar	Permite modificar o eliminar un paciente con confirmación.

//ExportService	Encargado de crear los archivos de exportación (CSV y PDF).

//DataService	Fuente de datos centralizada (almacena usuarios y pacientes).

//El AppBar es como el encabezado de tu aplicación o de cada pantalla.
//Se usa para mostrar información importante (como el nombre de la app o el usuario) y 
//controles comunes (como un ícono de búsqueda, regresar, o abrir el menú lateral).



import 'package:flutter/material.dart';

//par el formateo de fechas
import 'package:intl/intl.dart';

//servicio que maneja la lista de paientes
import '../services/data_service.dart';

//modelo de datos del paciente
import '../models/patient_model.dart';

//para el sidebar menu
import '../widgets/sidebar_menu.dart';

//el btn del perfil en el appBar
import '../widgets/user_profile_button.dart';

//dialogo del formulario para agregar, editar, borrar pacientes
import '../widgets/patient_form_dialog.dart';

//export de el excel y del pdf
import '../services/export_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_background.dart';


//Pantalla principal tras login
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PatientModel> get patients => DataService.patients;
  List<PatientModel> filteredPatients = [];
  final TextEditingController searchController = TextEditingController();
  final df = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    filteredPatients = patients;
  }

  //inicio de la funcion de busqueda
  void _filterPatients(String query) {
    setState(() {

      //si no hay texto en la barra, muestra todos los pacientes
      if (query.isEmpty) {
        filteredPatients = patients;
      } else {
        //pasa el texto a minuscula para la busqueda sin mauyscula
        final q = query.toLowerCase();

        //filtra los paciente por coincidencias
        filteredPatients = patients.where((p) {
          return p.cedula.toLowerCase().contains(q) ||
              p.nombre.toLowerCase().contains(q) ||
              p.apellido.toLowerCase().contains(q) ||
              p.telefono.toLowerCase().contains(q) ||
              p.email.toLowerCase().contains(q) ||
              p.motivoConsulta.toLowerCase().contains(q) ||
              (p.entidad?.toLowerCase().contains(q) ?? false) ||
              (p.estadoPago?.toLowerCase().contains(q) ?? false) ||
              (p.fechaAtencion != null && 
                  DateFormat('yyyy-MM-dd').format(p.fechaAtencion!).contains(q));
        }).toList();
      }
    });
  }//fin de la funcion de busqueda


//Aqui se Hara el interfaz para la pantalla de home

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
            const Text('MyDoctor'),
          ],
        ),
        actions: const [
          UserProfileButton(),
        ],
      ),


      body: AppBackground(
        child: Row(
          children: [

            if (isWide)
              const SizedBox(width: 260, child: SidebarMenu(isDrawer: false)),


          //en este apartado se pondra el contenido principal de home
            Expanded(
              child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //esto es para poner el saludo con el nombre del usuario
                  Text('¡Bienvenido ${DataService.usuarioActual?.nombre ?? ''}!',
                      style: TextStyle(fontSize: 24)),
                  SizedBox(height: 12),


                  //Campo de busqueda actualizado
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar paciente',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: _filterPatients,//lamado a la funcion del filtro
                  ),
                  SizedBox(height: 12),



                  //tarjeta que contiene la tabla de los pacientes
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                          //cabecera con los botones de accion
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final actions = Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final added = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => const PatientFormDialog(),
                                      );
                                      if (added == true) {
                                        setState(() => filteredPatients = patients);
                                      }
                                    },
                                    icon: const Icon(Icons.person_add_alt_1),
                                    label: const Text('Agregar'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        ExportService.exportPatientsToCsv(filteredPatients),
                                    icon: const Icon(Icons.table_view_rounded),
                                    label: const Text('Excel'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        ExportService.exportPatientsToPdf(filteredPatients),
                                    icon: const Icon(Icons.picture_as_pdf),
                                    label: const Text('PDF'),
                                  ),
                                ],
                              );

                              final title = const Text(
                                'Lista de pacientes',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              );

                              if (constraints.maxWidth < 700) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    title,
                                    const SizedBox(height: 12),
                                    actions,
                                  ],
                                );
                              }

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  title,
                                  actions,
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                                    


                          //Tabla con los campos visibles con los 
                          //datos de los pacientes

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(

                              //encabezados
                              columns: [
                                DataColumn(label: Text('Cédula')),
                                DataColumn(label: Text('Nombre')),
                                DataColumn(label: Text('Apellido')),
                                DataColumn(label: Text('Teléfono')),
                                DataColumn(label: Text('Correo')),
                                DataColumn(label: Text('Entidad')),
                                DataColumn(label: Text('Motivo Consulta')),
                                DataColumn(label: Text('Fecha Nac.')),
                                DataColumn(label: Text('Fecha Atención')),
                                DataColumn(label: Text('Estado de Pago')),
                                DataColumn(label: Text('Acciones')),
                              ],

                              //filas dinamicas, se generan a partir de la
                              // lista de pacientes
                              rows: filteredPatients.map((p) {
                                return DataRow(cells: [
                                  DataCell(Text(p.cedula)),
                                  DataCell(Text(p.nombre)),
                                  DataCell(Text(p.apellido)),
                                  DataCell(Text(p.telefono)),
                                  DataCell(Text(p.email)),
                                  DataCell(Text(p.entidad ?? 'Sin entidad')),
                                  DataCell(Text(p.motivoConsulta)),
                                  DataCell(Text(df.format(p.fechaNacimiento))),
                                  DataCell(Text(
                                      p.fechaAtencion != null
                                          ? df.format(p.fechaAtencion!)
                                          : '—')),

                                  //este apartado va a ser para el estado de
                                  // pago que aparece en la tabla
                                  DataCell(Builder(
                                    builder: (_) {
                                      final estado = (p.estadoPago ?? '').toLowerCase();
                                      final estadoColor =
                                          estado == 'pagado' ? Colors.green : AppColors.accent;
                                      final etiqueta = estado.isEmpty ? 'Pendiente' : p.estadoPago!;
                                      return Text(
                                        etiqueta,
                                        style: TextStyle(
                                          color: estadoColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  )),



                                  //Acciones de editar y eliminar 
                                  //el paciente
                                  
                                  DataCell(Row(
                                    children: [

                                      //btn que abre el formulario para editar 
                                      //los datos del paciente
                                      IconButton(
                                        icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                                        onPressed: () async {
                                          final res = await showDialog(
                                            context: context,
                                            builder: (_) => PatientFormDialog(patient: p),
                                          );
                                          if (res == true) {
                                            setState(() => filteredPatients = patients);
                                          }
                                        },
                                      ),


                                      //btn que elimina el paciente
                                      //no sin antes pedir una confirmacion
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: Text('Confirmar'),
                                              content: Text('¿Eliminar paciente ${p.nombre} ${p.apellido}?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: Text('Cancelar'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  child: Text('Eliminar'),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            final eliminado = await DataService.deletePatient(p.cedula);
                                            if (!mounted) return;
                                            if (eliminado) {
                                              setState(() => filteredPatients = patients);
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('No se pudo eliminar al paciente.')),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  )),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ],
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

