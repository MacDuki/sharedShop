/**
 * Cloud Functions for Shared Grocery Budget App
 * Implementation of Phase 1: Foundation (Sprints 1.1, 1.2, 1.3)
 */

const {
  onRequest,
  onCall,
  HttpsError,
} = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const { initializeApp } = require("firebase-admin/app");
const {
  getFirestore,
  Timestamp,
  FieldValue,
} = require("firebase-admin/firestore");
const { getAuth } = require("firebase-admin/auth");
const logger = require("firebase-functions/logger");
const crypto = require("crypto");

// Initialize Firebase Admin
initializeApp();
const db = getFirestore();
const auth = getAuth();

// Global options for cost control
setGlobalOptions({ maxInstances: 10 });

// ============================================================================
// PHASE 1 - SPRINT 1.1: AUTHENTICATION AND USERS
// ============================================================================

/**
 * 1.1 createUserProfile
 * Trigger: onCreate - Creates user profile in Firestore when user registers
 */
exports.createUserProfile = onDocumentCreated(
  "users/{userId}",
  async (event) => {
    try {
      const userId = event.params.userId;
      const userData = event.data.data();

      logger.info("User document created", { userId });

      // Check if it's a new user or just document creation
      if (!userData) {
        logger.info("No user data, skipping");
        return;
      }

      return { success: true };
    } catch (error) {
      logger.error("Error in createUserProfile trigger", {
        error: error.message,
      });
      throw error;
    }
  }
);

/**
 * 1.2 getUserBudgets
 * Callable Function: Gets all budgets where user is owner or member
 */
exports.getUserBudgets = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const userId = request.auth.uid;
    logger.info("Getting user budgets", { userId });

    // Query budgets where user is owner or member
    const budgetsSnapshot = await db
      .collection("budgets")
      .where("memberIds", "array-contains", userId)
      .get();

    const budgets = [];
    for (const doc of budgetsSnapshot.docs) {
      const budgetData = doc.data();

      // Calculate current total spent
      const itemsSnapshot = await db
        .collection("shoppingItems")
        .where("budgetId", "==", doc.id)
        .where("isPurchased", "==", true)
        .get();

      const totalSpent = itemsSnapshot.docs.reduce(
        (sum, item) => sum + (item.data().estimatedPrice || 0),
        0
      );

      budgets.push({
        id: doc.id,
        name: budgetData.name,
        budgetAmount: budgetData.budgetAmount,
        totalSpent: totalSpent,
        remaining: budgetData.budgetAmount - totalSpent,
        currentPeriodEnd: budgetData.currentPeriodEnd,
        isOwner: budgetData.ownerId === userId,
        memberCount: budgetData.memberIds.length,
      });
    }

    logger.info("User budgets retrieved", { userId, count: budgets.length });
    return { budgets };
  } catch (error) {
    logger.error("Error getting user budgets", {
      userId: request.auth?.uid,
      error: error.message,
    });
    throw new HttpsError("internal", error.message);
  }
});

/**
 * 1.3 updateUserProfile
 * Callable Function: Updates user profile information
 */
exports.updateUserProfile = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const userId = request.auth.uid;
    const data = request.data;
    logger.info("Updating user profile", { userId, data });

    const updates = {};
    if (data.name !== undefined) updates.name = data.name;
    if (data.photoURL !== undefined) updates.photoURL = data.photoURL;

    if (Object.keys(updates).length === 0) {
      throw new HttpsError("invalid-argument", "No valid fields to update");
    }

    updates.updatedAt = FieldValue.serverTimestamp();

    await db.collection("users").doc(userId).update(updates);

    // Sync with Firebase Auth if name changed
    if (data.name !== undefined) {
      await auth.updateUser(userId, { displayName: data.name });
    }

    logger.info("User profile updated successfully", { userId });
    return { success: true, updates };
  } catch (error) {
    logger.error("Error updating user profile", {
      userId: request.auth?.uid,
      error: error.message,
    });
    throw new HttpsError("internal", error.message);
  }
});

// ============================================================================
// PHASE 1 - SPRINT 1.2: BUDGET MANAGEMENT
// ============================================================================

/**
 * 2.1 createBudget
 * Callable Function: Creates a new shared budget
 */
exports.createBudget = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    // Validate input
    if (!data.name || typeof data.name !== "string") {
      throw new HttpsError("invalid-argument", "Budget name is required");
    }

    if (
      !data.budgetAmount ||
      typeof data.budgetAmount !== "number" ||
      data.budgetAmount <= 0
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Budget amount must be a positive number"
      );
    }

    if (
      !data.budgetPeriod ||
      !["weekly", "monthly", "custom"].includes(data.budgetPeriod)
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Budget period must be weekly, monthly, or custom"
      );
    }

    const userId = request.auth.uid;
    logger.info("Creating budget", { userId, budgetName: data.name });

    // Calculate current period end
    let currentPeriodEnd;
    const now = new Date();

    if (data.budgetPeriod === "weekly") {
      currentPeriodEnd = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
    } else if (data.budgetPeriod === "monthly") {
      currentPeriodEnd = new Date(
        now.getFullYear(),
        now.getMonth() + 1,
        now.getDate()
      );
    } else if (data.budgetPeriod === "custom") {
      if (!data.customPeriodEnd) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Custom period end date is required"
        );
      }
      currentPeriodEnd = new Date(data.customPeriodEnd);
    }

    // Create budget document
    const budgetData = {
      name: data.name,
      description: data.description || null,
      budgetAmount: data.budgetAmount,
      budgetPeriod: data.budgetPeriod,
      ownerId: userId,
      memberIds: [userId],
      currentPeriodEnd: Timestamp.fromDate(currentPeriodEnd),
      iconName: data.iconName || null,
      colorHex: data.colorHex || null,
      createdAt: FieldValue.serverTimestamp(),
    };

    const budgetRef = await db.collection("budgets").add(budgetData);

    // Update user's budgetIds
    await db
      .collection("users")
      .doc(userId)
      .update({
        budgetIds: FieldValue.arrayUnion(budgetRef.id),
      });

    logger.info("Budget created successfully", {
      userId,
      budgetId: budgetRef.id,
    });

    return {
      budgetId: budgetRef.id,
      budget: {
        id: budgetRef.id,
        ...budgetData,
      },
    };
  } catch (error) {
    logger.error("Error creating budget", {
      userId: request.auth?.uid,
      error: error.message,
    });
    throw new HttpsError("internal", error.message);
  }
});

/**
 * 2.2 getBudgetDetails
 * Callable Function: Gets complete budget information with statistics
 */
