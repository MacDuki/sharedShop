# 🔥 Guía de Integración Firestore - Shared Grocery Budget App

> **Guía Práctica de Implementación**  
> Versión: 1.0 MVP  
> Fecha: 19 de Diciembre, 2025

---

## 📖 Índice

1. [Configuración Inicial](#configuración-inicial)
2. [Estructura de Base de Datos](#estructura-de-base-de-datos)
3. [Implementación por Fases](#implementación-por-fases)
4. [Reglas de Seguridad](#reglas-de-seguridad)
5. [Código de Implementación](#código-de-implementación)
6. [Patrones de Uso](#patrones-de-uso)

---

## ⚙️ Configuración Inicial

### Paso 1: Agregar Dependencias (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase Core
  firebase_core: ^2.24.2

  # Firestore
  cloud_firestore: ^4.13.6

  # Auth
  firebase_auth: ^4.15.3

  # Opcional pero recomendado
  provider: ^6.1.1 # State management
```

### Paso 2: Inicializar Firebase (main.dart)

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
```

### Paso 1: Crear Servicio Base

```dart
// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Referencia a colecciones
  static CollectionReference get users => _db.collection('users');
  static CollectionReference get budgets => _db.collection('budgets');
  static CollectionReference get shoppingItems => _db.collection('shoppingItems');
  static CollectionReference get invitations => _db.collection('invitations');
  static CollectionReference get notifications => _db.collection('notifications');
  static CollectionReference get budgetHistory => _db.collection('budgetHistory');
}
```

---

## 🗄️ Estructura de Base de Datos

### Colecciones Principales

```
Firestore Database
│
├── users/
│   └── {userId}
│       ├── name: string
│       ├── email: string
│       ├── photoURL: string
│       ├── createdAt: timestamp
│       └── budgetIds: array<string>
│
├── budgets/
│   └── {budgetId}
│       ├── name: string
│       ├── budgetAmount: number
│       ├── budgetPeriod: string (weekly|monthly|custom)
│       ├── currentPeriodEnd: timestamp
│       ├── createdAt: timestamp
│       ├── ownerId: string
│       └── memberIds: array<string>
│
├── shoppingItems/
│   └── {itemId}
│       ├── budgetId: string
│       ├── name: string
│       ├── estimatedPrice: number
│       ├── category: string
│       ├── isPurchased: boolean
│       ├── createdBy: string (userId)
│       ├── createdAt: timestamp
│       ├── purchasedBy: string (nullable)
│       └── purchasedAt: timestamp (nullable)
│
├── invitations/
│   └── {invitationId}
│       ├── budgetId: string
│       ├── inviterUserId: string
│       ├── invitedEmail: string
│       ├── invitedUserId: string (nullable)
│       ├── status: string (pending|accepted|rejected)
│       ├── createdAt: timestamp
│       └── acceptedAt: timestamp (nullable)
│
├── notifications/
│   └── {notificationId}
│       ├── userId: string
│       ├── type: string
│       ├── title: string
│       ├── body: string
│       ├── data: map
│       ├── isRead: boolean
│       └── createdAt: timestamp
│
└── budgetHistory/
    └── {historyId}
        ├── budgetId: string
        ├── periodStart: timestamp
        ├── periodEnd: timestamp
        ├── totalSpent: number
        └── itemCount: number
```

---

## 🚀 Implementación por Fases

### **FASE 1: FUNDACIÓN (Semana 1) - MVP CORE**

#### Objetivo: App funcional para un solo usuario

**Implementar:**

1. ✅ Crear perfil de usuario
2. ✅ Crear presupuesto
3. ✅ Agregar items a la lista
4. ✅ Marcar items como comprados
5. ✅ Ver total gastado

**Colecciones necesarias:** `users`, `budgets`, `shoppingItems`

---

### **FASE 2: COLABORACIÓN (Semana 2) - MULTI-USUARIO**

#### Objetivo: Presupuestos compartidos

**Implementar:**

1. ✅ Invitar miembros por email
2. ✅ Aceptar/rechazar invitaciones
3. ✅ Ver cambios en tiempo real
4. ✅ Sincronización entre usuarios

**Colecciones nuevas:** `invitations`

---

### **FASE 3: NOTIFICACIONES (Semana 3) - ALERTAS**

#### Objetivo: Sistema de notificaciones

**Implementar:**

1. ✅ Notificación al exceder presupuesto
2. ✅ Notificación de nuevas invitaciones
3. ✅ Notificación cuando alguien compra un item
4. ✅ Lista de notificaciones en la app

**Colecciones nuevas:** `notifications`

---

### **FASE 4: HISTORIAL (Semana 4) - ESTADÍSTICAS**

#### Objetivo: Tracking y análisis

**Implementar:**

1. ✅ Cierre automático de períodos
2. ✅ Historial de gastos
3. ✅ Estadísticas básicas
4. ✅ Comparación entre períodos

**Colecciones nuevas:** `budgetHistory`

---

## 🔒 Reglas de Seguridad

### Configurar en Firebase Console

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function isBudgetMember(budgetId) {
      return isAuthenticated() &&
        request.auth.uid in get(/databases/$(database)/documents/budgets/$(budgetId)).data.memberIds;
    }

    // Users: solo pueden ver/editar su propio perfil
    match /users/{userId} {
      allow read: if isOwner(userId);
      allow write: if isOwner(userId);
    }

    // Budgets: solo miembros pueden leer, solo owner puede escribir
    match /budgets/{budgetId} {
      allow read: if isBudgetMember(budgetId);
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() &&
        request.auth.uid == resource.data.ownerId;
      allow delete: if isAuthenticated() &&
        request.auth.uid == resource.data.ownerId;
    }

    // Shopping Items: todos los miembros pueden leer y escribir
    match /shoppingItems/{itemId} {
      allow read: if isAuthenticated() &&
        isBudgetMember(resource.data.budgetId);
      allow write: if isAuthenticated() &&
        isBudgetMember(request.resource.data.budgetId);
    }

    // Invitations: solo el invitado y el invitador pueden ver
    match /invitations/{invitationId} {
      allow read: if isAuthenticated() &&
        (request.auth.uid == resource.data.inviterUserId ||
         request.auth.uid == resource.data.invitedUserId);
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() &&
        request.auth.uid == resource.data.invitedUserId;
    }

    // Notifications: solo el usuario puede ver sus notificaciones
    match /notifications/{notificationId} {
      allow read: if isOwner(resource.data.userId);
      allow write: if isOwner(resource.data.userId);
    }

    // Budget History: solo miembros pueden leer
    match /budgetHistory/{historyId} {
      allow read: if isAuthenticated() &&
        isBudgetMember(resource.data.budgetId);
      allow write: if false; // Solo servidor
    }
  }
}
```

---

## 💻 Código de Implementación

### FASE 1: Operaciones Básicas

#### 1. Modelos de Datos

```dart
// lib/models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoURL;
  final DateTime createdAt;
  final List<String> budgetIds;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoURL,
    required this.createdAt,
    this.budgetIds = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      budgetIds: List<String>.from(data['budgetIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'budgetIds': budgetIds,
    };
  }
}
```

```dart
// lib/models/budget_model.dart
class BudgetModel {
  final String id;
  final String name;
  final double budgetAmount;
  final String budgetPeriod; // 'weekly', 'monthly', 'custom'
  final DateTime currentPeriodEnd;
  final DateTime createdAt;
  final String ownerId;
  final List<String> memberIds;

  BudgetModel({
    required this.id,
    required this.name,
    required this.budgetAmount,
    required this.budgetPeriod,
    required this.currentPeriodEnd,
    required this.createdAt,
    required this.ownerId,
    required this.memberIds,
  });

  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id: doc.id,
      name: data['name'],
      budgetAmount: (data['budgetAmount'] as num).toDouble(),
      budgetPeriod: data['budgetPeriod'],
      currentPeriodEnd: (data['currentPeriodEnd'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      ownerId: data['ownerId'],
      memberIds: List<String>.from(data['memberIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'budgetAmount': budgetAmount,
      'budgetPeriod': budgetPeriod,
      'currentPeriodEnd': Timestamp.fromDate(currentPeriodEnd),
      'createdAt': Timestamp.fromDate(createdAt),
      'ownerId': ownerId,
      'memberIds': memberIds,
    };
  }
}
```

```dart
// lib/models/shopping_item_model.dart
class ShoppingItemModel {
  final String id;
  final String budgetId;
  final String name;
  final double estimatedPrice;
  final String? category;
  final bool isPurchased;
  final String createdBy;
  final DateTime createdAt;
  final String? purchasedBy;
  final DateTime? purchasedAt;

  ShoppingItemModel({
    required this.id,
    required this.budgetId,
    required this.name,
    required this.estimatedPrice,
    this.category,
    required this.isPurchased,
    required this.createdBy,
    required this.createdAt,
    this.purchasedBy,
    this.purchasedAt,
  });

  factory ShoppingItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingItemModel(
      id: doc.id,
      budgetId: data['budgetId'],
      name: data['name'],
      estimatedPrice: (data['estimatedPrice'] as num).toDouble(),
      category: data['category'],
      isPurchased: data['isPurchased'] ?? false,
      createdBy: data['createdBy'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      purchasedBy: data['purchasedBy'],
      purchasedAt: data['purchasedAt'] != null
        ? (data['purchasedAt'] as Timestamp).toDate()
        : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'budgetId': budgetId,
      'name': name,
      'estimatedPrice': estimatedPrice,
      'category': category,
      'isPurchased': isPurchased,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'purchasedBy': purchasedBy,
      'purchasedAt': purchasedAt != null ? Timestamp.fromDate(purchasedAt!) : null,
    };
  }
}
```

---

#### 2. Servicio de Usuario

```dart
// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crear perfil de usuario
  Future<void> createUserProfile(String userId, String name, String email, {String? photoURL}) async {
    final user = UserModel(
      id: userId,
      name: name,
      email: email,
      photoURL: photoURL,
      createdAt: DateTime.now(),
      budgetIds: [],
    );

    await _db.collection('users').doc(userId).set(user.toFirestore());
  }

  // Obtener perfil de usuario
  Future<UserModel?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // Actualizar perfil
  Future<void> updateUserProfile(String userId, {String? name, String? photoURL}) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (photoURL != null) updates['photoURL'] = photoURL;

    await _db.collection('users').doc(userId).update(updates);
  }

  // Stream del perfil (tiempo real)
  Stream<UserModel?> userProfileStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }
}
```

---

#### 3. Servicio de Presupuestos

```dart
// lib/services/budget_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/budget_model.dart';
import '../models/shopping_item_model.dart';

class BudgetService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crear presupuesto
  Future<String> createBudget({
    required String userId,
    required String name,
    required double budgetAmount,
    required String budgetPeriod,
  }) async {
    final now = DateTime.now();
    final periodEnd = _calculatePeriodEnd(now, budgetPeriod);

    final budget = BudgetModel(
      id: '', // Se genera automáticamente
      name: name,
      budgetAmount: budgetAmount,
      budgetPeriod: budgetPeriod,
      currentPeriodEnd: periodEnd,
      createdAt: now,
      ownerId: userId,
      memberIds: [userId],
    );

    // Crear el budget
    final docRef = await _db.collection('budgets').add(budget.toFirestore());

    // Agregar a la lista de budgets del usuario
    await _db.collection('users').doc(userId).update({
      'budgetIds': FieldValue.arrayUnion([docRef.id])
    });

    return docRef.id;
  }

  // Calcular fecha fin del período
  DateTime _calculatePeriodEnd(DateTime start, String period) {
    switch (period) {
      case 'weekly':
        return start.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(start.year, start.month + 1, start.day);
      default:
        return start.add(const Duration(days: 30));
    }
  }

  // Obtener presupuesto
  Future<BudgetModel?> getBudget(String budgetId) async {
    final doc = await _db.collection('budgets').doc(budgetId).get();
    if (!doc.exists) return null;
    return BudgetModel.fromFirestore(doc);
  }

  // Stream de presupuesto (tiempo real)
  Stream<BudgetModel?> budgetStream(String budgetId) {
    return _db.collection('budgets').doc(budgetId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return BudgetModel.fromFirestore(doc);
    });
  }

  // Obtener presupuestos del usuario
  Stream<List<BudgetModel>> userBudgetsStream(String userId) {
    return _db
      .collection('budgets')
      .where('memberIds', arrayContains: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => BudgetModel.fromFirestore(doc)).toList();
      });
  }

  // Actualizar presupuesto
  Future<void> updateBudget(String budgetId, {
    String? name,
    double? budgetAmount,
    String? budgetPeriod,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (budgetAmount != null) updates['budgetAmount'] = budgetAmount;
    if (budgetPeriod != null) {
      updates['budgetPeriod'] = budgetPeriod;
      updates['currentPeriodEnd'] = Timestamp.fromDate(
        _calculatePeriodEnd(DateTime.now(), budgetPeriod)
      );
    }

    await _db.collection('budgets').doc(budgetId).update(updates);
  }

  // Eliminar presupuesto
  Future<void> deleteBudget(String budgetId) async {
    final budget = await getBudget(budgetId);
    if (budget == null) return;

    // Eliminar items del presupuesto
    final items = await _db.collection('shoppingItems')
      .where('budgetId', isEqualTo: budgetId)
      .get();

    for (var doc in items.docs) {
      await doc.reference.delete();
    }

    // Eliminar de budgetIds de los usuarios
    for (var memberId in budget.memberIds) {
      await _db.collection('users').doc(memberId).update({
        'budgetIds': FieldValue.arrayRemove([budgetId])
      });
    }

    // Eliminar el budget
    await _db.collection('budgets').doc(budgetId).delete();
  }

  // Calcular total gastado
  Future<double> calculateTotalSpent(String budgetId) async {
    final items = await _db.collection('shoppingItems')
      .where('budgetId', isEqualTo: budgetId)
      .where('isPurchased', isEqualTo: true)
      .get();

    double total = 0;
    for (var doc in items.docs) {
      final item = ShoppingItemModel.fromFirestore(doc);
      total += item.estimatedPrice;
    }

    return total;
  }
}
```

---

#### 4. Servicio de Items de Compra

```dart
// lib/services/shopping_item_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shopping_item_model.dart';

