# Plan por fases

> Público: el equipo. Cada fase es una rebanada vertical que se puede demostrar sola y no está
> terminada hasta que `informe-de-gestion.md` y `arquitectura.md` quedaron al día
> (checklist de cierre en la skill `avanzar-por-fases`).
>
> **Convención de este documento.** Cada fase lleva: qué permite hacer que antes no se podía,
> equipo responsable, historias de usuario (para cargar en Jira), casos borde que la fase tiene
> que sostener (cada uno termina con un test que lo nombra), **definiciones pendientes que se
> toman al llegar a la fase** —antes de armar las historias definitivas, no durante el código— y
> criterio de cierre.
>
> Roles de las historias: **planificador** (secretaría académica / coordinación), **docente**,
> **estudiante**, **integrante CP-SAT** (equipo de optimización), **desarrollador** (cualquier
> integrante, para historias de infraestructura).
>
> Equipos: **PPS** (API, frontend, importación y BD) y **CP-SAT** (paquete `solver/`), según
> [decisión 0012](decisiones/0012-el-solver-es-un-paquete-python-independiente-de-la-api-y-la-base.md).
>
> **Última actualización:** 2026-09-16.

## Orden y paralelismo

```
Fase 0 ──► Fase 1 (PPS) ──────────────► Fase 4 ──► Fase 5 (PPS) ──► Fase 6 ──► Fase 7 ──► Fase 8
       └─► Fase 2 (CP-SAT) ─► Fase 3 ─┘                              (ambos)   (CP-SAT)  (ambos)
```

Las Fases 1 y 2–3 corren en paralelo, unidas por el contrato de instancia (historia 1.5). El
Proyecto A queda completo a nivel modelo al cerrar la Fase 3 y a nivel sistema al cerrar la Fase
4; la Fase 6 es su validación sobre datos reales. Las Fases 7 y 8 son el Proyecto B.

---

## Fase 0 — Base del proyecto y puerta de calidad

**Permite:** que ningún integrante pueda pushear código que no pasó lint, tests y la revisión del
agente en su máquina, y que nada llegue a `main` sin CI verde y una aprobación humana.

**Equipo:** ambos. **Decisiones que aplica:** 0013, 0014, 0016, 0017.

### Historias

- **HU-0.1** Como desarrollador, quiero que el repositorio tenga la estructura
  `backend/`, `frontend/`, `solver/`, `docs/` con los linters y formateadores de cada parte
  configurados, para que los cuatro trabajemos con las mismas reglas desde el primer commit.
  *Aceptación:* `ruff`, `mypy`, `eslint`, `prettier`, `tsc` corren sin errores sobre el esqueleto;
  cada parte tiene un test trivial que pasa.
- **HU-0.2** Como desarrollador, quiero un hook de pre-push versionado en el repo que corra lint,
  tests y la revisión del agente sobre lo que voy a subir, y que bloquee el push si hay
  hallazgos bloqueantes, para no subir código que no pasa la puerta (decisión 0016).
  *Aceptación:* un push con un bug plantado queda bloqueado con el hallazgo a la vista; uno
  correcto sale; la salida queda en `.review/` lista para pegar en el PR; el README explica cómo
  activar el hook en un clon nuevo.
- **HU-0.3** Como desarrollador, quiero que cada pull request corra lint, formato, tests y la
  regla de importación `solver/`↛`backend/` en GitHub Actions, y que `main` esté protegida
  exigiendo CI verde y la aprobación de otro integrante, para que haya revisión humana además
  de la del agente.
  *Aceptación:* un PR de prueba que rompe lint queda bloqueado; uno correcto se mergea solo con
  aprobación.
- **HU-0.4** Como desarrollador, quiero un `README` en la raíz con cómo levantar cada parte y la
  base de datos con un solo comando, para ponerme a trabajar sin preguntar.
- **HU-0.5** Como desarrollador, quiero que el remoto tenga el proyecto de Jira enlazado (clave
  en ramas y commits), para seguir el avance sin cargar nada a mano.

### Casos borde

Todos con test en `.githooks/tests/test_pre_push.sh` salvo el de import-linter, que está en
`solver/tests/test_frontera.py`.

