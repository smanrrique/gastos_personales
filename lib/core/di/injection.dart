import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

/// Configuración inicial del service locator.
///
/// Se usa como complemento de Riverpod para registrar servicios singleton
/// que necesitan instanciarse antes del runApp (ej. clientes Firebase,
/// Hive boxes ya abiertas). La mayor parte de la inyección de dependencias
/// se hace vía Riverpod providers.
///
/// Cuando se introduzca Injectable, reemplazar el cuerpo por:
///   await sl.init();
/// y descomentar el import generado:
///   import 'injection.config.dart';
Future<void> configureDependencies() async {
  // Registros manuales aquí, o migrar a Injectable + build_runner.
}