class ShoppingItemService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Agregar item
  Future<String> addShoppingItem({
    required String budgetId,
    required String userId,
    required String name,
    required double estimatedPrice,
    String? category,
  }) async {
    final item = ShoppingItemModel(
      id: '',
      budgetId: budgetId,
      name: name,
      estimatedPrice: estimatedPrice,
      category: category,
      isPurchased: false,
      createdBy: userId,
      createdAt: DateTime.now(),
    );

    final docRef = await _db.collection('shoppingItems').add(item.toFirestore());
    return docRef.id;
  }

  // Stream de items del presupuesto (tiempo real)
  Stream<List<ShoppingItemModel>> budgetItemsStream(String budgetId) {
    return _db
      .collection('shoppingItems')
      .where('budgetId', isEqualTo: budgetId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => ShoppingItemModel.fromFirestore(doc)).toList();
      });
  }

  // Marcar como comprado
  Future<void> markAsPurchased(String itemId, String userId) async {
    await _db.collection('shoppingItems').doc(itemId).update({
      'isPurchased': true,
      'purchasedBy': userId,
      'purchasedAt': Timestamp.now(),
    });
  }

  // Desmarcar comprado
  Future<void> unmarkAsPurchased(String itemId) async {
    await _db.collection('shoppingItems').doc(itemId).update({
      'isPurchased': false,
      'purchasedBy': null,
      'purchasedAt': null,
    });
  }

  // Actualizar item
  Future<void> updateItem(String itemId, {
    String? name,
    double? estimatedPrice,
    String? category,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (estimatedPrice != null) updates['estimatedPrice'] = estimatedPrice;
    if (category != null) updates['category'] = category;

    await _db.collection('shoppingItems').doc(itemId).update(updates);
  }

  // Eliminar item
  Future<void> deleteItem(String itemId) async {
    await _db.collection('shoppingItems').doc(itemId).delete();
  }

  // Obtener items activos (no comprados)
  Stream<List<ShoppingItemModel>> activeItemsStream(String budgetId) {
    return _db
      .collection('shoppingItems')
      .where('budgetId', isEqualTo: budgetId)
      .where('isPurchased', isEqualTo: false)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => ShoppingItemModel.fromFirestore(doc)).toList();
      });
  }

  // Obtener items comprados
  Stream<List<ShoppingItemModel>> purchasedItemsStream(String budgetId) {
    return _db
      .collection('shoppingItems')
      .where('budgetId', isEqualTo: budgetId)
      .where('isPurchased', isEqualTo: true)
      .orderBy('purchasedAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => ShoppingItemModel.fromFirestore(doc)).toList();
      });
  }
}
```

---

### FASE 2: Invitaciones y Colaboración

#### 5. Modelos de Invitación

```dart
// lib/models/invitation_model.dart
class InvitationModel {
  final String id;
  final String budgetId;
  final String inviterUserId;
  final String invitedEmail;
  final String? invitedUserId;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;
  final DateTime? acceptedAt;

