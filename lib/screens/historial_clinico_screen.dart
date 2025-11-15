import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/sidebar_menu.dart';
import '../widgets/user_profile_button.dart';
import '../services/data_service.dart';
import '../models/patient_model.dart';
import '../widgets/app_background.dart';

class HistorialClinicoScreen extends StatefulWidget {
  const HistorialClinicoScreen({super.key});

  @override
  State<HistorialClinicoScreen> createState() => _HistorialClinicoScreenState();
}

class _HistorialClinicoScreenState extends State<HistorialClinicoScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _diagnosticoController = TextEditingController();
  List<PatientModel> pacientesFiltrados = [];
  final df = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    pacientesFiltrados = DataService.patients;
    _searchController.addListener(() {
      final q = _searchController.text.toLowerCase();
      setState(() {
        pacientesFiltrados = DataService.patients.where((p) {
          return p.nombre.toLowerCase().contains(q) ||
              p.apellido.toLowerCase().contains(q) ||
              p.cedula.toLowerCase().contains(q);
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _diagnosticoController.dispose();
    super.dispose();
  }

  void _abrirModalHistorial(PatientModel paciente) {
    // Obtiene historial del paciente (si existe)
    final historial = DataService.historiales
        .where((h) => h['cedula'] == paciente.cedula)
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Historial Clínico - ${paciente.nombre} ${paciente.apellido}'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cédula: ${paciente.cedula}'),
                  const SizedBox(height: 6),
                  Text('Teléfono: ${paciente.telefono.isNotEmpty ? paciente.telefono : "No registrado"}'),
                  const SizedBox(height: 6),
                  Text('Correo: ${paciente.email.isNotEmpty ? paciente.email : "No registrado"}'),
                  const SizedBox(height: 10),
                  Text('Entidad: ${paciente.entidad ?? "No registrada"}'),
                  Text('Procedimiento: ${paciente.procedimiento ?? "No registrado"}'),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Diagnósticos anteriores:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (historial.isEmpty)
                    const Text('No hay registros en el historial de este paciente.')
                  else
                    Column(
                      children: historial.map((h) {
                        final fecha = h['fecha'] is DateTime
                            ? df.format(h['fecha'] as DateTime)
                            : h['fecha'].toString();
                        return Card(
                          color: Colors.grey.shade100,
                          child: ListTile(
                            title: Text(h['diagnostico'] ?? ''),
                            subtitle: Text('Fecha: $fecha'),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Agregar nuevo diagnóstico:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _diagnosticoController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Escribe aquí el diagnóstico...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _diagnosticoController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Guardar diagnóstico'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                final texto = _diagnosticoController.text.trim();
                if (texto.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Escribe un diagnóstico antes de guardar')),
                  );
                  return;
                }

                // guarda en DataService.historiales (estructura simple)
                DataService.addHistorial({
                  'cedula': paciente.cedula,
                  'nombre': '${paciente.nombre} ${paciente.apellido}',
                  'diagnostico': texto,
                  'fecha': DateTime.now(),
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Diagnóstico guardado en el historial')),
                );

                _diagnosticoController.clear();
                Navigator.of(context).pop();
                setState(() {}); // refresca la lista si es necesario
              },
            ),
          ],
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
            const Text('Historial clínico'),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gestión del Historial Clínico',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              labelText: 'Buscar paciente por nombre, apellido o cédula',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Actualizar'),
                          onPressed: () => setState(() {}),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: pacientesFiltrados.isEmpty
                              ? const Center(child: Text('No hay pacientes para mostrar'))
                              : ListView.separated(
                                  itemCount: pacientesFiltrados.length,
                                  separatorBuilder: (_, __) => const Divider(),
                                  itemBuilder: (context, index) {
                                    final p = pacientesFiltrados[index];
                                    return ListTile(
                                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                      title: Text('${p.nombre} ${p.apellido}',
                                          style: const TextStyle(fontWeight: FontWeight.w600)),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Cédula: ${p.cedula}'),
                                          Text('Fecha Nac.: ${df.format(p.fechaNacimiento)}'),
                                        ],
                                      ),
                                      trailing: ElevatedButton.icon(
                                        icon: const Icon(Icons.medical_services_outlined),
                                        label: const Text('Ver historial'),
                                        onPressed: () => _abrirModalHistorial(p),
                                      ),
                                    );
                                  },
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
