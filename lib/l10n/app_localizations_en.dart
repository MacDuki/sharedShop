// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboard => 'DASHBOARD';

  @override
  String dashboardGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get remainingBudget => 'REMAINING BUDGET';

  @override
  String get budget => 'Budget';

  @override
  String get remaining => 'Remaining';

  @override
  String get spent => 'Spent';

  @override
  String get onTrack => 'On Track';

  @override
  String percentageRemaining(String percentage) {
    return '$percentage% Remaining';
  }

  @override
  String amountSpent(String amount) {
    return '\$$amount Spent';
  }

  @override
  String get total => 'TOTAL';

  @override
  String get daysLeftLabel => 'DAYS LEFT';

  @override
  String daysLeft(int days) {
    return '$days days left';
  }

  @override
  String get currentBudget => 'CURRENT BUDGET';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get quarter => 'Quarter';

  @override
  String get custom => 'Custom';

  @override
  String get budgetPeriod => 'Budget Period';

  @override
  String spentThisMonth(String period) {
    return 'Spent this $period';
  }

  @override
  String get shoppingList => 'SHOPPING LIST';

  @override
  String items(int count) {
    return '$count items';
  }

  @override
  String item(int count) {
    return '$count item';
  }

  @override
  String get addItem => 'Add Item';

  @override
  String get pending => 'Pending';

  @override
  String get purchased => 'Purchased';

  @override
  String get emptyShoppingList => 'Empty list';

  @override
  String get emptyShoppingListDescription =>
      'Add items to your shopping list\nto get started';

  @override
  String get addFirstItem => 'Add First Item';

  @override
  String get markAsPurchased => 'Mark as purchased';

  @override
  String get deleteItem => 'Delete item';

  @override
  String percentageUsed(String percentage) {
    return '$percentage% used';
  }

  @override
  String get budgetExceeded => 'Budget exceeded';

  @override
  String get nearLimit => 'Near limit';

  @override
  String get editItem => 'Edit Item';

  @override
  String get nameRequired => 'Name *';

  @override
  String get estimatedPriceRequired => 'Estimated Price *';

  @override
  String get requiredFieldsMissing => 'Please complete the required fields';

  @override
  String get invalidPriceError => 'Please enter a valid price';

  @override
  String get itemUpdated => 'Item updated';

  @override
  String get deleteItemTitle => 'Delete Item';

  @override
  String deleteItemConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String itemDeleted(String name) {
    return '$name deleted';
  }

  @override
  String get addNewItem => 'Add New Item';

  @override
  String get addItemTitle => 'Add Item';

  @override
  String get itemNameLabel => 'Item name';

  @override
  String get itemName => 'Item name';

  @override
  String get itemNameHint => 'e.g., Milk, Bread, Eggs...';

  @override
  String get estimatedPrice => 'Estimated price';

  @override
  String get price => 'Price';

  @override
  String get priceHint => '0.00';

  @override
  String get categoryOptional => 'Category (optional)';

  @override
  String get categoryHint => 'e.g., Dairy, Bakery, Fruits...';

  @override
  String get quantity => 'Quantity';

  @override
  String get quantityHint => '1';

  @override
  String get category => 'Category';

  @override
  String get selectCategory => 'Select a category';

  @override
  String get notes => 'Notes';

  @override
  String get notesHint => 'Additional notes (optional)';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get itemNameRequired => 'Please enter a name';

  @override
  String get priceRequired => 'Please enter a price';

  @override
  String get priceInvalid => 'Please enter a valid price greater than 0';

  @override
  String get quantityRequired => 'Quantity is required';

  @override
  String get quantityInvalid => 'Enter a valid quantity';

  @override
  String get itemAddedSuccess => 'Item added successfully';

  @override
  String get budgetImpact => 'Budget impact:';

  @override
  String get newRemaining => 'New remaining:';

  @override
  String get budgetExceededWarning => 'You will exceed your budget!';

  @override
  String itemAddedRemaining(String amount) {
    return 'Item added. Remaining: \$$amount';
  }

  @override
  String get fruits => 'Fruits';

  @override
  String get vegetables => 'Vegetables';

  @override
  String get meat => 'Meat';

  @override
  String get dairy => 'Dairy';

  @override
  String get bakery => 'Bakery';

  @override
  String get beverages => 'Beverages';

  @override
  String get snacks => 'Snacks';

  @override
  String get frozen => 'Frozen';

  @override
  String get canned => 'Canned';

  @override
  String get condiments => 'Condiments';

  @override
  String get other => 'Other';

  @override
  String get budgetSettings => 'Budget Settings';

  @override
  String get configureBudget => 'Configure Budget';

  @override
  String get budgetInfoText => 'Define your budget for shared purchases';

  @override
  String get budgetAmountLabel => 'Budget Amount';

  @override
  String get budgetAmount => 'Budget Amount';

  @override
  String get budgetAmountHint => 'Enter amount';

  @override
  String get budgetAmountRequired => 'Please enter an amount';

  @override
  String get budgetAmountInvalid =>
      'Please enter a valid amount greater than 0';

  @override
  String get budgetPeriodLabel => 'Budget Period';

  @override
  String get budgetPeriodRequired => 'Select a budget period';

  @override
  String get customPeriodInvalid => 'Select valid dates for the custom period';

  @override
  String get weekly => 'Weekly';

  @override
  String get weeklyDescription => 'Budget renews every week';

  @override
  String get monthly => 'Monthly';

  @override
  String get monthlyDescription => 'Budget renews every month';

  @override
  String get customPeriod => 'Custom';

  @override
  String get customPeriodDescription => 'Define your own period';

  @override
  String get startDateLabel => 'Start Date';

  @override
  String get endDateLabel => 'End Date';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectStartDate => 'Select start date';

  @override
  String get selectEndDate => 'Select end date';

  @override
  String get preview => 'Preview:';

  @override
  String get spentLabel => 'Spent:';

  @override
  String get remainingLabel => 'Remaining:';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get budgetUpdatedSuccess => 'Budget updated successfully';

  @override
  String get userSettings => 'User Settings';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get changeProfilePhoto => 'Change profile photo';

  @override
  String get photoFeatureNotImplemented =>
      'This feature will be implemented with image_picker in a future version.';

  @override
  String get understood => 'Understood';

  @override
  String get editName => 'Edit name';

  @override
  String get editEmail => 'Edit email';

  @override
  String get nameUpdated => 'Name updated';

  @override
  String get emailUpdated => 'Email updated';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get subscription => 'Subscription';

  @override
  String get plan => 'Plan';

  @override
  String get changePlan => 'Change plan';

  @override
  String get free => 'Free';

  @override
  String get premium => 'Premium';

  @override
  String get basicFeatures => 'Basic features';

  @override
  String get allFeatures => 'All features';

  @override
  String get perMonth => '/month';

  @override
  String get close => 'Close';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get emailNotifications => 'Email notifications';

  @override
  String get budgetAlerts => 'Budget alerts';

  @override
  String get shoppingReminders => 'Shopping reminders';

  @override
  String get support => 'Support';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get reportBug => 'Report a bug';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get logout => 'Logout';

  @override
  String get history => 'HISTORY';

  @override
  String get historyTitle => 'History';

  @override
  String get purchaseHistory => 'Purchase History';

  @override
  String get emptyHistory => 'No history yet';

  @override
  String get emptyHistoryDescription =>
      'History from previous periods\nwill appear here';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get totalSpentLabel => 'Total spent';

  @override
  String get viewDetails => 'View Details';

  @override
  String get deletePeriod => 'Delete period';

  @override
  String get deletePeriodConfirm =>
      'Are you sure you want to delete this period from history?';

  @override
  String get periodDeleted => 'Period deleted from history';

  @override
  String get exceeded => 'Exceeded';

  @override
  String get underControl => 'Under control';

  @override
  String ofAmount(String amount) {
    return 'Of \$$amount';
  }

  @override
  String exceededBy(String amount) {
    return 'Exceeded by \$$amount';
  }

  @override
  String saved(String amount) {
    return 'You saved \$$amount';
  }

  @override
  String get notificationsTitle => 'NOTIFICATIONS';

  @override
  String get notificationsLabel => 'Notifications';

  @override
  String get viewAll => 'View all';

  @override
  String get notificationDeleted => 'Notification deleted';

  @override
  String get emptyNotifications => 'No notifications';

  @override
  String get emptyNotificationsDescription => 'Notifications will appear here';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get clearAll => 'Clear';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get deleteAllConfirm =>
      'Are you sure you want to delete all notifications from the current budget?';

  @override
  String get delete => 'Delete';

  @override
  String get groupSettings => 'Group Settings';

  @override
  String get groupName => 'Group Name';

  @override
  String get members => 'Members';

  @override
  String get addMember => 'Add Member';

  @override
  String get removeMember => 'Remove Member';

  @override
  String get removeMemberConfirm => 'Are you sure you want to remove';

  @override
  String get wasRemovedFromBudget => 'was removed from budget';

  @override
  String get removedSuccessfully => 'removed successfully';

  @override
  String get remove => 'Remove';

  @override
  String get leaveGroup => 'Leave Group';

  @override
  String get inviteMembers => 'Invite Members';

  @override
  String get inviteByEmail => 'Invite by email';

  @override
  String get emailAddress => 'Email address';

  @override
  String get sendInvitation => 'Send Invitation';

  @override
  String get invitationSent => 'Invitation sent';

  @override
  String get inviteCode => 'Invitation code';

  @override
  String get inviteCodeCopied => 'Code copied to clipboard';

  @override
  String get inviteMessageCopied => 'Invitation message copied';

  @override
  String joinGroupMessage(String code) {
    return 'Join my shared shopping group with code: $code';
  }

  @override
  String get myGroup => 'My Group';

  @override
  String get member => 'member';

  @override
  String get copy => 'Copy';

  @override
  String get currentMembers => 'Current members';

  @override
  String get noMembersYet => 'No members yet';

  @override
  String get membersCanViewEdit =>
      'Members will be able to view and edit the shopping list and shared budget';

  @override
  String get privateProject => 'Private';

  @override
  String get privateProjectNote =>
      'This is a private budget. Only you can see it.';

  @override
  String get personalProjectWarningTitle => '⚠️ Share personal budget';

  @override
  String get personalProjectWarning =>
      'By sharing this code, your personal budget will no longer be private and other people will be able to access it.';

  @override
  String get budgetMembers => 'Budget members';

  @override
  String get currentBudgetMembers => 'Members of this budget';

  @override
  String get onlyYou => 'Only you';

  @override
  String get shareYourBudget => 'Share your budget';

  @override
  String get shareYourBudgetDescription =>
      'You can share the selected budget with other users if you wish. They will be able to view and edit expenses.';

  @override
  String get share => 'Share';

  @override
  String get noEditPermission =>
      'You don\'t have permission to edit this budget. Only the creator can edit it.';

  @override
  String get filterAndSort => 'Filter and Sort';

  @override
  String get all => 'All';

  @override
  String get sortBy => 'Sort by';

  @override
  String get status => 'Status';

  @override
  String get ascending => 'Ascending';

  @override
  String get descending => 'Descending';

  @override
  String get apply => 'Apply';

  @override
  String get login => 'Login';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get signInWithEmail => 'Sign in with Email';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get now => 'Now';

  @override
  String minutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get home => 'Home';

  @override
  String get family => 'Family';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get continueButton => 'Continue';

  @override
  String get skip => 'Skip';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get refresh => 'Refresh';

  @override
  String get retry => 'Retry';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get discard => 'Discard';

  @override
  String get myBudgets => 'My Budgets';

  @override
  String get noBudgetsYet => 'No budgets yet';

  @override
  String get noBudgetsDescription => 'Create your first budget to get started';

  @override
  String get personalBudgets => 'Personal Budgets';

  @override
  String get sharedBudgets => 'Shared Budgets';

  @override
  String get newBudget => 'New Budget';

  @override
  String get createBudget => 'Create Budget';

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get budgetDetails => 'Budget Details';

  @override
  String switchedToBudget(String name) {
    return 'Switched to \"$name\"';
  }

  @override
  String get activeBudget => 'Active';

  @override
  String get personal => 'Personal';

  @override
  String get shared => 'Shared';

  @override
  String get budgetName => 'Budget Name';

  @override
  String get budgetNameHint => 'e.g., Groceries, Vacation';

  @override
  String get budgetNameRequired => 'Please enter a budget name';

  @override
  String get description => 'Description';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get descriptionHint => 'Add a description...';

  @override
  String get budgetType => 'Budget Type';

  @override
  String get personalBudget => 'Personal';

  @override
  String get personalBudgetDescription => 'Only for you';

  @override
  String get sharedBudget => 'Shared';

  @override
  String get sharedBudgetDescription => 'With others';

  @override
  String get iconOptional => 'Icon (Optional)';

  @override
  String get colorOptional => 'Color (Optional)';

  @override
  String get budgetCreatedSuccess => 'Budget created successfully';

  @override
  String get budgetDeletedSuccess => 'Budget deleted';

  @override
  String get deleteBudgetTitle => 'Delete Budget';

  @override
  String get deleteBudgetConfirm =>
      'Are you sure you want to delete this budget? This action cannot be undone.';

  @override
  String get budgetOverview => 'Budget Overview';

  @override
  String get totalBudget => 'Total Budget';

  @override
  String get period => 'Period';

  @override
  String get duration => 'Duration';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get invite => 'Invite';

  @override
  String membersCount(int count) {
    return '$count members';
  }

  @override
  String get recentItems => 'Recent Items';

  @override
  String get noItemsYet => 'No items yet';

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get selectStartEndDates => 'Please select start and end dates';

  @override
  String get enterBudgetName => 'Please enter a budget name';

  @override
  String get addDescription => 'Add a description...';

  @override
  String get onlyForYou => 'Only for you';

  @override
  String get withOthers => 'With others';

  @override
  String get enterBudgetAmount => 'Please enter a budget amount';

  @override
  String get enterValidAmount => 'Please enter a valid amount';

  @override
  String get budgetDeleted => 'Budget deleted';

  @override
  String get deleteBudget => 'Delete Budget';

  @override
  String get deleteBudgetConfirmation =>
      'Are you sure you want to delete this budget? This action cannot be undone.';

  @override
  String get noBudgetSelected => 'No budget selected';

  @override
  String get pleaseSelectStartEndDates => 'Please select start and end dates';

  @override
  String get budgetAmountGreaterThanZero => 'Please enter a valid amount';

  @override
  String get expensesByMember => 'Expenses by Member';

  @override
  String get viewExpensesByMember => 'View Expenses by Member';

  @override
  String get memberExpenses => 'Member Expenses';

  @override
  String get completedItems => 'Completed items';

  @override
  String get totalCompleted => 'Total completed';

  @override
  String get itemsPurchased => 'Items purchased';

  @override
  String get totalPurchased => 'Total purchased';

  @override
  String get noCompletedItems => 'No completed items';

  @override
  String get noPurchasedItems => 'No items purchased';

  @override
  String get noCompletedItemsDescription =>
      'This member hasn\'t completed any items yet';

  @override
  String get viewItemDetails => 'View Details';

  @override
  String get itemDetails => 'Item Details';

  @override
  String completedBy(String name) {
    return 'Completed by $name';
  }

  @override
  String completedOn(String date) {
    return 'Completed on $date';
  }

  @override
  String itemsCompletedCount(int count) {
    return '$count items';
  }

  @override
  String contributionPercentage(String percentage) {
    return '$percentage% of total';
  }

  @override
  String get noMemberExpenses => 'No expenses recorded';

  @override
  String get noMemberExpensesDescription =>
      'Members haven\'t completed any items in this budget yet';
}
