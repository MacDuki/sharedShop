📌 MVP DEFINITIVO — Shared Grocery Budget
0️⃣ Objetivo del MVP (no negociable)

Permitir que varias personas compartan una lista de compras y vean en tiempo real cómo cada ítem impacta en un presupuesto común, evitando sobrepasarlo.

1️⃣ Alcance del MVP (qué SÍ )
✅ Incluido

Presupuesto compartido

Lista de compras colaborativa

Cálculo en tiempo real

Historial básico

Invitación de miembros



2️⃣ Entidades principales (modelo conceptual)
User

id

name

email

householdId

Household (Grupo)

id

name

budgetAmount

budgetPeriod (weekly | monthly)

createdAt

ShoppingItem

id

householdId

name

estimatedPrice (number)

category (optional)

createdBy (userId)

createdAt

isPurchased (boolean)

BudgetHistory

id

householdId

periodStart

periodEnd

totalSpent

3️⃣ Pantallas del MVP y funcionalidades EXACTAS
🟢 1. Home / Dashboard
Objetivo

Mostrar de forma inmediata el estado del presupuesto compartido.

Elementos UI

Presupuesto total

Total gastado

Presupuesto restante (elemento principal)

Barra de progreso visual

Estado visual:

Verde: < 70%

Ámbar: 70–100%

Rojo: > 100%

Funcionalidades

Cálculo automático:

totalGastado = suma(estimatedPrice de items activos)
restante = budgetAmount - totalGastado


Actualización en tiempo real cuando:

Se agrega / edita / elimina un ítem

Otro miembro hace cambios

Reglas

No permite editar desde aquí

Solo visualización

🟢 2. Shopping List
Objetivo

Permitir agregar y gestionar compras viendo su impacto financiero.

Elementos UI

Lista de ítems

Precio estimado por ítem

Total acumulado visible arriba

Indicador visual si se excede el presupuesto

Funcionalidades

Agregar ítem

Editar ítem (nombre / precio)

Eliminar ítem

Marcar ítem como comprado (checkbox)

Reglas

Al marcar como comprado:

NO se elimina

Permanece hasta cierre de período

Cada cambio recalcula el presupuesto en tiempo real

🟢 3. Add Item
Objetivo

Agregar ítems con mínima fricción.

Campos

Nombre (string, obligatorio)

Precio estimado (number, obligatorio)

Categoría (string, opcional)

Funcionalidades

Validación básica:

Nombre no vacío

Precio > 0

Botón “Agregar”

Feedback inmediato del impacto en presupuesto

Reglas

No autocompletado

No sugerencias inteligentes (fuera del MVP)

🟢 4. Budget Settings
Objetivo

Configurar el presupuesto compartido.

Campos

Monto del presupuesto (number)

Período:

Semanal

Mensual

Funcionalidades

Editar presupuesto

Guardar cambios

Recalcular totales automáticamente

Reglas

Cambiar el presupuesto NO borra la lista

El período solo afecta historial futuro

🟢 5. History
Objetivo

Dar visibilidad básica del gasto pasado.

Elementos UI

Lista de períodos anteriores

Total gastado por período

Fecha de inicio / fin

Funcionalidades

Lectura únicamente

No edición

Datos agregados

Reglas

Se genera un registro cuando:

Finaliza el período actual

La lista activa se resetea automáticamente

🟢 6. Invite Members
Objetivo

Habilitar colaboración sin fricción.

Elementos UI

Código o link de invitación

Lista de miembros actuales

Funcionalidades

Generar link/código

Unirse a household existente

Reglas

Todos los miembros tienen los mismos permisos (MVP)

No roles (admin/user) en MVP

4️⃣ Comportamientos globales (reglas importantes)

Todos los cambios son sincronizados en tiempo real

No hay conflictos de edición (última escritura gana)

No hay control de permisos

Una persona = un household (MVP)

5️⃣ Métricas clave del MVP (para validar)

% de usuarios que crean un household

% que agregan ≥ 5 ítems

Uso recurrente semanal

Cambios en presupuesto

Usuarios invitados por household

6️⃣ Definición de “MVP completo”

El MVP está listo cuando:

Se puede crear un grupo

Definir presupuesto

Agregar ítems

Ver impacto en tiempo real

Compartir con otra persona

Cerrar un período y ver historial

Nada más.

7️⃣ Nota IMPORTANTE para Copilot / IA

Este documento es la única fuente de verdad.
No agregar funcionalidades no listadas aquí.
Priorizar simplicidad, claridad y lógica determinística.