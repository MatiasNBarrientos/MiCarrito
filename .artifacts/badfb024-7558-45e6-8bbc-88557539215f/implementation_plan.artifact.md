# Rediseño de Interfaz y Mejora de Seguridad en Carrito

Este plan contempla la reubicación del botón de cierre de carrito para evitar clics accidentales y el rediseño de la barra de navegación inferior para cumplir con estándares de diseño responsivo.

## User Review Required

> [!IMPORTANT]
> El botón "CERRAR CARRITO" ya no estará en la parte inferior, sino en la esquina superior derecha como un icono de check. Se ha añadido un paso de confirmación adicional.

## Proposed Changes

### Pantalla de Lista de Compras

#### [MODIFY] [lista_compras.dart](file:///C:/proyectos/MiCarrito/lib/models/screens/lista_compras.dart)
- Extraer la lógica de cierre de carrito a una función privada `_cerrarCarrito`.
- Implementar `_confirmarCierreCarrito` con un diálogo de confirmación.
- Mover el botón a la barra superior personalizada.
- Ajustar márgenes inferiores del contenedor de "Total Estimado".

### Pantalla Principal (Navegación)

#### [MODIFY] [pantalla_principal.dart](file:///C:/proyectos/MiCarrito/lib/models/screens/pantalla_principal.dart)
- Aumentar la altura de `BottomAppBar` a un valor estándar (70).
- Usar `SafeArea` en la barra inferior.
- Mejorar el espaciado de los botones de navegación.

## Verification Plan

### Manual Verification
- Abrir la app y verificar que la barra de navegación inferior se vea más espaciosa y respete los bordes del dispositivo.
- Ir a la lista de compras y verificar que el botón "Cerrar Carrito" esté en la parte superior.
- Tocar el botón de cerrar y verificar que aparezca el diálogo de confirmación.
- Confirmar el cierre y verificar que la acción se realice correctamente.
