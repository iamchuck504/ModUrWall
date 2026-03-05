# ModUrWall - Diseñador de Wallpapers con IA

Aplicación Flutter para diseñar wallpapers personalizados con IA. Esta es la maqueta inicial con un carrusel 3D interactivo.

## Características

- ✨ Carrusel 3D giratorio con 9 diseños
- 🎨 4 temas de color (Wine, Ocean, Fusion, Orange)
- 🌓 Modo claro/oscuro
- 🔄 Rotación reversible y velocidad ajustable
- 💫 Efecto de flip en las tarjetas al hacer clic
- 🖼️ Soporte para GIFs animados
- 📱 Diseño responsive

## Requisitos

- Flutter SDK (versión 3.0.0 o superior)
- Xcode (para compilar en iOS/macOS)
- Dart SDK

## Agregar tus Animaciones/GIFs

### Opción 1: Copiar tu carpeta Animations/ existente

```bash
# Desde donde tienes tu carpeta Animations/
cp Animations/*.gif /ruta/a/moduruwall/assets/animations/
```

La app está configurada para usar estos 9 GIFs de tu colección:

1. **NeuralNetwork.gif** - Red Neuronal
2. **Blockchain.gif** - Blockchain
3. **QuantumComputing.gif** - Computación Cuántica
4. **Cybersecurity.gif** - Ciberseguridad
5. **DigitalMatrix.gif** - Matriz Digital
6. **DataVisualization.gif** - Visualización de Datos
7. **digitalSamurai.gif** - Samurái Digital
8. **CloudComputing.gif** - Computación en la Nube
9. **Infrastructure.gif** - Infraestructura

### Opción 2: Copiar solo estos 9 archivos

```bash
# Copia solo los GIFs necesarios
cp Animations/NeuralNetwork.gif moduruwall/assets/animations/
cp Animations/Blockchain.gif moduruwall/assets/animations/
cp Animations/QuantumComputing.gif moduruwall/assets/animations/
cp Animations/Cybersecurity.gif moduruwall/assets/animations/
cp Animations/DigitalMatrix.gif moduruwall/assets/animations/
cp Animations/DataVisualization.gif moduruwall/assets/animations/
cp Animations/digitalSamurai.gif moduruwall/assets/animations/
cp Animations/CloudComputing.gif moduruwall/assets/animations/
cp Animations/Infrastructure.gif moduruwall/assets/animations/
```

**Nota:** Si no agregas los GIFs, la app mostrará gradientes de colores hermosos como placeholder.

## Instalación y Ejecución

### 1. Preparar el proyecto

```bash
cd moduruwall
flutter pub get
```

### 2. Ejecutar en iOS Simulator

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en iPhone Simulator
flutter run -d ios

# O específicamente en un simulador
flutter run -d "iPhone 15 Pro"
```

### 3. Abrir en Xcode

```bash
# Generar el proyecto de Xcode
flutter build ios --no-codesign

# Abrir el workspace en Xcode
open ios/Runner.xcworkspace
```

Luego en Xcode:
1. Selecciona tu dispositivo o simulador de destino
2. Presiona ⌘+R para compilar y ejecutar

### 4. Ejecutar en macOS

```bash
flutter run -d macos
```

## Estructura del Proyecto

```
moduruwall/
├── lib/
│   └── main.dart              # Código principal de la aplicación
├── assets/
│   ├── animations/            # GIFs animados (design1.gif - design9.gif)
│   └── images/                # Imágenes estáticas
├── pubspec.yaml               # Dependencias y configuración
├── ios/                       # Configuración de iOS
├── macos/                     # Configuración de macOS
└── README.md                  # Este archivo
```

## Uso de la Aplicación

### Pantalla Principal
- **Grid de 9 diseños**: Vista de galería con diseños de wallpapers (GIFs o gradientes)
- **Hover effect**: Las tarjetas se elevan al pasar el mouse
- **Overlay animado**: Muestra el nombre del diseño al hacer hover
- **Barra de búsqueda**: Para buscar diseños (funcionalidad futura)
- **Temas de color**: Botones en la parte superior para cambiar el color de acento
- **Toggle día/noche**: Cambia entre modo claro y oscuro

### Vista de Carrusel
- **Clic en cualquier diseño**: Abre la vista de carrusel 3D
- **Clic en una tarjeta**: Gira la tarjeta para ver información adicional
- **Botón de rotación**: Invierte la dirección del carrusel
- **Botones SLOW/FAST**: Ajusta la velocidad de rotación
- **Botón X**: Cierra el carrusel y regresa a la vista principal

## Próximas Características

- [ ] Integración con API de generación de imágenes IA
- [ ] Guardado de wallpapers favoritos
- [ ] Compartir diseños
- [ ] Edición avanzada de wallpapers
- [ ] Sincronización con la nube
- [ ] Categorías y colecciones

## Tecnologías Utilizadas

- **Flutter/Dart**: Framework principal
- **Animaciones 3D**: Transformaciones Matrix4
- **Material Design**: Para componentes UI
- **Assets locales**: Para GIFs y imágenes

## Notas de Desarrollo

Este es un prototipo inicial. Las imágenes actuales son placeholders con gradientes de colores, pero la app está configurada para cargar archivos GIF desde `assets/animations/`.

El efecto de carrusel 3D está inspirado en el diseño web de Lempyra.com/chapters/ariandel.html, adaptado para una experiencia móvil nativa.

## Solución de Problemas

### Los GIFs no se muestran
1. Verifica que los archivos estén en `assets/animations/`
2. Asegúrate de que los nombres sean exactamente: `design1.gif`, `design2.gif`, etc.
3. Ejecuta `flutter pub get` nuevamente
4. Limpia y recompila: `flutter clean && flutter pub get && flutter run`

### Error de compilación
- Asegúrate de tener Flutter SDK actualizado: `flutter upgrade`
- Verifica que Xcode esté actualizado (versión 14.0 o superior)

## Licencia

Todos los derechos reservados © 2025 ModUrWall