exports.getBudgetDetails = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    if (!data.budgetId || typeof data.budgetId !== "string") {
      throw new HttpsError("invalid-argument", "Budget ID is required");
    }

    const userId = request.auth.uid;
    logger.info("Getting budget details", { userId, budgetId: data.budgetId });

    // Get budget
    const budgetDoc = await db.collection("budgets").doc(data.budgetId).get();

    if (!budgetDoc.exists) {
      throw new HttpsError("not-found", "Budget not found");
    }

    const budgetData = budgetDoc.data();

    // Validate user is member
    if (!budgetData.memberIds.includes(userId)) {
      throw new HttpsError(
        "permission-denied",
        "User is not a member of this budget"
      );
    }

    // Get all items
    const itemsSnapshot = await db
      .collection("shoppingItems")
      .where("budgetId", "==", data.budgetId)
      .get();

    let totalSpent = 0;
    let itemCount = 0;
    let purchasedItemCount = 0;

    itemsSnapshot.forEach((doc) => {
      const item = doc.data();
      itemCount++;
      if (item.isPurchased) {
        purchasedItemCount++;
        totalSpent += item.estimatedPrice || 0;
      }
    });

    const remaining = budgetData.budgetAmount - totalSpent;
    const percentageUsed = (totalSpent / budgetData.budgetAmount) * 100;

    // Determine status
    let status = "ok";
    if (percentageUsed >= 100) {
      status = "exceeded";
    } else if (percentageUsed >= 80) {
      status = "warning";
    }

    // Calculate days remaining based on budget period
    let daysRemaining = 0;
    if (budgetData.currentPeriodEnd) {
      const now = new Date();
      const periodEnd = budgetData.currentPeriodEnd.toDate();
      const diffTime = periodEnd.getTime() - now.getTime();
      daysRemaining = Math.max(0, Math.ceil(diffTime / (1000 * 60 * 60 * 24)));
    }

    // Get member details
    const members = [];
    for (const memberId of budgetData.memberIds) {
      const userDoc = await db.collection("users").doc(memberId).get();
      if (userDoc.exists) {
        const userData = userDoc.data();
        members.push({
          userId: memberId,
          name: userData.name,
          email: userData.email,
          photoURL: userData.photoURL,
          isOwner: memberId === budgetData.ownerId,
        });
      }
    }

    logger.info("Budget details retrieved", { budgetId: data.budgetId });

    return {
      budget: {
        id: budgetDoc.id,
        name: budgetData.name,
        description: budgetData.description || null,
        budgetAmount: budgetData.budgetAmount,
        budgetPeriod: budgetData.budgetPeriod,
        totalSpent: totalSpent,
        remaining: remaining,
        percentageUsed: percentageUsed,
        status: status,
        daysRemaining: daysRemaining,
        currentPeriodEnd: budgetData.currentPeriodEnd,
        iconName: budgetData.iconName || null,
        colorHex: budgetData.colorHex || null,
        members: members,
        memberIds: budgetData.memberIds,
        itemCount: itemCount,
        purchasedItemCount: purchasedItemCount,
        ownerId: budgetData.ownerId,
        createdAt: budgetData.createdAt,
      },
    };
  } catch (error) {
    logger.error("Error getting budget details", {
      userId: request.auth?.uid,
      budgetId: data.budgetId,
      error: error.message,
    });
    throw new HttpsError("internal", error.message);
  }
});

/**
 * 2.3 updateBudget
 * Callable Function: Updates budget configuration
 */
exports.updateBudget = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    if (!data.budgetId || typeof data.budgetId !== "string") {
      throw new HttpsError("invalid-argument", "Budget ID is required");
    }

    const userId = request.auth.uid;
    logger.info("Updating budget", { userId, budgetId: data.budgetId });

    // Get budget
    const budgetRef = db.collection("budgets").doc(data.budgetId);
    const budgetDoc = await budgetRef.get();

    if (!budgetDoc.exists) {
      throw new HttpsError("not-found", "Budget not found");
    }

    const budgetData = budgetDoc.data();

    // Validate user is owner
    if (budgetData.ownerId !== userId) {
      throw new HttpsError(
        "permission-denied",
        "Only the owner can update the budget"
      );
    }

    // Build updates object
    const updates = {};
    if (data.name !== undefined) updates.name = data.name;
    if (data.description !== undefined)
      updates.description = data.description || null;
    if (data.iconName !== undefined) updates.iconName = data.iconName || null;
    if (data.colorHex !== undefined) updates.colorHex = data.colorHex || null;
    if (data.budgetAmount !== undefined) {
      if (typeof data.budgetAmount !== "number" || data.budgetAmount <= 0) {
        throw new HttpsError(
          "invalid-argument",
          "Budget amount must be a positive number"
        );
      }
      updates.budgetAmount = data.budgetAmount;
    }

    if (data.budgetPeriod !== undefined) {
      if (!["weekly", "monthly", "custom"].includes(data.budgetPeriod)) {
        throw new HttpsError("invalid-argument", "Invalid budget period");
      }
      updates.budgetPeriod = data.budgetPeriod;

      // Recalculate period end
      const now = new Date();
      let currentPeriodEnd;

      if (data.budgetPeriod === "weekly") {
        currentPeriodEnd = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
      } else if (data.budgetPeriod === "monthly") {
        currentPeriodEnd = new Date(
          now.getFullYear(),
          now.getMonth() + 1,
          now.getDate()
        );
      } else if (data.budgetPeriod === "custom") {
        if (!data.customPeriodEnd) {
          throw new HttpsError(
            "invalid-argument",
            "Custom period end date is required"
          );
        }
        currentPeriodEnd = new Date(data.customPeriodEnd);
      }

      updates.currentPeriodEnd = Timestamp.fromDate(currentPeriodEnd);
    }

    if (Object.keys(updates).length === 0) {
      throw new HttpsError("invalid-argument", "No valid fields to update");
    }

    updates.updatedAt = FieldValue.serverTimestamp();

    await budgetRef.update(updates);

    logger.info("Budget updated successfully", { budgetId: data.budgetId });

    return { success: true, updates };
  } catch (error) {
    logger.error("Error updating budget", {
      userId: request.auth?.uid,
      budgetId: data.budgetId,
      error: error.message,
    });
    throw new HttpsError("internal", error.message);
  }
});

// ============================================================================
// PHASE 1 - SPRINT 1.3: SHOPPING ITEMS MANAGEMENT
// ============================================================================

/**
 * 3.1 addShoppingItem
 * Callable Function: Adds a new item to the shopping list
 */
exports.addShoppingItem = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    // Validate input
    if (!data.budgetId || typeof data.budgetId !== "string") {
      throw new HttpsError("invalid-argument", "Budget ID is required");
    }

    if (!data.name || typeof data.name !== "string") {
      throw new HttpsError("invalid-argument", "Item name is required");
    }

    if (
      !data.estimatedPrice ||
      typeof data.estimatedPrice !== "number" ||
      data.estimatedPrice <= 0
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Estimated price must be a positive number"
      );
    }

    const userId = request.auth.uid;
    logger.info("Adding shopping item", { userId, budgetId: data.budgetId });

    // Verify budget exists and user is member
    const budgetDoc = await db.collection("budgets").doc(data.budgetId).get();

    if (!budgetDoc.exists) {
      throw new HttpsError("not-found", "Budget not found");
    }

    const budgetData = budgetDoc.data();

    if (!budgetData.memberIds.includes(userId)) {
      throw new HttpsError(
        "permission-denied",
        "User is not a member of this budget"
      );
    }

    // Create shopping item
    const itemData = {
      budgetId: data.budgetId,
      name: data.name,
      estimatedPrice: data.estimatedPrice,
      category: data.category || "",
      createdBy: userId,
      createdAt: FieldValue.serverTimestamp(),
      isPurchased: false,
      purchasedBy: null,
      purchasedAt: null,
    };

    const itemRef = await db.collection("shoppingItems").add(itemData);

    // Calculate new total spent (only purchased items)
    const itemsSnapshot = await db
      .collection("shoppingItems")
      .where("budgetId", "==", data.budgetId)
      .where("isPurchased", "==", true)
      .get();

    const totalSpent = itemsSnapshot.docs.reduce(
      (sum, doc) => sum + (doc.data().estimatedPrice || 0),
      0
    );

    const remaining = budgetData.budgetAmount - totalSpent;
    const exceeded = remaining < 0;

    logger.info("Shopping item added successfully", { itemId: itemRef.id });

    return {
      itemId: itemRef.id,
      item: {
        id: itemRef.id,
        ...itemData,
      },
      budgetStatus: {
        totalSpent: totalSpent,
        remaining: remaining,
        exceeded: exceeded,
      },
    };
  } catch (error) {
    logger.error("Error adding shopping item", {
      userId: request.auth?.uid,
      budgetId: data.budgetId,
      error: error.message,
    });
    throw new HttpsError("internal", error.message);
  }
});

