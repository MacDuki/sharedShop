# BudgetProvider Dependency Audit

**Date:** December 27, 2025  
**Purpose:** Read-only analysis of UI dependencies on BudgetProvider  
**Status:** No fixes applied - documentation only

---

## Screen: DashboardScreen

**File:** `lib/screens/dashboard/dashboard_screen.dart`

### Dependencies:

1. **Provider method: `loadUserBudgets()`**

   - Purpose in UI: Initialize data on screen load (initState)
   - Expected type: `Future<void>`
   - Null-safe?: N/A (method call)
   - When accessed: Build time (via addPostFrameCallback)

2. **Provider field: `household`**

   - Purpose in UI: Display household name, check if data loaded
   - Expected type: `HouseholdModel?`
   - Null-safe?: **NO** - shows loading spinner if null, but assumes non-null after loading
   - When accessed: Build time (every rebuild)

3. **Provider field: `activeBudget`**

   - Purpose in UI: Display active budget details, calculate remaining days
   - Expected type: `BudgetModel?`
   - Null-safe?: **NO** - shows loading spinner if null, assumes non-null for calculations
   - When accessed: Build time (every rebuild)

4. **Provider field: `budgetPercentage`**

   - Purpose in UI: Display budget usage percentage
   - Expected type: `double`
   - Null-safe?: Yes (returns 0.0 if null budget)
   - When accessed: Build time

5. **Provider field: `currentUser`**

   - Purpose in UI: Display user name in greeting
   - Expected type: `UserModel?`
   - Null-safe?: Yes (uses household.name as fallback)
   - When accessed: Build time

6. **Provider field: `shoppingItems`**

   - Purpose in UI: Display shopping item count and list
   - Expected type: `List<ShoppingItemModel>`
   - Null-safe?: Yes (returns empty list if null)
   - When accessed: Build time

7. **Provider field: `totalSpent`**

   - Purpose in UI: Display total spent amount
   - Expected type: `double`
   - Null-safe?: Yes (returns 0.0 if null)
   - When accessed: Build time

8. **Provider field: `remainingBudget`**

   - Purpose in UI: Display remaining budget
   - Expected type: `double`
   - Null-safe?: Yes (returns 0.0 if null)
   - When accessed: Build time

9. **Provider field: `budgetState`**

   - Purpose in UI: Determine color/status indicators
   - Expected type: `BudgetState` enum
   - Null-safe?: Yes (returns normal if null)
   - When accessed: Build time

10. **Provider field: `notifications`**
    - Purpose in UI: Display notification count and list preview
    - Expected type: `List<NotificationModel>`
    - Null-safe?: Yes (returns empty list)
    - When accessed: Build time

**Breaking Conditions:**

- If `household` is null after loading completes → UI breaks (shows loading forever)
- If `activeBudget` is null after loading completes → UI breaks (shows loading forever)
- Backend must populate both fields or UI hangs

---

## Screen: BudgetListScreen

**File:** `lib/screens/budget_list/budget_list_screen.dart`

### Dependencies:

1. **Provider field: `budgets`**

   - Purpose in UI: Display list of all budgets, filter by type
   - Expected type: `List<BudgetModel>`
   - Null-safe?: Yes (shows empty state if empty)
   - When accessed: Build time

2. **Provider field: `activeBudget`**

   - Purpose in UI: Highlight which budget is currently active
   - Expected type: `BudgetModel?`
   - Null-safe?: Yes (checks for null explicitly with `?.id`)
   - When accessed: Build time

3. **Provider method: `setActiveBudget(String budgetId)`**
   - Purpose in UI: Switch active budget when user taps a card
   - Expected type: `void` (now `Future<void>`)
   - Null-safe?: N/A
   - When accessed: User interaction (tap on budget card)

**Breaking Conditions:**

- If `setActiveBudget()` is now async, UI doesn't await it → may show stale state briefly
- If `budgets` list is empty but user previously had budgets → confusing UX

---

## Screen: BudgetDetailsScreen

**File:** `lib/screens/budget_details/budget_details_screen.dart`

### Dependencies:

