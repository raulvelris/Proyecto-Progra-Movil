<h1 align="center">EventMaster</h1>

Este aplicativo móvil es...

## Índice

- [Configuración del Ambiente de Desarrollo](#configuración-del-ambiente-de-desarrollo)
- [Diagrama de Despliegue](#diagrama-de-despliegue)
- [Requerimientos No Funcionales](#requerimientos-no-funcionales)
- [Diagrama de Casos de Uso](#diagrama-de-casos-de-uso)

## Configuración del Ambiente de Desarrollo

Mucho texto...

## Diagrama de Despliegue

Mucho texto...

## Requerimientos No Funcionales

A continuación, se detallan los requerimientos no funcionales del sistema:

### 1. Escalabilidad
El sistema deberá estar preparado para gestionar un incremento progresivo en el número de usuarios, eventos y recursos compartidos sin afectar su rendimiento. La arquitectura backend deberá permitir escalamiento horizontal para atender picos de uso, como en eventos masivos o campañas promocionales.

### 2. Alta disponibilidad
El servicio deberá garantizar una disponibilidad mínima del **99.9%** mensual, asegurando acceso constante a los usuarios, especialmente durante eventos programados. Se debe implementar un sistema de recuperación ante fallos y redundancia en los servidores para evitar caídas del servicio.

### 3. Seguridad y privacidad
La comunicación entre cliente y servidor se realizará mediante **HTTPS**, y se utilizarán **tokens JWT** para autenticación y autorización de usuarios.  
Además, los **eventos privados** deberán contar con controles que impidan el acceso a usuarios no invitados, protegiendo detalles como ubicación, recursos adjuntos y lista de asistentes.

### 4. Compatibilidad multiplataforma
La aplicación, desarrollada en **Flutter**, debe ser plenamente funcional en dispositivos con sistema operativo **Android** (desde la versión 8.0) y **iOS** (desde la versión 13.0), sin pérdida de funcionalidades ni errores de diseño en ninguna de las plataformas.

### 5. Eficiencia del sistema
- **Rendimiento:** Las funciones clave como visualizar eventos, confirmar asistencia o gestionar invitados deben ejecutarse con una latencia menor a **200 ms** bajo condiciones normales.  
- **Optimización de red:** Las respuestas del servidor deberán estar comprimidas y usar mecanismos de **caching** para reducir el uso de datos móviles, especialmente en la carga de eventos públicos y recursos multimedia.

### 6. Usabilidad
La interfaz deberá seguir las pautas de diseño de **Material Design**, asegurando una navegación intuitiva.  
Se dará prioridad a la simplicidad de uso para usuarios que no estén familiarizados con aplicaciones de gestión de eventos, utilizando íconos comprensibles, flujos de registro/invitación claros y acciones visibles.

### 7. Mantenibilidad y actualizaciones
El sistema deberá estructurarse de forma modular para facilitar el mantenimiento, resolución de errores y ampliación de funcionalidades.  
Se deberá implementar un proceso de **integración y despliegue continuo (CI/CD)** que permita realizar actualizaciones sin interrumpir el servicio a los usuarios activos.

### 8. Integridad y consistencia de datos
El backend deberá implementar transacciones **ACID** para garantizar la consistencia de datos críticos, como la confirmación de asistencia, creación/eliminación de eventos, y actualización del estado de los invitados.

### 9. Registro y monitoreo de eventos del sistema
El backend deberá contar con un sistema de **logging centralizado** y herramientas de monitoreo en tiempo real, capaces de detectar errores, registrar actividad de los usuarios e informar sobre eventos inusuales (como intentos de acceso no autorizado).

### 10. Sincronización en tiempo real
Los cambios en eventos (como confirmaciones de asistencia, cancelaciones o recursos compartidos) deberán reflejarse **en tiempo real** en los dispositivos de los participantes.

## Diagrama de Casos de Uso

El siguiente diagrama de casos de uso representa las principales interacciones dentro del Sistema de Gestión de Eventos. En este sistema, los clientes pueden registrarse, iniciar sesión, acceder al detalle de los eventos, administrar su perfil y cerrar sesión.

El asistente, como especialización del cliente, tiene la posibilidad de explorar eventos públicos, consultar notificaciones y gestionar los eventos a los que está inscrito. Por su parte, el organizador cuenta con funcionalidades adicionales que le permiten crear y administrar sus propios eventos, incluyendo la edición y eliminación de los mismos, así como la gestión de recursos e invitados.

Estas funcionalidades en conjunto aseguran una experiencia completa tanto para los asistentes como para los organizadores, facilitando la creación, consulta y participación en eventos dentro de la plataforma móvil.

![Casos de Uso](images/UserCases.png)

A continuación, se detallan los casos de uso:

| Código | Nombre                        | Actor       | Descripción                                                                                                                                  |
| ------ | ----------------------------- | ----------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| UC1    | Registrarse                   | Usuario     | Permite a los usuarios crear una nueva cuenta en el sistema y activarla para poder acceder a sus funcionalidades.                            |
| UC2    | Iniciar sesión                | Usuario     | Permite a los usuarios autenticarse ingresando sus credenciales en la aplicación.                                                            |
| UC3    | Explorar eventos públicos     | Usuario     | Permite al usuario visualizar y explorar todos los eventos disponibles al público.                                                           |
| UC4    | Consultar notificaciones      | Usuario     | Permite al usuario visualizar todas las notificaciones recibidas, incluyendo invitaciones privadas, y confirmar su asistencia a los eventos. |
| UC5    | Consultar eventos asistidos   | Usuario     | Permite al usuario visualizar los eventos a los que está inscrito y desvincularse de ellos si lo desea.                                      |
| UC6    | Crear evento                  | Organizador | Permite al organizador crear un nuevo evento, definiendo sus características principales.                                                    |
| UC7    | Consultar eventos creados     | Organizador | Permite al organizador visualizar, editar o eliminar los eventos que ha creado.                                                              |
| UC8    | Acceder al detalle del evento | Usuario     | Permite al usuario consultar información completa de un evento, incluyendo ubicación, recursos y detalles relevantes.                        |
| UC9    | Administrar un evento         | Organizador | Permite al organizador gestionar los recursos e invitados de un evento específico.                                                           |
| UC10   | Administrar perfil            | Usuario     | Permite al usuario consultar y actualizar su información personal.                                                                           |
| UC11   | Cerrar sesión                 | Usuario     | Permite al usuario cerrar su sesión de manera segura en la aplicación.                                                                       |

Y el diagrama de clases es el siguiente:

![Casos de Uso](images/DatabaseDiagram.png)                                                                  