/**
 * 3.2 updateShoppingItem
 * Callable Function: Updates an existing shopping item
 */
exports.updateShoppingItem = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    if (!data.itemId || typeof data.itemId !== "string") {
      throw new HttpsError("invalid-argument", "Item ID is required");
    }

    const userId = request.auth.uid;
    logger.info("Updating shopping item", { userId, itemId: data.itemId });

    // Get item
    const itemRef = db.collection("shoppingItems").doc(data.itemId);
    const itemDoc = await itemRef.get();

    if (!itemDoc.exists) {
      throw new HttpsError("not-found", "Item not found");
    }

    const itemData = itemDoc.data();

    // Verify user is member of the budget
    const budgetDoc = await db
      .collection("budgets")
      .doc(itemData.budgetId)
      .get();

    if (!budgetDoc.exists) {
      throw new HttpsError("not-found", "Budget not found");
    }

    const budgetData = budgetDoc.data();

    if (!budgetData.memberIds.includes(userId)) {
      throw new HttpsError(
        "permission-denied",
        "User is not a member of this budget"
      );
    }

    // Build updates object
    const updates = {};
    if (data.name !== undefined) updates.name = data.name;
    if (data.category !== undefined) updates.category = data.category;

    if (data.estimatedPrice !== undefined) {
      if (typeof data.estimatedPrice !== "number" || data.estimatedPrice <= 0) {
        throw new HttpsError(
          "invalid-argument",
          "Estimated price must be a positive number"
        );
      }
      updates.estimatedPrice = data.estimatedPrice;
    }

    if (data.isPurchased !== undefined) {
      updates.isPurchased = data.isPurchased;
      if (data.isPurchased === true && !itemData.isPurchased) {
        updates.purchasedBy = userId;
        updates.purchasedAt = FieldValue.serverTimestamp();
      } else if (data.isPurchased === false) {
        updates.purchasedBy = null;
        updates.purchasedAt = null;
      }
    }

    if (Object.keys(updates).length === 0) {
      throw new HttpsError("invalid-argument", "No valid fields to update");
    }

    updates.updatedAt = FieldValue.serverTimestamp();

    await itemRef.update(updates);

    logger.info("Shopping item updated successfully", { itemId: data.itemId });

    return { success: true, updates };
  } catch (error) {
    logger.error("Error updating shopping item", {
      userId: request.auth?.uid,
      itemId: data.itemId,
      error: error.message,
    });
    throw new HttpsError("internal", error.message);
  }
});

/**
 * 3.3 getBudgetItems
 * Callable Function: Gets all items for a budget
 */
exports.getBudgetItems = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    if (!data.budgetId || typeof data.budgetId !== "string") {
      throw new HttpsError("invalid-argument", "Budget ID is required");
    }

    const userId = request.auth.uid;
    const filter = data.filter || "all";

    logger.info("Getting budget items", {
      userId,
      budgetId: data.budgetId,
      filter,
    });

    // Verify budget exists and user is member
    const budgetDoc = await db.collection("budgets").doc(data.budgetId).get();

    if (!budgetDoc.exists) {
      throw new HttpsError("not-found", "Budget not found");
    }

    const budgetData = budgetDoc.data();

    if (!budgetData.memberIds.includes(userId)) {
      throw new HttpsError(
        "permission-denied",
        "User is not a member of this budget"
      );
    }

    // Build query
    let query = db
      .collection("shoppingItems")
      .where("budgetId", "==", data.budgetId);

    if (filter === "active") {
      query = query.where("isPurchased", "==", false);
    } else if (filter === "purchased") {
      query = query.where("isPurchased", "==", true);
    }

    const itemsSnapshot = await query.orderBy("createdAt", "desc").get();

    const items = [];
    let totalValue = 0;

    for (const doc of itemsSnapshot.docs) {
      const itemData = doc.data();

      // Get creator info
      const creatorDoc = await db
        .collection("users")
        .doc(itemData.createdBy)
        .get();
      const creatorData = creatorDoc.exists ? creatorDoc.data() : {};

      items.push({
        id: doc.id,
        name: itemData.name,
        estimatedPrice: itemData.estimatedPrice,
        category: itemData.category,
        isPurchased: itemData.isPurchased,
        createdBy: itemData.createdBy,
        createdByName: creatorData.name || "Unknown",
        createdAt: itemData.createdAt,
        purchasedBy: itemData.purchasedBy,
        purchasedAt: itemData.purchasedAt,
      });

      if (itemData.isPurchased) {
        totalValue += itemData.estimatedPrice || 0;
      }
    }

    logger.info("Budget items retrieved", {
      budgetId: data.budgetId,
      count: items.length,
    });

    return {
      items: items,
      totalItems: items.length,
      totalValue: totalValue,
    };
  } catch (error) {
    logger.error("Error getting budget items", {
      userId: request.auth?.uid,
      budgetId: data.budgetId,
      error: error.message,
    });
    throw new HttpsError("internal", error.message);
  }
});

/**
 * 3.4 deleteShoppingItem
 * Callable Function: Deletes a shopping item and recalculates budget totals
 */
exports.deleteShoppingItem = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    if (!data.itemId || typeof data.itemId !== "string") {
      throw new HttpsError("invalid-argument", "Item ID is required");
    }

    const userId = request.auth.uid;
    logger.info("Deleting shopping item", { userId, itemId: data.itemId });

    // Get item
    const itemRef = db.collection("shoppingItems").doc(data.itemId);
    const itemDoc = await itemRef.get();

    if (!itemDoc.exists) {
      throw new HttpsError("not-found", "Item not found");
    }

    const itemData = itemDoc.data();

    // Verify user is member of the budget
    const budgetDoc = await db
      .collection("budgets")
      .doc(itemData.budgetId)
      .get();

    if (!budgetDoc.exists) {
      throw new HttpsError("not-found", "Budget not found");
    }

    const budgetData = budgetDoc.data();

    if (!budgetData.memberIds.includes(userId)) {
      throw new HttpsError(
        "permission-denied",
        "User is not a member of this budget"
      );
    }

    // Delete the item
    await itemRef.delete();

    // Recalculate budget totals (only purchased items count toward spent)
    const remainingItemsSnapshot = await db
      .collection("shoppingItems")
      .where("budgetId", "==", itemData.budgetId)
      .where("isPurchased", "==", true)
      .get();

    const totalSpent = remainingItemsSnapshot.docs.reduce(
      (sum, doc) => sum + (doc.data().estimatedPrice || 0),
      0
    );

    const remaining = budgetData.budgetAmount - totalSpent;
    const exceeded = remaining < 0;

    logger.info("Shopping item deleted successfully", {
      itemId: data.itemId,
      budgetId: itemData.budgetId,
    });

    return {
      success: true,
      budgetStatus: {
        totalSpent: totalSpent,
        remaining: remaining,
        exceeded: exceeded,
      },
    };
  } catch (error) {
    logger.error("Error deleting shopping item", {
      userId: request.auth?.uid,
      itemId: data.itemId,
      error: error.message,
    });
    throw new HttpsError("internal", error.message);
  }
});

