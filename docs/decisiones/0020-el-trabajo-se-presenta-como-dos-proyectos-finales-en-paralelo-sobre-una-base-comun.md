# 0020 — El trabajo se presenta como dos Proyectos Finales (A: 1 persona, B: 2 personas) que avanzan en paralelo sobre una base común

**Estado:** Aceptada — 2026-09-16
**Modifica:** 0002 — A y B dejan de ser secuenciales ("A se construye primero; B se apoya en
A") y pasan a ser dos proyectos en paralelo con una base común construida entre ambos. La
división en A (duras) y B (relajación y calidad) y lo que comparten no cambian.

## Contexto

El Reglamento de Proyecto Final (Resol. 12/2023, §5.a) admite equipos de **hasta dos
personas**; más exige autorización de la Comisión de Carrera. Somos tres en Proyecto Final.
Además, cada proyecto tiene su propuesta con cronograma de no más de un año, su informe y su
defensa, y "el contenido del informe nunca podrá ser distinto a la propuesta aprobada" (§9.1).
Con la secuencialidad de [[0002]], las dos personas de B esperarían meses a que A terminara, y
un retraso de A haría incumplir el cronograma de B.

Alternativas evaluadas:

- **Un solo Proyecto Final con las tres personas** — un informe, una defensa. Se descarta porque
  exige una excepción de la Comisión que puede no otorgarse, y porque un solo informe con dos
  preguntas de investigación distintas es más difícil de evaluar y de defender.
- **A con dos personas y B con una** — A es el proyecto más grande en formalización. Se
  descarta por decisión del equipo: B tiene más trabajo de modelado (holguras, dos niveles,
  blandas, preferencias, corridas múltiples, experimentación comparativa) y la persona de A
  cuenta con la base común construida entre los tres.
- **A con una persona y B con dos, en paralelo sobre base común** — la elegida.

## Decisión

1. **Dos Proyectos Finales:** A (factibilidad bajo restricciones duras), una persona; B
   (relajación de restricciones y calidad de solución), dos personas. Propuestas en
   `docs/propuestas/`. La persona de PPS sigue con su reglamento y su porción ([[0012]]).
2. **Base común construida entre los tres en los primeros meses:** formato de instancia y
   solución, modelo de restricciones de recursos (Fase 2), validador de duras y CLI. Se declara
   como base común en ambos informes; ninguno la reclama como aporte propio exclusivo.
3. **Aporte propio de cada uno, por módulo:** A es dueño de la formulación curricular
   (Fase 3: R1–R4 existencial, pre-fijados, diagnóstico de infactibilidad) y del escalado
   (Fase 6). B es dueño del modelo con holguras y dos niveles, blandas y preferencias, validador
   extendido, corridas múltiples y experimentación comparativa (Fases 7 y 8).
4. **B no espera a A:** el marco de holguras se construye primero sobre las restricciones de
   recursos (R7, R8) y las blandas, que no dependen de la formulación curricular; la relajación
   de R1/R3 se integra cuando A la entrega (M6–M8 del cronograma de B). Si A se demora, B puede
   usar una formulación curricular simplificada propia y sustituirla al integrar.
5. **Cada informe cita el commit o *tag* de su entrega**; la autoría por archivo sale del
   historial de git. Los cambios de alcance después de aprobada una propuesta se registran acá
   **y** se comunican a la Comisión por el Profesor Guía (`docs/marco-reglamentario.md` §2).

## Consecuencias

**A favor:** cumple el reglamento sin excepción; dos informes con una pregunta clara cada uno;
B no depende del calendario de A para la mayor parte de su trabajo; la base común se construye
con tres personas, que es cuando más hace falta.

**En contra:** dos propuestas, dos cronogramas, dos defensas que coordinar; la frontera de
autoría hay que sostenerla con disciplina (módulos claros, PRs por persona); B puede terminar
con una formulación curricular provisoria si A se atrasa, y eso hay que explicarlo en el
informe.

**Riesgo abierto:** que la Comisión de Carrera objete que dos proyectos compartan repositorio y
base. **La señal:** una observación en la evaluación de las propuestas. En ese caso se separa
la base común en un paquete propio con su historial, sin cambiar el reparto. Otra señal: que la
persona de A quede sobrecargada con Fase 3 + Fase 6; ahí B absorbe el escenario multi-carrera
de la Fase 6 y se registra.