1. **Provider field: `budgets`**

   - Purpose in UI: Find current budget by ID (to get latest data)
   - Expected type: `List<BudgetModel>`
   - Null-safe?: Yes (uses orElse to fallback to passed budget)
   - When accessed: Build time

2. **Provider method: `getItemsForBudget(String budgetId)`**
   - Purpose in UI: Get all items for this specific budget
   - Expected type: `List<ShoppingItemModel>`
   - Null-safe?: Yes
   - When accessed: Build time

**Breaking Conditions:**

- Screen calculates `totalSpent` locally instead of using Provider's computed value
- **INCONSISTENCY:** Screen does local calculation but Provider has `totalSpent` getter
- If items aren't loaded for this budget, calculations show 0

---

## Screen: AddItemScreen

**File:** `lib/screens/add_item/add_item_screen.dart`

### Dependencies:

1. **Provider field: `activeBudget`**

   - Purpose in UI: Get budgetId for new item, validate budget exists
   - Expected type: `BudgetModel?`
   - Null-safe?: **NO** - shows error snackbar if null, but doesn't handle gracefully
   - When accessed: User interaction (save button)

2. **Provider field: `totalSpent`**

   - Purpose in UI: Calculate preview of new total before saving
   - Expected type: `double`
   - Null-safe?: Yes
   - When accessed: Build time (Consumer) and user interaction

3. **Provider field: `household`**

   - Purpose in UI: Calculate remaining budget for feedback
   - Expected type: `HouseholdModel?`
   - Null-safe?: **NO** - uses `!` operator, will crash if null
   - When accessed: Build time (Consumer)

4. **Provider method: `addItem(ShoppingItemModel item)`**
   - Purpose in UI: Save new item to backend
   - Expected type: `Future<void>`
   - Null-safe?: N/A
   - When accessed: User interaction (save button)

**Breaking Conditions:**

- Line 258: `budgetProvider.household!.budgetAmount` will crash if household is null
- If `activeBudget` is null, error handling is weak (just snackbar)
- Uses legacy `household` field instead of `activeBudget.budgetAmount`

---

## Screen: ShoppingListScreen

**File:** `lib/screens/shopping_list/shopping_list_screen.dart`

### Dependencies:

1. **Provider field: `shoppingItems`**

   - Purpose in UI: Display all items, filter by purchased status
   - Expected type: `List<ShoppingItemModel>`
   - Null-safe?: Yes
   - When accessed: Build time

2. **Provider field: `household`**

   - Purpose in UI: Check if data is loaded
   - Expected type: `HouseholdModel?`
   - Null-safe?: **NO** - assumes non-null after initial check
   - When accessed: Build time

3. **Provider field: `totalSpent`**

   - Purpose in UI: Display total spent amount
   - Expected type: `double`
   - Null-safe?: Yes
   - When accessed: Build time

4. **Provider field: `remainingBudget`**

   - Purpose in UI: Display remaining budget
   - Expected type: `double`
   - Null-safe?: Yes
   - When accessed: Build time

5. **Provider field: `budgetState`**

   - Purpose in UI: Color coding for budget status
   - Expected type: `BudgetState` enum
   - Null-safe?: Yes
   - When accessed: Build time

6. **Provider field: `budgetPercentage`**

   - Purpose in UI: Progress bar display
   - Expected type: `double`
   - Null-safe?: Yes
   - When accessed: Build time

7. **Provider method: `toggleItemPurchased(String itemId)`**

   - Purpose in UI: Mark item as purchased/unpurchased
   - Expected type: `Future<void>`
   - Null-safe?: N/A
   - When accessed: User interaction (checkbox tap)

8. **Provider method: `updateItem(String itemId, ShoppingItemModel updatedItem)`**

   - Purpose in UI: Edit item details
   - Expected type: `Future<void>`
   - Null-safe?: N/A
   - When accessed: User interaction (edit dialog save)

9. **Provider method: `deleteItem(String itemId)`**
   - Purpose in UI: Delete item
   - Expected type: `Future<void>`
   - Null-safe?: N/A
   - When accessed: User interaction (delete confirmation)

**Breaking Conditions:**