// ============================================================================
// BUDGET DELETION
// ============================================================================

/**
 * deleteBudget
 * Callable Function: Deletes a budget and all associated data
 */
exports.deleteBudget = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    if (!data.budgetId || typeof data.budgetId !== "string") {
      throw new HttpsError("invalid-argument", "Budget ID is required");
    }

    const userId = request.auth.uid;
    logger.info("Deleting budget", { userId, budgetId: data.budgetId });

    // Get budget
    const budgetRef = db.collection("budgets").doc(data.budgetId);
    const budgetDoc = await budgetRef.get();

    if (!budgetDoc.exists) {
      throw new HttpsError("not-found", "Budget not found");
    }

    const budgetData = budgetDoc.data();

    // Validate user is owner (only owner can delete budget)
    if (budgetData.ownerId !== userId) {
      throw new HttpsError(
        "permission-denied",
        "Only the owner can delete the budget"
      );
    }

    // Delete all shopping items associated with this budget
    const itemsSnapshot = await db
      .collection("shoppingItems")
      .where("budgetId", "==", data.budgetId)
      .get();

    const batch = db.batch();

    itemsSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    // Delete the budget document
    batch.delete(budgetRef);

    await batch.commit();

    // Remove budget reference from all member users
    const memberIds = budgetData.memberIds || [];
    const userUpdates = memberIds.map((memberId) =>
      db
        .collection("users")
        .doc(memberId)
        .update({
          budgetIds: FieldValue.arrayRemove(data.budgetId),
        })
    );

    await Promise.all(userUpdates);

    logger.info("Budget deleted successfully", {
      budgetId: data.budgetId,
      itemsDeleted: itemsSnapshot.size,
      membersUpdated: memberIds.length,
    });

    return {
      success: true,
      itemsDeleted: itemsSnapshot.size,
      membersUpdated: memberIds.length,
    };
  } catch (error) {
    logger.error("Error deleting budget", {
      userId: request.auth?.uid,
      budgetId: data.budgetId,
      error: error.message,
    });
    throw new HttpsError("internal", error.message);
  }
});

// ============================================================================
// USER PROFILE AND ACTIVE BUDGET STATE MANAGEMENT
// ============================================================================

/**
 * getCurrentUserProfile
 * Callable Function: Retrieves the current user's profile from Firestore
 */
exports.getCurrentUserProfile = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const userId = request.auth.uid;
    logger.info("Getting current user profile", { userId });

    // Read user document from Firestore
    const userDoc = await db.collection("users").doc(userId).get();

    // Fail explicitly if user document does not exist
    if (!userDoc.exists) {
      logger.error("User document does not exist", { userId });
      throw new HttpsError(
        "not-found",
        "User profile not found. Please complete registration."
      );
    }

    const userData = userDoc.data();

    // Return user profile data
    const userProfile = {
      userId: userId,
      name: userData.name || null,
      email: userData.email || null,
      photoURL: userData.photoURL || null,
      preferences: userData.preferences || {},
      createdAt: userData.createdAt || null,
    };

    logger.info("User profile retrieved successfully", { userId });
    return { profile: userProfile };
  } catch (error) {
    logger.error("Error getting user profile", {
      userId: request.auth?.uid,
      error: error.message,
    });
    // Re-throw HttpsError as is, wrap others
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", error.message);
  }
});

/**
 * getLastActiveBudget
 * Callable Function: Retrieves the last active budget ID for the current user
 */
exports.getLastActiveBudget = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const userId = request.auth.uid;
    logger.info("Getting last active budget", { userId });

    // Read lastActiveBudgetId from user document
    const userDoc = await db.collection("users").doc(userId).get();

    if (!userDoc.exists) {
      logger.error("User document does not exist", { userId });
      throw new HttpsError("not-found", "User profile not found");
    }

    const userData = userDoc.data();
    const lastActiveBudgetId = userData.lastActiveBudgetId;

    // If lastActiveBudgetId is not present, return null
    if (!lastActiveBudgetId) {
      logger.info("No last active budget set", { userId });
      return { budgetId: null };
    }

    // Validate the budget exists
    const budgetDoc = await db
      .collection("budgets")
      .doc(lastActiveBudgetId)
      .get();

    if (!budgetDoc.exists) {
      logger.warn("Last active budget no longer exists", {
        userId,
        budgetId: lastActiveBudgetId,
      });
      // Clear the invalid reference
      await db.collection("users").doc(userId).update({
        lastActiveBudgetId: FieldValue.delete(),
      });
      return { budgetId: null };
    }

    const budgetData = budgetDoc.data();

    // Validate the user is still a member
    if (!budgetData.memberIds || !budgetData.memberIds.includes(userId)) {
      logger.warn("User is no longer a member of last active budget", {
        userId,
        budgetId: lastActiveBudgetId,
      });
      // Clear the invalid reference
      await db.collection("users").doc(userId).update({
        lastActiveBudgetId: FieldValue.delete(),
      });
      return { budgetId: null };
    }

    // Return the valid budget ID
    logger.info("Last active budget retrieved", {
      userId,
      budgetId: lastActiveBudgetId,
    });
    return { budgetId: lastActiveBudgetId };
  } catch (error) {
    logger.error("Error getting last active budget", {
      userId: request.auth?.uid,
      error: error.message,
    });
    // Re-throw HttpsError as is, wrap others
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", error.message);
  }
});

/**
 * setLastActiveBudget
 * Callable Function: Sets the last active budget ID for the current user
 */
exports.setLastActiveBudget = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    if (!data.budgetId || typeof data.budgetId !== "string") {
      throw new HttpsError("invalid-argument", "Budget ID is required");
    }

    const userId = request.auth.uid;
    const budgetId = data.budgetId;

    logger.info("Setting last active budget", { userId, budgetId });

    // Validate that the budget exists
    const budgetDoc = await db.collection("budgets").doc(budgetId).get();

    if (!budgetDoc.exists) {
      throw new HttpsError("not-found", "Budget not found");
    }

    const budgetData = budgetDoc.data();

    // Validate that the user is a member of the budget
    if (!budgetData.memberIds || !budgetData.memberIds.includes(userId)) {
      throw new HttpsError(
        "permission-denied",
        "User is not a member of this budget"
      );
    }

    // Persist lastActiveBudgetId in user document
    await db.collection("users").doc(userId).update({
      lastActiveBudgetId: budgetId,
      updatedAt: FieldValue.serverTimestamp(),
    });

    logger.info("Last active budget set successfully", { userId, budgetId });
    return { success: true, budgetId: budgetId };
  } catch (error) {
    logger.error("Error setting last active budget", {
      userId: request.auth?.uid,
      budgetId: request.data?.budgetId,
      error: error.message,
    });
    // Re-throw HttpsError as is, wrap others
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", error.message);
  }
});

