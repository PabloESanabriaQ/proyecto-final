# 0011 — Los turnos arrancan con rangos predefinidos (08–13, 13–18, 18–22) y son configurables

**Estado:** Aceptada — 2026-09-16

## Contexto

La blanda B3 (continuidad de turno) habla de mañana, tarde y noche, pero ningún documento definía
los rangos. Los rangos reales de la institución se definirán más adelante. Sin un valor inicial
no se puede escribir ni probar B3.

Alternativas evaluadas:

- **Esperar los rangos reales** — se descarta porque bloquea el Proyecto B por un dato que no
  cambia el modelo, solo tres números.
- **Turnos fijos en el código** — se descarta porque los rangos reales van a reemplazar a los
  provisorios y no debería ser un cambio de código.
- **Rangos predefinidos y configurables** — la elegida.

## Decisión

Los turnos forman parte de la configuración del período, con estos valores por defecto:

| Turno | Desde | Hasta |
|---|---|---|
| Mañana | 08:00 | 13:00 |
| Tarde | 13:00 | 18:00 |
| Noche | 18:00 | 22:00 |

Procedencia: valores provisorios fijados por el equipo el 2026-09-16, a reemplazar por los rangos
reales de la institución cuando se definan. Un dictado pertenece al turno en el que empieza.

## Consecuencias

**A favor:** B3 se puede implementar y probar ya; cambiar los rangos no toca el código.

**En contra:** un dictado que cruza el límite (por ejemplo, 12:00–14:00) queda en el turno de
inicio, lo que puede no coincidir con el criterio de la institución.

**Riesgo abierto:** que los rangos reales no sean tres, o no sean iguales para todas las carreras.
**La señal:** que al definirlos aparezca un cuarto turno o un rango por carrera. Ahí se modifica
esta decisión.