- PR que toca solo `docs/`: CI pasa sin correr tests de código; el hook no invoca al agente.
- PR que toca solo `frontend/`: no corre los tests de Python (y viceversa).
- `solver/` importando `backend/`: CI falla (regla de import-linter).
- Push sin cambios respecto de `origin/main` (rama ya subida): el hook no invoca al agente.
- Push con el agente no disponible (ausente del PATH, caído, o colgado más de 10 min): el hook
  falla con un mensaje claro, no deja pasar en silencio.
- Push de una rama con varios commits: el agente revisa el diff acumulado, no commit por commit.
- Veredicto `BLOQUEADO`: corta el push y muestra cómo descartar; con descarte del autor, deja
  pasar y registra el motivo.
- Un `APROBADO` seguido de una mención a "BLOQUEADO" en el texto no bloquea (el veredicto es
  la línea completa).
- El diff que ve el agente no incluye lockfiles; un diff con ``` adentro no rompe el prompt.
- Cambios sin commitear: aviso, no bloqueo.

### Definiciones pendientes a tomar al llegar

- ~~Proveedor del remoto~~ — GitHub (2026-09-16).
- ~~Dónde corre el agente~~ — hook local de pre-push, decisión 0016.
- ~~Versión de Python y de Node~~ — 3.14 y 24 LTS, decisión 0017.
- Nombre y clave del proyecto en Jira (este plan usa `AUL` como ejemplo).

### Cierre

CI verde sobre el esqueleto; el PR de prueba bloqueado y el correcto mergeado quedan como
evidencia; `arquitectura.md` §5 ("Cómo correrlo") completada.

---

## Fase 1 — Cargar los datos de un período y verlos

**Permite:** que el planificador suba el Excel de un período, vea la lista de errores de
validación con fila y motivo, y vea los datos cargados en la web. Y que el equipo CP-SAT tenga el
formato de instancia normalizada publicado, generable desde la base, para trabajar sin la web.

**Equipo:** PPS (1.1–1.4, 1.6), CP-SAT (1.5). **Decisiones que aplica:** 0004, 0005, 0006, 0007,
0009, 0012, 0013.

### Historias

- **HU-1.1** Como planificador, quiero descargar la plantilla Excel del período con todas sus
  hojas y columnas, para cargar los datos sin adivinar el formato.
- **HU-1.2** Como planificador, quiero subir el Excel completo y que el sistema lo valide entero
  antes de guardar nada, para no dejar un período a medio cargar.
- **HU-1.3** Como planificador, quiero recibir la lista completa de errores de validación (hoja,
  fila, columna, motivo en lenguaje claro), para corregir el archivo de una sola vez.
- **HU-1.4** Como planificador, quiero ver en la web las carreras, materias con su ubicación en
  cada plan, comisiones, docentes, no-disponibilidades, aulas y bloqueos del período cargado, para
  verificar que la entrada es la que quería.
- **HU-1.5** Como integrante CP-SAT, quiero que exista un formato de instancia normalizada (JSON
  con esquema publicado) y un comando que lo exporte desde la base para un período, para
  desarrollar el solver contra el mismo dato que va a usar la API.
- **HU-1.6** Como planificador, quiero que al resubir el Excel de un período ya cargado el sistema
  me pida confirmación y reemplace los datos, para corregir sin duplicar.

### Casos borde

- Falta una hoja obligatoria; falta una columna obligatoria; columna extra desconocida (se ignora
  con advertencia).
- ID duplicado dentro de una hoja; referencia a un ID inexistente (docente, aula, materia,
  tipo de aula, teoría asociada).
- `Teoria_Asociada` apunta a una práctica, a una comisión de otra materia, o está presente en una
  teoría.
- Comisión de práctica sin teoría asociada; comisión teórico-práctica con teoría asociada.
- Comisión sin docente; comisión con el mismo docente repetido.
- Duración que no es múltiplo del bloque; duración mayor que la jornada; dictados por semana
  mayor que los días habilitados; dictados por semana en 0.
- Aula con capacidad 0; alumnos en 0 (se acepta con advertencia); alumnos mayores que toda aula
  disponible (se acepta: lo resuelve el solver como infactible).
- No-disponibilidad o bloqueo fuera de la grilla, con desde ≥ hasta, o en un día no habilitado.
- Materia sin ninguna carrera; materia en dos carreras con distinto año; materia en la misma
  carrera dos veces.
- Tipo de aula alternativo igual al requerido; tipo alternativo inexistente.
- Excel vacío; Excel con solo la configuración.
- Período reimportado mientras existe una corrida (se define en Fase 4; acá se bloquea).

### Definiciones pendientes a tomar al llegar

- **Plantilla definitiva del Excel** con los cambios listados en `arquitectura.md` §2: cómo se
  expresan varios docentes por comisión (columna con separador vs. hoja `Comision_Docente`), cómo
  se expresan los tipos alternativos (ídem), y las columnas nuevas de configuración.
- **Esquema exacto del JSON de instancia** (lo define CP-SAT; PPS lo consume). Se acuerda antes de
  la primera historia de cada equipo.
- **Autenticación:** quién puede subir un Excel. Para esta fase se asume sin login (un solo
  planificador); la decisión formal de roles y acceso se toma en la Fase 4, donde aparecen
  docentes y estudiantes como lectores.
- Si un período se identifica por (ciclo lectivo, cuatrimestre) o por un ID libre.

### Cierre

Subir el Excel del juguete (cuando exista; mientras, el de ejemplo adaptado a la plantilla nueva)
produce los datos en la web; subir uno con cada error de la lista produce el mensaje correcto;
`exportar-instancia` genera un JSON válido contra el esquema publicado.

---

## Fase 2 — Primer horario del caso de prueba

**Permite:** que el equipo CP-SAT, desde línea de comandos y sin la web, obtenga para el caso de
prueba un horario que respeta docentes, aulas, capacidad, tipo de aula, bloqueos y grilla, y lo
verifique con un validador que no depende del solver.

**Equipo:** CP-SAT. **Decisiones que aplica:** 0003, 0004, 0005, 0007 (parcial: un dictado),
0009, 0012.

### Historias

- **HU-2.1** Como integrante CP-SAT, quiero correr `aulero-solver solve instancia.json` y obtener
  una solución en JSON con estado, asignaciones y métricas, para iterar el modelo sin la web.
- **HU-2.2** Como integrante CP-SAT, quiero que el solver respete la grilla (0004), R5 (docente
  sin superposición), R6 (no-disponibilidad docente), R7 (capacidad), R8 con 0009 (tipo exacto o
  alternativo) y R11 (bloqueos de aula), y que dos comisiones no compartan aula en el mismo
  bloque, para tener un horario físicamente válido.
- **HU-2.3** Como integrante CP-SAT, quiero un validador independiente
  (`aulero-solver validar instancia.json solucion.json`) que verifique cada restricción y liste
  las violaciones con las entidades afectadas, para no confiar solo en el modelo.
- **HU-2.4** Como integrante CP-SAT, quiero que el solver corra con un límite de tiempo y distinga
  `INFACTIBLE` de `TIEMPO_AGOTADO`, para saber si el problema no tiene solución o no la encontró.
- **HU-2.5** Como integrante CP-SAT, quiero los datos del caso de prueba (primer cuatrimestre de
  1.º y 2.º año de ISI: 9 materias, comisiones, docentes, aulas, disponibilidades, bloqueos) en el
  formato de instancia, para tener la referencia contra la que se prueba todo lo que sigue.
- **HU-2.6** Como integrante CP-SAT, quiero que el paquete se instale y sus tests corran solos
  (`pip install -e solver && pytest solver`), para que el modelo se desarrolle y se defienda sin
  levantar nada más.

### Casos borde

- Docente sin ninguna no-disponibilidad; docente no disponible todos los días salvo uno.
- Aula bloqueada la jornada completa; aula con un solo hueco donde entra exactamente una clase.
- Comisión que solo entra en un aula (única con capacidad); dos comisiones que solo entran en la
  misma aula y el mismo docente (infactible).
- Clase de 3 h con la jornada terminando a las 22:00: última posición válida 19:00.
- Instancia sin aulas del tipo requerido por una comisión: infactible, con diagnóstico.
- Instancia con cero comisiones: solución vacía, factible.
- Comisión con un tipo alternativo: puede caer en cualquiera de los dos; con el requerido lleno,
  cae en el alternativo.
- Docente con dos comisiones que solo caben en el mismo bloque: infactible.
- Validador sobre una solución con una asignación fuera de grilla, con superposición de docente,
  con superposición de aula, con sobrecupo, con tipo no declarado: reporta cada una por su nombre.

### Definiciones pendientes a tomar al llegar

- **Datos definitivos del juguete** (el equipo los arma "a la brevedad"). Hasta tenerlos, se usa
  una instancia sintética con la misma forma; la historia 2.5 no se cierra sin los datos reales
  del caso de prueba.
- **Límite de tiempo por defecto** de una corrida (y de dónde sale el número).
- **Objetivo del Proyecto A:** factibilidad pura o un objetivo trivial de desempate (por ejemplo,
  minimizar el bloque de fin más tardío) para que la solución sea reproducible y "razonable" a la
  vista. Se recomienda factibilidad pura con semilla fija; decidir y registrar.
- **Mecanismo de tipos alternativos** en la instancia (lista por comisión, según 0009).

### Cierre

`aulero-solver solve` sobre el juguete devuelve `FACTIBLE`; `aulero-solver validar` sobre esa
solución devuelve cero violaciones; cada caso borde tiene su test nombrado; salida de `pytest`
pegada en el cierre.

---

## Fase 3 — Horario que respeta el plan de estudios

**Permite:** que el caso de prueba completo —dos años, teorías con sus prácticas asociadas,
varios dictados por semana, una materia compartida— se resuelva respetando R1–R4 con la lectura
existencial, o que el solver diga qué grupo de restricciones impide resolverlo. Con esto el
Proyecto A queda completo a nivel modelo.

**Equipo:** CP-SAT. **Decisiones que aplica:** 0001, 0006, 0007, 0015.

### Historias

- **HU-3.1** Como planificador, quiero que para cada carrera, año y cuatrimestre exista al menos
  una combinación cursable (teoría + su práctica) de cada materia que no se pise con las demás,
  para que un alumno que sigue el plan pueda cursar todo.
- **HU-3.2** Como planificador, quiero que ninguna práctica se superponga con su teoría asociada,
  y que sí pueda hacerlo con otras comisiones de su materia (R4).
- **HU-3.3** Como planificador, quiero que las materias de años distintos del mismo cuatrimestre
  puedan superponerse (R2), para no restringir de más.
- **HU-3.4** Como planificador, quiero que los dictados de una misma comisión caigan en días
  distintos (0007).
- **HU-3.5** Como planificador, quiero que una materia compartida por dos carreras respete el
  grupo de conflicto de cada una (0006).
- **HU-3.6** Como integrante CP-SAT, quiero que las comisiones con varios docentes apliquen R5 y
  R6 a cada uno.
- **HU-3.7** Como integrante CP-SAT, quiero que ante `INFACTIBLE` el solver informe un conjunto
  mínimo de restricciones en conflicto (por nombre de regla y entidades), para saber qué relajar
  en el Proyecto B.
- **HU-3.8** Como integrante CP-SAT, quiero que el validador cubra R1–R4 con la lectura
  existencial, para verificar el modelo curricular con independencia del solver.
- **HU-3.9** Como planificador, quiero poder fijar de antemano el día, el bloque de inicio y/o el
  aula de un dictado, y que el solver respete eso y resuelva el resto (decisión 0015).

### Casos borde

- Materia con 1 teoría y 3 prácticas (ejemplo (a) del estado del arte): las prácticas pueden
  pisarse entre sí; ninguna con la teoría.
- Materia con 2 teorías, cada una con su práctica (ejemplo (b)): T1 puede pisar T2 y P2, no P1.
- Materia teórico-práctica: su única comisión es la combinación.
- Dos materias del mismo grupo con una sola comisión cada una: no pueden pisarse en absoluto.
- Grupo con una sola materia: sin restricción curricular.
- Materia compartida con año distinto en cada carrera: pertenece a dos grupos.
- Materia en dos carreras, grupos que se cruzan por docente compartido.
- Comisión con 2 dictados y docente disponible solo 2 días: los dos días quedan fijados.
- Comisión con 2 dictados y docente disponible 1 día: infactible, diagnóstico nombra R6 y 0007.
- Combinación cursable que existe pero es única para dos materias y ambas exigen el mismo bloque:
  infactible, diagnóstico nombra R1.
- Juguete completo factible; juguete con un aula menos: factible o infactible con diagnóstico,
  según los datos (el resultado se registra como referencia).
- Dictado con solo el día pre-fijado: el solver elige bloque y aula; con solo el aula: elige día
  y bloque; con los tres: solo verifica.
- Dictado pre-fijado en un aula de tipo no declarado, o con capacidad insuficiente, o en una
  no-disponibilidad del docente: error de validación, no llega al solver.
- Dos dictados pre-fijados en la misma aula y el mismo bloque: infactible, diagnóstico los nombra.
- Dictado pre-fijado que hace imposible la lectura existencial de R1 para su grupo: infactible,
  diagnóstico nombra R1 y el pre-fijado.

### Definiciones pendientes a tomar al llegar

- ~~Comisiones pre-fijadas~~ — entrada opcional por dictado, decisión 0015 (2026-09-16).
- **Optativas:** confirmar que participan de R1 como cualquier materia de su grupo (0005 las
  trata como entrada; falta decir si chocan con las obligatorias del año).
- Si el **diagnóstico de infactibilidad** (3.7) es parte obligatoria del Proyecto A o se difiere a
  la Fase 7. Se recomienda en A: es lo que le da valor a un `INFACTIBLE`.
- Cota de combinaciones cursables por materia a partir de la cual el modelo necesita otra
  formulación (se mide en esta fase; se decide en la 6).

### Cierre

Juguete completo `FACTIBLE` con cero violaciones del validador; cada caso borde con test
nombrado; `informe-de-gestion.md` con el ejemplo narrado del caso de prueba resuelto.

---

## Fase 4 — Ver el horario en la web

**Permite:** que el planificador lance la optimización del período cargado desde la web, siga su
estado, y vea el horario resultante por aula, por docente y por carrera/año; que un docente vea
su semana y un estudiante la de su año. Es la primera vez que todo el circuito
(Excel → BD → solver → BD → API → web) funciona de punta a punta.

**Equipo:** PPS (4.1–4.5, 4.7), CP-SAT (4.6). **Decisiones que aplica:** 0002, 0012, 0013.

### Historias

- **HU-4.1** Como planificador, quiero lanzar la optimización del período desde la web y ver su
  estado (en cola, en curso, terminada, infactible, tiempo agotado), para no quedarme esperando
  sin saber.
- **HU-4.2** Como planificador, quiero ver el horario en una grilla semanal filtrable por aula,
  por docente y por carrera/año, para revisarlo como lo reviso hoy en papel.
- **HU-4.3** Como docente, quiero ver mi horario semanal con materia, comisión y aula.
- **HU-4.4** Como estudiante, quiero ver el horario de mi carrera y año, con todas las comisiones
  de cada materia.
- **HU-4.5** Como planificador, quiero que cuando no hay solución la web muestre el diagnóstico
  (qué reglas y qué entidades están en conflicto), para saber qué tocar en la entrada.
- **HU-4.6** Como integrante CP-SAT, quiero que la solución se guarde en la base en el formato
  definido por el paquete (asignaciones, métricas, diagnóstico), para recuperarla, compararla y
  analizarla después.
- **HU-4.7** Como planificador, quiero que la grilla sea navegable con teclado y legible con
  lector de pantalla (vista en lista), para cumplir la accesibilidad básica.

### Casos borde

- Lanzar una corrida sobre un período sin comisiones: se rechaza con mensaje.
- Lanzar una segunda corrida mientras hay una en curso para el mismo período: se rechaza o se
  encola (a definir abajo).
- El solver agota el tiempo: la corrida queda `TIEMPO_AGOTADO` y la web lo muestra.
- Los datos del período cambian después de una corrida: la corrida queda marcada como
  desactualizada (se define abajo).
- Docente sin comisiones en el período: vista vacía con mensaje, no error.
- Carrera/año sin materias: ídem.
- Dictado que cruza el límite de un turno o termina exactamente a las 22:00: se dibuja completo.
- Dos dictados de la misma comisión en distintas aulas: la vista por comisión los muestra a los
  dos.

### Definiciones pendientes a tomar al llegar

- **Ejecución del solver:** tarea en segundo plano dentro del proceso de la API (recomendado para
  empezar) o cola de trabajos. Riesgo abierto de 0012.
- **Concurrencia de corridas** por período: rechazar o encolar.
- **Autenticación y roles:** si docentes y estudiantes acceden sin login (horario público) y el
  planificador con uno. Se recomienda horario público de solo lectura y un único usuario
  planificador con contraseña; decidir y registrar.
- **Qué pasa con una corrida cuando cambia la entrada:** se marca desactualizada (recomendado) o
  se borra.
- Cuántas corridas se conservan por período (relevante para la Fase 8).
- Formato de exportación del horario (PDF, Excel, ninguno) — puede quedar fuera de alcance.

### Cierre

Desde un navegador: subir el juguete, lanzar, ver el horario en las tres vistas, con el test de
axe sin violaciones serias; cada caso borde con test nombrado; los dos documentos vivos con el
circuito completo narrado.

---

## Fase 5 — Carga por formulario y excepciones por semana

**Permite:** que el planificador corrija cualquier dato del período por formulario sin resubir el
Excel, registre una excepción de aula para una comisión en una semana y vea esa semana con la
excepción aplicada (o el aviso de que no hay aula).

**Equipo:** PPS. **Decisiones que aplica:** 0008, 0009.

### Historias

- **HU-5.1** Como planificador, quiero crear, editar y eliminar carreras, materias (con su
  ubicación por carrera), docentes, no-disponibilidades, aulas, bloqueos y comisiones por
  formulario, con la misma validación que el Excel, para corregir un dato sin rehacer la carga.
- **HU-5.2** Como planificador, quiero registrar una excepción de aula (comisión, semana, tipo de
  aula) y que el sistema busque un aula libre de ese tipo en el mismo día y horario de esa semana.
- **HU-5.3** Como planificador, quiero ver el horario de una semana concreta del período con sus
  excepciones aplicadas, para saber qué pasa esa semana y no solo en la semana tipo.
- **HU-5.4** Como planificador, quiero que el sistema me avise cuando no hay aula disponible para
  una excepción, y que no modifique el horario base.
- **HU-5.5** Como planificador, quiero que al editar un dato que afecta al horario (docente,
  duración, alumnos, aulas) la corrida vigente quede marcada como desactualizada.

### Casos borde

- Excepción en una semana fuera del período; en una semana sin clases (a definir).
- Dos excepciones que piden la misma aula en el mismo bloque de la misma semana: la segunda no
  encuentra aula.
- Excepción para una comisión con 2 dictados: aplica a uno (a definir cuál) o a los dos.
- Excepción que pide el mismo tipo que ya tiene la comisión: se rechaza.
- Aula candidata bloqueada (R11) justo esa semana: no se usa.
- Eliminar una entidad referenciada (docente con comisiones, aula con bloqueos): se rechaza con
  mensaje.
- Editar la duración de una comisión: la corrida queda desactualizada; editar el nombre: no.
- Formulario enviado con teclado únicamente; errores anunciados junto al campo (a11y).

### Definiciones pendientes a tomar al llegar

- **Cantidad de semanas y fecha de inicio del período**, y cómo se numeran las semanas
  (dato de `Periodo`, 0008).
- Si una excepción aplica a **un dictado o a todos los dictados** de la semana.
- Si las excepciones se cargan también por Excel (hoja `Excepciones_Aula` del ejemplo) o solo por
  formulario.
- Qué campos exactamente marcan una corrida como desactualizada.

### Cierre

Editar una comisión y ver el cambio; cargar una excepción y verla en la semana; cargar una sin
aula posible y ver el aviso; cada caso borde con test nombrado.

---

## Fase 6 — Escalar a la instancia real

**Permite:** resolver la carrera ISI completa (todos los años y comisiones de un cuatrimestre) y
luego un escenario con varias carreras que comparten aulas y docentes, dentro de un tiempo
acotado, con los tiempos medidos y comparables entre corridas.

**Equipo:** ambos (CP-SAT en rendimiento, PPS en datos y visualización a escala).
**Decisiones que aplica:** 0002, 0003, 0006.

### Historias

- **HU-6.1** Como planificador, quiero cargar la carrera ISI completa y obtener un horario, o su
  diagnóstico, dentro del tiempo acordado.
- **HU-6.2** Como planificador, quiero cargar varias carreras con docentes y aulas compartidos y
  obtener un horario que respete el grupo de conflicto de cada carrera.
- **HU-6.3** Como integrante CP-SAT, quiero que cada corrida registre tamaño de la instancia
  (comisiones, dictados, aulas, combinaciones cursables), tiempo de resolución y tiempo hasta la
  primera solución, para comparar formulaciones.
- **HU-6.4** Como integrante CP-SAT, quiero un conjunto de instancias de referencia versionadas
  (juguete, ISI completa, multi-carrera sintética) con su resultado esperado, para detectar
  regresiones del modelo.
- **HU-6.5** Como planificador, quiero que la grilla siga siendo usable con cientos de comisiones
  (filtros, búsqueda), para revisar la instancia real.

### Casos borde

- Docente que dicta en tres carreras; aula única de un tipo demandada por todas las carreras.
- Materia compartida por tres carreras con tres años distintos.
- Instancia que agota el tiempo: se informa `TIEMPO_AGOTADO` y el tamaño, no se inventa una
  solución parcial.
- Instancia real con datos incompletos (docente sin no-disponibilidad cargada, aula sin
  capacidad): la validación de Fase 1 los atrapa antes de llegar acá.

### Definiciones pendientes a tomar al llegar

- **Tiempo objetivo** de resolución para la instancia real (número y procedencia).
- **Disponibilidad de los datos reales** de ISI y de las otras carreras (quién los entrega, en
  qué formato, con qué permiso).
- Si la instancia multi-carrera se valida con datos reales o sintéticos.
- **Estrategia de descomposición** si el solver no escala (riesgo abierto de 0003): resolver por
  carrera y reparar recursos compartidos. Se decide con los tiempos medidos, no antes.
- Cota de combinaciones cursables (medida en Fase 3) y si obliga a reformular R1/R3.

### Cierre

ISI completa resuelta o diagnosticada dentro del tiempo objetivo, con la tabla de tiempos pegada;
instancia multi-carrera con al menos un docente y un aula compartidos resuelta; instancias de
referencia en el repo con test de regresión.

---

## Fase 7 — Proyecto B: horario con violaciones acotadas

**Permite:** que ante una instancia sin horario perfecto el sistema entregue el mejor horario
posible, con la lista exacta de qué reglas se violaron, dónde y cuánto, y que sobre una instancia
factible entregue el mismo resultado que el Proyecto A con cero violaciones.

**Equipo:** CP-SAT (7.1–7.4), PPS (7.5). **Decisiones que aplica:** 0002, 0010.

### Historias

- **HU-7.1** Como integrante CP-SAT, quiero que el modelo B tenga una variable de holgura por
  instancia de R1/R3, R7 y R8, y mantenga duras todas las demás, para medir cada violación.
- **HU-7.2** Como integrante CP-SAT, quiero que el primer nivel minimice la suma ponderada de
  holguras con pesos tomados de la configuración, para obtener el horario con menos violaciones
  según la prioridad de la institución.
- **HU-7.3** Como integrante CP-SAT, quiero que la solución liste cada violación con la regla, las
  entidades y la magnitud, y que el validador las confirme, para que el reporte sea verificable.
- **HU-7.4** Como integrante CP-SAT, quiero correr A y B sobre la misma instancia y obtener una
  comparación (estado, tiempo, violaciones por regla), para el capítulo comparativo.
- **HU-7.5** Como planificador, quiero elegir el modelo (A o B) al lanzar una corrida, fijar los
  pesos y el tope de sobrecupo, y ver las violaciones en la grilla y en una lista, para decidir si
  el horario es aceptable.

### Casos borde

- Instancia factible en A: B devuelve todas las holguras en cero y un horario válido bajo A.
- Todos los pesos en cero: el modelo sigue dando un horario (se acepta cualquier violación).
- Peso de una relajación "infinito" (muy alto): equivale a mantenerla dura.
- Sobrecupo necesario mayor que el tope: sigue infactible, con diagnóstico.
- Instancia que necesita las tres relajaciones a la vez.
- Violación de R8 con un tipo alternativo declarado: no es violación (0009); con uno no
  declarado: sí.
- Validador sobre una solución de B: confirma exactamente las violaciones que reporta el solver,
  ni una más ni una menos.

### Definiciones pendientes a tomar al llegar

- **Tope de sobrecupo** (número y procedencia: dato de secretaría o criterio declarado).
- **Pesos por defecto** de cada holgura, con procedencia.
- **Métrica de comparación A vs. B** para el informe (qué columnas, qué instancias).
- Si al dar `INFACTIBLE` en A el sistema **ofrece correr B automáticamente** o lo hace el
  planificador.
- Si los pesos se fijan por período (configuración) o por corrida (recomendado: por corrida, con
  el defecto del período).

### Cierre

Sobre el juguete con un aula menos (o la instancia que resultó infactible en Fase 3/6), B devuelve
horario con violaciones listadas y confirmadas por el validador; sobre el juguete factible, cero
violaciones; comparación A/B pegada en el cierre; cada caso borde con test nombrado.

---

## Fase 8 — Proyecto B: calidad del horario y comparación de corridas

**Permite:** horarios compactos, con aula estable y turno continuo, que tienen en cuenta las
preferencias horarias de los docentes; varias corridas guardadas y comparables lado a lado; y la
publicación de una como horario oficial del período.

**Equipo:** CP-SAT (8.1–8.2), PPS (8.3–8.6). **Decisiones que aplica:** 0007, 0010, 0011.

### Historias

- **HU-8.1** Como integrante CP-SAT, quiero el segundo nivel de optimización que, con las
  violaciones del primer nivel fijadas, minimice la suma ponderada de B1 (huecos entre dictados
  de una comisión el mismo día), B2 (aulas distintas entre dictados), B3 (turnos distintos en la
  semana) y preferencias docentes no respetadas.
- **HU-8.2** Como integrante CP-SAT, quiero que la solución reporte el valor de cada blanda por
  separado, para explicar qué se ganó con cada peso.
- **HU-8.3** Como docente, quiero cargar mis preferencias horarias (franjas en las que prefiero
  dictar), sabiendo que no son obligatorias, para que se tengan en cuenta si es posible.
- **HU-8.4** Como planificador, quiero guardar varias corridas del mismo período con distintos
  pesos y verlas lado a lado (violaciones, blandas, tiempo), para elegir.
- **HU-8.5** Como planificador, quiero publicar una corrida como horario oficial del período y
  que sea la que ven docentes y estudiantes.
- **HU-8.6** Como planificador, quiero ver las diferencias entre dos corridas (qué comisiones
  cambiaron de día, hora o aula), para no revisar todo de nuevo.

### Casos borde

- Comisión con un solo dictado: B1, B2 y B3 son triviales (valor cero).
- Preferencia docente que coincide con una no-disponibilidad: gana la dura; se advierte al cargar.
- Dictado que cruza el límite de turno: pertenece al turno en que empieza (0011).
- Dos corridas con los mismos pesos y la misma semilla: idénticas; la comparación muestra cero
  diferencias.
- Publicar una corrida cuando ya hay otra publicada: reemplaza, con confirmación.
- Publicar una corrida desactualizada: se rechaza con mensaje.
- Corrida de B con violaciones publicada: las violaciones se muestran en el horario oficial.

### Definiciones pendientes a tomar al llegar

- **Rangos reales de los turnos** (reemplazan los provisorios de 0011).
- **Pesos por defecto de las blandas**, con procedencia.
- Si la preferencia docente se expresa por **franja** o por **turno**.
- Qué muestra exactamente la comparación lado a lado y el diff entre corridas.
- Cuántas corridas se conservan por período (viene de la Fase 4).
- Si la publicación notifica a alguien (probablemente fuera de alcance).

### Cierre

Sobre la instancia real: corrida de B con blandas, comparación de al menos dos corridas, una
publicada y visible como oficial; cada caso borde con test nombrado; los dos documentos vivos con
el estado final y la deuda anotada.

---

## Fuera de alcance del proyecto

Lo que queda afuera y por qué, para que un pedido nuevo se compare contra esto y no contra la
buena voluntad:

| Fuera | Por qué |
|---|---|
| Inscripción real de alumnos, recursantes, correlatividades en el modelo | Decisión 0001. |
| Asignar docentes a comisiones | R9: las comisiones llegan armadas. |
| Algoritmo genético, aprendizaje por refuerzo, cualquier segundo motor | Decisión 0003. |
| Cambiar día u hora de un dictado para una semana puntual | Decisión 0008; solo cambia el aula. |
| Distancias o traslados entre edificios | No hay dato ni pedido; un aula es un aula. |
| Más de un período planificado a la vez | Un período por corrida. |
| Gestión de cupos e inscripciones | Los alumnos por comisión son entrada (0005). |
| Notificaciones (correo, mensajes) al publicar | Sin pedido; puede revisarse al cerrar la Fase 8. |

## Cómo cargar esto en Jira

- Un **epic por fase** (`Fase N — Nombre`), con la descripción "Permite:" como resumen del epic.
- Una **historia por HU-N.M**, con el texto tal cual y los casos borde que le corresponden como
  criterios de aceptación.
- Las **definiciones pendientes** de cada fase como tareas del epic, etiquetadas `definicion`,
  que se cierran registrando la decisión en `docs/decisiones/` antes de empezar las historias de
  la fase.
- El **cierre** de cada fase como una tarea `cierre` con el checklist de `cierre-de-fase.md` de la
  skill `avanzar-por-fases`.