// ============================================================================
// INVITATION AND MEMBER MANAGEMENT
// ============================================================================

/**
 * createBudgetInvitation
 * Callable Function: Creates a secure invitation token for a budget
 */
exports.createBudgetInvitation = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    if (!data.budgetId || typeof data.budgetId !== "string") {
      throw new HttpsError("invalid-argument", "Budget ID is required");
    }

    const userId = request.auth.uid;
    const budgetId = data.budgetId;

    logger.info("Creating budget invitation", { userId, budgetId });

    // Get budget
    const budgetDoc = await db.collection("budgets").doc(budgetId).get();

    if (!budgetDoc.exists) {
      throw new HttpsError("not-found", "Budget not found");
    }

    const budgetData = budgetDoc.data();

    // Validate that the requester is the budget owner
    if (budgetData.ownerId !== userId) {
      throw new HttpsError(
        "permission-denied",
        "Only the budget owner can create invitations"
      );
    }

    // Generate a secure invitation token
    const invitationToken = crypto.randomBytes(32).toString("hex");

    // Calculate expiration date (7 days from now)
    const expirationDate = new Date();
    expirationDate.setDate(expirationDate.getDate() + 7);

    // Persist invitation document
    const invitationData = {
      budgetId: budgetId,
      invitedBy: userId,
      invitationToken: invitationToken,
      expiresAt: Timestamp.fromDate(expirationDate),
      status: "pending",
      createdAt: FieldValue.serverTimestamp(),
    };

    const invitationRef = await db
      .collection("invitations")
      .add(invitationData);

    logger.info("Budget invitation created successfully", {
      userId,
      budgetId,
      invitationId: invitationRef.id,
    });

    return {
      invitationToken: invitationToken,
      invitationId: invitationRef.id,
      expiresAt: expirationDate.toISOString(),
    };
  } catch (error) {
    logger.error("Error creating budget invitation", {
      userId: request.auth?.uid,
      budgetId: request.data?.budgetId,
      error: error.message,
    });
    // Re-throw HttpsError as is, wrap others
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", error.message);
  }
});

/**
 * acceptBudgetInvitation
 * Callable Function: Accepts a budget invitation using a token
 */
exports.acceptBudgetInvitation = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    if (!data.invitationToken || typeof data.invitationToken !== "string") {
      throw new HttpsError("invalid-argument", "Invitation token is required");
    }

    const userId = request.auth.uid;
    const invitationToken = data.invitationToken;

    logger.info("Accepting budget invitation", { userId });

    // Find invitation by token
    const invitationsSnapshot = await db
      .collection("invitations")
      .where("invitationToken", "==", invitationToken)
      .limit(1)
      .get();

    if (invitationsSnapshot.empty) {
      throw new HttpsError("not-found", "Invalid invitation token");
    }

    const invitationDoc = invitationsSnapshot.docs[0];
    const invitationData = invitationDoc.data();

    // Validate invitation is not expired
    const now = new Date();
    const expiresAt = invitationData.expiresAt.toDate();

    if (now > expiresAt) {
      throw new HttpsError("failed-precondition", "Invitation has expired");
    }

    // Validate invitation is not already used
    if (invitationData.status !== "pending") {
      throw new HttpsError(
        "failed-precondition",
        "Invitation has already been used"
      );
    }

    const budgetId = invitationData.budgetId;

    // Get budget
    const budgetRef = db.collection("budgets").doc(budgetId);
    const budgetDoc = await budgetRef.get();

    if (!budgetDoc.exists) {
      throw new HttpsError("not-found", "Budget not found");
    }

    const budgetData = budgetDoc.data();

    // Check if user is already a member
    if (budgetData.memberIds && budgetData.memberIds.includes(userId)) {
      throw new HttpsError(
        "already-exists",
        "You are already a member of this budget"
      );
    }

    // Use a batch for atomic updates
    const batch = db.batch();

    // Add userId to budget.memberIds
    batch.update(budgetRef, {
      memberIds: FieldValue.arrayUnion(userId),
      updatedAt: FieldValue.serverTimestamp(),
    });

    // Add budgetId to users/{userId}.budgetIds
    const userRef = db.collection("users").doc(userId);
    batch.update(userRef, {
      budgetIds: FieldValue.arrayUnion(budgetId),
      updatedAt: FieldValue.serverTimestamp(),
    });

    // Mark invitation as accepted
    const invitationRef = invitationDoc.ref;
    batch.update(invitationRef, {
      status: "accepted",
      acceptedBy: userId,
      acceptedAt: FieldValue.serverTimestamp(),
    });

    await batch.commit();

    logger.info("Budget invitation accepted successfully", {
      userId,
      budgetId,
      invitationId: invitationDoc.id,
    });

    // Return updated budget summary
    const updatedBudgetDoc = await budgetRef.get();
    const updatedBudgetData = updatedBudgetDoc.data();

    // Get member details
    const members = [];
    for (const memberId of updatedBudgetData.memberIds) {
      const memberDoc = await db.collection("users").doc(memberId).get();
      if (memberDoc.exists) {
        const memberData = memberDoc.data();
        members.push({
          userId: memberId,
          name: memberData.name,
          email: memberData.email,
          photoURL: memberData.photoURL,
          isOwner: memberId === updatedBudgetData.ownerId,
        });
      }
    }

    return {
      success: true,
      budget: {
        id: budgetId,
        name: updatedBudgetData.name,
        budgetAmount: updatedBudgetData.budgetAmount,
        budgetPeriod: updatedBudgetData.budgetPeriod,
        currentPeriodEnd: updatedBudgetData.currentPeriodEnd,
        ownerId: updatedBudgetData.ownerId,
        memberCount: updatedBudgetData.memberIds.length,
        members: members,
      },
    };
  } catch (error) {
    logger.error("Error accepting budget invitation", {
      userId: request.auth?.uid,
      error: error.message,
    });
    // Re-throw HttpsError as is, wrap others
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", error.message);
  }
});

/**
 * removeBudgetMember
 * Callable Function: Removes a member from a budget
 */