  InvitationModel({
    required this.id,
    required this.budgetId,
    required this.inviterUserId,
    required this.invitedEmail,
    this.invitedUserId,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
  });

  factory InvitationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvitationModel(
      id: doc.id,
      budgetId: data['budgetId'],
      inviterUserId: data['inviterUserId'],
      invitedEmail: data['invitedEmail'],
      invitedUserId: data['invitedUserId'],
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      acceptedAt: data['acceptedAt'] != null
        ? (data['acceptedAt'] as Timestamp).toDate()
        : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'budgetId': budgetId,
      'inviterUserId': inviterUserId,
      'invitedEmail': invitedEmail,
      'invitedUserId': invitedUserId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
    };
  }
}
```

---

#### 6. Servicio de Invitaciones

```dart
// lib/services/invitation_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invitation_model.dart';

class InvitationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Enviar invitación
  Future<String> inviteMember({
    required String budgetId,
    required String inviterUserId,
    required String invitedEmail,
  }) async {
    // Verificar si ya existe una invitación pendiente
    final existing = await _db
      .collection('invitations')
      .where('budgetId', isEqualTo: budgetId)
      .where('invitedEmail', isEqualTo: invitedEmail)
      .where('status', isEqualTo: 'pending')
      .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Ya existe una invitación pendiente para este email');
    }

    final invitation = InvitationModel(
      id: '',
      budgetId: budgetId,
      inviterUserId: inviterUserId,
      invitedEmail: invitedEmail,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    final docRef = await _db.collection('invitations').add(invitation.toFirestore());
    return docRef.id;
  }

  // Obtener invitaciones del usuario
  Stream<List<InvitationModel>> userInvitationsStream(String userEmail) {
    return _db
      .collection('invitations')
      .where('invitedEmail', isEqualTo: userEmail)
      .where('status', isEqualTo: 'pending')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => InvitationModel.fromFirestore(doc)).toList();
      });
  }

  // Aceptar invitación
  Future<void> acceptInvitation(String invitationId, String userId) async {
    final invitationDoc = await _db.collection('invitations').doc(invitationId).get();
    if (!invitationDoc.exists) throw Exception('Invitación no encontrada');

    final invitation = InvitationModel.fromFirestore(invitationDoc);

    // Actualizar invitación
    await _db.collection('invitations').doc(invitationId).update({
      'status': 'accepted',
      'invitedUserId': userId,
      'acceptedAt': Timestamp.now(),
    });

    // Agregar usuario al budget
    await _db.collection('budgets').doc(invitation.budgetId).update({
      'memberIds': FieldValue.arrayUnion([userId])
    });

    // Agregar budget al usuario
    await _db.collection('users').doc(userId).update({
      'budgetIds': FieldValue.arrayUnion([invitation.budgetId])
    });
  }

  // Rechazar invitación
  Future<void> rejectInvitation(String invitationId) async {
    await _db.collection('invitations').doc(invitationId).update({
      'status': 'rejected',
    });
  }

  // Eliminar miembro del presupuesto
  Future<void> removeMember(String budgetId, String memberId) async {
    // Remover del budget
    await _db.collection('budgets').doc(budgetId).update({
      'memberIds': FieldValue.arrayRemove([memberId])
    });

    // Remover del usuario
    await _db.collection('users').doc(memberId).update({
      'budgetIds': FieldValue.arrayRemove([budgetId])
    });
  }
}
```

---

### FASE 3: Notificaciones

#### 7. Modelo de Notificación

```dart
// lib/models/notification_model.dart
class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'],
      type: data['type'],
      title: data['title'],
      body: data['body'],
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
```

---

#### 8. Servicio de Notificaciones

```dart
// lib/services/notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crear notificación
  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final notification = NotificationModel(
      id: '',
      userId: userId,
      type: type,
      title: title,
      body: body,
      data: data ?? {},
      isRead: false,
      createdAt: DateTime.now(),
    );

    await _db.collection('notifications').add(notification.toFirestore());
  }

  // Stream de notificaciones del usuario
  Stream<List<NotificationModel>> userNotificationsStream(String userId) {
    return _db
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
      });
  }

  // Obtener notificaciones no leídas
  Stream<List<NotificationModel>> unreadNotificationsStream(String userId) {
    return _db
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .where('isRead', isEqualTo: false)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
      });
  }

  // Marcar como leída
  Future<void> markAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  // Marcar todas como leídas
  Future<void> markAllAsRead(String userId) async {
    final unread = await _db
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .where('isRead', isEqualTo: false)
      .get();

    final batch = _db.batch();
    for (var doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // Notificar cuando se excede el presupuesto
  Future<void> notifyBudgetExceeded(String budgetId, List<String> memberIds) async {
    for (var memberId in memberIds) {
      await createNotification(
        userId: memberId,
        type: 'budget_exceeded',
        title: '⚠️ Presupuesto Excedido',
        body: 'El presupuesto ha sido excedido',
        data: {'budgetId': budgetId},
      );
    }
  }

  // Notificar nueva invitación
  Future<void> notifyInvitation(String userId, String budgetName, String inviterName) async {
    await createNotification(
      userId: userId,
      type: 'invitation_received',
      title: '📬 Nueva Invitación',
      body: '$inviterName te invitó a "$budgetName"',
      data: {},
    );
  }

  // Notificar item comprado
  Future<void> notifyItemPurchased(String budgetId, List<String> memberIds, String itemName, String buyerName) async {
    for (var memberId in memberIds) {
      await createNotification(
        userId: memberId,
        type: 'item_purchased',
        title: '✅ Item Comprado',
        body: '$buyerName compró "$itemName"',
        data: {'budgetId': budgetId},
      );
    }
  }
}
```

---

### FASE 4: Historial y Estadísticas

#### 9. Servicio de Historial

```dart
// lib/services/budget_history_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetHistoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Crear registro de historial
  Future<void> createHistoryRecord({
    required String budgetId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required double totalSpent,
    required int itemCount,
  }) async {
    await _db.collection('budgetHistory').add({
      'budgetId': budgetId,
      'periodStart': Timestamp.fromDate(periodStart),
      'periodEnd': Timestamp.fromDate(periodEnd),
      'totalSpent': totalSpent,
      'itemCount': itemCount,
    });
  }

  // Obtener historial del presupuesto
  Stream<List<Map<String, dynamic>>> budgetHistoryStream(String budgetId) {
    return _db
      .collection('budgetHistory')
      .where('budgetId', isEqualTo: budgetId)
      .orderBy('periodEnd', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'periodStart': (data['periodStart'] as Timestamp).toDate(),
            'periodEnd': (data['periodEnd'] as Timestamp).toDate(),
            'totalSpent': data['totalSpent'],
            'itemCount': data['itemCount'],
          };
        }).toList();
      });
  }

  // Calcular estadísticas
  Future<Map<String, dynamic>> calculateStatistics(String budgetId) async {
    final items = await _db
      .collection('shoppingItems')
      .where('budgetId', isEqualTo: budgetId)
      .where('isPurchased', isEqualTo: true)
      .get();

    double total = 0;
    final categories = <String, double>{};

    for (var doc in items.docs) {
      final data = doc.data();
      final price = (data['estimatedPrice'] as num).toDouble();
      final category = data['category'] as String? ?? 'Sin categoría';

      total += price;
      categories[category] = (categories[category] ?? 0) + price;
    }

    // Ordenar categorías por total
    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'totalSpent': total,
      'itemCount': items.docs.length,
      'topCategories': sortedCategories.take(5).map((e) => {
        'category': e.key,
        'total': e.value,
      }).toList(),
    };
  }
}
```

---

## 🎨 Patrones de Uso en UI

### Widget con Stream Builder

```dart
// Ejemplo: Lista de presupuestos en tiempo real
class BudgetListScreen extends StatelessWidget {
  final String userId;
  final BudgetService _budgetService = BudgetService();

  BudgetListScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BudgetModel>>(
      stream: _budgetService.userBudgetsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final budgets = snapshot.data ?? [];

        if (budgets.isEmpty) {
          return const Center(child: Text('No tienes presupuestos'));
        }

        return ListView.builder(
          itemCount: budgets.length,
          itemBuilder: (context, index) {
            final budget = budgets[index];
            return BudgetCard(budget: budget);
          },
        );
      },
    );
  }
}
```

---

### Widget para Agregar Item

```dart
// Ejemplo: Formulario para agregar item
class AddItemForm extends StatefulWidget {
  final String budgetId;
  final String userId;

  AddItemForm({required this.budgetId, required this.userId});

  @override
  _AddItemFormState createState() => _AddItemFormState();
}

class _AddItemFormState extends State<AddItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final ShoppingItemService _itemService = ShoppingItemService();

  bool _isLoading = false;

  Future<void> _addItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _itemService.addShoppingItem(
        budgetId: widget.budgetId,
        userId: widget.userId,
        name: _nameController.text,
        estimatedPrice: double.parse(_priceController.text),
        category: _categoryController.text.isEmpty ? null : _categoryController.text,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item agregado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nombre del item'),
            validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
          ),
          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Precio estimado'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Requerido';
              if (double.tryParse(value!) == null) return 'Debe ser un número';
              return null;
            },
          ),
          TextFormField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Categoría (opcional)'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _addItem,
            child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Agregar Item'),
          ),
        ],
      ),
    );
  }
}
```

---

### Widget de Resumen de Presupuesto

```dart
// Ejemplo: Card de presupuesto con total gastado
class BudgetSummaryCard extends StatelessWidget {
  final String budgetId;
  final BudgetService _budgetService = BudgetService();

