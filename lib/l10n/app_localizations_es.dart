// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get dashboard => 'DASHBOARD';

  @override
  String dashboardGreeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get remainingBudget => 'PRESUPUESTO RESTANTE';

  @override
  String get budget => 'Presupuesto';

  @override
  String get remaining => 'Restante';

  @override
  String get spent => 'Gastado';

  @override
  String get onTrack => 'En buen camino';

  @override
  String percentageRemaining(String percentage) {
    return '$percentage% Restante';
  }

  @override
  String amountSpent(String amount) {
    return '\$$amount Gastado';
  }

  @override
  String get total => 'TOTAL';

  @override
  String get daysLeftLabel => 'DÍAS RESTANTES';

  @override
  String daysLeft(int days) {
    return '$days días restantes';
  }

  @override
  String get currentBudget => 'PRESUPUESTO ACTUAL';

  @override
  String get week => 'Semana';

  @override
  String get month => 'Mes';

  @override
  String get quarter => 'Trimestre';

  @override
  String get custom => 'Personalizado';

  @override
  String get budgetPeriod => 'Período del Presupuesto';

  @override
  String spentThisMonth(String period) {
    return 'Gastado este $period';
  }

  @override
  String get shoppingList => 'LISTA DE COMPRAS';

  @override
  String items(int count) {
    return '$count ítems';
  }

  @override
  String item(int count) {
    return '$count ítem';
  }

  @override
  String get addItem => 'Agregar Ítem';

  @override
  String get pending => 'Pendiente';

  @override
  String get purchased => 'Comprado';

  @override
  String get emptyShoppingList => 'Lista vacía';

  @override
  String get emptyShoppingListDescription =>
      'Agrega ítems a tu lista de compras\npara comenzar';

  @override
  String get addFirstItem => 'Agregar Primer Ítem';

  @override
  String get markAsPurchased => 'Marcar como comprado';

  @override
  String get deleteItem => 'Eliminar ítem';

  @override
  String percentageUsed(String percentage) {
    return '$percentage% usado';
  }

  @override
  String get budgetExceeded => 'Presupuesto excedido';

  @override
  String get nearLimit => 'Cerca del límite';

  @override
  String get editItem => 'Editar Ítem';

  @override
  String get nameRequired => 'Nombre *';

  @override
  String get estimatedPriceRequired => 'Precio Estimado *';

  @override
  String get requiredFieldsMissing =>
      'Por favor completa los campos obligatorios';

  @override
  String get invalidPriceError => 'Por favor ingresa un precio válido';

  @override
  String get itemUpdated => 'Ítem actualizado';

  @override
  String get deleteItemTitle => 'Eliminar Ítem';

  @override
  String deleteItemConfirm(String name) {
    return '¿Estás seguro de que quieres eliminar \"$name\"?';
  }

  @override
  String itemDeleted(String name) {
    return '$name eliminado';
  }

  @override
  String get addNewItem => 'Agregar Nuevo Ítem';

  @override
  String get addItemTitle => 'Agregar Ítem';

  @override
  String get itemNameLabel => 'Nombre del ítem';

  @override
  String get itemName => 'Nombre del ítem';

  @override
  String get itemNameHint => 'Ej: Leche, Pan, Huevos...';

  @override
  String get estimatedPrice => 'Precio estimado';

  @override
  String get price => 'Precio';

  @override
  String get priceHint => '0.00';

  @override
  String get categoryOptional => 'Categoría (opcional)';

  @override
  String get categoryHint => 'Ej: Lácteos, Panadería, Frutas...';

  @override
  String get quantity => 'Cantidad';

  @override
  String get quantityHint => '1';

  @override
  String get category => 'Categoría';

  @override
  String get selectCategory => 'Selecciona una categoría';

  @override
  String get notes => 'Notas';

  @override
  String get notesHint => 'Notas adicionales (opcional)';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get itemNameRequired => 'Por favor ingresa un nombre';

  @override
  String get priceRequired => 'Por favor ingresa un precio';

  @override
  String get priceInvalid => 'Por favor ingresa un precio válido mayor a 0';

  @override
  String get quantityRequired => 'La cantidad es requerida';

  @override
  String get quantityInvalid => 'Ingresa una cantidad válida';

  @override
  String get itemAddedSuccess => 'Ítem agregado exitosamente';

  @override
  String get budgetImpact => 'Impacto en el presupuesto:';

  @override
  String get newRemaining => 'Nuevo restante:';

  @override
  String get budgetExceededWarning => '¡Excederás el presupuesto!';

  @override
  String itemAddedRemaining(String amount) {
    return 'Ítem agregado. Restante: \$$amount';
  }

  @override
  String get fruits => 'Frutas';

  @override
  String get vegetables => 'Verduras';

  @override
  String get meat => 'Carnes';

  @override
  String get dairy => 'Lácteos';

  @override
  String get bakery => 'Panadería';

  @override
  String get beverages => 'Bebidas';

  @override
  String get snacks => 'Snacks';

  @override
  String get frozen => 'Congelados';

  @override
  String get canned => 'Enlatados';

  @override
  String get condiments => 'Condimentos';

  @override
  String get other => 'Otros';

  @override
  String get budgetSettings => 'Configuración de Presupuesto';

  @override
  String get configureBudget => 'Configurar Presupuesto';

  @override
  String get budgetInfoText => 'Define tu presupuesto para compras compartidas';

  @override
  String get budgetAmountLabel => 'Monto del presupuesto';

  @override
  String get budgetAmount => 'Monto del Presupuesto';

  @override
  String get budgetAmountHint => 'Ingresa el monto';

  @override
  String get budgetAmountRequired => 'Por favor ingresa un monto';

  @override
  String get budgetAmountInvalid =>
      'Por favor ingresa un monto válido mayor a 0';

  @override
  String get budgetPeriodLabel => 'Período del presupuesto';

  @override
  String get budgetPeriodRequired => 'Selecciona un período de presupuesto';

  @override
  String get customPeriodInvalid =>
      'Selecciona fechas válidas para el período personalizado';

  @override
  String get weekly => 'Semanal';

  @override
  String get weeklyDescription => 'El presupuesto se renueva cada semana';

  @override
  String get monthly => 'Mensual';

  @override
  String get monthlyDescription => 'El presupuesto se renueva cada mes';

  @override
  String get customPeriod => 'Personalizado';

  @override
  String get customPeriodDescription => 'Define tu propio período';

  @override
  String get startDateLabel => 'Fecha de inicio';

  @override
  String get endDateLabel => 'Fecha de fin';

  @override
  String get startDate => 'Fecha de Inicio';

  @override
  String get endDate => 'Fecha de Fin';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get selectStartDate => 'Selecciona fecha de inicio';

  @override
  String get selectEndDate => 'Selecciona fecha de fin';

  @override
  String get preview => 'Vista previa:';

  @override
  String get spentLabel => 'Gastado:';

  @override
  String get remainingLabel => 'Restante:';

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String get budgetUpdatedSuccess => 'Presupuesto actualizado correctamente';

  @override
  String get userSettings => 'Configuración de Usuario';

  @override
  String get settings => 'Configuración';

  @override
  String get profile => 'Perfil';

  @override
  String get name => 'Nombre';

  @override
  String get email => 'Correo electrónico';

  @override
  String get changeProfilePhoto => 'Cambiar foto de perfil';

  @override
  String get photoFeatureNotImplemented =>
      'Esta funcionalidad se implementará con image_picker en una futura versión.';

  @override
  String get understood => 'Entendido';

  @override
  String get editName => 'Editar nombre';

  @override
  String get editEmail => 'Editar correo electrónico';

  @override
  String get nameUpdated => 'Nombre actualizado';

  @override
  String get emailUpdated => 'Correo actualizado';

  @override
  String get appearance => 'Apariencia';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get subscription => 'Suscripción';

  @override
  String get plan => 'Plan';

  @override
  String get changePlan => 'Cambiar plan';

  @override
  String get free => 'Gratis';

  @override
  String get premium => 'Premium';

  @override
  String get basicFeatures => 'Funcionalidades básicas';

  @override
  String get allFeatures => 'Todas las funcionalidades';

  @override
  String get perMonth => '/mes';

  @override
  String get close => 'Cerrar';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get pushNotifications => 'Notificaciones push';

  @override
  String get emailNotifications => 'Notificaciones por correo';

  @override
  String get budgetAlerts => 'Alertas de presupuesto';

  @override
  String get shoppingReminders => 'Recordatorios de compras';

  @override
  String get support => 'Soporte';

  @override
  String get helpCenter => 'Centro de Ayuda';

  @override
  String get contactSupport => 'Contactar Soporte';

  @override
  String get reportBug => 'Reportar un error';

  @override
  String get about => 'Acerca de';

  @override
  String get version => 'Versión';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get termsOfService => 'Términos de Servicio';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutConfirmTitle => '¿Cerrar sesión?';

  @override
  String get logoutConfirmMessage =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get logoutError => 'Error al cerrar sesión';

  @override
  String get history => 'HISTORIAL';

  @override
  String get historyTitle => 'Historial';

  @override
  String get purchaseHistory => 'Historial de Compras';

  @override
  String get emptyHistory => 'Sin historial aún';

  @override
  String get emptyHistoryDescription =>
      'El historial de períodos anteriores\naparecerá aquí';

  @override
  String get totalSpent => 'Total Gastado';

  @override
  String get totalSpentLabel => 'Total gastado';

  @override
  String get viewDetails => 'Ver Detalles';

  @override
  String get deletePeriod => 'Eliminar período';

  @override
  String get deletePeriodConfirm =>
      '¿Estás seguro de que quieres eliminar este período del historial?';

  @override
  String get periodDeleted => 'Período eliminado del historial';

  @override
  String get exceeded => 'Excedido';

  @override
  String get underControl => 'Bajo control';

  @override
  String ofAmount(String amount) {
    return 'De \$$amount';
  }

  @override
  String exceededBy(String amount) {
    return 'Excedido por \$$amount';
  }

  @override
  String saved(String amount) {
    return 'Ahorraste \$$amount';
  }

  @override
  String get notificationsTitle => 'NOTIFICACIONES';

  @override
  String get notificationsLabel => 'Notificaciones';

  @override
  String get viewAll => 'Ver todas';

  @override
  String get notificationDeleted => 'Notificación eliminada';

  @override
  String get emptyNotifications => 'Sin notificaciones';

  @override
  String get emptyNotificationsDescription =>
      'Las notificaciones aparecerán aquí';

  @override
  String get markAllAsRead => 'Marcar todo como leído';

  @override
  String get clearAll => 'Limpiar';

  @override
  String get deleteAll => 'Eliminar todas';

  @override
  String get deleteAllConfirm =>
      '¿Estás seguro de que quieres eliminar todas las notificaciones del presupuesto actual?';

  @override
  String get delete => 'Eliminar';

  @override
  String get groupSettings => 'Configuración de Grupo';

  @override
  String get groupName => 'Nombre del Grupo';

  @override
  String get members => 'Miembros';

  @override
  String get addMember => 'Agregar Miembro';

  @override
  String get removeMember => 'Eliminar Miembro';

  @override
  String get removeMemberConfirm => '¿Estás seguro de eliminar a';

  @override
  String get wasRemovedFromBudget => 'fue eliminado del presupuesto';

  @override
  String get removedSuccessfully => 'eliminado exitosamente';

  @override
  String get remove => 'Eliminar';

  @override
  String get leaveGroup => 'Salir del Grupo';

  @override
  String get inviteMembers => 'Invitar Miembros';

  @override
  String get inviteByEmail => 'Invitar por correo';

  @override
  String get emailAddress => 'Dirección de correo';

  @override
  String get sendInvitation => 'Enviar Invitación';

  @override
  String get invitationSent => 'Invitación enviada';

  @override
  String get inviteCode => 'Código de invitación';

  @override
  String get inviteCodeCopied => 'Código copiado al portapapeles';

  @override
  String get inviteMessageCopied => 'Mensaje de invitación copiado';

  @override
  String joinGroupMessage(String code) {
    return 'Únete a mi grupo de compras compartidas con el código: $code';
  }

  @override
  String get myGroup => 'Mi Grupo';

  @override
  String get member => 'miembro';

  @override
  String get copy => 'Copiar';

  @override
  String get currentMembers => 'Miembros actuales';

  @override
  String get noMembersYet => 'Aún no hay miembros';

  @override
  String get membersCanViewEdit =>
      'Los miembros podrán ver y editar la lista de compras y el presupuesto compartido';

  @override
  String get privateProject => 'Privado';

  @override
  String get privateProjectNote =>
      'Este es un presupuesto privado. Solo tú puedes verlo.';

  @override
  String get personalProjectWarningTitle => '⚠️ Compartir presupuesto personal';

  @override
  String get personalProjectWarning =>
      'Al compartir este código, tu presupuesto personal dejará de ser privado y otras personas podrán acceder a él.';

  @override
  String get budgetMembers => 'Miembros del presupuesto';

  @override
  String get currentBudgetMembers => 'Miembros de este presupuesto';

  @override
  String get onlyYou => 'Solo tú';

  @override
  String get shareYourBudget => 'Comparte tu presupuesto';

  @override
  String get shareYourBudgetDescription =>
      'Puedes compartir el presupuesto seleccionado con otros usuarios si lo deseas. Ellos podrán ver y editar los gastos.';

  @override
  String get share => 'Compartir';

  @override
  String get noEditPermission =>
      'No tienes permisos para editar este presupuesto. Solo el creador puede editarlo.';

  @override
  String get filterAndSort => 'Filtrar y Ordenar';

  @override
  String get all => 'Todas';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get status => 'Estado';

  @override
  String get ascending => 'Ascendente';

  @override
  String get descending => 'Descendente';

  @override
  String get apply => 'Aplicar';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get signInWithApple => 'Iniciar sesión con Apple';

  @override
  String get signInWithEmail => 'Iniciar sesión con Email';

  @override
  String get dontHaveAccount => '¿No tienes cuenta?';

  @override
  String get signUp => 'Registrarse';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get now => 'Ahora';

  @override
  String minutesAgo(int minutes) {
    return 'Hace ${minutes}m';
  }

  @override
  String hoursAgo(int hours) {
    return 'Hace ${hours}h';
  }

  @override
  String get yesterday => 'Ayer';

  @override
  String daysAgo(int days) {
    return 'Hace ${days}d';
  }

  @override
  String get home => 'Inicio';

  @override
  String get family => 'Familia';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get warning => 'Advertencia';

  @override
  String get info => 'Info';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Hecho';

  @override
  String get next => 'Siguiente';

  @override
  String get back => 'Atrás';

  @override
  String get continueButton => 'Continuar';

  @override
  String get skip => 'Omitir';

  @override
  String get search => 'Buscar';

  @override
  String get filter => 'Filtrar';

  @override
  String get sort => 'Ordenar';

  @override
  String get refresh => 'Actualizar';

  @override
  String get retry => 'Reintentar';

  @override
  String get edit => 'Editar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get discard => 'Descartar';

  @override
  String get myBudgets => 'Mis Presupuestos';

  @override
  String get noBudgetsYet => 'Aún no hay presupuestos';

  @override
  String get noBudgetsDescription => 'Crea tu primer presupuesto para comenzar';

  @override
  String get personalBudgets => 'Presupuestos Personales';

  @override
  String get sharedBudgets => 'Presupuestos Compartidos';

  @override
  String get newBudget => 'Nuevo Presupuesto';

  @override
  String get createBudget => 'Crear Presupuesto';

  @override
  String get editBudget => 'Editar Presupuesto';

  @override
  String get budgetDetails => 'Detalles del Presupuesto';

  @override
  String switchedToBudget(String name) {
    return 'Cambiado a \"$name\"';
  }

  @override
  String get activeBudget => 'Activo';

  @override
  String get personal => 'Personal';

  @override
  String get shared => 'Compartido';

  @override
  String get budgetName => 'Nombre del Presupuesto';

  @override
  String get budgetNameHint => 'Ej: Compras, Vacaciones';

  @override
  String get budgetNameRequired => 'Por favor ingresa un nombre de presupuesto';

  @override
  String get description => 'Descripción';

  @override
  String get descriptionOptional => 'Descripción (Opcional)';

  @override
  String get descriptionHint => 'Agrega una descripción...';

  @override
  String get budgetType => 'Tipo de Presupuesto';

  @override
  String get personalBudget => 'Personal';

  @override
  String get personalBudgetDescription => 'Solo para ti';

  @override
  String get sharedBudget => 'Compartido';

  @override
  String get sharedBudgetDescription => 'Con otros';

  @override
  String get iconOptional => 'Ícono (Opcional)';

  @override
  String get colorOptional => 'Color (Opcional)';

  @override
  String get budgetCreatedSuccess => 'Presupuesto creado exitosamente';

  @override
  String get budgetDeletedSuccess => 'Presupuesto eliminado';

  @override
  String get deleteBudgetTitle => 'Eliminar Presupuesto';

  @override
  String get deleteBudgetConfirm =>
      '¿Estás seguro de que quieres eliminar este presupuesto? Esta acción no se puede deshacer.';

  @override
  String get budgetOverview => 'Resumen del Presupuesto';

  @override
  String get totalBudget => 'Presupuesto Total';

  @override
  String get period => 'Período';

  @override
  String get duration => 'Duración';

  @override
  String get from => 'Desde';

  @override
  String get to => 'Hasta';

  @override
  String get invite => 'Invitar';

  @override
  String membersCount(int count) {
    return '$count miembros';
  }

  @override
  String get recentItems => 'Ítems Recientes';

  @override
  String get noItemsYet => 'Aún no hay ítems';

  @override
  String get noHistoryYet => 'Aún no hay historial';

  @override
  String get selectStartEndDates =>
      'Por favor selecciona fechas de inicio y fin';

  @override
  String get enterBudgetName => 'Por favor ingresa un nombre de presupuesto';

  @override
  String get addDescription => 'Agrega una descripción...';

  @override
  String get onlyForYou => 'Solo para ti';

  @override
  String get withOthers => 'Con otros';

  @override
  String get enterBudgetAmount => 'Por favor ingresa un monto de presupuesto';

  @override
  String get enterValidAmount => 'Por favor ingresa un monto válido';

  @override
  String get budgetDeleted => 'Presupuesto eliminado';

  @override
  String get deleteBudget => 'Eliminar Presupuesto';

  @override
  String get deleteBudgetConfirmation =>
      '¿Estás seguro de que quieres eliminar este presupuesto? Esta acción no se puede deshacer.';

  @override
  String get noBudgetSelected => 'No hay presupuesto seleccionado';

  @override
  String get pleaseSelectStartEndDates =>
      'Por favor selecciona las fechas de inicio y fin';

  @override
  String get budgetAmountGreaterThanZero => 'Por favor ingresa un monto válido';

  @override
  String get expensesByMember => 'Gastos por Miembro';

  @override
  String get viewExpensesByMember => 'Ver Gastos por Miembro';

  @override
  String get memberExpenses => 'Gastos de Miembros';

  @override
  String get completedItems => 'Ítems completados';

  @override
  String get totalCompleted => 'Total completado';

  @override
  String get itemsPurchased => 'Ítems comprados';

  @override
  String get totalPurchased => 'Total comprado';

  @override
  String get noCompletedItems => 'Sin ítems completados';

  @override
  String get noPurchasedItems => 'Sin ítems comprados';

  @override
  String get noCompletedItemsDescription =>
      'Este miembro aún no ha completado ningún ítem';

  @override
  String get viewItemDetails => 'Ver Detalles';

  @override
  String get itemDetails => 'Detalles de Ítems';

  @override
  String completedBy(String name) {
    return 'Completado por $name';
  }

  @override
  String completedOn(String date) {
    return 'Completado el $date';
  }

  @override
  String itemsCompletedCount(int count) {
    return '$count ítems';
  }

  @override
  String contributionPercentage(String percentage) {
    return '$percentage% del total';
  }

  @override
  String get noMemberExpenses => 'Sin gastos registrados';

  @override
  String get noMemberExpensesDescription =>
      'Los miembros aún no han completado ítems en este presupuesto';

  @override
  String get errorLoadingBudget => 'Error al cargar presupuesto';

  @override
  String get budgetNotFound => 'Presupuesto no encontrado';

  @override
  String get errorAddingItem => 'Error al agregar ítem';

  @override
  String get currentBudgetStatus => 'Estado Actual del Presupuesto';

  @override
  String get currentRemaining => 'Restante Actual';

  @override
  String get afterAdding => 'Después de agregar este ítem';

  @override
  String get budgetWillBeExceeded => 'Este ítem excederá tu presupuesto';

  @override
  String get errorUpdatingBudget => 'Error al actualizar presupuesto';

  @override
  String get currentBudgetLabel => 'Presupuesto Actual';

  @override
  String get newRemainingLabel => 'Nuevo Restante';

  @override
  String get budgetLowerThanSpent =>
      'El nuevo presupuesto es menor que el gasto actual';
}