exports.removeBudgetMember = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    if (!data.budgetId || typeof data.budgetId !== "string") {
      throw new HttpsError("invalid-argument", "Budget ID is required");
    }

    if (!data.memberUserId || typeof data.memberUserId !== "string") {
      throw new HttpsError("invalid-argument", "Member user ID is required");
    }

    const userId = request.auth.uid;
    const budgetId = data.budgetId;
    const memberUserId = data.memberUserId;

    logger.info("Removing budget member", { userId, budgetId, memberUserId });

    // Get budget
    const budgetRef = db.collection("budgets").doc(budgetId);
    const budgetDoc = await budgetRef.get();

    if (!budgetDoc.exists) {
      throw new HttpsError("not-found", "Budget not found");
    }

    const budgetData = budgetDoc.data();

    // Validate requester is the budget owner
    if (budgetData.ownerId !== userId) {
      throw new HttpsError(
        "permission-denied",
        "Only the budget owner can remove members"
      );
    }

    // Prevent removing the owner
    if (memberUserId === budgetData.ownerId) {
      throw new HttpsError(
        "invalid-argument",
        "Cannot remove the budget owner"
      );
    }

    // Validate target user is a member
    if (!budgetData.memberIds || !budgetData.memberIds.includes(memberUserId)) {
      throw new HttpsError("not-found", "User is not a member of this budget");
    }

    // Use a batch for atomic updates
    const batch = db.batch();

    // Remove userId from budget.memberIds
    batch.update(budgetRef, {
      memberIds: FieldValue.arrayRemove(memberUserId),
      updatedAt: FieldValue.serverTimestamp(),
    });

    // Remove budgetId from users/{userId}.budgetIds
    const memberUserRef = db.collection("users").doc(memberUserId);
    batch.update(memberUserRef, {
      budgetIds: FieldValue.arrayRemove(budgetId),
      updatedAt: FieldValue.serverTimestamp(),
    });

    // If the removed user had this as their last active budget, clear it
    const memberUserDoc = await memberUserRef.get();
    if (
      memberUserDoc.exists &&
      memberUserDoc.data().lastActiveBudgetId === budgetId
    ) {
      batch.update(memberUserRef, {
        lastActiveBudgetId: FieldValue.delete(),
      });
    }

    await batch.commit();

    logger.info("Budget member removed successfully", {
      userId,
      budgetId,
      memberUserId,
    });

    // Get updated member list
    const updatedBudgetDoc = await budgetRef.get();
    const updatedBudgetData = updatedBudgetDoc.data();

    const members = [];
    for (const memberId of updatedBudgetData.memberIds) {
      const memberDoc = await db.collection("users").doc(memberId).get();
      if (memberDoc.exists) {
        const memberData = memberDoc.data();
        members.push({
          userId: memberId,
          name: memberData.name,
          email: memberData.email,
          photoURL: memberData.photoURL,
          isOwner: memberId === updatedBudgetData.ownerId,
        });
      }
    }

    return {
      success: true,
      members: members,
      memberCount: members.length,
    };
  } catch (error) {
    logger.error("Error removing budget member", {
      userId: request.auth?.uid,
      budgetId: request.data?.budgetId,
      memberUserId: request.data?.memberUserId,
      error: error.message,
    });
    // Re-throw HttpsError as is, wrap others
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", error.message);
  }
});

// ============================================================================
// BUDGET HISTORY AND MEMBER MANAGEMENT
// ============================================================================

/**
 * createBudgetHistorySnapshot
 * Callable Function: Creates a snapshot of budget state for historical tracking
 */
exports.createBudgetHistorySnapshot = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    if (!data.budgetId || typeof data.budgetId !== "string") {
      throw new HttpsError("invalid-argument", "Budget ID is required");
    }

    const userId = request.auth.uid;
    const budgetId = data.budgetId;

    logger.info("Creating budget history snapshot", { userId, budgetId });

    // Get budget
    const budgetDoc = await db.collection("budgets").doc(budgetId).get();

    if (!budgetDoc.exists) {
      throw new HttpsError("not-found", "Budget not found");
    }

    const budgetData = budgetDoc.data();

    // Validate that the requester is the budget owner
    if (budgetData.ownerId !== userId) {
      throw new HttpsError(
        "permission-denied",
        "Only the budget owner can create history snapshots"
      );
    }

    // Calculate totalSpent from shopping items
    const itemsSnapshot = await db
      .collection("shoppingItems")
      .where("budgetId", "==", budgetId)
      .where("isPurchased", "==", true)
      .get();

    const totalSpent = itemsSnapshot.docs.reduce(
      (sum, item) => sum + (item.data().estimatedPrice || 0),
      0
    );

    const remaining = budgetData.budgetAmount - totalSpent;

    // Determine period dates
    const periodEnd = budgetData.currentPeriodEnd.toDate();
    let periodStart;

    if (budgetData.budgetPeriod === "weekly") {
      periodStart = new Date(periodEnd.getTime() - 7 * 24 * 60 * 60 * 1000);
    } else if (budgetData.budgetPeriod === "monthly") {
      periodStart = new Date(
        periodEnd.getFullYear(),
        periodEnd.getMonth() - 1,
        periodEnd.getDate()
      );
    } else {
      // For custom periods, try to infer from createdAt or use 30 days
      const createdAt = budgetData.createdAt?.toDate() || new Date();
      periodStart = new Date(periodEnd.getTime() - 30 * 24 * 60 * 60 * 1000);
    }

    // Create snapshot document
    const snapshotData = {
      budgetId: budgetId,
      budgetName: budgetData.name,
      budgetAmount: budgetData.budgetAmount,
      budgetPeriod: budgetData.budgetPeriod,
      totalSpent: totalSpent,
      remaining: remaining,
      memberIds: budgetData.memberIds || [],
      memberCount: (budgetData.memberIds || []).length,
      periodStart: Timestamp.fromDate(periodStart),
      periodEnd: Timestamp.fromDate(periodEnd),
      itemCount: itemsSnapshot.size,
      createdAt: FieldValue.serverTimestamp(),
      createdBy: userId,
    };

    const snapshotRef = await db.collection("budgetHistory").add(snapshotData);

    logger.info("Budget history snapshot created successfully", {
      userId,
      budgetId,
      snapshotId: snapshotRef.id,
      totalSpent,
    });

    return {
      snapshotId: snapshotRef.id,
      snapshot: {
        id: snapshotRef.id,
        ...snapshotData,
      },
    };
  } catch (error) {
    logger.error("Error creating budget history snapshot", {
      userId: request.auth?.uid,
      budgetId: request.data?.budgetId,
      error: error.message,
    });
    // Re-throw HttpsError as is, wrap others
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", error.message);
  }
});

/**
 * getBudgetHistory
 * Callable Function: Retrieves historical snapshots for a budget
 */
exports.getBudgetHistory = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    if (!data.budgetId || typeof data.budgetId !== "string") {
      throw new HttpsError("invalid-argument", "Budget ID is required");
    }

    const userId = request.auth.uid;
    const budgetId = data.budgetId;
    const limit = data.limit || 10;

    logger.info("Getting budget history", { userId, budgetId, limit });

    // Get budget to validate membership
    const budgetDoc = await db.collection("budgets").doc(budgetId).get();

    if (!budgetDoc.exists) {
      throw new HttpsError("not-found", "Budget not found");
    }

    const budgetData = budgetDoc.data();

    // Validate user is a member of the budget
    if (!budgetData.memberIds || !budgetData.memberIds.includes(userId)) {
      throw new HttpsError(
        "permission-denied",
        "User is not a member of this budget"
      );
    }

    // Query budgetHistory by budgetId, ordered by periodEnd descending
    const historySnapshot = await db
      .collection("budgetHistory")
      .where("budgetId", "==", budgetId)
      .orderBy("periodEnd", "desc")
      .limit(limit)
      .get();

    const historyList = [];
    historySnapshot.forEach((doc) => {
      const historyData = doc.data();
      const percentageUsed =
        historyData.budgetAmount > 0
          ? (historyData.totalSpent / historyData.budgetAmount) * 100
          : 0;
      historyList.push({
        id: doc.id,
        budgetId: historyData.budgetId,
        budgetName: historyData.budgetName,
        budgetAmount: historyData.budgetAmount,
        budgetPeriod: historyData.budgetPeriod,
        totalSpent: historyData.totalSpent,
        remaining: historyData.remaining,
        percentageUsed: percentageUsed,
        memberCount: historyData.memberCount,
        itemCount: historyData.itemCount,
        periodStart: historyData.periodStart,
        periodEnd: historyData.periodEnd,
        createdAt: historyData.createdAt,
      });
    });

    logger.info("Budget history retrieved successfully", {
      userId,
      budgetId,
      count: historyList.length,
    });

    return {
      history: historyList,
      count: historyList.length,
    };
  } catch (error) {
    logger.error("Error getting budget history", {
      userId: request.auth?.uid,
      budgetId: request.data?.budgetId,
      error: error.message,
    });
    // Re-throw HttpsError as is, wrap others
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", error.message);
  }
});

