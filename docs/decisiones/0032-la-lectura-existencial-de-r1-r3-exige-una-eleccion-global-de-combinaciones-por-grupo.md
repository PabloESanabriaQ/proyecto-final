# 0032 — La lectura existencial de R1–R3 exige una elección global de combinaciones por grupo

**Estado:** Aceptada — 2026-11-27
**Modifica:** 0006 — fija que la combinación cursable se elige una por materia y de forma
conjunta para todo el grupo, no par a par.

## Contexto

Al formalizar R1–R11 (AUL-40, `docs/modelo-formal.md`) la redacción de [[0006]], punto 2, admite
dos fórmulas distintas. Dice que para cada materia del grupo tiene que existir una combinación
cursable "que no se superponga en horario con al menos una combinación cursable de cada una de las
demás materias del grupo". Eso se puede leer de dos maneras:

- **Par a par.** Para cada par de materias del grupo existe un par de combinaciones compatibles,
  elegidas por separado para ese par. Con tres materias A, B y C puede pasar que A–B se resuelva
  con la combinación A1, A–C con A2 y B–C con B2 y C1, sin que exista ninguna cursada completa: un
  alumno que sigue el plan no puede cursar las tres. Es más barata de modelar y de verificar (no
  hay que elegir nada global), pero deja pasar justo lo que R1 quiere evitar. **Se descarta.**
- **Global.** Existe una elección de **una** combinación por materia del grupo tal que ninguna de
  las elegidas se pisa con otra. Es lo que dice la formulación del equipo citada en [[0006]]
  ("al menos una de las distintas combinaciones no tiene que pisarse con el resto de las materias
  de esa carrera de ese año y cuatrimestre") y lo que dice el primer caso derivado ("su única
  combinación no puede pisarse con ninguna combinación **elegida** de las demás"). Es también lo
  que pide HU-3.1: "que un alumno que sigue el plan pueda cursar todo". **Se elige.**
- **No-solapamiento total** entre todas las comisiones de materias del mismo grupo. Ya la descartó
  [[0006]] por volver infactibles instancias razonables; no se reabre.

La formalización también tiene que decir qué es una combinación en dos casos que [[0006]] no
nombra: una teoría sin ninguna práctica asociada dentro de una materia que sí tiene prácticas, y
una materia que está en un plan pero no tiene comisiones en la instancia.

## Decisión

1. **Elección global por grupo.** Para cada grupo de conflicto $g$ = (carrera, año, cuatrimestre)
   se elige exactamente una combinación cursable por cada materia del grupo, y dos combinaciones
   elegidas de materias distintas del grupo no se superponen en ningún bloque de ningún día.
   Procedencia: lectura de [[0006]], punto 2, y de HU-3.1, según el contexto.

2. **La elección es por grupo.** Una materia compartida por dos grupos ([[0006]], punto 1) puede
   tener elegida una combinación distinta en cada uno. Procedencia: deducción; cada grupo es una
   cohorte distinta de alumnos.

3. **Qué es una combinación cursable de una materia:**
   - una teoría junto con una de sus prácticas asociadas ([[0006]], R4);
   - una teoría sin ninguna práctica asociada, sola. Procedencia: criterio propio, por analogía
     con la teórico-práctica de [[0006]]: si la teoría no tiene práctica, cursarla es cursar solo
     la teoría;
   - una comisión teórico-práctica, sola ([[0006]]).

   Dos combinaciones se superponen si algún dictado de alguna comisión de una comparte un bloque
   del mismo día con algún dictado de alguna comisión de la otra.

4. **Una materia sin comisiones en la instancia no participa del grupo.** Procedencia: [[0005]]
   ("si no está en la entrada, no se planifica"); sin este punto, una materia del plan que no se
   dicta este período volvería infactible todo su grupo.

5. **Casos borde nombrados para la Fase 3 (HU-3.1 y HU-3.8):**
   - Tres materias de un grupo, compatibles de a pares pero sin ninguna elección conjunta:
     `INFACTIBLE`, y el validador reporta R1 sobre una solución así.
   - Materia con una teoría con práctica y otra teoría sin práctica: la teoría sola es una
     combinación válida.
   - Materia en un plan sin comisiones en la instancia: no restringe a su grupo.

## Consecuencias

**A favor:** la fórmula garantiza lo que R1 quiere decir: una cursada completa posible por
cohorte. Coincide con la holgura "por par de combinaciones en conflicto" de [[0010]]: bajo B se
relaja el choque entre dos combinaciones elegidas.

**En contra:** el modelo necesita una variable de elección por (grupo, materia, combinación) y una
restricción por cada par de combinaciones de materias distintas del grupo, en cada bloque: crece
con el cuadrado de las combinaciones. Y el validador, que no usa CP-SAT, tiene que buscar una
elección compatible: en general es un problema combinatorio (elegir un representante por materia
sin choques). En el caso acotado y en ISI se resuelve enumerando, porque las combinaciones por
materia son pocas; a escala de universidad puede no alcanzar.

**Riesgo abierto:** que la verificación del validador o el tamaño del modelo no escalen en la
Fase 6. **La señal:** la cota de combinaciones por materia que la Fase 3 mide (definición
pendiente de esa fase) supera lo que el validador enumera en un tiempo razonable. Ahí se decide
otra formulación o un validador con búsqueda propia, no se vuelve a la lectura par a par.
