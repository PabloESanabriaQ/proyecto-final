# Modelo formal del Proyecto A — grilla y restricciones R1–R11

> Público: quien implementa el modelo (AUL-45 y la Fase 3), quien escribe el validador (AUL-47),
> el Proyecto B, que relaja parte de estas restricciones, y el informe final.
> Escrito el 2026-11-27 (AUL-40).

## 0. Propósito y cómo se lee

Este documento es la **definición formal única** del problema que resuelve el Proyecto A:
conjuntos, parámetros, variables y cada restricción como fórmula, con su lectura en castellano y
la decisión de la que sale. No decide nada nuevo:

- Si una fórmula de acá contradice una decisión de `docs/decisiones/`, manda la decisión y se
  corrige este texto.
- Lo que no está decidido figura en §9 como punto abierto y no se resuelve acá.

**De dónde sale cada regla.** R1–R11 son las del estado del arte (`aulero_estado_del_arte.pdf`,
§2.3, material histórico) con lo que las precisan las decisiones 0001, 0004–0009, 0011, 0015,
0023 y 0032. El objetivo y los estados del resultado salen de 0030 y 0031. La exclusividad de
aula no tiene número R en el estado del arte; acá se llama **EA** (HU-2.2).

**Nombres.** Los conjuntos y parámetros llevan al lado el campo del JSON de instancia del que
salen. Esos campos son los de la propuesta de esquema de la decisión 0027 (PR #10, AUL-41), que
todavía no está aceptada: si el esquema publicado cambia un nombre, se cambia acá en el mismo PR.

**Notación.**

- $[a, b)$ es un rango semiabierto: incluye $a$ y excluye $b$.
- Las fórmulas son de programación lineal entera sobre variables binarias, para que se lean sin
  conocer CP-SAT. Cómo se traducen a CP-SAT está en §4.2, como guía y no como obligación.

## 1. Grilla temporal

Decisiones 0004 (valores por defecto) y 0027 §3 (horarios en `HH:MM` y alineación).

| Símbolo | Qué es | Campo |
|---|---|---|
| $D$ | días habilitados del período, en orden de la semana | `periodo.dias` |
| $h_0, h_1$ | inicio y fin de la jornada, en minutos desde las 00:00 | `periodo.jornada.desde`, `.hasta` |
| $\beta$ | minutos por bloque | `periodo.bloque_minutos` |
| $n$ | bloques por día: $n = (h_1 - h_0)/\beta$, entero por validación de entrada | — |
| $T$ | bloques del día: $T = \{0, 1, \dots, n-1\}$ | — |

Con los valores por defecto (lunes a sábado, 08:00–22:00, $\beta = 30$) quedan $|D| = 6$,
$n = 28$ y 168 bloques por semana.

**El bloque de una hora.** Una hora $h$ alineada con la grilla está en el bloque
$\mathrm{blq}(h) = (h - h_0)/\beta$. El bloque $\tau$ cubre los minutos
$[h_0 + \tau\beta,\; h_0 + (\tau+1)\beta)$. Un rango de horas $[a, b)$ ocupa los bloques
$\{\mathrm{blq}(a), \dots, \mathrm{blq}(b) - 1\}$. Que toda hora y toda duración de la entrada
estén alineadas lo verifica la carga de la instancia (0027 §7), no el modelo.

**Inicios admisibles.** Un dictado de $d$ bloques que empieza en el bloque $t$ ocupa
$\{t, \dots, t+d-1\}$ y tiene que terminar dentro de la jornada; puede terminar justo al cierre:

```math
S(d) = \{\, t \in T : t + d \le n \,\}
```

Ejemplo (caso borde de la Fase 2): una clase de 3 h ($d = 6$) con jornada 08:00–22:00 tiene como
último inicio $t = 22$, las 19:00.

**Turnos** (0011). Son una partición de la jornada en rangos con nombre, y un dictado pertenece
al turno en el que empieza. El Proyecto A no los usa: solo intervienen en la blanda B3 del
Proyecto B (0010).

## 2. Conjuntos

| Símbolo | Qué es | Campo |
|---|---|---|
| $C$ | comisiones | `comisiones` |
| $K_c$ | dictados de la comisión $c$: $K_c = \{1, \dots, k_c\}$ | `dictados_por_semana` |
| $J$ | todos los dictados: $J = \{(c, k) : c \in C,\ k \in K_c\}$ | — |
| $P$ | docentes | `docentes` |
| $P_c \subseteq P$ | docentes de la comisión $c$, al menos uno (0007) | `comisiones[].docentes` |
| $C_p \subseteq C$ | comisiones del docente $p$: $C_p = \{c : p \in P_c\}$ | — |
| $Y$ | tipos de aula, catálogo abierto (R8) | `tipos_aula` |
| $R$ | aulas | `aulas` |
| $M$ | materias | `materias` |
| $m(c)$ | materia de la comisión $c$ | `comisiones[].materia` |
| $\mathit{Prac} \subseteq C$ | comisiones de práctica | `actividad = "practica"` |
| $\theta(c)$ | teoría asociada a la práctica $c$, de la misma materia (R4) | `comisiones[].teoria` |
| $G$ | grupos de conflicto: ternas (carrera, año, cuatrimestre) que aparecen en los planes (0006) | `materias[].planes` |
| $M_g \subseteq M$ | materias del grupo $g$ que tienen al menos una comisión en la instancia (0032, punto 4) | — |
| $Q_m$ | combinaciones cursables de la materia $m$, cada una un conjunto de comisiones (0032, punto 3) | — |

**Combinaciones cursables** (0006 y 0032). Para una materia $m$:

```math
\begin{aligned}
Q_m = \;& \{\, \{t, p\} : p \in \mathit{Prac},\ m(p) = m,\ t = \theta(p) \,\} \\
\cup\;& \{\, \{t\} : t \text{ teoría de } m \text{ sin ninguna práctica } p \text{ con } \theta(p) = t \,\} \\
\cup\;& \{\, \{c\} : c \text{ teórico-práctica de } m \,\}
\end{aligned}
```

Una materia del grupo con al menos una comisión tiene al menos una combinación: toda práctica
tiene teoría, y toda teoría o teórico-práctica forma una combinación por sí misma o con alguna de
sus prácticas.

## 3. Parámetros

| Símbolo | Qué es | Campo | Decisión |
|---|---|---|---|
| $d_c$ | duración de cada dictado de $c$, en bloques: $d_c = \texttt{duracion\_minutos}/\beta$ | `duracion_minutos` | 0004, 0007 |
| $k_c$ | dictados por semana de $c$, 1 por defecto | `dictados_por_semana` | 0007 |
| $a_c$ | alumnos de $c$, una sola cifra | `alumnos` | 0005 |
| $Y_c \subseteq Y$ | tipos admitidos por $c$: el requerido más los alternativos | `tipo_aula`, `tipos_aula_alternativos` | 0009 |
| $\mathit{cap}_r$ | capacidad del aula $r$ | `aulas[].capacidad` | R7 |
| $y_r \in Y$ | tipo del aula $r$ | `aulas[].tipo` | R8 |
| $U_p \subseteq D \times T$ | bloques en que el docente $p$ no está disponible | `docentes[].no_disponible` | R6 |
| $B_r \subseteq D \times T$ | bloques del aula $r$ ocupados por actividades externas | `aulas[].bloqueos` | R11 |
| $\hat\delta_{ck},\ \hat t_{ck},\ \hat r_{ck}$ | día, inicio y aula prefijados del dictado $(c,k)$; cada uno puede faltar | `comisiones[].prefijados` | 0015 |

Para abreviar se usan $S_c = S(d_c)$ (inicios admisibles de $c$) y el conjunto de inicios de $c$
que cubren el bloque $\tau$:

```math
S_c(\tau) = \{\, t \in S_c : t \le \tau < t + d_c \,\}
```

$U_p$ y $B_r$ salen de convertir cada rango `{dia, desde, hasta}` a bloques según §1.

**Lo que no es parámetro del modelo.** La cantidad de semanas, la fecha de inicio y las
excepciones de aula por semana (0008) los usa la API después de la corrida. Las preferencias
horarias de los docentes son del Proyecto B (0010). La carrera de una comisión no existe para el
solver: solo entra a través de los grupos $G$ (0023, punto 4).

## 4. Variables de decisión

### 4.1 Formulación

Una variable binaria por dictado, día, inicio y aula:

```math
x_{c,k,\delta,t,r} \in \{0, 1\} \qquad (c,k) \in J,\ \delta \in D,\ t \in S_c,\ r \in R
```

$x_{c,k,\delta,t,r} = 1$ si el dictado $k$ de la comisión $c$ se dicta el día $\delta$, empieza
en el bloque $t$ y usa el aula $r$. Que $t$ solo recorra $S_c$ ya expresa la grilla (§5.1).

Una variable binaria por grupo y combinación cursable, para R1–R3 (§5.4):

```math
s_{g,q} \in \{0, 1\} \qquad g \in G,\ q \in Q_m,\ m \in M_g
```

$s_{g,q} = 1$ si $q$ es la combinación elegida de su materia en el grupo $g$. No es parte de la
solución que se entrega: es un testigo de que la cohorte puede cursar.

**Expresiones derivadas** (no son variables nuevas):

```math
\begin{aligned}
o_{c,\delta,\tau} &= \sum_{k \in K_c} \sum_{t \in S_c(\tau)} \sum_{r \in R} x_{c,k,\delta,t,r}
  && \text{la comisión } c \text{ ocupa el bloque } \tau \text{ del día } \delta \\
w_{r,\delta,\tau} &= \sum_{(c,k) \in J} \sum_{t \in S_c(\tau)} x_{c,k,\delta,t,r}
  && \text{cuántos dictados ocupan el aula } r \text{ en } (\delta,\tau) \\
z_{c,k,\delta} &= \sum_{t \in S_c} \sum_{r \in R} x_{c,k,\delta,t,r}
  && \text{el dictado } (c,k) \text{ cae el día } \delta
\end{aligned}
```

**De la variable a la solución.** Cada dictado con $x_{c,k,\delta,t,r} = 1$ se informa como una
asignación (comisión $c$, dictado $k$, día $\delta$, aula $r$) con `desde` $= h_0 + t\beta$ y
`hasta` $= h_0 + (t + d_c)\beta$, en `HH:MM` (0027 §8).

### 4.2 Traducción a CP-SAT (guía para AUL-45)

La formulación de §4.1 tiene $|J| \cdot |D| \cdot |S_c| \cdot |R|$ variables: sirve para definir,
no para resolver a escala. La forma habitual en CP-SAT, que respeta las mismas restricciones, es:

- **Tiempo absoluto de la semana.** Para cada dictado, un inicio $u_{ck} = \delta \cdot n + t$
  con dominio $\{\delta n + t : \delta \in D, t \in S_c\}$ y un intervalo
  $[u_{ck}, u_{ck} + d_c)$. Como $t + d_c \le n$, ningún intervalo cruza de un día al siguiente,
  y el día es $\lfloor u_{ck}/n \rfloor$.
- **Aula.** Un literal $\ell_{ck,r}$ por aula admisible ($r \in R_c$, ver §5.8–5.9) con
  `ExactlyOne`, y un intervalo opcional por (dictado, aula) presente si $\ell_{ck,r}$.
- **R5, R6, R4 y EA con R11** como `NoOverlap` sobre los intervalos de cada docente (con los
  bloques de $U_p$ como intervalos fijos), de cada par práctica–teoría y de cada aula (con los
  bloques de $B_r$ como intervalos fijos).
- **Días distintos** como `AllDifferent` de los días de los dictados de cada comisión.
- **R1–R3** con los literales $s_{g,q}$ y, para cada par de comisiones de combinaciones de
  materias distintas del grupo, la no superposición de sus intervalos exigida solo si las dos
  combinaciones están elegidas.

Cuál de estas formas usar, y cómo, lo decide AUL-45. Lo que no puede cambiar es el conjunto de
horarios aceptados: tiene que ser exactamente el de §5.

## 5. Restricciones

Cada restricción tiene la misma ficha:

- **Fórmula** y **lectura** en castellano.
- **Origen:** la regla del estado del arte y la decisión que la precisa.
- **Dónde se implementa:** la historia y la fase.
- **En B:** si el Proyecto B la mantiene dura o la relaja (0010). La lista de relajables de 0010
  es cerrada: lo que no figura en ella no se relaja.

El **rótulo** (G, AS, DD, R1…, EA, PF) es el nombre corto con que el validador y el diagnóstico
nombran la restricción. La forma de esos reportes la fija AUL-50.

### 5.1 G — Grilla

```math
x_{c,k,\delta,t,r} \text{ solo existe para } \delta \in D,\ t \in S_c
```

**Lectura:** todo dictado empieza en un bloque de la grilla de un día habilitado y termina, a más
tardar, al cierre de la jornada.
**Origen:** 0004; 0027 §3 (rangos semiabiertos). **Dónde:** HU-2.2, Fase 2 (AUL-45).
**En B:** no se relaja (0010).

### 5.2 AS — Asignación completa

```math
\sum_{\delta \in D} \sum_{t \in S_c} \sum_{r \in R} x_{c,k,\delta,t,r} = 1
\qquad \forall (c,k) \in J
```

**Lectura:** cada dictado de cada comisión recibe exactamente un día, un inicio y un aula. Las
comisiones son dato, no se crean ni se descartan (R9).
**Origen:** R9; 0007 (cada dictado es una asignación propia). **Dónde:** HU-2.2, Fase 2.
**En B:** no se relaja.

### 5.3 DD — Dictados en días distintos

```math
\sum_{k \in K_c} z_{c,k,\delta} \le 1 \qquad \forall c \in C,\ \delta \in D
```

**Lectura:** dos dictados de una misma comisión no caen el mismo día. Pueden caer en aulas
distintas.
**Origen:** 0007. **Dónde:** HU-3.4, Fase 3. En la Fase 2 todas las comisiones del caso tienen un
dictado (el plan aplica 0007 "parcial").
**En B:** no se relaja (0007, 0010).

**Consecuencia de DD con R6.** Si los docentes de $c$ tienen menos de $k_c$ días con algún inicio
libre, la instancia no tiene solución. Que $k_c \le |D|$ lo rechaza la carga (0027 §5). Si el
caso con días del docente insuficientes se rechaza como entrada o da `INFACTIBLE` es el punto
abierto 0029 (§9). La fórmula es la misma en los dos casos.

### 5.4 R1–R3 — Conflicto curricular, lectura existencial global

Elegir una combinación por materia del grupo:

```math
\sum_{q \in Q_m} s_{g,q} = 1 \qquad \forall g \in G,\ m \in M_g
```

Dos combinaciones elegidas de materias distintas del grupo no se pisan:

```math
s_{g,q} + s_{g,q'} + o_{c,\delta,\tau} + o_{c',\delta,\tau} \le 3
\qquad
\begin{aligned}
&\forall g \in G,\ m \ne m' \in M_g,\ q \in Q_m,\ q' \in Q_{m'}, \\
&\forall c \in q,\ c' \in q',\ \delta \in D,\ \tau \in T
\end{aligned}
```

**Lectura:**

- En cada carrera, año y cuatrimestre tiene que haber una cursada completa posible: una
  combinación (teoría y una de sus prácticas, o la comisión sola) por cada materia, sin que dos
  de ellas coincidan en ningún bloque. La desigualdad solo muerde cuando las dos combinaciones
  están elegidas y las dos comisiones ocupan el mismo bloque.
- **R2** es la ausencia de esta restricción entre grupos distintos: materias de años distintos
  del mismo cuatrimestre pueden superponerse.
- **R3** es la existencial: las comisiones que no forman parte de la combinación elegida pueden
  superponerse con cualquier cosa.
- Una materia compartida pertenece a cada uno de sus grupos y en cada uno puede tener elegida
  una combinación distinta.

**Origen:** R1–R3; 0001 (modelo curricular), 0006 (grupo de conflicto), 0023 (todas las
carreras), 0032 (elección global, qué es una combinación, materias sin comisiones).
**Dónde:** HU-3.1, HU-3.3 y HU-3.5, Fase 3.
**En B:** relajable, con una holgura por par de combinaciones elegidas en conflicto (0010).

### 5.5 R4 — Práctica y su teoría

```math
o_{p,\delta,\tau} + o_{\theta(p),\delta,\tau} \le 1
\qquad \forall p \in \mathit{Prac},\ \delta \in D,\ \tau \in T
```

**Lectura:** una práctica no coincide en ningún bloque con su propia teoría. Con cualquier otra
comisión de su materia (otras prácticas, otras teorías) puede coincidir. A diferencia de R1–R3, no
depende de qué combinación se elija: vale para toda práctica.
**Origen:** R4; 0006. **Dónde:** HU-3.2, Fase 3.
**En B:** no se relaja (0010).

### 5.6 R5 — Docente sin superposición

```math
\sum_{c \in C_p} o_{c,\delta,\tau} \le 1 \qquad \forall p \in P,\ \delta \in D,\ \tau \in T
```

**Lectura:** un docente no está en dos dictados a la vez, sean de la misma materia o de materias
distintas. Si una comisión tiene varios docentes, la restricción vale para cada uno.
**Origen:** R5; 0007 (varios docentes). **Dónde:** HU-2.2, Fase 2 (un docente por comisión);
HU-3.6, Fase 3 (varios).
**En B:** no se relaja.

### 5.7 R6 — No-disponibilidad docente

```math
o_{c,\delta,\tau} = 0 \qquad \forall p \in P,\ c \in C_p,\ (\delta,\tau) \in U_p
```

**Lectura:** ningún dictado de una comisión ocupa un bloque en que alguno de sus docentes no está
disponible. Es distinta de las preferencias horarias, que solo usa B.
**Origen:** R6; 0007 (cada docente), 0010 (dura en A y en B). **Dónde:** HU-2.2, Fase 2; HU-3.6,
Fase 3.
**En B:** no se relaja.

### 5.8 R7 — Capacidad

```math
x_{c,k,\delta,t,r} = 0 \qquad \forall (c,k) \in J,\ \delta,\ t,\ r \in R : \mathit{cap}_r < a_c
```

**Lectura:** una comisión solo se asigna a un aula donde entran todos sus alumnos. Si no hay
ninguna, la instancia es `INFACTIBLE` en A.
**Origen:** R7; 0005 (alumnos como dato, el solver elige el aula). **Dónde:** HU-2.2, Fase 2.
**En B:** relajable hasta un tope de sobrecupo, con una holgura por comisión (0010; tope en
AUL-51).

### 5.9 R8 — Tipo de aula, exacto o alternativo

```math
x_{c,k,\delta,t,r} = 0 \qquad \forall (c,k) \in J,\ \delta,\ t,\ r \in R : y_r \notin Y_c
```

**Lectura:** una comisión solo se asigna a un aula del tipo que requiere o de uno de los tipos
alternativos que declara. En A todos los tipos declarados valen lo mismo.
**Origen:** R8 (catálogo abierto); 0009; 0027 §6 (lista `tipos_aula_alternativos`). Las
excepciones por semana que menciona R8 quedan fuera del modelo (0008, §6). **Dónde:** HU-2.2,
Fase 2.
**En B:** relajable, con una holgura por comisión asignada a un tipo no declarado (0010).

R7 y R8 juntas definen las **aulas admisibles** de cada comisión:

```math
R_c = \{\, r \in R : y_r \in Y_c,\ \mathit{cap}_r \ge a_c \,\}
```

En A conviene crear $x_{c,k,\delta,t,r}$ solo para $r \in R_c$; es la misma restricción.

### 5.10 R11 — Bloqueos de aula

```math
w_{r,\delta,\tau} = 0 \qquad \forall r \in R,\ (\delta,\tau) \in B_r
```

**Lectura:** ningún dictado ocupa un bloque de un aula que usa una actividad externa al
problema.
**Origen:** R11. **Dónde:** HU-2.2, Fase 2.
**En B:** no se relaja.

### 5.11 EA — Exclusividad de aula

```math
w_{r,\delta,\tau} \le 1 \qquad \forall r \in R,\ \delta \in D,\ \tau \in T
```

**Lectura:** dos dictados, de la misma comisión o de comisiones distintas, no comparten aula en un
mismo bloque.
**Origen:** no tiene número en el estado del arte, que la da por supuesta. La pide HU-2.2 ("que
dos comisiones no compartan aula en el mismo bloque"). **Dónde:** HU-2.2, Fase 2.
**En B:** no se relaja (no está en la lista cerrada de 0010).

### 5.12 PF — Dictados prefijados

```math
\begin{aligned}
x_{c,k,\delta,t,r} &= 0 && \text{si } \hat\delta_{ck} \text{ está dado y } \delta \ne \hat\delta_{ck} \\
x_{c,k,\delta,t,r} &= 0 && \text{si } \hat t_{ck} \text{ está dado y } t \ne \hat t_{ck} \\
x_{c,k,\delta,t,r} &= 0 && \text{si } \hat r_{ck} \text{ está dado y } r \ne \hat r_{ck}
\end{aligned}
```

**Lectura:** lo que viene fijado de un dictado (día, inicio, aula, cualquier subconjunto) se
respeta, y el solver decide el resto con todas las demás restricciones. Lo que se puede comprobar
sin resolver lo rechaza la carga antes de llegar al solver: un prefijado fuera de grilla, en un
aula de tipo no declarado o sin capacidad, o sobre una no-disponibilidad o un bloqueo. Si los
prefijados hacen infactible el resto, el diagnóstico los nombra.
**Origen:** 0015; 0027 §5 y §7 (número de dictado 1 a $k_c$, validación previa).
**Dónde:** HU-3.9, Fase 3.
**En B:** no se relaja (0015). Sobre la capacidad del aula prefijada en B hay un punto abierto
(0028, §9).

## 6. Reglas que no son restricciones del modelo

| Regla | Qué pasa con ella | Decisión |
|---|---|---|
| **R2** | Es permisiva: dice dónde **no** hay restricción. Queda expresada en que §5.4 solo relaciona materias del mismo grupo. | 0006 |
| **R9** | Las comisiones son dato. En el modelo se ve en que no hay variables que creen, partan o junten comisiones, y en AS (§5.2). | — |
| **R10** | Correlatividades: no participan del modelo, solo de la carga de datos. | 0001 |
| **Excepciones de aula por semana** (segunda parte de R8) | Se resuelven después de la corrida, fuera del modelo, buscando aula libre en el mismo bloque. | 0008 |
| **Turnos y preferencias docentes** | Solo el Proyecto B (blandas B3 y preferencias). | 0010, 0011 |
| **Traslado entre edificios** | No existe hoy. Si las carreras usan más de un edificio, es una restricción nueva de la Fase 6. | 0023 |

## 7. Objetivo y resultado del Proyecto A

**Sin función objetivo.** El Proyecto A es un problema de factibilidad: encontrar $x$ (y los
testigos $s$) que cumplan §5.1 a §5.12, o probar que no existen (0030). Un horario que cumple todo
es tan bueno como cualquier otro. Que se vea mal (huecos, dispersión) es material para comparar A
con B, no un defecto de A.

**Estados del resultado** (0031). CP-SAT corre con un límite de reloj, por defecto 60 s:

| Estado de CP-SAT | Estado de la solución | Asignaciones |
|---|---|---|
| `OPTIMAL` o `FEASIBLE` | `FACTIBLE` | Todas, una por dictado (§4.1) |
| `INFEASIBLE` | `INFACTIBLE` | Ninguna; diagnóstico en la Fase 3 |
| `UNKNOWN` | `TIEMPO_AGOTADO` | Ninguna (A termina en el primer horario) |
| `MODEL_INVALID` | — | Error de programación: excepción |

Un límite menor o igual a cero se rechaza en la configuración.

**Reproducibilidad** (0030 y 0031). Misma instancia y misma configuración dan el mismo horario,
con `random_seed` = `semilla` (1 por defecto), `num_workers = 8` e `interleave_search = True`. La
garantía vale cuando la corrida termina antes del límite.

## 8. Lo que hereda el Proyecto B

El Proyecto B parte de este mismo modelo y relaja solo la lista cerrada de 0010:

| Restricción | En B |
|---|---|
| R1–R3 (§5.4) | Holgura por par de combinaciones elegidas en conflicto |
| R7 (§5.8) | Holgura por comisión con sobrecupo, hasta un tope (AUL-51) |
| R8 (§5.9) | Holgura por comisión en un tipo no declarado |
| G, AS, DD, R4, R5, R6, R11, EA, PF | Duras, igual que en A |

Una instancia factible en A tiene en B todas las holguras en cero (0010, punto 5). La
formalización de las holguras, los pesos y los dos niveles es del Proyecto B (AUL-49 a AUL-53) y
no va en este documento.

## 9. Puntos abiertos

- **Esquema de instancia (0027, PR #10).** Los nombres de campo de §1–§3 son los de la propuesta.
  Si cambian al aceptarla, se actualizan acá.
- **Días del docente insuficientes (0029).** La propuesta es `INFACTIBLE` con diagnóstico en lugar
  de rechazo de la entrada que pide 0007. No cambia ninguna fórmula: cambia en qué capa se
  detecta.
- **Aula prefijada sin capacidad en B (0028).** La propuesta es admitir sobrecupo dentro del tope
  en B y mantener el rechazo en A. No cambia §5 para A.
- **Grilla y turnos por carrera (Fase 6, 0004, 0011, 0023).** Si se decide, $D$, $T$ y $S_c$
  pasan a depender de la carrera, y §5.4 compara bloques de grillas distintas. Hoy son del
  período.
- **Materias anuales (Fase 6, 0023).** No hay forma de representarlas en un período cuatrimestral.
- **Optativas en R1 (Fase 3).** Falta confirmar si participan de §5.4 como cualquier materia de
  su grupo. La fórmula las incluye; si se decide que no, se excluyen de $M_g$.
- **Escala de R1–R3 y del validador (0032).** Crecen con el cuadrado de las combinaciones del
  grupo. La cota se mide en la Fase 3 y se decide en la 6.

## 10. Trazabilidad

Los casos borde son los de `plan-de-fases.md` y las decisiones citadas. Cada uno termina en un
test que lo nombra.

| Rótulo | Decisiones | Historia | Issue | Casos borde que la prueban |
|---|---|---|---|---|
| G | 0004 | HU-2.2 | AUL-45 | Clase de 3 h con última posición 19:00; validador: asignación fuera de grilla |
| AS | 0007, R9 | HU-2.2 | AUL-45 | Cero comisiones: solución vacía, factible |
| DD | 0007 | HU-3.4 | — | Dos dictados con docente disponible 2 días o 1 día |
| R1–R3 | 0001, 0006, 0023, 0032 | HU-3.1, 3.3, 3.5, 3.8 | — | Ejemplos (a) y (b); dos materias de una comisión; grupo de una materia; materia compartida; compatibles de a pares pero sin elección conjunta (0032) |
| R4 | 0006 | HU-3.2 | — | 1 teoría y 3 prácticas; 2 teorías con su práctica cada una |
| R5 | 0007 | HU-2.2, HU-3.6 | AUL-45 | Docente con dos comisiones que solo caben en el mismo bloque; validador: superposición de docente |
| R6 | 0007, 0010 | HU-2.2, HU-3.6 | AUL-45 | Docente sin no-disponibilidad; disponible un solo día |
| R7 | 0005 | HU-2.2 | AUL-45 | Comisión que solo entra en un aula; validador: sobrecupo |
| R8 | 0009 | HU-2.2 | AUL-45 | Sin aulas del tipo requerido: infactible; alternativo usado con el requerido lleno; validador: tipo no declarado |
| R11 | — | HU-2.2 | AUL-45 | Aula bloqueada la jornada entera; aula con un solo hueco justo |
| EA | — | HU-2.2 | AUL-45 | Dos comisiones que solo entran en la misma aula; validador: superposición de aula |
| PF | 0015 | HU-3.9 | — | Prefijado parcial (día, aula) y total; dos prefijados en la misma aula y bloque |
| Resultado | 0030, 0031 | HU-2.2, HU-2.4 | AUL-45, AUL-46 | Dos corridas idénticas; `INFACTIBLE` frente a `TIEMPO_AGOTADO`; límite ≤ 0 |

El validador (HU-2.3, AUL-47; HU-3.8) verifica las mismas fórmulas sobre una solución dada, sin
CP-SAT. Para R1–R3 tiene que encontrar una elección de combinaciones compatible: alcanza con
que exista una (0032).
