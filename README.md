# Gastos Personales

Aplicación móvil de finanzas personales construida en **Flutter** con **Clean Architecture**, **offline-first** y **100 % local**. El usuario registra ingresos y gastos, los organiza por categorías, define presupuestos mensuales con alertas, y consulta estadísticas con gráficos.

> **Estado del proyecto:** funcional / showcase. Se desarrolló como pieza de portafolio para demostrar arquitectura limpia, separación de capas, gestión de estado moderna y UX cuidada en Flutter.

---

## Tabla de contenidos

[Capturas y demo](#capturas-y-demo)
[Funcionalidades](#funcionalidades)
[Stack técnico](#stack-técnico)
[Arquitectura](#arquitectura)
[Estructura del proyecto](#estructura-del-proyecto)
[Modelo de datos](#modelo-de-datos)
[Flujo de una transacción (extremo a extremo)](#flujo-de-una-transacción-extremo-a-extremo)
[Decisiones técnicas y trade-offs](#decisiones-técnicas-y-trade-offs)
[Cómo correr el proyecto](#cómo-correr-el-proyecto)
[Estructura de carpetas con documentación interna](#estructura-de-carpetas-con-documentación-interna)
[Roadmap](#roadmap)
[Autor](#autor)

---


## Capturas y demo

> _Reemplaza estos placeholders con capturas reales antes de publicar el repo._

| Inicio (Dashboard) | Movimientos | Estadísticas | Presupuestos |
| :---: | :---: | :---: | :---: |
| ![home](docs/screenshots/home.png) | ![movs](docs/screenshots/transactions.png) | ![stats](docs/screenshots/statistics.png) | ![budgets](docs/screenshots/budgets.png) |

---

## Funcionalidades

- **Movimientos** — Registrar ingresos y gastos con monto, descripción, fecha y categoría. Edición y borrado con confirmación.
- **Categorías** — Catálogo editable con ícono y color.
- **Presupuestos mensuales** — Por categoría o globales, con umbral de alerta configurable (50 % – 100 %). Barra de progreso con color semántico (verde / amarillo / rojo).
- **Notificaciones locales** — Alertas idempotentes cuando un presupuesto pasa su umbral o se excede. Una notificación por presupuesto, por mes y por tipo.
- **Estadísticas** — Selector de periodo (este mes / mes pasado / este año), totales, gráfico de torta por categoría y gráfico de barras de los últimos 6 meses.
- **Ajustes** — Tema (claro/oscuro/automático), moneda, idioma, exportar/importar JSON, borrar todos los datos.
- **Tema claro y oscuro** — Material 3 con paleta propia.

---

## Stack técnico

| Categoría | Tecnología |
| --- | --- | --- |
| **UI** | Flutter 3 / Material 3 |
| **Estado** | `flutter_riverpod` |
| **Routing** | `go_router` con `StatefulShellRoute` |
| **Persistencia** | `hive_ce` (NoSQL embebido) |
| **Preferencias** | `shared_preferences` |
| **Manejo de errores** | `dartz` (`Either<Failure, T>`) |
| **DI** | `get_it` + providers de Riverpod |
| **Gráficos** | `fl_chart` |
| **Notificaciones** | `flutter_local_notifications` + `timezone` |
| **Modelado** | `equatable` |
| **Code-gen** | `build_runner` + `hive_ce_generator` |
| **Config** | `flutter_dotenv` |
| **IDs** | `uuid` |

---

## Arquitectura

### Clean Architecture en 3 capas

```
┌─────────────────────────────────────────────────────────────┐
│  PRESENTATION                                                │
│  Pages · Widgets · Providers (Riverpod)                     │
│  ────────────────────────────────────────────────────────── │
│  Solo conoce el Dominio. Usa providers para resolver        │
│  use cases y observar streams del repositorio.              │
└──────────────────────────┬──────────────────────────────────┘
                           │ depende de
                           ▼
┌─────────────────────────────────────────────────────────────┐
│  DOMAIN  (puro Dart, sin Flutter, sin Hive)                 │
│  Entities · Repositories (interfaces) · UseCases            │
│  ────────────────────────────────────────────────────────── │
│  Reglas de negocio. No sabe cómo se persiste ni se muestra. │
│  Testeable sin mocks pesados.                               │
└──────────────────────────▲──────────────────────────────────┘
                           │ implementa
┌──────────────────────────┴──────────────────────────────────┐
│  DATA                                                        │
│  Models (Hive) · DataSources · Repository Impl              │
│  ────────────────────────────────────────────────────────── │
│  Mapea modelos persistidos ⇄ entidades del dominio.         │
│  Captura excepciones y las convierte en Failure.            │
└─────────────────────────────────────────────────────────────┘
```

### Manejo de errores

Las operaciones que pueden fallar devuelven `Either<Failure, T>`:

- **`Right(value)`** — éxito.
- **`Left(failure)`** — fallo tipado: `ValidationFailure`, `CacheFailure`, `NotFoundFailure`, etc.

### Reactividad

Hive expone `box.watch()`, que emite cada vez que cambian los datos. Cada feature define un `StreamProvider` que se conecta a ese stream y mapea los modelos a entidades. Los widgets observan el provider con `ref.watch(...)` y se reconstruyen automáticamente cuando los datos cambian — sin gestores manuales de estado, sin `setState` para datos del dominio.

```
Hive.box.watch() → DataSource.watchAll() (Stream<Model>)
                 → Repository.watchAll()  (Stream<Entity>)
                 → StreamProvider          (Riverpod)
                 → ref.watch() en Widget    (UI reactiva)
```

---

## Estructura del proyecto

```
lib/
├── main.dart                  # Bootstrap: dotenv, Hive, locale, notificaciones, runApp
├── hive_registrar.g.dart      # Generado por hive_ce_generator
│
├── core/                      # Infraestructura transversal
│   ├── config/                # EnvConfig (.env)
│   ├── constants/             # AppConstants, HiveBoxes
│   ├── di/                    # GetIt + Riverpod setup
│   ├── error/                 # Exceptions + Failures
│   ├── extensions/            # Helpers para BuildContext, DateTime, String
│   ├── router/                # GoRouter con StatefulShellRoute
│   ├── services/              # HiveService, NotificationService
│   ├── theme/                 # Colors, Spacing, Typography, AppTheme
│   ├── usecases/              # Contrato base UseCase<T, Params>
│   └── utils/                 # Formatters (moneda, fecha, parseAmount)
│
└── features/                  # Cada feature es independiente
    ├── transactions/          # CRUD de movimientos
    ├── categories/            # Catálogo con seeds + librería de íconos/colores
    ├── budgets/               # Presupuestos mensuales con progress derivado
    ├── dashboard/             # Home + shell con BottomNavigationBar
    ├── notifications/         # Alertas idempotentes + observer de presupuestos
    ├── settings/              # Tema, moneda, locale, export/import
    └── statistics/            # Período + pie + bar charts derivados
```

Cada feature sigue la misma estructura interna:

```
feature/
├── data/
│   ├── datasources/   # Acceso a Hive
│   ├── models/        # @HiveType con toEntity / fromEntity / toJson / fromJson
│   └── repositories/  # Implementación que mapea excepciones → Failure
├── domain/
│   ├── entities/      # Equatable, puros
│   ├── repositories/  # Interfaces abstractas
│   └── usecases/      # Una clase por caso de uso, contrato UseCase<T, Params>
└── presentation/
    ├── pages/         # Pantallas (ConsumerWidget / ConsumerStatefulWidget)
    ├── providers/     # Riverpod: providers de DataSource, Repo, UseCase, State
    └── widgets/       # Widgets específicos de la feature
```

---

## Modelo de datos

Cada entidad de Hive tiene un `typeId` único y se guarda en su propio box.

| Entidad | Hive `typeId` | Box | Notas |
| --- | :---: | --- | --- |
| `TransactionModel` | 0 | `transactions_box` | Income/Expense con `categoryId?` opcional |
| `CategoryModel` | 1 | `categories_box` | Sembrada al primer arranque (12 categorías por defecto) |
| `BudgetModel` | 2 | `budgets_box` | `categoryId?` null = aplica a todos los gastos del mes |
| `NotificationModel` | 3 | `notifications_box` | `referenceId + scope + type` garantizan idempotencia |
| `AppSettings` | — | `shared_preferences` | Tema/moneda/locale fuera de Hive |

**Diseño deliberado:** los modelos guardan los enums como `int` (`typeIndex`) en lugar de strings, para que renombrar un enum en código no rompa los datos persistidos.

---

## Flujo de una transacción (extremo a extremo)

Trazando el camino desde un *tap* del usuario hasta que la UI se refresca:

1. **UI** — el usuario llena `TransactionFormPage` y presiona "Guardar".
2. **Presentation** — el form llama a `ref.read(createTransactionProvider).call(params)`.
3. **UseCase** — `CreateTransaction` valida (`amount > 0`, descripción no vacía) y, si pasa, delega al repo. Si falla, retorna `Left(ValidationFailure)`.
4. **Repository** — `TransactionRepositoryImpl` convierte la entidad a `TransactionModel`, llama al data source y atrapa cualquier excepción de Hive.
5. **DataSource** — `TransactionLocalDataSourceImpl.upsert()` hace `box.put(id, model)`.
6. **Hive** — emite un evento por `box.watch()`.
7. **StreamProvider** — `transactionsStreamProvider` recibe la nueva lista, mapea modelos a entidades y emite.
8. **UI** — `TransactionsPage` y `HomePage` observan el provider y se re-renderizan.
9. **Bonus** — `transactionTotalsProvider` (derivado) recalcula ingresos/gastos/balance; `budgetsProgressProvider` recalcula porcentajes; si algún presupuesto supera su umbral, `budgetAlertObserverProvider` dispara una notificación local.

---

## Cómo correr el proyecto

### Requisitos

- Flutter SDK **≥ 3.10.8** (canal stable)
- Android Studio o Xcode para emuladores
- Un emulador o dispositivo físico

### Pasos

```bash
# 1. Clonar
git clone https://github.com/smanrrique/gastos_personales
cd gastos_personales

# 2. Instalar dependencias
flutter pub get

# 3. Generar adaptadores de Hive
dart run build_runner build --delete-conflicting-outputs

# 4. Correr
flutter run
```

### Tests

```bash
flutter test
```

> Actualmente solo hay un smoke test (`test/widget_test.dart`). El dominio está diseñado para ser testeable: cada `UseCase` se puede testear con un mock de `Repository`, y cada repo con un fake `DataSource`.

## Autor

**Sebastián Manrique** — Desarrollador móvil.

- LinkedIn: _<https://www.linkedin.com/in/sebastian-manrique-zabala-a87aaa262/>_
- Portafolio: _<https://sebastian-manrique.vercel.app/>_
