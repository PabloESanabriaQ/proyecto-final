# 0026 — El paquete `solver/` se divide por módulo, con un responsable cada uno

**Estado:** Propuesta — 2026-11-24; pendiente de revisión y acuerdo explícito del equipo.

El merge del PR de AUL-41 publica este borrador para continuar la revisión; no acepta
automáticamente el reparto ni las reglas propuestas aquí. Cuando el equipo acuerde la
decisión, su aceptación se registrará actualizando el estado de este archivo y del índice
de decisiones en el mismo cambio.

## Contexto

El plan de puesta al día (`docs/plan-de-puesta-al-dia.md`, regla 3) reparte `solver/` entre las
tres personas del Proyecto Final: el esquema y la línea de comandos para Nico (B1), el modelo
para Hugo (A), el validador y las instancias para Pablo (B2). Pide registrar la división exacta
antes de publicar el esquema (AUL-41), porque desde ahí los tres escriben en el mismo paquete a la
vez y en ramas apiladas.

El reparto corresponde al cambio de roles del 2026-11-24: Nico es B1 y Pablo es B2,
según [Quién hace qué del plan de puesta al día](../plan-de-puesta-al-dia.md#quién-hace-qué).
El cambio se integró en `chore/AUL-1-fase-0-base`, base del PR de AUL-41, mediante el
[PR #9](https://github.com/PabloESanabriaQ/proyecto-final/pull/9) de AUL-54.

Alternativas evaluadas:

- **Por restricción** (cada persona implementa unas R en el modelo y en el validador). Reparte
  parejo el trabajo de modelado, pero dispersa la responsabilidad del validador y favorece
  que se reutilice la lógica de cada restricción para comprobarla. Se descarta por ese
  acoplamiento; tener autores distintos no garantiza por sí solo la independencia (HU-2.3).
- **Sin dueños, todos en todo.** No hay que acordar nada, pero tres personas con ramas apiladas
  sobre los mismos archivos producen conflictos en cada merge, y nadie responde por el contrato.
  Se descarta.
- **Por módulo, con un responsable cada uno.** Es la que se elige: sigue las líneas que el plan ya
  trazó y permite separar la implementación del validador de los modelos. Pablo conserva
  tanto AUL-47 (validador de recursos) como AUL-53 (objetivo del primer nivel), según el plan
  y Jira. Por eso no se promete independencia de autoría: se propone independencia de
  cálculo y revisión por otra persona, con el riesgo residual indicado en Consecuencias.

## Decisión

| Módulo de `solver/` | Qué tiene | Responsable |
|---|---|---|
| `aulero_solver/instancia.py`, `solucion.py`, `configuracion.py` | Los modelos de datos del contrato ([[0027]]) | Nico |
| `aulero_solver/esquema.py`, `solver/esquema/` | La generación del JSON Schema y los esquemas versionados | Nico |
| `aulero_solver/cli.py` y la implementación de `solve` (ubicación pendiente, ver abajo) | La línea de comandos y el punto de entrada `solve` (AUL-44) | Nico |
| `aulero_solver/modelo/` | El modelo CP-SAT: grilla, variables y restricciones duras (AUL-45, AUL-46) | Hugo |
| `aulero_solver/relajacion/` | Holguras (AUL-52), Nico; función objetivo y niveles (AUL-53), Pablo | Nico y Pablo, cada uno en su parte |
| `aulero_solver/validador.py` | La implementación de `validar`, validador independiente (AUL-47) | Pablo |
| `aulero_solver/__init__.py` | Exposición de la interfaz pública; contenido y responsable por acordar | Pendiente de revisión de Pablo |
| `solver/instancias/` | Instancias de referencia: caso acotado y simuladas (AUL-36, AUL-43) | Pablo |
| `solver/tests/` | Cada test con el módulo que prueba, y del mismo responsable | El del módulo |

1. **El responsable decide** sobre su módulo. Quien necesita cambiar un módulo ajeno lo hace en su
   rama, lo dice en el PR y suma al responsable como revisor, además de la ronda de revisión del
   plan. Esto no reemplaza la aprobación de otra persona que pide la [[0014]].
2. **El contrato es de los tres.** Un cambio en `instancia.py`, `solucion.py` o
   `configuracion.py` que altere los documentos admitidos cambia la versión del esquema
   ([[0027]]) y se anuncia en el PR, como ya pedía `arquitectura.md` §3.1. Un cambio solo de
   descripción o formato del JSON Schema no cambia por sí mismo el contrato.
3. **El validador es independiente de ambos modelos.** `modelo/` y `relajacion/` no importan
   `validador.py`; el validador no importa esos módulos ni OR-Tools, tampoco a través de otros
   módulos. Comparte con ellos los modelos de datos y conversiones de unidades, pero no el
   cálculo que decide si una restricción se cumple o cuánto penaliza. Las holguras sí pueden
   apoyarse en el modelo de recursos de Hugo. Se verifica con contratos de `import-linter`, como la frontera de la
   [[0012]], cuando existan los módulos correspondientes.

   AUL-47 comprueba las restricciones de recursos sin CP-SAT. Cuando se extienda el validador
   para B, las magnitudes de infracción y los costos se recalculan desde la instancia, la
   configuración y las asignaciones, sin tomar las holguras o métricas reportadas como prueba
   de corrección ni reutilizar funciones de cálculo del modelo. Se comparan luego los valores
   recalculados con los reportados. Esa comprobación verifica la solución y su costo; la
   optimalidad requiere la evidencia del solver y no la demuestra el validador.

   Para AUL-53 y la extensión del validador, Nico prepara o comprueba de forma independiente
   los resultados esperados de casos pequeños calculables a mano, y revisa ambos cálculos,
   siguiendo la ronda de revisión del plan. Se incluyen casos con distintas magnitudes y
   pesos que permitan detectar errores de conteo y ponderación. No basta con comparar dos
   resultados derivados de la misma función. Esta extensión corresponde al Proyecto B y
   no se da por implementada ni incluida en AUL-47 de recursos.
4. **Rutas respecto de la arquitectura.** `modelo/` y `relajacion/` son la organización propuesta
   para los futuros archivos `modelo_a.py`, `modelo_b.py` y `restricciones/` del árbol de
   `arquitectura.md` §1. No hay implementación que migrar todavía. Al publicar AUL-41 se
   actualizará ese árbol y se enlazará esta decisión; hasta su aceptación sigue siendo propuesta.

## Definición pendiente — `__init__.py` (revisión de Pablo)

**Estado:** pendiente de acuerdo. El plan asigna `solve` a Nico (AUL-44), el paquete
instalable a Pablo (AUL-42) y el validador a Pablo (AUL-47), pero no asigna un responsable
a `__init__.py` ni fija su contenido. La tabla anterior separa esas responsabilidades
funcionales de la decisión aún abierta sobre este archivo.

**Propuesta común a ambas alternativas:** que `__init__.py` tenga un responsable único y
solo reexporte la interfaz pública, sin implementar `solve` ni `validar`.
La implementación de `solve` sigue a cargo de Nico y la de `validar`, de Pablo. Falta
acordar el módulo donde vivirá `solve` y cómo se expondrán ambas funciones respetando
la independencia de importaciones de la regla 3, incluso al inicializar el paquete.

Alternativas para la revisión de Pablo, sin preferencia ni asignación acordada:

| Opción | Ventaja | Costo |
|---|---|---|
| Pablo mantiene un `__init__.py` de reexportaciones | Alinea el mantenimiento con AUL-42 y deja un responsable único | Nico debe coordinar con Pablo los cambios en la exposición de `solve` |
| Nico mantiene un `__init__.py` de reexportaciones | Alinea la interfaz pública con su trabajo de contrato y `solve` | Pablo debe coordinar con Nico los cambios en la exposición de `validar` |

Pablo debe revisar ambas alternativas de responsable, el alcance de las reexportaciones y la
ubicación de `solve`; después se incorpora el acuerdo a la tabla y al árbol de arquitectura.
Esta sección registra una decisión a tomar: no asigna todavía el archivo ni presenta
ninguna de las alternativas como aceptada por Pablo.

## Consecuencias

**A favor:** cada rama apilada toca sobre todo archivos propios; el validador es independiente
en su implementación bajo la regla 3; queda claro a quién preguntar por cada parte.

**En contra:** el trabajo de modelado queda casi entero en Hugo, y el camino crítico pasa por él
(ya lo dice el plan). Salvo la regla 3, las fronteras entre módulos se sostienen con revisión,
no con herramientas.

Pablo participa en el objetivo y en el validador: aun con cálculos separados puede repetir
una interpretación incorrecta en ambos. Los casos revisados por Nico reducen ese riesgo,
pero no equivalen a tener autores distintos. Este mecanismo queda propuesto para revisión
del equipo; no se presenta como una observación de Hugo ya aceptada o resuelta por él.

**Señal de revisión del reparto:** un caso con resultado esperado independiente revela el
mismo error conceptual en el objetivo y el validador, o la revisión no puede justificar
sus resultados sin apoyarse en el modelo. En ese caso se revisará la responsabilidad de
la comprobación antes de cerrar el trabajo afectado.

**Riesgo abierto:** que la regla 3 de arriba se rompa en la práctica, porque el modelo y el
validador terminan necesitando el mismo cálculo (por ejemplo, convertir horas a bloques). **La
señal:** un PR que haga fallar el contrato de `import-linter` o que pida relajarlo. Ahí ese
cálculo de unidades sube a los modelos de datos, que son de los tres, y no se cruza la frontera.
La lógica de comprobación de las restricciones se mantiene independiente.
