# Module: Devices

## Purpose
Management of IoT devices: hubs, weather stations, and thermal sensors connected to silos.

## Structure
- `controllers/` - DevicesController extends GetxController
- `views/` - UI screens
- `widgets/` - Reusable device UI components

## Key Files
- `views/devices_view.dart` - Main view with TabBar (Sensores | Motores de Aeração)
- `views/aeration_motors_view.dart` - Standalone motors view (fallback via route)
- `controllers/devices_controller.dart` - Sensors controller
- `controllers/aeration_motor_controller.dart` - Aeration motors controller
- `widgets/telemetry_history_dialog.dart` - Sensor telemetry dialog
- `widgets/motor_control_card.dart` - Motor card with ON/OFF toggle

## Models
- `core/models/motor_aeracao_model.dart` - MotorAeracaoModel with id, motorId, description, status, estado (ligado/desligado), potenciaKW, rpm, vazaoAr, horimetro, consumoAtualKW, and linkage fields (siloId, secadorId)

## API Endpoints
- `GET/POST motores-aeracao/` - List/create motors
- `PUT/DELETE motores-aeracao/<id>/` - Update/delete motor
- `POST motores-aeracao/<id>/comando/` - Send command (ligar/desligar)

## Route (fallback)
`/devices/motors` (protected) — standalone access (main entry via Devices tab)
