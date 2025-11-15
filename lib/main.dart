//biblioteca para interfaces graficas
import 'package:flutter/material.dart';

// importa la pantalla de inicio de sesion desde la carpeta screen
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/citas_screen.dart';
import 'screens/pagos_screen.dart';
import 'screens/historial_clinico_screen.dart';

// importa el servicio que maneja los datos de los usuarios pacientes
import 'services/data_service.dart';
import 'screens/configuracion_screen.dart';
import 'theme/app_colors.dart';


//funcion principal 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataService.initialize();
  runApp(const MyDoctorApp()); // ejecuta la aplicacion principal
}

//CLASE PRINCIPAL DE LA APLICACION
class MyDoctorApp extends StatelessWidget {
  const MyDoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'MyDoctor',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const HomeScreen(),
        '/citas': (context) => const CitasScreen(),
        '/pagos': (context) => const PagosScreen(),
        '/historial_clinico': (context) => const HistorialClinicoScreen(),
        '/configuracion': (context) => ConfiguracionScreen(
              usuario: DataService.usuarioActual!,
            ),
      },
    );
  }
}

