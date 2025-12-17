---
description: 
globs: 
alwaysApply: true
---
Para el desarrollo de este proyecto, estamos usando las siguiente tecnologías:

- Flutter: Usamos Flutter para el desarrollo del cliente de nuestra aplicación en Android y IOS.
- Firebase Auth: Usamos Firebase Authentication para el registro e inicio de sesión de nuestros usuarios.
- Firebase Cloud Functions: Usamos Firebase Cloud Functions como nuestro "backend" para la ejecución de la lógica. 
- Firebase Firestore: Usamos la base de datos de Firestore para guardar los datos de nuestros usuarios y de nuestra aplicación.

Estructura de carpetas del proyecto Flutter:

lib
├── main.dart
├── screens (Aquí van las pantallas de la aplicación, cada pantalla separada en subcarpetas)
├── services (Aquí van los servicios de la aplicación, como llamado a cloud functions, auth, suscripciones, etc.)
├── state (Aquí van los archivos relacionados al manejo de estado de la aplicación)
├── utils (Aquí van los archivos de utilidades, como objetos de estilos, mapeo de assets, etc. )
└── widgets (Aquí van los widgets de la aplicación, agrupados en subcarpetas según la feature o pantalla)
└── models (Aquí van los modelos de la aplicación, agrupados en subcarpetas según la feature)

Reglas:

- Todas las funciones que involucren interactuar con una API externa o con nuestra base de datos en firestore, deben estar como cloud functions. Nunca se debe conectar nuestra aplicación de manera directa a una API o a nuestra base de datos por temas de seguridad.

- Escribe código limpio, siempre buscando la forma más óptima de llevar a cabo cada tarea o feature.

- Si tienes dudas respecto a una implementación, o la solicitud es demasiado ambigua o carece de detalles, por favor realiza todas las preguntas necesarias antes de llevar a cabo la implementación.

- Si para la implementación de una funcionalidad, necesitas de documentación, hazlo saber, o búscala directamente en internet, ya que tu código debe estar actualizado para funcionar correctamente.

- Prefiere crear modelos específicos en Flutter y acorde a la estructura de la base de datos para el manejo de datos, en vez de utilizar Maps.

- Prefiere crear nuevos widgets Stateless o Stateful según corresponda, antes que utilizar funciones que retornen widgets.