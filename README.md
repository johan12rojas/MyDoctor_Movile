# MyDoctor App

Aplicación integral para la gestión de pacientes, citas y pagos en clínicas. El frontend está construido en Flutter y el backend expone una API REST con Node.js/Express conectada a MySQL.

Repositorio remoto: [https://github.com/johan12rojas/MyDoctor_Movile](https://github.com/johan12rojas/MyDoctor_Movile)  

---

## Tabla de contenidos
1. [Arquitectura general](#arquitectura-general)
2. [Requisitos previos](#requisitos-previos)
3. [Clonado y preparación inicial](#clonado-y-preparación-inicial)
4. [Configuración de variables de entorno](#configuración-de-variables-de-entorno)
5. [Base de datos](#base-de-datos)
6. [Backend (API Node.js)](#backend-api-nodejs)
7. [Frontend Flutter](#frontend-flutter)
8. [Comandos útiles (incluye taskkill)](#comandos-útiles-incluye-taskkill)
9. [Estructura de carpetas destacada](#estructura-de-carpetas-destacada)
10. [Flujo recomendado de ejecución](#flujo-recomendado-de-ejecución)

---

## Arquitectura general
- **Flutter** (`lib/`): interfaz principal para Android, iOS, web y escritorio.
- **Backend Node.js** (`backend/`): API REST con Express, manejo de autenticación, pacientes, citas, pagos y catálogos.
- **MySQL** (`database/`): almacenamiento de toda la información operacional. Las migraciones manuales se documentan en `database/migrations/`.

---

## Requisitos previos
### Software base
- Flutter SDK 3.x y Dart (añadirlos al `PATH`).
- Android Studio / Xcode / Visual Studio Build Tools según la plataforma de destino.
- Node.js ≥ 18 y npm ≥ 10.
- MySQL Server 8 (o compatible) y MySQL Shell o cliente CLI.
- Git.

### Herramientas auxiliares
- Editor (VS Code, Android Studio, IntelliJ, etc.).
- Cliente de API (Postman, Thunder Client) para probar endpoints del backend.

---

## Clonado y preparación inicial
```powershell
git clone https://github.com/johan12rojas/MyDoctor_Movile.git
cd MyDoctor_Movile
```

> **Importante:** después de clonar debes crear tus propios archivos de configuración privados (ver `.env`). No modifiques carpetas del repo salvo lo necesario para tu entorno.

---

## Configuración de variables de entorno
1. Duplica `backend/.env` (si no está en el repo cuando clones, créalo manualmente).
2. Ajusta los valores conforme a tu instalación local:

```
API_PORT=3000
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=tu_password
DB_NAME=doc
```

3. Mantén este archivo fuera de control de versiones (ya está ignorado por `.gitignore`).

---

## Base de datos
1. **Instalación:** asegúrate de tener MySQL Server activo y accesible desde `localhost:3306`.
2. **Creación de esquema:**
   ```sql
   CREATE DATABASE doc CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   USE doc;
   ```
3. **Tablas iniciales:** importa tus definiciones base (según tus scripts internos) y luego ejecuta las migraciones manuales guardadas en `database/migrations/`. Ejemplo:
   ```sql
   SOURCE database/migrations/2025-11-15_add_user_photo.sql;
   ```
   Esta migración agrega la columna `foto_base64` a la tabla `usuarios`.
4. **Credenciales:** deben coincidir con lo declarado en `backend/.env`.
5. **Backups:** utiliza `mysqldump doc > backups/doc_<fecha>.sql` antes de correr nuevas migraciones.

---

## Backend (API Node.js)
- Ubicación: `backend/`
- Paquetes clave: `express`, `cors`, `mysql2`, `dotenv`, `nodemon`.

### Instalación
```powershell
cd backend
npm install
```

### Ejecución
```powershell
npm run dev   # inicia con nodemon
# o
npm start     # ejecución directa en producción
```

La API se publica en `http://localhost:3000` (o el puerto definido en `API_PORT`).

### Endpoints principales
- `GET /api/auth/*`
- `GET/POST /api/pacientes`
- `GET/POST /api/citas`
- `GET/POST /api/pagos`
- `GET/POST /api/users`
- `GET /api/catalogos/*`

Cada controlador se encuentra en `backend/src/controllers/` y comparte una capa de conexión en `backend/src/db.js`, que crea un `pool` MySQL usando `mysql2/promise`.

---

## Frontend Flutter
- Ubicación: `lib/`
- Widgets personalizados en `lib/widgets/`.
- Pantallas principales en `lib/screens/`.
- Servicios para acceso a datos en `lib/services/`.

### Dependencias
```powershell
flutter pub get
```

### Ejecución
```powershell
# Android/iOS (dispositivo o emulador)
flutter run

# Web
flutter run -d chrome

# Windows
flutter run -d windows

# Ejemplo en dispositivo físico Android (mismo comando pero definiendo la URL de la API):
flutter run -d <ID_DISPOSITIVO> --dart-define=API_BASE_URL=http://<AQUI_VA_TU_IP>:3000/api
# Reemplaza <AQUI_VA_TU_IP> por la dirección IPv4 de tu PC (ej. 192.168.0.25)
```

---

## Comandos útiles (incluye taskkill)
- Ver dispositivos disponibles: `flutter devices`
- Limpiar compilaciones: `flutter clean`
- **Liberar puertos ocupados en Windows** (por ejemplo, si `node` queda colgado en el puerto 3000):
  ```powershell
  netstat -ano | findstr :3000     # identifica el PID
  taskkill /PID <PID> /F           # termina solo ese proceso
  # si deseas terminar todos los procesos node:
  taskkill /F /IM node.exe
  ```
- Reiniciar el demonio de Flutter: `flutter doctor -v`

---

## Estructura de carpetas destacada
```
backend/
  src/
    controllers/
    routes/
    db.js
  package.json
database/
  migrations/
lib/
  screens/
  services/
  widgets/
pubspec.yaml
```

- `lib/imgs/`: recursos gráficos usados por los fondos y logotipos.
- `lib/services/export_service*.dart`: capa para exportar información (IO/Web).
- `database/migrations/`: scripts SQL versionados que debes ejecutar manualmente.

---

## Flujo recomendado de ejecución
1. **Clonar** el repo y crear tu rama si vas a contribuir.
2. **Configurar** `backend/.env` con tus credenciales.
3. **Provisionar** la base de datos (`CREATE DATABASE doc;` + migraciones).
4. **Instalar dependencias**:
   - `flutter pub get`
   - `cd backend && npm install`
5. **Levantar backend**: `npm run dev`.
6. **Arrancar Flutter**: `flutter run` en el dispositivo/plataforma deseada.
7. **Probar endpoints** con un cliente REST y validar lectura/escritura en MySQL.
8. **Detener servicios** cuando sea necesario (usa `Ctrl+C` o `taskkill` si quedó un proceso huérfano).

Con esta guía tendrás la aplicación corriendo de extremo a extremo, sabrás cómo preparar la base de datos y contarás con los comandos necesarios para diagnosticar y liberar recursos en Windows.