- Uses legacy `household` field for null checking instead of `activeBudget`
- No loading states during async operations (toggle/update/delete)

---

## Screen: NotificationsScreen

**File:** `lib/screens/notifications/notifications_screen.dart`

### Dependencies:

1. **Provider field: `notifications`**

   - Purpose in UI: Display filtered notifications for active budget
   - Expected type: `List<NotificationModel>`
   - Null-safe?: Yes (returns empty list)
   - When accessed: Build time

2. **Provider field: `allNotifications`**

   - Purpose in UI: Display all notifications across budgets
   - Expected type: `List<NotificationModel>`
   - Null-safe?: Yes
   - When accessed: Build time (in full screen view)

3. **Provider field: `budgets`**

   - Purpose in UI: Find budget by ID to navigate to it
   - Expected type: `List<BudgetModel>`
   - Null-safe?: Yes (uses firstWhere with orElse)
   - When accessed: User interaction (notification tap)

4. **Provider method: `clearAllNotifications()`**

   - Purpose in UI: Clear all notifications
   - Expected type: `void`
   - Null-safe?: N/A
   - When accessed: User interaction (clear all button)

5. **Provider method: `deleteNotification(String notificationId)`**
   - Purpose in UI: Delete single notification
   - Expected type: `void`
   - Null-safe?: N/A
   - When accessed: User interaction (swipe to dismiss)

**Breaking Conditions:**

- Notifications are local-only (not persisted to backend)
- After reload, all notifications disappear

---

## Screen: HistoryScreen

**File:** `lib/screens/history/history_screen.dart`

### Dependencies:

1. **Provider field: `budgetHistory`**

   - Purpose in UI: Display historical budget periods
   - Expected type: `List<BudgetHistoryModel>`
   - Null-safe?: Yes (shows empty state if empty)
   - When accessed: Build time

2. **Provider field: `budgets`**
   - Purpose in UI: Match history items to budget details
   - Expected type: `List<BudgetModel>`
   - Null-safe?: Yes (uses firstWhere with fallback)
   - When accessed: Build time (for each history item)

**Breaking Conditions:**

- No delete functionality wired to backend (commented out in provider)
- History is never populated from backend (empty field in provider)
- Creates fallback budget with empty values if budget not found

---

## Screen: MemberExpensesScreen

**File:** `lib/screens/member_expenses/member_expenses_screen.dart`

### Dependencies:

1. **Provider method: `getItemsForBudget(String budgetId)`**

   - Purpose in UI: Get all items for budget, filter purchased ones
   - Expected type: `List<ShoppingItemModel>`
   - Null-safe?: Yes
   - When accessed: Build time

2. **Provider field: `householdMembers`**
   - Purpose in UI: Display member names and details
   - Expected type: `List<UserModel>`
   - Null-safe?: Yes (filters with where clause)
   - When accessed: Build time

**Breaking Conditions:**

- If `householdMembers` is empty, shows "Unknown User" for all purchases
- Members are never loaded from backend (`loadBudgetDetails` should populate this)

---

## Screen: InviteMembersScreen

**File:** `lib/screens/invite_members/invite_members_screen.dart`

### Dependencies:

1. **Provider field: `household`**

   - Purpose in UI: Generate invite code using household ID
   - Expected type: `HouseholdModel?`
   - Null-safe?: Yes (uses `?.id ?? ''` fallback)
   - When accessed: Screen init (initState)

2. **Provider field: `activeBudget`**

   - Purpose in UI: Check budget type for warning dialog
   - Expected type: `BudgetModel?`
   - Null-safe?: Yes (uses `?.type` safe navigation)
   - When accessed: User interaction (share button)

3. **Provider field: `householdMembers`**
   - Purpose in UI: Display current members list
   - Expected type: `List<UserModel>`
   - Null-safe?: Yes
   - When accessed: Build time

**Breaking Conditions:**

- Uses legacy `household` field
- Invite functionality is fake (no backend integration)
- Remove member functionality is local-only

---

## Screen: BudgetFormScreen

**File:** `lib/screens/budget_form/budget_form_screen.dart`

### Dependencies:

