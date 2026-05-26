// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Redsaldo';

  @override
  String get unexpectedError => 'Error inesperado';

  @override
  String get loginBrand => 'Redsaldo';

  @override
  String get loginSubtitle => 'Controla tu saldo semanal de Ticket Restaurant.';

  @override
  String get loginButton => 'INICIAR SESIÓN CON EDENRED';

  @override
  String get loginSecurityNote =>
      'Nunca guardamos tus números de tarjeta ni tus credenciales. Tus datos permanecen seguros.';

  @override
  String get refreshTooltip => 'Actualizar';

  @override
  String get logoutTooltip => 'Cerrar sesión';

  @override
  String get selectedProductFallback => 'Producto seleccionado';

  @override
  String get availableBalance => 'Saldo disponible';

  @override
  String get weeklyLimit => 'Límite semanal';

  @override
  String get spentThisWeek => 'Gastado esta semana';

  @override
  String get remainingThisWeek => 'Restante esta semana';

  @override
  String get editWeeklyLimit => 'Editar límite semanal';

  @override
  String get changeSelectedProduct => 'Cambiar producto seleccionado';

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get saveAction => 'Guardar';

  @override
  String get chooseProduct => 'Elegir producto';

  @override
  String get noProducts => 'No se recibieron productos de Edenred.';

  @override
  String ticketLabel(int idTicket) {
    return 'Ticket $idTicket';
  }

  @override
  String ticketLabelWithStatus(int idTicket, String status) {
    return 'Ticket $idTicket - $status';
  }

  @override
  String get edenredLogin => 'Inicio de sesión de Edenred';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get chooseCardTitle => 'Elige una tarjeta';

  @override
  String get chooseCardSubtitle =>
      'Selecciona la cuenta principal que quieres gestionar hoy.';

  @override
  String get selectedBadge => 'SELECCIONADA';

  @override
  String get inactiveBadge => 'INACTIVA';

  @override
  String get logoutButton => 'CERRAR SESIÓN';

  @override
  String get homeTitle => 'Saldo disponible';

  @override
  String get historyTitle => 'Historial';

  @override
  String get recentSpending => 'Gastos recientes';

  @override
  String get showingThisWeekOnly =>
      'Mostrando solo las transacciones de esta semana';

  @override
  String get notCounted => 'NO COMPUTA';

  @override
  String get noTransactionsTitle => 'Sin transacciones';

  @override
  String get noTransactionsBody => 'Tu historial de gastos aparecerá aquí.';

  @override
  String get cardStatusActive => 'Activa';

  @override
  String get cardStatusIssued => 'Emitida';

  @override
  String get logoutConfirmationTitle => 'Cerrar sesión';

  @override
  String get logoutConfirmationMessage =>
      '¿Estás seguro de que deseas cerrar sesión?';

  @override
  String get logoutConfirmationConfirm => 'Cerrar sesión';

  @override
  String get syncingAccountTitle => 'Sincronizando tu cuenta';

  @override
  String get syncingAccountStatus => 'Obteniendo tu saldo...';

  @override
  String get syncingAccountDescription =>
      'Esto solo tomará un momento. Conectando de forma segura con tu proveedor de vales de comida.';

  @override
  String get cardBalance => 'SALDO DE LA TARJETA';

  @override
  String get changeCardAction => 'Cambiar tarjeta';

  @override
  String get editLimitAction => 'Editar límite';

  @override
  String get lastUpdatedLabel => 'Última actualización';

  @override
  String lastUpdatedToday(String time) {
    return 'Hoy, $time';
  }

  @override
  String get navHome => 'Inicio';

  @override
  String get suggestedLimitText =>
      'Límite sugerido basado en 5 días laborables';

  @override
  String spentOfLimitText(String spent, String limit) {
    return '$spent EUR gastados de un límite de $limit EUR';
  }
}
