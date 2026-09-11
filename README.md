Mod para The Binding of Isaac: Repentance que otorga una recompensa aleatoria cada vez que limpias una sala de boss, miniboss o una oleada de Boss Rush.

Disponible en Steam Workshop.

Qué hace:

    Otorga una recompensa aleatoria al despejar salas de tipo boss, miniboss y bossrush (en Boss Rush, una recompensa por oleada limpiada, no por cada boss            individual).

Dos tipos de recompensa posibles:


 -Vida extra: corazón rojo (solo cura un corazon, no añade contenedor), de alma o negro.

 -Mejora de stat permanente: daño, cadencia, velocidad, suerte, rango o velocidad de disparo.


Probabilidad extra de que aparezca una sala de ángel al entrar en una sala de boss, aplicada antes de que empiece el combate.

Las mejoras de stats persisten durante la partida y se guardan/cargan correctamente entre sesiones, reiniciándose al empezar una run nueva.

Compatible con coop local.

Sobre este proyecto
Este es mi primer mod hecho en Lua, lenguaje que no había usado antes de este proyecto. Lo elegí como excusa para aprender el lenguaje de una forma práctica, apoyándome en la API de modding de Isaac en lugar de hacer ejercicios sueltos.

El reto principal no fue tanto la sintaxis de Lua en sí, sino entender el sistema de callbacks del juego (MC_POST_NPC_DEATH, MC_EVALUATE_CACHE, MC_POST_GAME_STARTED, etc.) y cómo encajar la lógica del mod dentro de ese flujo sin romper el estado del juego.

El código no es perfecto ni especialmente idiomático en Lua, pero funciona de forma estable y quedó validado con varias partidas de prueba.

Estructura del repositorio
main.lua — lógica principal del mod.

metadata.xml — metadatos requeridos por el Workshop de Steam.