/**
 * getBudgetMembers
 * Callable Function: Retrieves member information for a budget
 */
exports.getBudgetMembers = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    if (!data.budgetId || typeof data.budgetId !== "string") {
      throw new HttpsError("invalid-argument", "Budget ID is required");
    }

    const userId = request.auth.uid;
    const budgetId = data.budgetId;

    logger.info("Getting budget members", { userId, budgetId });

    // Get budget
    const budgetDoc = await db.collection("budgets").doc(budgetId).get();

    if (!budgetDoc.exists) {
      throw new HttpsError("not-found", "Budget not found");
    }

    const budgetData = budgetDoc.data();

    // Validate user is a member of the budget
    if (!budgetData.memberIds || !budgetData.memberIds.includes(userId)) {
      throw new HttpsError(
        "permission-denied",
        "User is not a member of this budget"
      );
    }

    // Fetch user profiles for each member
    const members = [];
    const memberIds = budgetData.memberIds || [];

    for (const memberId of memberIds) {
      const userDoc = await db.collection("users").doc(memberId).get();
      if (userDoc.exists) {
        const userData = userDoc.data();
        members.push({
          userId: memberId,
          name: userData.name || "Unknown",
          email: userData.email || null,
          photoURL: userData.photoURL || null,
          isOwner: memberId === budgetData.ownerId,
          joinedAt: userData.createdAt || null,
        });
      } else {
        // Handle case where user document doesn't exist
        logger.warn("User document not found for member", {
          memberId,
          budgetId,
        });
        members.push({
          userId: memberId,
          name: "Unknown User",
          email: null,
          photoURL: null,
          isOwner: memberId === budgetData.ownerId,
          joinedAt: null,
        });
      }
    }

    logger.info("Budget members retrieved successfully", {
      userId,
      budgetId,
      memberCount: members.length,
    });

    return {
      members: members,
      memberCount: members.length,
      ownerId: budgetData.ownerId,
    };
  } catch (error) {
    logger.error("Error getting budget members", {
      userId: request.auth?.uid,
      budgetId: request.data?.budgetId,
      error: error.message,
    });
    // Re-throw HttpsError as is, wrap others
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", error.message);
  }
});

// ============================================================================
// NOTIFICATION MANAGEMENT
// ============================================================================

/**
 * createNotification
 * Callable Function: Creates a notification for a user
 */
exports.createNotification = onCall(async (request) => {
  try {
    const data = request.data;

    // Validate required fields
    if (!data.userId || typeof data.userId !== "string") {
      throw new HttpsError("invalid-argument", "User ID is required");
    }

    if (!data.type || typeof data.type !== "string") {
      throw new HttpsError("invalid-argument", "Notification type is required");
    }

    if (!data.title || typeof data.title !== "string") {
      throw new HttpsError(
        "invalid-argument",
        "Notification title is required"
      );
    }

    const userId = data.userId;
    const triggerContext = data.triggerContext || "system";

    logger.info("Creating notification", {
      userId,
      type: data.type,
      triggerContext,
    });

    // Validate triggering context
    if (!["system", "user"].includes(triggerContext)) {
      throw new HttpsError(
        "invalid-argument",
        "Trigger context must be 'system' or 'user'"
      );
    }

    // Verify user exists
    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) {
      throw new HttpsError("not-found", "User not found");
    }

    // If budgetId is provided, verify it exists
    if (data.budgetId) {
      const budgetDoc = await db.collection("budgets").doc(data.budgetId).get();
      if (!budgetDoc.exists) {
        throw new HttpsError("not-found", "Budget not found");
      }
    }

    // Persist notification document
    const notificationData = {
      userId: userId,
      budgetId: data.budgetId || null,
      type: data.type,
      title: data.title,
      body: data.body || "",
      payload: data.payload || {},
      read: false,
      triggerContext: triggerContext,
      createdAt: FieldValue.serverTimestamp(),
    };

    const notificationRef = await db
      .collection("notifications")
      .add(notificationData);

    logger.info("Notification created successfully", {
      userId,
      notificationId: notificationRef.id,
      type: data.type,
    });

    return {
      notificationId: notificationRef.id,
      notification: {
        id: notificationRef.id,
        ...notificationData,
      },
    };
  } catch (error) {
    logger.error("Error creating notification", {
      userId: request.data?.userId,
      error: error.message,
    });
    // Re-throw HttpsError as is, wrap others
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", error.message);
  }
});

/**
 * getUserNotifications
 * Callable Function: Retrieves notifications for the authenticated user
 */
exports.getUserNotifications = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const userId = request.auth.uid;
    const data = request.data || {};
    const budgetId = data.budgetId;
    const limit = data.limit || 50;
    const unreadOnly = data.unreadOnly || false;

    logger.info("Getting user notifications", {
      userId,
      budgetId,
      limit,
      unreadOnly,
    });

    // Build query
    let query = db.collection("notifications").where("userId", "==", userId);

    // Optionally filter by budgetId
    if (budgetId) {
      query = query.where("budgetId", "==", budgetId);
    }

    // Optionally filter by unread
    if (unreadOnly) {
      query = query.where("read", "==", false);
    }

    // Order by createdAt descending and apply limit
    query = query.orderBy("createdAt", "desc").limit(limit);

    const notificationsSnapshot = await query.get();

    const notifications = [];
    notificationsSnapshot.forEach((doc) => {
      const notificationData = doc.data();
      notifications.push({
        id: doc.id,
        userId: notificationData.userId,
        budgetId: notificationData.budgetId,
        type: notificationData.type,
        title: notificationData.title,
        body: notificationData.body,
        payload: notificationData.payload,
        read: notificationData.read,
        createdAt: notificationData.createdAt,
      });
    });

    logger.info("User notifications retrieved successfully", {
      userId,
      count: notifications.length,
    });

    return {
      notifications: notifications,
      count: notifications.length,
      unreadCount: notifications.filter((n) => !n.read).length,
    };
  } catch (error) {
    logger.error("Error getting user notifications", {
      userId: request.auth?.uid,
      error: error.message,
    });
    // Re-throw HttpsError as is, wrap others
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", error.message);
  }
});

/**
 * markNotificationAsRead
 * Callable Function: Marks a notification as read
 */
exports.markNotificationAsRead = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    if (!data.notificationId || typeof data.notificationId !== "string") {
      throw new HttpsError("invalid-argument", "Notification ID is required");
    }

    const userId = request.auth.uid;
    const notificationId = data.notificationId;

    logger.info("Marking notification as read", { userId, notificationId });

    // Get notification
    const notificationRef = db.collection("notifications").doc(notificationId);
    const notificationDoc = await notificationRef.get();

    if (!notificationDoc.exists) {
      throw new HttpsError("not-found", "Notification not found");
    }

    const notificationData = notificationDoc.data();

    // Validate notification ownership
    if (notificationData.userId !== userId) {
      throw new HttpsError(
        "permission-denied",
        "You do not have permission to modify this notification"
      );
    }

    // Update notification
    await notificationRef.update({
      read: true,
      readAt: FieldValue.serverTimestamp(),
    });

    logger.info("Notification marked as read successfully", {
      userId,
      notificationId,
    });

    return { success: true };
  } catch (error) {
    logger.error("Error marking notification as read", {
      userId: request.auth?.uid,
      notificationId: request.data?.notificationId,
      error: error.message,
    });
    // Re-throw HttpsError as is, wrap others
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", error.message);
  }
});

