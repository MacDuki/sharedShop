import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'DASHBOARD'**
  String get dashboard;

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String dashboardGreeting(String name);

  /// No description provided for @remainingBudget.
  ///
  /// In en, this message translates to:
  /// **'REMAINING BUDGET'**
  String get remainingBudget;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @onTrack.
  ///
  /// In en, this message translates to:
  /// **'On Track'**
  String get onTrack;

  /// No description provided for @percentageRemaining.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% Remaining'**
  String percentageRemaining(String percentage);

  /// No description provided for @amountSpent.
  ///
  /// In en, this message translates to:
  /// **'\${amount} Spent'**
  String amountSpent(String amount);

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get total;

  /// No description provided for @daysLeftLabel.
  ///
  /// In en, this message translates to:
  /// **'DAYS LEFT'**
  String get daysLeftLabel;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String daysLeft(int days);

  /// No description provided for @currentBudget.
  ///
  /// In en, this message translates to:
  /// **'CURRENT BUDGET'**
  String get currentBudget;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @quarter.
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get quarter;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @budgetPeriod.
  ///
  /// In en, this message translates to:
  /// **'Budget Period'**
  String get budgetPeriod;

  /// No description provided for @spentThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Spent this {period}'**
  String spentThisMonth(String period);

  /// No description provided for @shoppingList.
  ///
  /// In en, this message translates to:
  /// **'SHOPPING LIST'**
  String get shoppingList;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String items(int count);

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'{count} item'**
  String item(int count);

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @purchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get purchased;

  /// No description provided for @emptyShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Empty list'**
  String get emptyShoppingList;

  /// No description provided for @emptyShoppingListDescription.
  ///
  /// In en, this message translates to:
  /// **'Add items to your shopping list\nto get started'**
  String get emptyShoppingListDescription;

  /// No description provided for @addFirstItem.
  ///
  /// In en, this message translates to:
  /// **'Add First Item'**
  String get addFirstItem;

  /// No description provided for @markAsPurchased.
  ///
  /// In en, this message translates to:
  /// **'Mark as purchased'**
  String get markAsPurchased;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get deleteItem;

  /// No description provided for @percentageUsed.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% used'**
  String percentageUsed(String percentage);

  /// No description provided for @budgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'Budget exceeded'**
  String get budgetExceeded;

  /// No description provided for @nearLimit.
  ///
  /// In en, this message translates to:
  /// **'Near limit'**
  String get nearLimit;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get nameRequired;

  /// No description provided for @estimatedPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Estimated Price *'**
  String get estimatedPriceRequired;

  /// No description provided for @requiredFieldsMissing.
  ///
  /// In en, this message translates to:
  /// **'Please complete the required fields'**
  String get requiredFieldsMissing;

  /// No description provided for @invalidPriceError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get invalidPriceError;

  /// No description provided for @itemUpdated.
  ///
  /// In en, this message translates to:
  /// **'Item updated'**
  String get itemUpdated;

  /// No description provided for @deleteItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItemTitle;

  /// No description provided for @deleteItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteItemConfirm(String name);

  /// No description provided for @itemDeleted.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted'**
  String itemDeleted(String name);

  /// No description provided for @addNewItem.
  ///
  /// In en, this message translates to:
  /// **'Add New Item'**
  String get addNewItem;

  /// No description provided for @addItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItemTitle;

  /// No description provided for @itemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemNameLabel;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemName;

  /// No description provided for @itemNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Milk, Bread, Eggs...'**
  String get itemNameHint;

  /// No description provided for @estimatedPrice.
  ///
  /// In en, this message translates to:
  /// **'Estimated price'**
  String get estimatedPrice;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @priceHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get priceHint;

  /// No description provided for @categoryOptional.
  ///
  /// In en, this message translates to:
  /// **'Category (optional)'**
  String get categoryOptional;

  /// No description provided for @categoryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Dairy, Bakery, Fruits...'**
  String get categoryHint;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @quantityHint.
  ///
  /// In en, this message translates to:
  /// **'1'**
  String get quantityHint;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategory;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Additional notes (optional)'**
  String get notesHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @itemNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get itemNameRequired;

  /// No description provided for @priceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a price'**
  String get priceRequired;

  /// No description provided for @priceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price greater than 0'**
  String get priceInvalid;

  /// No description provided for @quantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity is required'**
  String get quantityRequired;

  /// No description provided for @quantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity'**
  String get quantityInvalid;

  /// No description provided for @itemAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Item added successfully'**
  String get itemAddedSuccess;

  /// No description provided for @budgetImpact.
  ///
  /// In en, this message translates to:
  /// **'Budget impact:'**
  String get budgetImpact;

  /// No description provided for @newRemaining.
  ///
  /// In en, this message translates to:
  /// **'New remaining:'**
  String get newRemaining;

  /// No description provided for @budgetExceededWarning.
  ///
  /// In en, this message translates to:
  /// **'You will exceed your budget!'**
  String get budgetExceededWarning;

  /// No description provided for @itemAddedRemaining.
  ///
  /// In en, this message translates to:
  /// **'Item added. Remaining: \${amount}'**
  String itemAddedRemaining(String amount);

  /// No description provided for @fruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get fruits;

  /// No description provided for @vegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get vegetables;

  /// No description provided for @meat.
  ///
  /// In en, this message translates to:
  /// **'Meat'**
  String get meat;

  /// No description provided for @dairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get dairy;

  /// No description provided for @bakery.
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get bakery;

  /// No description provided for @beverages.
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get beverages;

  /// No description provided for @snacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get snacks;

  /// No description provided for @frozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get frozen;

  /// No description provided for @canned.
  ///
  /// In en, this message translates to:
  /// **'Canned'**
  String get canned;

  /// No description provided for @condiments.
  ///
  /// In en, this message translates to:
  /// **'Condiments'**
  String get condiments;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @budgetSettings.
  ///
  /// In en, this message translates to:
  /// **'Budget Settings'**
  String get budgetSettings;

  /// No description provided for @configureBudget.
  ///
  /// In en, this message translates to:
  /// **'Configure Budget'**
  String get configureBudget;

  /// No description provided for @budgetInfoText.
  ///
  /// In en, this message translates to:
  /// **'Define your budget for shared purchases'**
  String get budgetInfoText;

  /// No description provided for @budgetAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Budget Amount'**
  String get budgetAmountLabel;

  /// No description provided for @budgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Budget Amount'**
  String get budgetAmount;

  /// No description provided for @budgetAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get budgetAmountHint;

  /// No description provided for @budgetAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get budgetAmountRequired;

  /// No description provided for @budgetAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount greater than 0'**
  String get budgetAmountInvalid;

  /// No description provided for @budgetPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Budget Period'**
  String get budgetPeriodLabel;

  /// No description provided for @budgetPeriodRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a budget period'**
  String get budgetPeriodRequired;

  /// No description provided for @customPeriodInvalid.
  ///
  /// In en, this message translates to:
  /// **'Select valid dates for the custom period'**
  String get customPeriodInvalid;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @weeklyDescription.
  ///
  /// In en, this message translates to:
  /// **'Budget renews every week'**
  String get weeklyDescription;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @monthlyDescription.
  ///
  /// In en, this message translates to:
  /// **'Budget renews every month'**
  String get monthlyDescription;

  /// No description provided for @customPeriod.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customPeriod;

  /// No description provided for @customPeriodDescription.
  ///
  /// In en, this message translates to:
  /// **'Define your own period'**
  String get customPeriodDescription;

  /// No description provided for @startDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDateLabel;

  /// No description provided for @endDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDateLabel;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
  String get selectStartDate;

  /// No description provided for @selectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select end date'**
  String get selectEndDate;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview:'**
  String get preview;

  /// No description provided for @spentLabel.
  ///
  /// In en, this message translates to:
  /// **'Spent:'**
  String get spentLabel;

  /// No description provided for @remainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining:'**
  String get remainingLabel;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @budgetUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Budget updated successfully'**
  String get budgetUpdatedSuccess;

  /// No description provided for @userSettings.
  ///
  /// In en, this message translates to:
  /// **'User Settings'**
  String get userSettings;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changeProfilePhoto;

  /// No description provided for @photoFeatureNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'This feature will be implemented with image_picker in a future version.'**
  String get photoFeatureNotImplemented;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get editName;

  /// No description provided for @editEmail.
  ///
  /// In en, this message translates to:
  /// **'Edit email'**
  String get editEmail;

  /// No description provided for @nameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Name updated'**
  String get nameUpdated;

  /// No description provided for @emailUpdated.
  ///
  /// In en, this message translates to:
  /// **'Email updated'**
  String get emailUpdated;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @changePlan.
  ///
  /// In en, this message translates to:
  /// **'Change plan'**
  String get changePlan;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @basicFeatures.
  ///
  /// In en, this message translates to:
  /// **'Basic features'**
  String get basicFeatures;

  /// No description provided for @allFeatures.
  ///
  /// In en, this message translates to:
  /// **'All features'**
  String get allFeatures;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email notifications'**
  String get emailNotifications;

  /// No description provided for @budgetAlerts.
  ///
  /// In en, this message translates to:
  /// **'Budget alerts'**
  String get budgetAlerts;

  /// No description provided for @shoppingReminders.
  ///
  /// In en, this message translates to:
  /// **'Shopping reminders'**
  String get shoppingReminders;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a bug'**
  String get reportBug;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get history;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @purchaseHistory.
  ///
  /// In en, this message translates to:
  /// **'Purchase History'**
  String get purchaseHistory;

  /// No description provided for @emptyHistory.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get emptyHistory;

  /// No description provided for @emptyHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'History from previous periods\nwill appear here'**
  String get emptyHistoryDescription;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @totalSpentLabel.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get totalSpentLabel;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @deletePeriod.
  ///
  /// In en, this message translates to:
  /// **'Delete period'**
  String get deletePeriod;

  /// No description provided for @deletePeriodConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this period from history?'**
  String get deletePeriodConfirm;

  /// No description provided for @periodDeleted.
  ///
  /// In en, this message translates to:
  /// **'Period deleted from history'**
  String get periodDeleted;

  /// No description provided for @exceeded.
  ///
  /// In en, this message translates to:
  /// **'Exceeded'**
  String get exceeded;

  /// No description provided for @underControl.
  ///
  /// In en, this message translates to:
  /// **'Under control'**
  String get underControl;

  /// No description provided for @ofAmount.
  ///
  /// In en, this message translates to:
  /// **'Of \${amount}'**
  String ofAmount(String amount);

  /// No description provided for @exceededBy.
  ///
  /// In en, this message translates to:
  /// **'Exceeded by \${amount}'**
  String exceededBy(String amount);

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'You saved \${amount}'**
  String saved(String amount);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get notificationsTitle;

  /// No description provided for @notificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsLabel;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// No description provided for @emptyNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get emptyNotifications;

  /// No description provided for @emptyNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Notifications will appear here'**
  String get emptyNotificationsDescription;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearAll;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAll;

  /// No description provided for @deleteAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all notifications from the current budget?'**
  String get deleteAllConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @groupSettings.
  ///
  /// In en, this message translates to:
  /// **'Group Settings'**
  String get groupSettings;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get groupName;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get addMember;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMember;

  /// No description provided for @removeMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove'**
  String get removeMemberConfirm;

  /// No description provided for @wasRemovedFromBudget.
  ///
  /// In en, this message translates to:
  /// **'was removed from budget'**
  String get wasRemovedFromBudget;

  /// No description provided for @removedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'removed successfully'**
  String get removedSuccessfully;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @leaveGroup.
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get leaveGroup;

  /// No description provided for @inviteMembers.
  ///
  /// In en, this message translates to:
  /// **'Invite Members'**
  String get inviteMembers;

  /// No description provided for @inviteByEmail.
  ///
  /// In en, this message translates to:
  /// **'Invite by email'**
  String get inviteByEmail;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @sendInvitation.
  ///
  /// In en, this message translates to:
  /// **'Send Invitation'**
  String get sendInvitation;

  /// No description provided for @invitationSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent'**
  String get invitationSent;

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invitation code'**
  String get inviteCode;

  /// No description provided for @inviteCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get inviteCodeCopied;

  /// No description provided for @inviteMessageCopied.
  ///
  /// In en, this message translates to:
  /// **'Invitation message copied'**
  String get inviteMessageCopied;

  /// No description provided for @joinGroupMessage.
  ///
  /// In en, this message translates to:
  /// **'Join my shared shopping group with code: {code}'**
  String joinGroupMessage(String code);

  /// No description provided for @myGroup.
  ///
  /// In en, this message translates to:
  /// **'My Group'**
  String get myGroup;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'member'**
  String get member;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @currentMembers.
  ///
  /// In en, this message translates to:
  /// **'Current members'**
  String get currentMembers;

  /// No description provided for @noMembersYet.
  ///
  /// In en, this message translates to:
  /// **'No members yet'**
  String get noMembersYet;

  /// No description provided for @membersCanViewEdit.
  ///
  /// In en, this message translates to:
  /// **'Members will be able to view and edit the shopping list and shared budget'**
  String get membersCanViewEdit;

  /// No description provided for @privateProject.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateProject;

  /// No description provided for @privateProjectNote.
  ///
  /// In en, this message translates to:
  /// **'This is a private budget. Only you can see it.'**
  String get privateProjectNote;

  /// No description provided for @personalProjectWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Share personal budget'**
  String get personalProjectWarningTitle;

  /// No description provided for @personalProjectWarning.
  ///
  /// In en, this message translates to:
  /// **'By sharing this code, your personal budget will no longer be private and other people will be able to access it.'**
  String get personalProjectWarning;

  /// No description provided for @budgetMembers.
  ///
  /// In en, this message translates to:
  /// **'Budget members'**
  String get budgetMembers;

  /// No description provided for @currentBudgetMembers.
  ///
  /// In en, this message translates to:
  /// **'Members of this budget'**
  String get currentBudgetMembers;

  /// No description provided for @onlyYou.
  ///
  /// In en, this message translates to:
  /// **'Only you'**
  String get onlyYou;

  /// No description provided for @shareYourBudget.
  ///
  /// In en, this message translates to:
  /// **'Share your budget'**
  String get shareYourBudget;

  /// No description provided for @shareYourBudgetDescription.
  ///
  /// In en, this message translates to:
  /// **'You can share the selected budget with other users if you wish. They will be able to view and edit expenses.'**
  String get shareYourBudgetDescription;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @noEditPermission.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to edit this budget. Only the creator can edit it.'**
  String get noEditPermission;

  /// No description provided for @filterAndSort.
  ///
  /// In en, this message translates to:
  /// **'Filter and Sort'**
  String get filterAndSort;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// No description provided for @signInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Email'**
  String get signInWithEmail;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(int hours);

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(int days);

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @myBudgets.
  ///
  /// In en, this message translates to:
  /// **'My Budgets'**
  String get myBudgets;

  /// No description provided for @noBudgetsYet.
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get noBudgetsYet;

  /// No description provided for @noBudgetsDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your first budget to get started'**
  String get noBudgetsDescription;

  /// No description provided for @personalBudgets.
  ///
  /// In en, this message translates to:
  /// **'Personal Budgets'**
  String get personalBudgets;

  /// No description provided for @sharedBudgets.
  ///
  /// In en, this message translates to:
  /// **'Shared Budgets'**
  String get sharedBudgets;

  /// No description provided for @newBudget.
  ///
  /// In en, this message translates to:
  /// **'New Budget'**
  String get newBudget;

  /// No description provided for @createBudget.
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get createBudget;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @budgetDetails.
  ///
  /// In en, this message translates to:
  /// **'Budget Details'**
  String get budgetDetails;

  /// No description provided for @switchedToBudget.
  ///
  /// In en, this message translates to:
  /// **'Switched to \"{name}\"'**
  String switchedToBudget(String name);

  /// No description provided for @activeBudget.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeBudget;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @shared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get shared;

  /// No description provided for @budgetName.
  ///
  /// In en, this message translates to:
  /// **'Budget Name'**
  String get budgetName;

  /// No description provided for @budgetNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Groceries, Vacation'**
  String get budgetNameHint;

  /// No description provided for @budgetNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a budget name'**
  String get budgetNameRequired;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add a description...'**
  String get descriptionHint;

  /// No description provided for @budgetType.
  ///
  /// In en, this message translates to:
  /// **'Budget Type'**
  String get budgetType;

  /// No description provided for @personalBudget.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personalBudget;

  /// No description provided for @personalBudgetDescription.
  ///
  /// In en, this message translates to:
  /// **'Only for you'**
  String get personalBudgetDescription;

  /// No description provided for @sharedBudget.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get sharedBudget;

  /// No description provided for @sharedBudgetDescription.
  ///
  /// In en, this message translates to:
  /// **'With others'**
  String get sharedBudgetDescription;

  /// No description provided for @iconOptional.
  ///
  /// In en, this message translates to:
  /// **'Icon (Optional)'**
  String get iconOptional;

  /// No description provided for @colorOptional.
  ///
  /// In en, this message translates to:
  /// **'Color (Optional)'**
  String get colorOptional;

  /// No description provided for @budgetCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Budget created successfully'**
  String get budgetCreatedSuccess;

  /// No description provided for @budgetDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Budget deleted'**
  String get budgetDeletedSuccess;

  /// No description provided for @deleteBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get deleteBudgetTitle;

  /// No description provided for @deleteBudgetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this budget? This action cannot be undone.'**
  String get deleteBudgetConfirm;

  /// No description provided for @budgetOverview.
  ///
  /// In en, this message translates to:
  /// **'Budget Overview'**
  String get budgetOverview;

  /// No description provided for @totalBudget.
  ///
  /// In en, this message translates to:
  /// **'Total Budget'**
  String get totalBudget;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String membersCount(int count);

  /// No description provided for @recentItems.
  ///
  /// In en, this message translates to:
  /// **'Recent Items'**
  String get recentItems;

  /// No description provided for @noItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get noItemsYet;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @selectStartEndDates.
  ///
  /// In en, this message translates to:
  /// **'Please select start and end dates'**
  String get selectStartEndDates;

  /// No description provided for @enterBudgetName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a budget name'**
  String get enterBudgetName;

  /// No description provided for @addDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a description...'**
  String get addDescription;

  /// No description provided for @onlyForYou.
  ///
  /// In en, this message translates to:
  /// **'Only for you'**
  String get onlyForYou;

  /// No description provided for @withOthers.
  ///
  /// In en, this message translates to:
  /// **'With others'**
  String get withOthers;

  /// No description provided for @enterBudgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a budget amount'**
  String get enterBudgetAmount;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @budgetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Budget deleted'**
  String get budgetDeleted;

  /// No description provided for @deleteBudget.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get deleteBudget;

  /// No description provided for @deleteBudgetConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this budget? This action cannot be undone.'**
  String get deleteBudgetConfirmation;

  /// No description provided for @noBudgetSelected.
  ///
  /// In en, this message translates to:
  /// **'No budget selected'**
  String get noBudgetSelected;

  /// No description provided for @pleaseSelectStartEndDates.
  ///
  /// In en, this message translates to:
  /// **'Please select start and end dates'**
  String get pleaseSelectStartEndDates;

  /// No description provided for @budgetAmountGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get budgetAmountGreaterThanZero;

  /// No description provided for @expensesByMember.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Member'**
  String get expensesByMember;

  /// No description provided for @viewExpensesByMember.
  ///
  /// In en, this message translates to:
  /// **'View Expenses by Member'**
  String get viewExpensesByMember;

  /// No description provided for @memberExpenses.
  ///
  /// In en, this message translates to:
  /// **'Member Expenses'**
  String get memberExpenses;

  /// No description provided for @completedItems.
  ///
  /// In en, this message translates to:
  /// **'Completed items'**
  String get completedItems;

  /// No description provided for @totalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Total completed'**
  String get totalCompleted;

  /// No description provided for @itemsPurchased.
  ///
  /// In en, this message translates to:
  /// **'Items purchased'**
  String get itemsPurchased;

  /// No description provided for @totalPurchased.
  ///
  /// In en, this message translates to:
  /// **'Total purchased'**
  String get totalPurchased;

  /// No description provided for @noCompletedItems.
  ///
  /// In en, this message translates to:
  /// **'No completed items'**
  String get noCompletedItems;

  /// No description provided for @noPurchasedItems.
  ///
  /// In en, this message translates to:
  /// **'No items purchased'**
  String get noPurchasedItems;

  /// No description provided for @noCompletedItemsDescription.
  ///
  /// In en, this message translates to:
  /// **'This member hasn\'t completed any items yet'**
  String get noCompletedItemsDescription;

  /// No description provided for @viewItemDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewItemDetails;

  /// No description provided for @itemDetails.
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get itemDetails;

  /// No description provided for @completedBy.
  ///
  /// In en, this message translates to:
  /// **'Completed by {name}'**
  String completedBy(String name);

  /// No description provided for @completedOn.
  ///
  /// In en, this message translates to:
  /// **'Completed on {date}'**
  String completedOn(String date);

  /// No description provided for @itemsCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCompletedCount(int count);

  /// No description provided for @contributionPercentage.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% of total'**
  String contributionPercentage(String percentage);

  /// No description provided for @noMemberExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded'**
  String get noMemberExpenses;

  /// No description provided for @noMemberExpensesDescription.
  ///
  /// In en, this message translates to:
  /// **'Members haven\'t completed any items in this budget yet'**
  String get noMemberExpensesDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
