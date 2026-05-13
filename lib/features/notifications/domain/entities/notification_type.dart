enum AppNotificationType {
  budgetAlert,
  budgetExceeded,
  info;

  String get label => switch (this) {
        AppNotificationType.budgetAlert => 'Alerta de presupuesto',
        AppNotificationType.budgetExceeded => 'Presupuesto excedido',
        AppNotificationType.info => 'Información',
      };
}
