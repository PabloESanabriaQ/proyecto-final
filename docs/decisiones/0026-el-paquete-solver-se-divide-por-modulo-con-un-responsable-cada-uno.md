# 0026 — El paquete `solver/` se divide por módulo, con un responsable cada uno

**Estado:** Propuesta — 2026-11-24 (borrador; se acepta al mergear el PR de AUL-41)

## Contexto

El plan de puesta al día (`docs/plan-de-puesta-al-dia.md`, regla 3) reparte `solver/` entre las
tres personas del Proyecto Final: el esquema y la línea de comandos para Nico (B1), el modelo
para Hugo (A), el validador y las instancias para Pablo (B2). Pide registrar la división exacta
antes de publicar el esquema (AUL-41), porque desde ahí los tres escriben en el mismo paquete a la
vez y en ramas apiladas.

Alternativas evaluadas:

- **Por restricción** (cada persona implementa unas R en el modelo y en el validador). Reparte
  parejo el trabajo de modelado, pero la misma persona escribiría la restricción y su
  verificación, y el validador dejaría de ser una comprobación independiente (HU-2.3). Se
  descarta.
- **Sin dueños, todos en todo.** No hay que acordar nada, pero tres personas con ramas apiladas
  sobre los mismos archivos producen conflictos en cada merge, y nadie responde por el contrato.
  Se descarta.
- **Por módulo, con un responsable cada uno.** Es la que se elige: sigue las líneas que el plan ya
  trazó, y deja el validador en manos de alguien que no escribió el modelo.

## Decisión

| Módulo de `solver/` | Qué tiene | Responsable |
|---|---|---|
| `aulero_solver/instancia.py`, `solucion.py`, `configuracion.py` | Los modelos de datos del contrato ([[0027]]) | Nico |
| `aulero_solver/esquema.py`, `solver/esquema/` | La generación del JSON Schema y los esquemas versionados | Nico |
| `aulero_solver/cli.py` y `solve` en `__init__.py` | La línea de comandos y el punto de entrada `solve` (AUL-44) | Nico |
| `aulero_solver/modelo/` | El modelo CP-SAT: grilla, variables y restricciones duras (AUL-45, AUL-46) | Hugo |
| `aulero_solver/relajacion/` | Holguras y niveles del Proyecto B (AUL-52, AUL-53) | Nico y Pablo |
| `aulero_solver/validador.py` y `validar` en `__init__.py` | El validador independiente (AUL-47) | Pablo |
| `solver/instancias/` | Instancias de referencia: caso acotado y simuladas (AUL-36, AUL-43) | Pablo |
| `solver/tests/` | Cada test con el módulo que prueba, y del mismo responsable | El del módulo |

1. **El responsable decide** sobre su módulo. Quien necesita cambiar un módulo ajeno lo hace en su
   rama, lo dice en el PR y suma al responsable como revisor, además de la ronda de revisión del
   plan. Esto no reemplaza la aprobación de otra persona que pide la [[0014]].
2. **El contrato es de los tres.** Un cambio en `instancia.py`, `solucion.py` o
   `configuracion.py` que altere el JSON Schema cambia la versión del esquema ([[0027]]) y se
   anuncia en el PR, como ya pedía `arquitectura.md` §3.1.
3. **`modelo/` no importa `validador.py`, ni al revés.** Los dos leen solo los modelos de datos.
   Así el validador comprueba la solución sin compartir código con quien la produjo. Se verifica
   con un contrato de `import-linter`, como la frontera de la [[0012]].

## Consecuencias

**A favor:** cada rama apilada toca sobre todo archivos propios; el validador es independiente
por construcción; queda claro a quién preguntar por cada parte.

**En contra:** el trabajo de modelado queda casi entero en Hugo, y el camino crítico pasa por él
(ya lo dice el plan). Salvo la regla 3, las fronteras entre módulos se sostienen con revisión,
no con herramientas.

**Riesgo abierto:** que la regla 3 de arriba se rompa en la práctica, porque el modelo y el
validador terminan necesitando el mismo cálculo (por ejemplo, convertir horas a bloques). **La
señal:** un PR que haga fallar el contrato de `import-linter` o que pida relajarlo. Ahí ese
cálculo sube a los modelos de datos, que son de los tres, y no se cruza la frontera.
