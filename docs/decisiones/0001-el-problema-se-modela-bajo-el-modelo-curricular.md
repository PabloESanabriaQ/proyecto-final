# 0001 — El problema se modela bajo el modelo curricular, no por inscripción real

**Estado:** Aceptada — 2026-09-16

## Contexto

El documento de estado del arte (`docs/aulero_estado_del_arte.pdf`, Sección 3, Definición
Pendiente N.º 1) identificó esta como la decisión estructural principal: de ella dependen la
redacción exacta de R1, R3 y R10, el tratamiento de las optativas y la generalización a varias
carreras. El Excel de ejemplo (`docs/ejemplo_inputs_aulero_unvime-1.xlsx`, hoja LEEME) ya la asumía
—"Modelo académico: Curricular"— sin que estuviera registrada. Sin decidirla no se puede escribir
ninguna restricción curricular ni el modelo de datos.

Alternativas evaluadas:

- **Modelo de inscripción real** — los conflictos se derivan de qué alumnos están efectivamente
  inscriptos en qué comisiones, contemplando recursantes y correlatividades. Más fiel a la
  realidad. Se descarta porque es considerablemente más complejo de modelar y resolver, exige
  contar con la matrícula individual al momento de planificar (dato que no está en la entrada
  definida) y vuelve la entidad Alumno parte del problema. El motivo adicional del equipo, si lo
  hubo, no quedó registrado.
- **Modelo curricular** — los conflictos se derivan del año y cuatrimestre de cada materia en el
  plan de estudios, asumiendo una cohorte ideal. Es la elegida.

## Decisión

El problema se modela bajo el **modelo curricular**: dos comisiones están en conflicto por su
posición en el plan de estudios, no por la inscripción efectiva de alumnos. La entidad Alumno no
forma parte de la entrada del sistema. Las correlatividades (R10) no participan del modelo: su
rol queda limitado a la carga de datos de entrada, fuera del solver.

Cómo se define exactamente el grupo de conflicto y su lectura queda en [[0006]].

## Consecuencias

**A favor:** el modelo se puede escribir con los datos que hoy existen (plan de estudios,
comisiones); la instancia es pequeña y estable; no hace falta un padrón de alumnos.

**En contra:** el sistema no garantiza un horario libre de choques para alumnos recursantes ni
para quien cursa materias de años distintos. Las optativas se tratan como una materia más de su
año, sin distinguir quién las elige.

**Riesgo abierto:** que en la práctica la proporción de recursantes haga que los horarios
"curricularmente válidos" resulten inservibles. **La señal:** que la primera revisión del horario
con secretaría académica reporte choques reales entre materias de años distintos como problema
principal. En ese caso, la salida es tratar los cruces frecuentes como una restricción blanda del
Proyecto B ([[0010]]), no cambiar de modelo.
