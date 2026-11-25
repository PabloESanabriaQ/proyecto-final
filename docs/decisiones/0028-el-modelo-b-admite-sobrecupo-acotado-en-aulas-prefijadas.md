# 0028 — El modelo B admite sobrecupo acotado en aulas prefijadas

**Estado:** Propuesta — 2026-11-24; pendiente de revisión con los integrantes del equipo.

**Propone modificar:** [0015](0015-una-comision-puede-venir-prefijada-a-dia-horario-y-aula.md),
solo la validación de capacidad del aula prefijada en B. Mantiene la relajación de R7 de
[0010](0010-el-proyecto-b-relaja-una-lista-cerrada-de-duras-con-holguras-y-optimiza-en-dos-niveles.md).

> No está aceptada ni implementada. Hasta que el equipo la acepte, 0015 conserva su regla
> vigente. El título expresa el comportamiento propuesto, no una aprobación del equipo.

## Contexto

Al revisar el contrato de AUL-41 (borrador 0027), apareció una tensión entre dos reglas:
0015 exige rechazar un aula prefijada con capacidad insuficiente, mientras 0010 permite a B
relajar R7 hasta un tope. La fijación determina qué aula usar; falta acordar si además hace
irrelajable su capacidad. Esta propuesta se redacta por pedido de Nico para discutirla con
el equipo, sin dar por tomada la decisión.

Alternativas para la revisión:

| Opción | Ventaja | Costo |
|---|---|---|
| **Recomendada: permitir sobrecupo acotado en B** | Conserva el aula fijada y permite que B ofrezca una alternativa con su infracción visible | La validación de capacidad debe conocer el modelo y el tope de la corrida |
| **Alternativa más viable: rechazar en A y B** | Mantiene 0015 tal como está y permite validar el prefijado de igual manera en ambos modelos | B no puede proponer sobrecupo en esa aula aunque el tope lo permita; el planificador debe corregir o quitar la fijación |

La recomendación favorece la finalidad del Proyecto B: ofrecer horarios con violaciones
acotadas y explícitas cuando no se pueden cumplir las condiciones ideales. La alternativa
estricta sigue siendo viable si el equipo entiende que fijar un aula implica exigir también
su capacidad sin excepciones. Ninguna opción se presenta como aprobada o descartada.

## Decisión propuesta

1. El aula prefijada sigue siendo obligatoria en A y B: el solver no puede cambiarla para
   resolver un problema de capacidad.
2. En A, la capacidad insuficiente del aula prefijada continúa siendo un error de validación
   de entrada, según 0015.
3. En B, esa insuficiencia puede admitirse dentro del tope configurado de R7. La solución
   reporta el sobrecupo conforme a la unidad de infracción y al formato que se acuerden en
   AUL-49 y AUL-50. Si supera el tope, no hay una solución admisible con esa fijación.
4. La comprobación de capacidad depende de la configuración de la corrida; no se rechaza
   universalmente al deserializar la instancia compartida por A y B. La separación concreta
   entre carga y validación previa se documentará en 0027 si se acepta esta propuesta.
5. Se mantienen los demás controles de 0015. Esta propuesta no extiende la relajación a tipos
   de aula prefijados no declarados, no-disponibilidades docentes ni bloqueos de aula.
6. No se fija un tope numérico nuevo ni una fórmula de penalización: corresponden a AUL-51
   y a las definiciones del Proyecto B.

Ejemplo ilustrativo, sin valor normativo: una comisión de 60 alumnos en un aula fijada de
50 lugares tiene un exceso de 10 alumnos. A rechaza la entrada por capacidad. B puede
conservar esa aula si el tope acordado admite ese exceso, y lo hace visible en la solución.
Los números solo sirven para explicar la comparación; no son valores por defecto.

## Consecuencias

**A favor:** el prefijado conserva su sentido de fijar una variable; B mantiene su capacidad
de ofrecer alternativas y explica el costo de conservar el aula.

**En contra:** A y B pueden responder de manera distinta ante los mismos datos de entrada.
La comparación de corridas debe distinguir el error de validación de A del resultado de B.
El sobrecupo requiere revisión del planificador; producir una alternativa no la publica ni
la acepta automáticamente.

**Riesgo abierto:** que la institución considere la capacidad del aula un límite que nunca
puede excederse cuando el aula está fijada. **La señal:** que el equipo o la institución exija
esa interpretación. En tal caso se elige la alternativa estricta antes de implementar.

Para aceptar esta propuesta, el equipo debe acordar la excepción a 0015 y su efecto sobre
el contrato 0027 y los casos de prueba. Hasta entonces, ambas opciones quedan para revisión.
