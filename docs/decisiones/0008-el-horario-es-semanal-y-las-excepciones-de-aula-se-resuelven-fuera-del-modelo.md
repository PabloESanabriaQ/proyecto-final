# 0008 — El horario es semanal y repetitivo; las excepciones de aula por semana se resuelven fuera del modelo de optimización

**Estado:** Aceptada — 2026-09-16

## Contexto

El estado del arte (Definición Pendiente N.º 4) preguntaba si las excepciones puntuales de aula de
R8 mantienen día y horario —y entonces son una verificación de disponibilidad— o si pueden
requerir cambio de día u hora —y entonces son un subproblema de reasignación—. Además, la blanda
B2 ("aulas distintas a lo largo del cuatrimestre") sugería un horario que varía por semana,
mientras que el Excel hablaba de "aula final". Había que decir si el horario es una configuración
semanal que se repite o un calendario por semana.

Alternativas evaluadas:

- **Calendario completo por semana** — cada semana del cuatrimestre se optimiza aparte. Máxima
  fidelidad. Se descarta porque multiplica el problema por la cantidad de semanas para atender
  excepciones que son puntuales.
- **Excepciones dentro del modelo** — incluir las semanas con excepción como variables del
  solver. Se descarta porque obliga a correr la optimización completa por un cambio de aula de una
  semana.
- **Configuración semanal + excepciones fuera del modelo** — la elegida.

## Decisión

El horario que produce el solver es una **configuración semanal** que se repite durante todo el
período. Las **excepciones de aula** de una comisión para una semana concreta **mantienen día,
horario y duración**; solo piden un tipo de aula distinto para esa semana. Se resuelven **después
y fuera del modelo**, como una búsqueda de aula libre del tipo pedido en el mismo bloque horario
de esa semana, teniendo en cuenta los bloqueos externos y las demás excepciones. Si no hay aula
libre, el sistema lo informa como conflicto y no modifica el horario base.

La vista de una semana específica muestra la configuración base con las excepciones de esa semana
aplicadas.

## Consecuencias

**A favor:** el modelo de optimización no conoce las semanas; una excepción se resuelve en
milisegundos sin recorrer; B2 se simplifica a "misma aula en todos los dictados de la
configuración base".

**En contra:** una excepción que necesite cambiar el horario no está soportada; el sistema solo
puede decir "no hay aula". La cantidad de semanas y la fecha de inicio del período pasan a ser
datos de configuración necesarios.

**Riesgo abierto:** que las excepciones reales sean más de horario que de aula (feriados,
recuperatorios, semanas de parciales). **La señal:** que el planificador pida cambiar día u hora de
un dictado para una semana. Ahí se registra una decisión nueva para un subproblema de
reasignación acotado, sin tocar el horario base.
