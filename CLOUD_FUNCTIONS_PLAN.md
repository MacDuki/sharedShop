# 📋 Plan Integral de Cloud Functions

## Shared Grocery Budget App

> **Documento de Especificación Técnica**  
> Versión: 1.0  
> Fecha: 19 de Diciembre, 2025

---

## 📖 Índice

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Arquitectura General](#arquitectura-general)
3. [Catálogo Completo de Cloud Functions](#catálogo-completo-de-cloud-functions)
4. [Plan de Implementación Progresivo](#plan-de-implementación-progresivo)
5. [Especificaciones Detalladas por Función](#especificaciones-detalladas-por-función)
6. [Consideraciones Técnicas](#consideraciones-técnicas)
7. [Métricas y Monitoreo](#métricas-y-monitoreo)

---

## 🎯 Resumen Ejecutivo

Este documento define el **100% de las Cloud Functions** necesarias para el sistema **Shared Grocery Budget**, una aplicación que permite a grupos familiares gestionar presupuestos compartidos de compras en tiempo real.

### Estadísticas del Plan

- **Total de Functions:** 25
- **Functions Críticas:** 8
- **Functions de Soporte:** 10
- **Functions de Automatización:** 7

---

## 🏗️ Arquitectura General

### Principios de Diseño

1. **Seguridad First:** Todas las operaciones críticas deben validarse en el servidor
2. **Integridad de Datos:** Transacciones atómicas para operaciones financieras
3. **Real-time:** Sincronización instantánea entre miembros del grupo
4. **Escalabilidad:** Diseño que soporte crecimiento de usuarios
5. **Observabilidad:** Logs y métricas en todas las funciones

### Estructura de Colecciones Firestore

```
users/
  └── {userId}
      ├── name
      ├── email
      ├── photoURL
      ├── createdAt
      └── budgetIds[]

budgets/
  └── {budgetId}
      ├── name
      ├── budgetAmount
      ├── budgetPeriod (weekly|monthly|custom)
      ├── createdAt
      ├── ownerId
      ├── memberIds[]
      └── currentPeriodEnd

shoppingItems/
  └── {itemId}
      ├── budgetId
      ├── name
      ├── estimatedPrice
      ├── category
      ├── createdBy
      ├── createdAt
      ├── isPurchased
      ├── purchasedBy
      └── purchasedAt

budgetHistory/
  └── {historyId}
      ├── budgetId
      ├── periodStart
      ├── periodEnd
      └── totalSpent

invitations/
  └── {invitationId}
      ├── budgetId
      ├── inviterUserId
      ├── invitedEmail
      ├── invitedUserId
      ├── status (pending|accepted|rejected|cancelled)
      ├── createdAt
      └── acceptedAt

notifications/
  └── {notificationId}
      ├── userId
      ├── type
      ├── title
      ├── body
      ├── data
      ├── isRead
      └── createdAt
```

---

## 📚 Catálogo Completo de Cloud Functions

### Categorías

1. **Autenticación y Usuarios** (4 functions)
2. **Gestión de Presupuestos** (5 functions)
3. **Gestión de Items de Compra** (4 functions)
4. **Invitaciones y Miembros** (4 functions)
5. **Notificaciones** (3 functions)
6. **Automatización y Triggers** (5 functions)

---

## 📋 1. AUTENTICACIÓN Y USUARIOS

### 1.1 `createUserProfile`

**Tipo:** onCreate Trigger  
**Prioridad:** 🔴 CRÍTICA

```javascript
exports.createUserProfile = functions.auth.user().onCreate(async (user) => {
  // Crea el perfil del usuario en Firestore al registrarse
});
```

**Funcionalidad:**

- Crear documento en `/users/{userId}` cuando se registra un usuario
- Inicializar campos: name, email, photoURL, createdAt, budgetIds[]
- Enviar evento de tracking a AppsFlyer
- Enviar notificación de bienvenida

**Datos de entrada:** Firebase Auth User Object  
**Salida:** User document created

---

### 1.2 `deleteUserAccount`

**Tipo:** Callable Function  
**Prioridad:** 🟡 MEDIA

```javascript
exports.deleteUserAccount = functions.https.onCall(async (data, context) => {
  // Elimina cuenta del usuario y todos sus datos
});
```

**Funcionalidad:**

- Validar que el usuario está autenticado
- Si es owner de budgets, transferir ownership o eliminar
- Eliminar usuario de todos los budgets donde es miembro
- Eliminar invitaciones pendientes
- Eliminar notificaciones
- Eliminar cuenta de Firebase Auth
- Eliminar documento de usuario

**Entrada:**

```json
{
  "userId": "string",
  "transferOwnershipTo": "userId (opcional)"
}
```

**Salida:**

```json
{
  "success": true,
  "message": "Account deleted successfully"
}
```

---

### 1.3 `updateUserProfile`

**Tipo:** Callable Function  
**Prioridad:** 🟢 BAJA

```javascript
exports.updateUserProfile = functions.https.onCall(async (data, context) => {
  // Actualiza información del perfil del usuario
});
```

**Funcionalidad:**

- Validar autenticación
- Actualizar name, photoURL
- Sincronizar cambios en Firebase Auth si es necesario

**Entrada:**

```json
{
  "name": "string (opcional)",
  "photoURL": "string (opcional)"
}
```

---

### 1.4 `getUserBudgets`

**Tipo:** Callable Function  
**Prioridad:** 🟡 MEDIA

```javascript
exports.getUserBudgets = functions.https.onCall(async (data, context) => {
  // Obtiene todos los budgets del usuario
});
```

**Funcionalidad:**

- Listar todos los budgets donde el usuario es owner o miembro
- Incluir información resumida de cada budget
- Calcular presupuesto restante actual

**Salida:**

```json
{
  "budgets": [
    {
      "id": "budgetId",
      "name": "Family Groceries",
      "budgetAmount": 500,
      "totalSpent": 350.5,
      "remaining": 149.5,
      "memberCount": 4,
      "isOwner": true
    }
  ]
}
```

---

## 💰 2. GESTIÓN DE PRESUPUESTOS

### 2.1 `createBudget`

**Tipo:** Callable Function  
**Prioridad:** 🔴 CRÍTICA

```javascript
exports.createBudget = functions.https.onCall(async (data, context) => {
  // Crea un nuevo presupuesto compartido
});
```

**Funcionalidad:**

- Validar autenticación
- Crear documento en `/budgets/{budgetId}`
- Añadir al creador como owner
- Inicializar memberIds con el creador
- Calcular currentPeriodEnd basado en budgetPeriod
- Actualizar budgetIds[] del usuario
- Enviar evento a AppsFlyer

**Entrada:**

```json
{
  "name": "Family Groceries",
  "budgetAmount": 500.0,
  "budgetPeriod": "weekly|monthly|custom",
  "customPeriodStart": "ISO date (si custom)",
  "customPeriodEnd": "ISO date (si custom)"
}
```

**Salida:**

```json
{
  "budgetId": "abc123",
  "budget": {
    /* budget object */
  }
}
```

---

### 2.2 `updateBudget`

**Tipo:** Callable Function  
**Prioridad:** 🔴 CRÍTICA

```javascript
exports.updateBudget = functions.https.onCall(async (data, context) => {
  // Actualiza configuración del presupuesto
});
```

**Funcionalidad:**

- Validar que el usuario es owner del budget
- Permitir cambiar: name, budgetAmount, budgetPeriod
- Si cambia el período, recalcular currentPeriodEnd
- Notificar a todos los miembros del cambio
- Trackear evento en AppsFlyer

**Entrada:**

```json
{
  "budgetId": "string",
  "name": "string (opcional)",
  "budgetAmount": "number (opcional)",
  "budgetPeriod": "string (opcional)"
}
```

**Validaciones:**

- Solo el owner puede modificar
- budgetAmount debe ser > 0
- budgetPeriod debe ser válido

---

### 2.3 `deleteBudget`

**Tipo:** Callable Function  
**Prioridad:** 🟡 MEDIA

```javascript
exports.deleteBudget = functions.https.onCall(async (data, context) => {
  // Elimina un presupuesto y todos sus datos relacionados
});
```

**Funcionalidad:**

- Validar que el usuario es owner
- Crear snapshot final en budgetHistory
- Eliminar todos los shoppingItems asociados
- Eliminar todas las invitations pendientes
- Eliminar budget de budgetIds[] de todos los miembros
- Notificar a todos los miembros
- Eliminar documento del budget

**Entrada:**

```json
{
  "budgetId": "string"
}
```

**Salida:**

```json
{
  "success": true,
  "message": "Budget deleted successfully",
  "finalSnapshot": {
    /* history object */
  }
}
```

---

### 2.4 `getBudgetDetails`

**Tipo:** Callable Function  
**Prioridad:** 🟡 MEDIA

```javascript
exports.getBudgetDetails = functions.https.onCall(async (data, context) => {
  // Obtiene información completa del presupuesto
});
```

**Funcionalidad:**

- Validar que el usuario es miembro del budget
- Calcular totalSpent actual
- Calcular remaining
- Obtener lista de miembros con detalles
- Obtener estadísticas del período actual

**Entrada:**

```json
{
  "budgetId": "string"
}
```

**Salida:**

```json
{
  "budget": {
    "id": "budgetId",
    "name": "Family Groceries",
    "budgetAmount": 500,
    "totalSpent": 350.5,
    "remaining": 149.5,
    "percentageUsed": 70.1,
    "status": "ok|warning|exceeded",
    "currentPeriodEnd": "ISO date",
    "members": [
      {
        "userId": "user1",
        "name": "John Doe",
        "email": "john@example.com",
        "isOwner": true
      }
    ],
    "itemCount": 15,
    "purchasedItemCount": 8
  }
}
```

---

### 2.5 `transferBudgetOwnership`

**Tipo:** Callable Function  
**Prioridad:** 🟢 BAJA

```javascript
exports.transferBudgetOwnership = functions.https.onCall(
  async (data, context) => {
    // Transfiere el ownership del budget a otro miembro
  }
);
```

**Funcionalidad:**

- Validar que el usuario actual es owner
- Validar que el nuevo owner es miembro del budget
- Actualizar ownerId del budget
- Notificar al nuevo owner
- Notificar a todos los miembros

**Entrada:**

```json
{
  "budgetId": "string",
  "newOwnerId": "string"
}
```

---

## 🛒 3. GESTIÓN DE ITEMS DE COMPRA

### 3.1 `addShoppingItem`

**Tipo:** Callable Function  
**Prioridad:** 🔴 CRÍTICA

```javascript
exports.addShoppingItem = functions.https.onCall(async (data, context) => {
  // Añade un nuevo ítem a la lista de compras
});
```

**Funcionalidad:**

- Validar que el usuario es miembro del budget
- Crear documento en `/shoppingItems/{itemId}`
- Validar que estimatedPrice > 0
- Calcular nuevo totalSpent
- Verificar si se excede el presupuesto
- Notificar a miembros si se pasa del límite
- Trackear evento en AppsFlyer

**Entrada:**

```json
{
  "budgetId": "string",
  "name": "Milk",
  "estimatedPrice": 3.5,
  "category": "Dairy (opcional)"
}
```

**Salida:**

```json
{
  "itemId": "item123",
  "item": {
    /* item object */
  },
  "budgetStatus": {
    "totalSpent": 353.5,
    "remaining": 146.5,
    "exceeded": false
  }
}
```

---

### 3.2 `updateShoppingItem`

**Tipo:** Callable Function  
**Prioridad:** 🔴 CRÍTICA

```javascript
exports.updateShoppingItem = functions.https.onCall(async (data, context) => {
  // Actualiza un ítem existente
});
```

**Funcionalidad:**

- Validar que el usuario es miembro del budget
- Permitir cambiar: name, estimatedPrice, category, isPurchased
- Si cambia isPurchased a true, registrar purchasedBy y purchasedAt
- Recalcular totalSpent si cambia el precio
- Notificar si el cambio causa exceso de presupuesto

**Entrada:**

```json
{
  "itemId": "string",
  "name": "string (opcional)",
  "estimatedPrice": "number (opcional)",
  "category": "string (opcional)",
  "isPurchased": "boolean (opcional)"
}
```

---

### 3.3 `deleteShoppingItem`

**Tipo:** Callable Function  
**Prioridad:** 🟡 MEDIA

```javascript
exports.deleteShoppingItem = functions.https.onCall(async (data, context) => {
  // Elimina un ítem de la lista
});
```

**Funcionalidad:**

- Validar que el usuario es miembro del budget
- Solo el creador del item o el owner del budget pueden eliminar
- Eliminar documento del item
- Recalcular totalSpent

**Entrada:**

```json
{
  "itemId": "string"
}
```

---

### 3.4 `getBudgetItems`

**Tipo:** Callable Function  
**Prioridad:** 🟡 MEDIA

```javascript
exports.getBudgetItems = functions.https.onCall(async (data, context) => {
  // Obtiene todos los items de un presupuesto
});
```

**Funcionalidad:**

- Validar que el usuario es miembro del budget
- Filtrar por isPurchased si se solicita
- Ordenar por fecha de creación
- Incluir información del creador de cada item

**Entrada:**

```json
{
  "budgetId": "string",
  "filter": "all|active|purchased"
}
```

**Salida:**

```json
{
  "items": [
    {
      "id": "item1",
      "name": "Milk",
      "estimatedPrice": 3.5,
      "category": "Dairy",
      "isPurchased": false,
      "createdBy": {
        "userId": "user1",
        "name": "John Doe"
      },
      "createdAt": "ISO date"
    }
  ],
  "totalItems": 15,
  "totalValue": 350.5
}
```

---

## 👥 4. INVITACIONES Y MIEMBROS

### 4.1 `inviteMemberToBudget`

**Tipo:** Callable Function  
**Prioridad:** 🔴 CRÍTICA

```javascript
exports.inviteMemberToBudget = functions.https.onCall(async (data, context) => {
  // Invita a un usuario a unirse al presupuesto
});
```

**Funcionalidad:**

- Validar que el usuario es miembro del budget (cualquier miembro puede invitar)
- Verificar que el email no es de un miembro existente
- Crear documento en `/invitations/{invitationId}`
- Si el usuario invitado existe, crear notificación
- Enviar email de invitación
- Trackear evento en AppsFlyer

**Entrada:**

```json
{
  "budgetId": "string",
  "invitedEmail": "email@example.com"
}
```

**Salida:**

```json
{
  "invitationId": "inv123",
  "invitation": {
    /* invitation object */
  },
  "userExists": true,
  "notificationSent": true
}
```

---

### 4.2 `acceptBudgetInvitation`

**Tipo:** Callable Function  
**Prioridad:** 🔴 CRÍTICA

```javascript
exports.acceptBudgetInvitation = functions.https.onCall(
  async (data, context) => {
    // Acepta una invitación al presupuesto
  }
);
```

**Funcionalidad:**

- Validar que el usuario está autenticado
- Validar que la invitación es para el email del usuario
- Validar que la invitación está pending
- Añadir userId a memberIds[] del budget
- Añadir budgetId a budgetIds[] del usuario
- Actualizar invitation status a accepted
- Notificar al inviter
- Notificar a todos los miembros del budget

**Entrada:**

```json
{
  "invitationId": "string"
}
```

**Salida:**

```json
{
  "success": true,
  "budget": {
    /* budget object */
  }
}
```

---

### 4.3 `rejectBudgetInvitation`

**Tipo:** Callable Function  
**Prioridad:** 🟢 BAJA

```javascript
exports.rejectBudgetInvitation = functions.https.onCall(
  async (data, context) => {
    // Rechaza una invitación
  }
);
```

**Funcionalidad:**

- Validar que el usuario está autenticado
- Actualizar invitation status a rejected
- Notificar al inviter

**Entrada:**

```json
{
  "invitationId": "string"
}
```

---

### 4.4 `removeMemberFromBudget`

**Tipo:** Callable Function  
**Prioridad:** 🟡 MEDIA

```javascript
exports.removeMemberFromBudget = functions.https.onCall(
  async (data, context) => {
    // Elimina un miembro del presupuesto
  }
);
```

**Funcionalidad:**

- Validar que el usuario es owner del budget O es el propio miembro saliendo
- No permitir que el owner se elimine a sí mismo
- Eliminar userId de memberIds[] del budget
- Eliminar budgetId de budgetIds[] del usuario
- Notificar al usuario eliminado
- Notificar a todos los miembros restantes

**Entrada:**

```json
{
  "budgetId": "string",
  "memberUserId": "string"
}
```

---

## 🔔 5. NOTIFICACIONES

### 5.1 `sendPushNotification`

**Tipo:** Callable Function  
**Prioridad:** 🟡 MEDIA

```javascript
exports.sendPushNotification = functions.https.onCall(async (data, context) => {
  // Envía una notificación push a un usuario
});
```

**Funcionalidad:**

- Validar autenticación
- Crear documento en `/notifications/{notificationId}`
- Obtener FCM token del usuario
- Enviar push notification vía Firebase Cloud Messaging
- Guardar en Firestore para historial

**Entrada:**

```json
{
  "userId": "string",
  "title": "Budget Alert",
  "body": "You've exceeded your budget",
  "type": "budget_exceeded",
  "data": {
    "budgetId": "budget123"
  }
}
```

---

### 5.2 `getUnreadNotifications`

**Tipo:** Callable Function  
**Prioridad:** 🟢 BAJA

```javascript
exports.getUnreadNotifications = functions.https.onCall(
  async (data, context) => {
    // Obtiene notificaciones no leídas del usuario
  }
);
```

**Funcionalidad:**

- Validar autenticación
- Consultar `/notifications` donde userId == context.auth.uid AND isRead == false
- Ordenar por createdAt desc
- Limitar a las últimas 50

**Salida:**

```json
{
  "notifications": [
    {
      "id": "notif1",
      "type": "budget_exceeded",
      "title": "Budget Alert",
      "body": "Family Groceries budget exceeded",
      "data": { "budgetId": "budget123" },
      "createdAt": "ISO date",
      "isRead": false
    }
  ],
  "count": 5
}
```

---

### 5.3 `markNotificationsAsRead`

**Tipo:** Callable Function  
**Prioridad:** 🟢 BAJA

```javascript
exports.markNotificationsAsRead = functions.https.onCall(
  async (data, context) => {
    // Marca notificaciones como leídas
  }
);
```

**Entrada:**

```json
{
  "notificationIds": ["notif1", "notif2"]
}
```

---

## ⚙️ 6. AUTOMATIZACIÓN Y TRIGGERS

### 6.1 `onBudgetPeriodEnd`

**Tipo:** Scheduled Function (Cron)  
**Prioridad:** 🔴 CRÍTICA

```javascript
exports.onBudgetPeriodEnd = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async (context) => {
    // Verifica y cierra períodos de presupuesto finalizados
  });
```

**Funcionalidad:**

- Ejecutar cada 24 horas
- Consultar todos los budgets donde currentPeriodEnd < now
- Para cada budget:
  - Calcular totalSpent del período
  - Crear documento en `/budgetHistory`
  - Marcar todos los items como archivados o eliminarlos
  - Calcular nuevo currentPeriodEnd
  - Notificar a todos los miembros con resumen del período
  - Enviar evento a AppsFlyer

**Importancia:** Esta función mantiene la integridad del sistema de períodos

---

### 6.2 `onShoppingItemUpdated`

**Tipo:** Firestore Trigger  
**Prioridad:** 🟡 MEDIA

```javascript
exports.onShoppingItemUpdated = functions.firestore
  .document("shoppingItems/{itemId}")
  .onUpdate(async (change, context) => {
    // Reacciona a cambios en items de compra
  });
```

**Funcionalidad:**

- Detectar si cambió estimatedPrice
- Detectar si cambió isPurchased
- Si estimatedPrice cambió:
  - Notificar a miembros del budget
  - Verificar si ahora se excede el presupuesto
- Si isPurchased cambió a true:
  - Notificar al creador del item
  - Actualizar estadísticas

---

### 6.3 `onBudgetExceeded`

**Tipo:** Firestore Trigger  
**Prioridad:** 🟡 MEDIA

```javascript
exports.onBudgetExceeded = functions.firestore
  .document("budgets/{budgetId}")
  .onUpdate(async (change, context) => {
    // Detecta cuando se excede un presupuesto
  });
```

**Funcionalidad:**

- Calcular totalSpent antes y después
- Si antes no excedía y ahora sí:
  - Enviar notificación push a todos los miembros
  - Crear alerta en la app
  - Trackear evento en AppsFlyer

---

### 6.4 `cleanupOldInvitations`

**Tipo:** Scheduled Function  
**Prioridad:** 🟢 BAJA

```javascript
exports.cleanupOldInvitations = functions.pubsub
  .schedule("every 7 days")
  .onRun(async (context) => {
    // Limpia invitaciones antiguas
  });
```

**Funcionalidad:**

- Ejecutar semanalmente
- Consultar invitations donde createdAt < (now - 30 days) AND status == pending
- Actualizar status a cancelled
- Opcionalmente eliminar invitations muy antiguas (> 90 days)

---

### 6.5 `calculateBudgetStatistics`

**Tipo:** Callable Function  
**Prioridad:** 🟢 BAJA

```javascript
exports.calculateBudgetStatistics = functions.https.onCall(
  async (data, context) => {
    // Calcula estadísticas avanzadas del presupuesto
  }
);
```

**Funcionalidad:**

- Validar que el usuario es miembro del budget
- Calcular:
  - Promedio de gasto por día
  - Proyección de gasto al final del período
  - Categorías más caras
  - Miembro que más contribuye
  - Tendencia vs. períodos anteriores

**Entrada:**

```json
{
  "budgetId": "string"
}
```

**Salida:**

```json
{
  "statistics": {
    "avgDailySpend": 25.5,
    "projectedEndSpend": 510.0,
    "topCategories": [
      { "category": "Dairy", "total": 45.0 },
      { "category": "Meat", "total": 120.5 }
    ],
    "topContributor": {
      "userId": "user1",
      "name": "John Doe",
      "itemCount": 25
    },
    "comparisonToPreviousPeriod": {
      "percentageChange": +15.5,
      "difference": 50.0
    }
  }
}
```

---

### 6.6 `exportBudgetHistory`

**Tipo:** Callable Function  
**Prioridad:** 🟢 BAJA

```javascript
exports.exportBudgetHistory = functions.https.onCall(async (data, context) => {
  // Exporta el historial del presupuesto en CSV
});
```

**Funcionalidad:**

- Validar que el usuario es miembro del budget
- Consultar todos los documentos en budgetHistory para el budget
- Generar archivo CSV con los datos
- Subir a Cloud Storage
- Generar URL firmada con expiración
- Retornar URL de descarga

**Entrada:**

```json
{
  "budgetId": "string",
  "format": "csv|json"
}
```

**Salida:**

```json
{
  "downloadUrl": "https://storage.googleapis.com/...",
  "expiresAt": "ISO date"
}
```

---

### 6.7 `sendWeeklySummaryEmail`

**Tipo:** Scheduled Function  
**Prioridad:** 🟢 BAJA

```javascript
exports.sendWeeklySummaryEmail = functions.pubsub
  .schedule("every monday 09:00")
  .timeZone("America/Mexico_City")
  .onRun(async (context) => {
    // Envía resumen semanal por email
  });
```

**Funcionalidad:**

- Ejecutar cada lunes a las 9 AM
- Para cada budget activo:
  - Calcular estadísticas de la semana pasada
  - Generar email HTML con resumen
  - Enviar a todos los miembros
- Incluir:
  - Total gastado vs presupuesto
  - Items agregados
  - Items completados
  - Proyección para la semana

---

## 📊 Plan de Implementación Progresivo

### Fase 1: FUNDACIÓN (Semanas 1-3) 🔴

**Objetivo:** Establecer funcionalidad básica para MVP funcional

#### Sprint 1.1 - Autenticación y Usuarios

- ✅ `createUserProfile`
- ✅ `getUserBudgets`
- ✅ `updateUserProfile`

**Criterio de Éxito:** Usuarios pueden registrarse y ver su perfil

---

#### Sprint 1.2 - Presupuestos Básicos

- ✅ `createBudget`
- ✅ `getBudgetDetails`
- ✅ `updateBudget`

**Criterio de Éxito:** Usuarios pueden crear y editar presupuestos

---

#### Sprint 1.3 - Items de Compra

- ✅ `addShoppingItem`
- ✅ `updateShoppingItem`
- ✅ `getBudgetItems`

**Criterio de Éxito:** Lista de compras funcional con cálculo de presupuesto

---

### Fase 2: COLABORACIÓN (Semanas 4-6) 🟡

**Objetivo:** Habilitar funcionalidad multi-usuario

#### Sprint 2.1 - Sistema de Invitaciones

- ✅ `inviteMemberToBudget`
- ✅ `acceptBudgetInvitation`
- ✅ `rejectBudgetInvitation`

**Criterio de Éxito:** Usuarios pueden invitar y unirse a presupuestos

---

#### Sprint 2.2 - Gestión de Miembros

- ✅ `removeMemberFromBudget`
- ✅ `transferBudgetOwnership`

**Criterio de Éxito:** Gestión completa de miembros del grupo

---

#### Sprint 2.3 - Notificaciones Básicas

- ✅ `sendPushNotification`
- ✅ `getUnreadNotifications`
- ✅ `markNotificationsAsRead`

**Criterio de Éxito:** Sistema de notificaciones en tiempo real

---

### Fase 3: AUTOMATIZACIÓN (Semanas 7-9) 🟢

**Objetivo:** Automatizar procesos y triggers

#### Sprint 3.1 - Triggers Firestore

- ✅ `onShoppingItemUpdated`
- ✅ `onBudgetExceeded`

**Criterio de Éxito:** Alertas automáticas al exceder presupuesto

---

#### Sprint 3.2 - Gestión de Períodos

- ✅ `onBudgetPeriodEnd`

**Criterio de Éxito:** Cierre automático de períodos con historial

---

#### Sprint 3.3 - Limpieza y Mantenimiento

- ✅ `cleanupOldInvitations`

**Criterio de Éxito:** Base de datos limpia y eficiente

---

### Fase 4: ANALYTICS Y FEATURES AVANZADOS (Semanas 10-12) 🔵

**Objetivo:** Añadir funcionalidades avanzadas

#### Sprint 4.1 - Estadísticas

- ✅ `calculateBudgetStatistics`

**Criterio de Éxito:** Dashboard con insights sobre gastos

---

#### Sprint 4.2 - Exportación y Reportes

- ✅ `exportBudgetHistory`
- ✅ `sendWeeklySummaryEmail`

**Criterio de Éxito:** Usuarios pueden exportar y recibir reportes

---

#### Sprint 4.3 - Gestión Avanzada

- ✅ `deleteBudget`
- ✅ `deleteShoppingItem`
- ✅ `deleteUserAccount`

**Criterio de Éxito:** Gestión completa del ciclo de vida

---

### Fase 5: OPTIMIZACIÓN (Semanas 13-16) ⚡

**Objetivo:** Optimizar rendimiento y escalabilidad

#### Tareas:

1. Implementar caching con Cloud Memorystore
2. Optimizar queries con índices compuestos
3. Implementar rate limiting
4. Añadir retry logic con exponential backoff
5. Configurar alertas de monitoreo
6. Implementar feature flags
7. Testing de carga
8. Documentación completa de APIs

---

## 🔧 Consideraciones Técnicas

### Seguridad

#### Security Rules Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users - solo pueden leer/escribir su propio documento
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Budgets - solo miembros pueden leer
    match /budgets/{budgetId} {
      allow read: if request.auth != null &&
        request.auth.uid in resource.data.memberIds;
      allow write: if request.auth != null &&
        request.auth.uid == resource.data.ownerId;
    }

    // Shopping Items - solo miembros del budget pueden leer/escribir
    match /shoppingItems/{itemId} {
      allow read: if request.auth != null &&
        exists(/databases/$(database)/documents/budgets/$(resource.data.budgetId)) &&
        request.auth.uid in get(/databases/$(database)/documents/budgets/$(resource.data.budgetId)).data.memberIds;
      allow write: if request.auth != null &&
        exists(/databases/$(database)/documents/budgets/$(resource.data.budgetId)) &&
        request.auth.uid in get(/databases/$(database)/documents/budgets/$(resource.data.budgetId)).data.memberIds;
    }

    // Invitations
    match /invitations/{invitationId} {
      allow read: if request.auth != null &&
        (request.auth.uid == resource.data.inviterUserId ||
         request.auth.uid == resource.data.invitedUserId);
      allow write: if false; // Solo a través de Cloud Functions
    }

    // Notifications
    match /notifications/{notificationId} {
      allow read: if request.auth != null && request.auth.uid == resource.data.userId;
      allow write: if false; // Solo a través de Cloud Functions
    }
  }
}
```

---

### Validaciones Comunes

Todas las funciones callable deben incluir:

```javascript
// Validar autenticación
if (!context.auth) {
  throw new functions.https.HttpsError(
    "unauthenticated",
    "User must be authenticated"
  );
}

// Validar input
if (!data.budgetId || typeof data.budgetId !== "string") {
  throw new functions.https.HttpsError(
    "invalid-argument",
    "budgetId is required and must be a string"
  );
}

// Validar permisos
const budget = await db.collection("budgets").doc(data.budgetId).get();
if (!budget.exists) {
  throw new functions.https.HttpsError("not-found", "Budget not found");
}

if (!budget.data().memberIds.includes(context.auth.uid)) {
  throw new functions.https.HttpsError(
    "permission-denied",
    "User is not a member of this budget"
  );
}
```

---

### Manejo de Errores

```javascript
try {
  // Function logic
  return { success: true, data: result };
} catch (error) {
  logger.error("Error in functionName", {
    error: error.message,
    userId: context.auth?.uid,
    data: data,
  });

  throw new functions.https.HttpsError(
    "internal",
    "An error occurred while processing your request"
  );
}
```

---

### Límites y Cuotas

#### Configuración por Function

```javascript
exports.criticalFunction = functions
  .runWith({
    timeoutSeconds: 60,
    memory: "512MB",
    maxInstances: 100,
  })
  .https.onCall(async (data, context) => {
    // Function logic
  });
```

#### Límites Recomendados por Tipo

| Tipo de Function    | Timeout | Memory | Max Instances |
| ------------------- | ------- | ------ | ------------- |
| Callable (simple)   | 60s     | 256MB  | 50            |
| Callable (compleja) | 120s    | 512MB  | 50            |
| Trigger Firestore   | 60s     | 256MB  | 100           |
| Scheduled           | 540s    | 1GB    | 1             |

---

### Testing

#### Estructura de Tests

```javascript
// test/functions/budget.test.js
const test = require("firebase-functions-test")();
const admin = require("firebase-admin");

describe("Budget Functions", () => {
  let myFunctions;

  before(() => {
    myFunctions = require("../index");
  });

  after(() => {
    test.cleanup();
  });

  describe("createBudget", () => {
    it("should create a budget successfully", async () => {
      const data = {
        name: "Test Budget",
        budgetAmount: 500,
        budgetPeriod: "weekly",
      };

      const context = {
        auth: { uid: "testUser123" },
      };

      const result = await myFunctions.createBudget(data, context);

      assert.equal(result.success, true);
      assert.exists(result.budgetId);
    });

    it("should fail without authentication", async () => {
      const data = { name: "Test", budgetAmount: 500 };
      const context = {};

      await assert.rejects(() => myFunctions.createBudget(data, context), {
        code: "unauthenticated",
      });
    });
  });
});
```

---

## 📈 Métricas y Monitoreo

### KPIs de las Cloud Functions

#### Performance Metrics

- **Latencia promedio:** < 500ms para callable functions
- **Error rate:** < 1%
- **Cold start time:** < 2s
- **Success rate:** > 99%

#### Business Metrics

- **Budgets creados por día**
- **Items agregados por día**
- **Invitaciones enviadas vs aceptadas**
- **Notificaciones entregadas**
- **Períodos cerrados automáticamente**

---

### Monitoreo con Cloud Monitoring

```javascript
// Ejemplo de métricas personalizadas
const { Logging } = require("@google-cloud/logging");
const logging = new Logging();

async function logMetric(metricName, value, labels = {}) {
  const log = logging.log("cloud-functions-metrics");
  const metadata = {
    resource: { type: "cloud_function" },
    severity: "INFO",
    labels: labels,
  };

  const entry = log.entry(metadata, {
    metric: metricName,
    value: value,
    timestamp: new Date().toISOString(),
  });

  await log.write(entry);
}

// Uso en una función
exports.createBudget = functions.https.onCall(async (data, context) => {
  const startTime = Date.now();

  try {
    // Function logic
    const result = await budgetService.create(data);

    // Log success metric
    await logMetric("budget_created", 1, {
      userId: context.auth.uid,
      budgetPeriod: data.budgetPeriod,
    });

    const duration = Date.now() - startTime;
    await logMetric("function_duration", duration, {
      functionName: "createBudget",
    });

    return result;
  } catch (error) {
    await logMetric("budget_creation_failed", 1, {
      error: error.message,
    });
    throw error;
  }
});
```

---

### Alertas Recomendadas

1. **Error Rate > 5%** durante 5 minutos
2. **Latencia > 2s** en el percentil 95
3. **Cold starts > 100** por hora
4. **Budget exceeded** sin notificación enviada
5. **Period end** no procesado

---

## 📝 Checklist de Implementación

Por cada Cloud Function a implementar:

- [ ] Definir firma de la función (inputs/outputs)
- [ ] Implementar validaciones de seguridad
- [ ] Implementar lógica de negocio
- [ ] Añadir manejo de errores
- [ ] Implementar logging
- [ ] Escribir tests unitarios
- [ ] Escribir tests de integración
- [ ] Documentar en JSDoc
- [ ] Configurar métricas
- [ ] Deploy a staging
- [ ] QA testing
- [ ] Deploy a producción
- [ ] Monitorear por 24h

---

## 🚀 Comandos de Deployment

### Deploy Individual

```bash
firebase deploy --only functions:createBudget
```

### Deploy por Grupo

```bash
# Solo functions de autenticación
firebase deploy --only functions:createUserProfile,functions:getUserBudgets

# Solo functions críticas
firebase deploy --only functions:createBudget,functions:addShoppingItem,functions:inviteMemberToBudget
```

### Deploy Completo

```bash
firebase deploy --only functions
```

### Rollback

```bash
# Ver versiones
firebase functions:list

# Rollback a versión anterior
firebase functions:roll-back functionName --version versionNumber
```

---

## 📚 Recursos Adicionales

### Documentación Oficial

- [Firebase Cloud Functions](https://firebase.google.com/docs/functions)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)

### Best Practices

- [Cloud Functions Best Practices](https://firebase.google.com/docs/functions/best-practices)
- [Firestore Data Modeling](https://firebase.google.com/docs/firestore/manage-data/structure-data)
- [Error Handling](https://firebase.google.com/docs/functions/callable#handle_errors)

---

## 📞 Soporte y Contacto

Para preguntas sobre este plan de implementación:

- **Documentación del Proyecto:** `/contextoCopilot/rules/`
- **Firebase Console:** [console.firebase.google.com](https://console.firebase.google.com)

---

**Versión del Documento:** 1.0  
**Última Actualización:** 19 de Diciembre, 2025  
**Estado:** ✅ Aprobado para Implementación

---

## 🎯 Próximos Pasos

1. **Revisar y aprobar** este documento con el equipo
2. **Configurar entorno** de Cloud Functions (staging + production)
3. **Comenzar Fase 1, Sprint 1.1** - Autenticación y Usuarios
4. **Setup de CI/CD** para deployment automatizado
5. **Configurar monitoreo** en Cloud Monitoring

---

**¡Manos a la obra! 🚀**