/**
 * deleteNotification
 * Callable Function: Deletes a notification
 */
exports.deleteNotification = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const data = request.data;
    if (!data.notificationId || typeof data.notificationId !== "string") {
      throw new HttpsError("invalid-argument", "Notification ID is required");
    }

    const userId = request.auth.uid;
    const notificationId = data.notificationId;

    logger.info("Deleting notification", { userId, notificationId });

    // Get notification
    const notificationRef = db.collection("notifications").doc(notificationId);
    const notificationDoc = await notificationRef.get();

    if (!notificationDoc.exists) {
      throw new HttpsError("not-found", "Notification not found");
    }

    const notificationData = notificationDoc.data();

    // Validate notification ownership
    if (notificationData.userId !== userId) {
      throw new HttpsError(
        "permission-denied",
        "You do not have permission to delete this notification"
      );
    }

    // Delete notification document
    await notificationRef.delete();

    logger.info("Notification deleted successfully", {
      userId,
      notificationId,
    });

    return { success: true };
  } catch (error) {
    logger.error("Error deleting notification", {
      userId: request.auth?.uid,
      notificationId: request.data?.notificationId,
      error: error.message,
    });
    // Re-throw HttpsError as is, wrap others
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", error.message);
  }
});

/**
 * clearAllNotifications
 * Callable Function: Deletes all notifications for the authenticated user
 */
exports.clearAllNotifications = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const userId = request.auth.uid;

    logger.info("Clearing all notifications", { userId });

    // Query all notifications for the user
    const notificationsSnapshot = await db
      .collection("notifications")
      .where("userId", "==", userId)
      .get();

    const totalNotifications = notificationsSnapshot.size;

    if (totalNotifications === 0) {
      logger.info("No notifications to delete", { userId });
      return { success: true, deletedCount: 0 };
    }

    // Use batch operation for deletion
    // Firestore batch has a limit of 500 operations, so we need to handle that
    const batches = [];
    let currentBatch = db.batch();
    let operationCount = 0;
    const batchLimit = 500;

    notificationsSnapshot.docs.forEach((doc) => {
      currentBatch.delete(doc.ref);
      operationCount++;

      // If we reach the batch limit, start a new batch
      if (operationCount === batchLimit) {
        batches.push(currentBatch);
        currentBatch = db.batch();
        operationCount = 0;
      }
    });

    // Add the last batch if it has operations
    if (operationCount > 0) {
      batches.push(currentBatch);
    }

    // Commit all batches
    await Promise.all(batches.map((batch) => batch.commit()));

    logger.info("All notifications cleared successfully", {
      userId,
      deletedCount: totalNotifications,
    });

    return { success: true, deletedCount: totalNotifications };
  } catch (error) {
    logger.error("Error clearing all notifications", {
      userId: request.auth?.uid,
      error: error.message,
    });
    // Re-throw HttpsError as is, wrap others
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", error.message);
  }
});

// ============================================================================
// MEMBER EXPENSES
// ============================================================================

/**
 * getMemberExpenses
 * Callable Function: Gets expenses aggregated by member for a specific budget
 * Derives data from purchased shopping items only
 */
exports.getMemberExpenses = onCall(async (request) => {
  try {
    // Validate authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    const userId = request.auth.uid;
    const { budgetId } = request.data;

    // Validate required fields
    if (!budgetId) {
      throw new HttpsError("invalid-argument", "budgetId is required");
    }

    logger.info("Getting member expenses", { userId, budgetId });

    // Verify user has access to this budget
    const budgetDoc = await db.collection("budgets").doc(budgetId).get();
    if (!budgetDoc.exists) {
      throw new HttpsError("not-found", "Budget not found");
    }

    const budgetData = budgetDoc.data();
    if (!budgetData.memberIds.includes(userId)) {
      throw new HttpsError(
        "permission-denied",
        "User does not have access to this budget"
      );
    }

    // Get all purchased items for this budget
    const itemsSnapshot = await db
      .collection("shoppingItems")
      .where("budgetId", "==", budgetId)
      .where("isPurchased", "==", true)
      .get();

    // Group items by purchasedBy and calculate totals
    const memberExpensesMap = new Map();

    for (const itemDoc of itemsSnapshot.docs) {
      const item = itemDoc.data();
      const purchasedBy = item.purchasedBy;

      if (!purchasedBy) {
        continue; // Skip items without purchasedBy
      }

      if (!memberExpensesMap.has(purchasedBy)) {
        memberExpensesMap.set(purchasedBy, {
          userId: purchasedBy,
          totalSpent: 0,
          itemCount: 0,
          items: [],
        });
      }

      const memberData = memberExpensesMap.get(purchasedBy);
      memberData.totalSpent += item.estimatedPrice || 0;
      memberData.itemCount += 1;
      memberData.items.push({
        id: itemDoc.id,
        name: item.name,
        estimatedPrice: item.estimatedPrice || 0,
        category: item.category || "",
        purchasedAt: item.purchasedAt || null,
      });
    }

    // Get user details for each member
    const memberExpenses = [];
    const grandTotal = Array.from(memberExpensesMap.values()).reduce(
      (sum, member) => sum + member.totalSpent,
      0
    );

    for (const [userId, expenseData] of memberExpensesMap.entries()) {
      try {
        const userDoc = await db.collection("users").doc(userId).get();
        const userData = userDoc.exists ? userDoc.data() : null;

        const percentage =
          grandTotal > 0 ? (expenseData.totalSpent / grandTotal) * 100 : 0;

        memberExpenses.push({
          userId: userId,
          name: userData?.name || "Unknown User",
          email: userData?.email || "",
          photoURL: userData?.photoURL || null,
          totalSpent: expenseData.totalSpent,
          itemCount: expenseData.itemCount,
          percentage: percentage,
          items: expenseData.items,
        });
      } catch (error) {
        logger.warn("Could not fetch user data", {
          userId,
          error: error.message,
        });
        // Add with basic info if user fetch fails
        memberExpenses.push({
          userId: userId,
          name: "Unknown User",
          email: "",
          photoURL: null,
          totalSpent: expenseData.totalSpent,
          itemCount: expenseData.itemCount,
          percentage:
            grandTotal > 0 ? (expenseData.totalSpent / grandTotal) * 100 : 0,
          items: expenseData.items,
        });
      }
    }

    // Sort by total spent (descending)
    memberExpenses.sort((a, b) => b.totalSpent - a.totalSpent);

    logger.info("Member expenses retrieved successfully", {
      budgetId,
      memberCount: memberExpenses.length,
      grandTotal,
    });

    return {
      memberExpenses,
      grandTotal,
      totalItems: itemsSnapshot.size,
    };
  } catch (error) {
    logger.error("Error getting member expenses", {
      userId: request.auth?.uid,
      budgetId: request.data?.budgetId,
      error: error.message,
    });
    // Re-throw HttpsError as is, wrap others
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", error.message);
  }
});