1. **Provider method: `updateBudgetData(BudgetModel updatedBudget)`**

   - Purpose in UI: Save edited budget
   - Expected type: `Future<void>`
   - Null-safe?: N/A
   - When accessed: User interaction (save button in edit mode)

2. **Provider method: `addBudget(BudgetModel budget)`**

   - Purpose in UI: Create new budget
   - Expected type: `Future<void>`
   - Null-safe?: N/A
   - When accessed: User interaction (save button in create mode)

3. **Provider method: `deleteBudget(String budgetId)`**
   - Purpose in UI: Delete existing budget
   - Expected type: `Future<void>`
   - Null-safe?: N/A
   - When accessed: User interaction (delete confirmation)

**Breaking Conditions:**

- No loading states during async save/delete operations
- Doesn't handle errors from backend (try-catch but only shows generic error)

---

## Screen: UserSettingsScreen

**File:** `lib/screens/user_settings/user_settings_screen.dart`

### Dependencies:

1. **Provider field: `currentUser`**
   - Purpose in UI: Display user name and email
   - Expected type: `UserModel?`
   - Null-safe?: Yes (uses `?. ?? 'fallback'` pattern)
   - When accessed: Build time

**Breaking Conditions:**

- `currentUser` is never populated from backend (always null)
- Falls back to hardcoded strings

---

## Widget: BudgetCard

**File:** `lib/widgets/budget/budget_card.dart`

### Dependencies:

- **NO DIRECT DEPENDENCIES** - receives data as props

---

## Widget: ShoppingItemCard

**File:** `lib/widgets/shopping/shopping_item_card.dart`

### Dependencies:

- **NO DIRECT DEPENDENCIES** - receives data as props

---

## Critical Findings Summary

### Fields Never Populated from Backend:

1. ✅ `household` - Legacy field, no longer loaded
2. ✅ `currentUser` - Never loaded (constructor missing backend call)
3. ❌ `budgetHistory` - Empty, no backend integration
4. ❌ `householdMembers` - Empty until `loadBudgetDetails()` called
5. ❌ `notifications` - Local only, cleared on reload

### Fields Populated Only via `loadUserBudgets()`:

1. ✅ `budgets` - Loaded correctly

### Fields Populated Only via `loadBudgetDetails()`:

1. ✅ `activeBudget` - Set correctly
2. ✅ `householdMembers` - Should be populated (NEW)

### Fields Populated Only via `loadBudgetItems()`:

1. ✅ `shoppingItems` - Loaded correctly

### Computed Fields (Always Safe):

1. ✅ `totalSpent` - Computed from items
2. ✅ `remainingBudget` - Computed from budget/items
3. ✅ `budgetPercentage` - Computed from budget/items
4. ✅ `budgetState` - Computed from percentage

### Async Method Changes (Breaking):

- `setActiveBudget()` changed from `void` to `Future<void>` - screens don't await!

### Local-Only Operations (Not Persisted):

- Notifications (create/delete)
- Budget history (never loaded or saved)

### Null Safety Issues:

1. **CRITICAL:** `AddItemScreen` line 258 uses `household!` (will crash)
2. **CRITICAL:** Multiple screens check `household == null` but it's never populated
3. **WARNING:** `DashboardScreen` shows loading forever if household/activeBudget null

### Inconsistencies:

1. `BudgetDetailsScreen` calculates `totalSpent` locally, ignores Provider getter
2. Many screens use legacy `household` field instead of `activeBudget`
3. `AddItemScreen` uses `household.budgetAmount` instead of `activeBudget.budgetAmount`

---

## Recommendations (NOT IMPLEMENTED):

1. **Remove legacy `household` field** - causes confusion
2. **Populate `currentUser` on auth** - currently always null
3. **Call `loadBudgetDetails()` after `loadUserBudgets()`** - to populate members
4. **Add loading states** for all async operations
5. **Await `setActiveBudget()`** in all calling screens
6. **Fix `AddItemScreen` crash** - remove `!` operator on household
7. **Wire up budget history** to backend or remove UI
8. **Persist notifications** to backend or remove feature

---

**End of Audit**
