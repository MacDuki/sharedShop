# Guía de Uso de Localizaciones

## Configuración Completada ✓

La aplicación ahora soporta múltiples idiomas (Español e Inglés) con las siguientes características:

### 1. Archivos Configurados

- ✅ `pubspec.yaml`: Habilitado flutter_localizations y generación automática
- ✅ `l10n.yaml`: Configuración de generación de localizaciones
- ✅ `lib/l10n/app_en.arb`: Traducciones en inglés
- ✅ `lib/l10n/app_es.arb`: Traducciones en español
- ✅ `lib/state/app_provider.dart`: Gestión de estado del idioma con persistencia
- ✅ `lib/main.dart`: Configurado con soporte de localizaciones
- ✅ Selector de idioma en User Settings: Conectado con AppProvider

### 2. Cómo Usar las Localizaciones en las Pantallas

Para usar las traducciones en cualquier pantalla:

#### Paso 1: Importar AppLocalizations

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

#### Paso 2: Obtener la instancia de localización en el build

```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return Text(l10n.nombreDeLaClave); // Ejemplo: l10n.dashboard
}
```

### 3. Textos Disponibles

Todos los textos están definidos en los archivos ARB. Ejemplos:

#### Dashboard

- `l10n.dashboard` → "DASHBOARD" / "DASHBOARD"
- `l10n.dashboardGreeting('Nombre')` → "Hi, Nombre" / "Hola, Nombre"
- `l10n.remainingBudget` → "REMAINING BUDGET" / "PRESUPUESTO RESTANTE"
- `l10n.budget` → "Budget" / "Presupuesto"
- `l10n.spent` → "Spent" / "Gastado"
- `l10n.daysLeft(12)` → "12 days left" / "12 días restantes"

#### Shopping List

- `l10n.shoppingList` → "SHOPPING LIST" / "LISTA DE COMPRAS"
- `l10n.items(5)` → "5 items" / "5 ítems"
- `l10n.addItem` → "Add Item" / "Agregar Ítem"
- `l10n.pending` → "Pending" / "Pendiente"
- `l10n.purchased` → "Purchased" / "Comprado"

#### User Settings

- `l10n.settings` → "Settings" / "Configuración"
- `l10n.profile` → "Profile" / "Perfil"
- `l10n.name` → "Name" / "Nombre"
- `l10n.email` → "Email" / "Correo electrónico"
- `l10n.language` → "Language" / "Idioma"
- `l10n.selectLanguage` → "Select language" / "Seleccionar idioma"

#### Categories

- `l10n.fruits` → "Fruits" / "Frutas"
- `l10n.vegetables` → "Vegetables" / "Verduras"
- `l10n.meat` → "Meat" / "Carnes"
- `l10n.dairy` → "Dairy" / "Lácteos"
- `l10n.bakery` → "Bakery" / "Panadería"
- `l10n.beverages` → "Beverages" / "Bebidas"

#### Common

- `l10n.save` → "Save" / "Guardar"
- `l10n.cancel` → "Cancel" / "Cancelar"
- `l10n.edit` → "Edit" / "Editar"
- `l10n.delete` → "Delete" / "Eliminar"
- `l10n.close` → "Close" / "Cerrar"
- `l10n.yes` → "Yes" / "Sí"
- `l10n.no` → "No" / "No"

### 4. Cambiar Idioma

El usuario puede cambiar el idioma desde:
**User Settings → Appearance → Language**

El cambio de idioma:

- Se aplica inmediatamente en toda la aplicación
- Se persiste usando SharedPreferences
- Se restaura automáticamente al reiniciar la app

### 5. Agregar Nuevas Traducciones

Para agregar nuevas traducciones:

1. Edita `lib/l10n/app_en.arb` y agrega la clave en inglés:

```json
"newKey": "New Text in English"
```

2. Edita `lib/l10n/app_es.arb` y agrega la traducción en español:

```json
"newKey": "Nuevo Texto en Español"
```

3. Si el texto tiene parámetros:

```json
"greeting": "Hello, {name}",
"@greeting": {
  "placeholders": {
    "name": {
      "type": "String"
    }
  }
}
```

4. Regenera los archivos de localización:

```bash
flutter gen-l10n
```

5. Usa en tu código:

```dart
Text(l10n.newKey)
// o con parámetros:
Text(l10n.greeting('Usuario'))
```

### 6. Pantallas a Actualizar

Las siguientes pantallas necesitan ser actualizadas para usar las localizaciones:

- ✅ **Dashboard Screen** (parcialmente actualizado)
- ⏳ **Shopping List Screen**
- ⏳ **Add Item Screen**
- ⏳ **Budget Settings Screen**
- ⏳ **User Settings Screen** (selector conectado, textos pendientes)
- ⏳ **History Screen**
- ⏳ **Notifications Screen**
- ⏳ **Group Settings Screen**
- ⏳ **Invite Members Screen**
- ⏳ **Login Screen**

### 7. Ejemplo de Implementación Completa

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: Column(
        children: [
          Text(l10n.name),
          Text(l10n.email),
          ElevatedButton(
            onPressed: () {},
            child: Text(l10n.save),
          ),
          TextButton(
            onPressed: () {},
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
```

### 8. Notas Importantes

- ⚠️ No uses palabras reservadas de Dart como nombres de claves (ej: "continue" → usar "continueButton")
- 💡 Todas las claves están en camelCase
- 🔄 Los archivos de localización se generan automáticamente en `.dart_tool/flutter_gen/gen_l10n/`
- 💾 El idioma seleccionado se guarda automáticamente en SharedPreferences
- 🌍 El idioma por defecto es español ('es')

## Estado Actual

✅ **Funcionalidad de cambio de idioma completamente implementada y funcional**
✅ **Toggle en User Settings conectado a AppProvider**
✅ **Persistencia de idioma configurada**
✅ **Archivos de traducción completos para toda la aplicación**

Para completar la implementación, actualiza cada pantalla siguiendo los ejemplos anteriores.
