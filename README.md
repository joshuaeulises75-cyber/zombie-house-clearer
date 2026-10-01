# Zombie House Clearer - Juego 2D en Godot

## 🎮 Características principales:

### ✨ Sistema de Aliados Inteligente
- **Tres tipos de aliados**: Médico, Francotirador, Tanque
- **Personalidades dinámicas**: Brave, Cautious, Coward
- **+40 diálogos únicos** por personalidad
- **Interacciones entre aliados** con conversaciones contextuales
- **Abandono por miedo**: ¡Los aliados pueden huir si les da demasiado miedo!
- **Estados emocionales visuales**: Emojis 😤😱😊 que cambian según el estado
- **Sistema de moral y estrés**: Afecta el comportamiento

### 🧟 Zombies Especiales
- **Common**: Zombie normal
- **Runner**: Rápido pero débil
- **Tank**: Lento pero muy fuerte
- **Spitter**: Lanza proyectiles desde distancia

### 🎯 Sistema de Armas
- **Pistol**: Rápida y precisa
- **Rifle**: Poder y precisión media
- **Shotgun**: Máximo daño en cercana

### 🏪 Tienda
- Compra aliados con monedas
- Sistema de progresión
- Interfaz intuitiva

### 🎨 Animaciones Mejoradas
- Estados emocionales visuales
- Cambio de color según personalidad
- Animaciones de curación, ataque, huida

### 📱 Controles Multi-plataforma
- Joystick táctil para móvil
- Botones de apuntar y disparar
- Teclado para PC
- Compatible con web

## 🚀 Cómo usar

1. Abre Godot 4.3+
2. Importa esta carpeta como proyecto
3. Abre `MainMenu.tscn` como escena principal
4. Presiona F5 para jugar

## 🌐 Exportar a Web

```bash
1. En Godot: Project > Export
2. Agregar exportador HTML5
3. Configurar opciones
4. Exportar
5. Subir a tu hosting web
```

## 🎮 Controles

- **Mover**: A/D o Joystick
- **Disparar**: Espacio o botón "Disparar"
- **Apuntar**: Flechas arriba/abajo o botón "Apuntar"
- **Móvil**: Toque y arrastra el joystick

## 📊 Estructura de Carpetas

```
zombie-house-clearer/
├── scripts/
│   ├── Player.gd
│   ├── Ally.gd
│   ├── AllyManager.gd
│   ├── Zombie.gd
│   ├── ZombieProjectile.gd
│   ├── Bullet.gd
│   ├── Civilian.gd
│   ├── Level1.gd
│   ├── MainMenu.gd
│   ├── Shop.gd
│   ├── GameData.gd
│   ├── VirtualJoystick.gd
│   └── WeaponSystem.gd
├── scenes/
│   ├── MainMenu.tscn
│   ├── Shop.tscn
│   ├── Level1.tscn
│   ├── Level2.tscn
│   ├── Player.tscn
│   ├── Ally.tscn
│   ├── Zombie.tscn
│   ├── ZombieProjectile.tscn
│   ├── Bullet.tscn
│   ├── Civilian.tscn
│   └── VirtualJoystick.tscn
├── project.godot
├── icon.svg
└── README.md
```

## 🤖 Comportamiento de Aliados

### Médico (Medic)
- Te cura cuando estás herido
- Se mantiene cerca tuyo
- Personalidad: Brave o Cautious
- Dispara ocasionalmente a zombies

### Francotirador (Sniper)
- Se posiciona a distancia
- Dispara con precisión
- Personalidad: Cautious
- Evita estar en primera línea

### Tanque (Tank)
- Carga contra los zombies
- Personalidad: Brave
- Máxima salud
- Protege al equipo

## 💬 Diálogos Dinámicos

Cada personalidad tiene diálogos únicos:
- **Brave**: Agresivo, motivador, confiado
- **Cautious**: Estratégico, analítico, prudente
- **Coward**: Asustado, dudoso, puede abandonar

## 🏆 Sistema de Puntuación

- Rescatar civil: +100 puntos y +50 monedas
- Matar zombie: +puntos por tipo
- Nivel completo: +200 monedas
- Comprar aliados: consume monedas

## 🎯 Próximas mejoras

- [ ] Más niveles y dificultades
- [ ] Sprites personalizados
- [ ] Efectos de sonido
- [ ] Música de fondo
- [ ] Efectos visuales de partículas
- [ ] Sistema de logros
- [ ] Tabla de puntuaciones

## 📝 Licencia

Projecto de código abierto. Úsalo y modifícalo como quieras.

## 👨‍💻 Autor

Desarrollado con ❤️ en Godot 4