  BudgetSummaryCard({required this.budgetId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BudgetModel?>(
      stream: _budgetService.budgetStream(budgetId),
      builder: (context, budgetSnapshot) {
        if (!budgetSnapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final budget = budgetSnapshot.data!;

        return FutureBuilder<double>(
          future: _budgetService.calculateTotalSpent(budgetId),
          builder: (context, spentSnapshot) {
            final totalSpent = spentSnapshot.data ?? 0;
            final remaining = budget.budgetAmount - totalSpent;
            final percentage = (totalSpent / budget.budgetAmount * 100).clamp(0, 100);

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[300],
                      color: percentage > 90 ? Colors.red : Colors.green,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Gastado: \$${totalSpent.toStringAsFixed(2)}'),
                        Text('Restante: \$${remaining.toStringAsFixed(2)}'),
                      ],
                    ),
                    Text('${percentage.toStringAsFixed(1)}% usado'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
```

---

## ⚡ Optimizaciones Importantes

### 1. Índices Compuestos en Firestore

En Firebase Console, crear estos índices:

```
Collection: shoppingItems
Fields: budgetId (Ascending), isPurchased (Ascending), createdAt (Descending)

Collection: shoppingItems
Fields: budgetId (Ascending), isPurchased (Ascending), purchasedAt (Descending)

Collection: invitations
Fields: invitedEmail (Ascending), status (Ascending), createdAt (Descending)

Collection: notifications
Fields: userId (Ascending), isRead (Ascending), createdAt (Descending)
```

---

### 2. Paginación para Listas Grandes

```dart
// Ejemplo de paginación
class PaginatedItemsList extends StatefulWidget {
  final String budgetId;

  @override
  _PaginatedItemsListState createState() => _PaginatedItemsListState();
}

class _PaginatedItemsListState extends State<PaginatedItemsList> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<ShoppingItemModel> _items = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;

  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    Query query = _db
      .collection('shoppingItems')
      .where('budgetId', isEqualTo: widget.budgetId)
      .orderBy('createdAt', descending: true)
      .limit(_pageSize);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isEmpty) {
      setState(() {
        _hasMore = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _lastDocument = snapshot.docs.last;
      _items.addAll(snapshot.docs.map((doc) => ShoppingItemModel.fromFirestore(doc)));
      _isLoading = false;
      _hasMore = snapshot.docs.length == _pageSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          _loadMore();
          return const Center(child: CircularProgressIndicator());
        }
        return ItemCard(item: _items[index]);
      },
    );
  }
}
```

---

### 3. Batch Writes para Operaciones Múltiples

```dart
// Ejemplo: Eliminar múltiples items
Future<void> deleteMultipleItems(List<String> itemIds) async {
  final batch = FirebaseFirestore.instance.batch();

  for (var itemId in itemIds) {
    batch.delete(
      FirebaseFirestore.instance.collection('shoppingItems').doc(itemId)
    );
  }

  await batch.commit();
}
```

---

## 🎯 Checklist de Implementación MVP

### Semana 1: Fundación

- [ ] Configurar Firebase en el proyecto
- [ ] Crear modelos de datos (User, Budget, ShoppingItem)
- [ ] Implementar UserService
- [ ] Implementar BudgetService
- [ ] Implementar ShoppingItemService
- [ ] Crear pantalla de registro/login
- [ ] Crear pantalla de lista de presupuestos
- [ ] Crear pantalla de detalle de presupuesto
- [ ] Crear pantalla de lista de compras
- [ ] Implementar formulario para agregar items
- [ ] Implementar marcar items como comprados
- [ ] Mostrar total gastado en tiempo real

### Semana 2: Colaboración

- [ ] Crear modelo de Invitation
- [ ] Implementar InvitationService
- [ ] Crear pantalla de invitar miembros
- [ ] Crear pantalla de invitaciones pendientes
- [ ] Implementar aceptar/rechazar invitaciones
- [ ] Mostrar miembros del presupuesto
- [ ] Implementar remover miembros
- [ ] Testing de sincronización en tiempo real

### Semana 3: Notificaciones

- [ ] Crear modelo de Notification
- [ ] Implementar NotificationService
- [ ] Crear pantalla de notificaciones
- [ ] Implementar notificación al exceder presupuesto
- [ ] Implementar notificación de invitaciones
- [ ] Implementar notificación de items comprados
- [ ] Badge de notificaciones no leídas

### Semana 4: Historial y Pulido

- [ ] Implementar BudgetHistoryService
- [ ] Crear pantalla de historial
- [ ] Implementar estadísticas básicas
- [ ] Implementar configurar reglas de seguridad
- [ ] Testing completo
- [ ] Optimizar queries con índices
- [ ] Testing de performance
- [ ] Deploy de reglas de seguridad

---

## 🚨 Errores Comunes y Soluciones

### Error: Missing Index

**Problema:** Query requiere un índice compuesto  
**Solución:** Click en el link del error en consola, te lleva directo a crear el índice

### Error: Permission Denied

**Problema:** Reglas de seguridad bloquean la operación  
**Solución:** Revisar reglas de seguridad y asegurar que el usuario tiene permisos

### Error: Null Safety

**Problema:** Datos pueden ser null  
**Solución:** Usar operadores null-safe (?, ??, !) correctamente

### Error: Stream no se actualiza

**Problema:** El StreamBuilder no refleja cambios  
**Solución:** Verificar que estás usando .snapshots() y no .get()

---

## 📊 Testing de Base de Datos

### Test de Escritura

```dart
// Probar crear un budget
final budgetService = BudgetService();
final budgetId = await budgetService.createBudget(
  userId: 'testUser123',
  name: 'Test Budget',
  budgetAmount: 500,
  budgetPeriod: 'weekly',
);
print('Budget creado: $budgetId');
```

### Test de Lectura

```dart
// Probar leer un budget
final budget = await budgetService.getBudget(budgetId);
print('Budget leído: ${budget?.name}');
```

### Test de Stream

```dart
// Probar stream en tiempo real
budgetService.budgetStream(budgetId).listen((budget) {
  print('Budget actualizado: ${budget?.name}');
});
```

---

## ✅ Criterios de Éxito

Al final de las 4 semanas, la app debe:

1. ✅ Permitir crear cuenta y login
2. ✅ Crear presupuestos con períodos
3. ✅ Agregar items a la lista de compras
4. ✅ Calcular total gastado en tiempo real
5. ✅ Marcar items como comprados
6. ✅ Invitar miembros por email
7. ✅ Aceptar/rechazar invitaciones
8. ✅ Sincronizar cambios entre usuarios en tiempo real
9. ✅ Mostrar notificaciones de eventos importantes
10. ✅ Ver historial de períodos anteriores
11. ✅ Funcionar sin Cloud Functions (todo desde el cliente)
12. ✅ Ser segura con reglas de Firestore apropiadas

---

## 🎓 Próximos Pasos Post-MVP

Después del MVP, considera:

1. **Cloud Functions** - Implementar lógica crítica en el servidor
2. **Firebase Storage** - Para fotos de recibos
3. **Analytics** - Tracking de uso con Firebase Analytics
4. **Crashlytics** - Monitoreo de errores
5. **Remote Config** - Feature flags
6. **A/B Testing** - Optimización de UI/UX

---

**¡Listo para comenzar! 🚀**

Comienza por la Fase 1 y avanza progresivamente. Cada fase es funcional por sí misma, permitiendo testing continuo.
