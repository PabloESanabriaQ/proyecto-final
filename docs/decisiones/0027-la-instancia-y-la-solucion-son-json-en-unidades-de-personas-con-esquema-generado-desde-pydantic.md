# 0027 — La instancia y la solución son JSON en unidades de personas, con esquema generado desde Pydantic

**Estado:** Propuesta — 2026-11-24; pendiente de revisión y acuerdo explícito del equipo.

## Alcance de esta propuesta

Los puntos 1–7, 9 y 10 describen la propuesta del contrato de instancia y los criterios
compartidos de formato, versión y validación. El punto 8 es un inventario preliminar de
solución y configuración: no define sus contratos completos ni autoriza a implementarlos.
Las menciones a esos documentos en los demás puntos expresan criterios propuestos, no
completan sus campos, tipos ni validaciones pendientes.

La parte de instancia también conserva dos definiciones abiertas: el tratamiento de la
capacidad del aula prefijada en B (0028) y la clasificación de los días docentes insuficientes
(0029). Hasta que se acuerden, siguen vigentes 0015 y 0007, con el conflicto de esta última
frente al plan señalado más abajo. No se presenta el contrato de instancia como cerrado.

El merge de este PR publica el borrador para continuar la revisión; no acepta automáticamente
esta decisión ni publica los modelos Pydantic o los JSON Schema de AUL-41. La aceptación
requiere resolver o excluir explícitamente del alcance las definiciones abiertas y actualizar
el estado de este archivo y del índice de decisiones de forma coherente.

## Contexto

AUL-20 pide fijar el esquema exacto del JSON de instancia, y AUL-39 cómo se expresan en él los
tipos de aula alternativos de una comisión ([[0009]]). Lo consumen el modelo (Hugo), el validador y
las instancias simuladas (Pablo), la línea de comandos (Nico) y, del lado de la PPS, la exportación
desde la base (HU-1.5, AUL-17). Las entidades ya están fijadas por las decisiones [[0004]] a
[[0011]] y [[0015]], y resumidas en `arquitectura.md` §2; lo que falta es la forma concreta, cómo
se escriben los horarios, cómo se referencian las entidades entre sí, qué valida el esquema y cómo
se versiona. La referencia de diseño que pide AUL-41 es el
[formato oficial de la ITC2019](https://www.itc2019.org/format).

Alternativas evaluadas:

- **Horarios en índices de la grilla** (`"dia": 0`, `"bloque": 1`). Es compacto y es lo que usa
  el modelo, pero un número solo significa algo junto con la configuración del período, y el caso
  acotado (AUL-43) se arma a mano desde una planilla. Se descarta.
- **Horarios en unidades de personas** (`"dia": "lunes"`, `"desde": "08:30"`). Lo lee cualquiera,
  sale directo de la planilla y de la base, y no cambia si cambia la grilla. Cuesta una conversión
  a bloques y una validación de alineación. **Se elige.**
- **El formato XML de la ITC2019 tal cual.** Tiene herramientas y validadores, pero representa el
  días y semanas como cadenas de bits, y sus restricciones son un catálogo genérico de
  distribución con penalidades por opción. Nuestras reglas ya están fijadas por las decisiones y no
  entran en ese catálogo sin forzarlas. Se toma su estructura (ver Decisión, punto 9), no su
  formato.
- **JSON Schema escrito a mano, con los modelos aparte.** Deja el esquema legible por sí mismo,
  pero son dos fuentes que se desalinean. Se descarta: los modelos Pydantic son la fuente y el
  esquema se genera (lo pide AUL-17).

## Decisión

1. **Formato y fuente.** La instancia y la solución son documentos JSON. La fuente son los modelos
   Pydantic de `aulero_solver` (`instancia.py`, `solucion.py`, `configuracion.py`). El JSON Schema
   se genera desde ellos y se guarda versionado en `solver/esquema/` (`instancia.schema.json`,
   `solucion.schema.json`, `configuracion.schema.json`). Un test falla si el esquema guardado no
   coincide con el generado.

2. **Versión.** Cada documento lleva `version_esquema`, con la forma `MAYOR.MENOR`. Arranca en
   `1.0`, por criterio de esta propuesta: primera publicación del contrato. Un cambio que hace
   inválido un documento que antes era válido sube la mayor; una ampliación que conserva los
   documentos anteriores sube la menor. Esto también incluye las validaciones de Pydantic que
   no aparecen en el JSON Schema. Cada versión publicada conserva sus esquemas; los nombres del
   punto 1 se guardan bajo `solver/esquema/1.0/` para la primera publicación.

   El paquete declara las versiones que admite y rechaza las que no conoce, incluso una menor
   futura: compartir la mayor no garantiza que un lector antiguo entienda campos nuevos.
   Inicialmente admite `1.0`. La versión del esquema es independiente de la del paquete. Los
   campos desconocidos se rechazan para detectar errores de escritura, sin convertirlos en
   campos ignorados. Esta política es una elección técnica de la propuesta.

3. **Horarios en unidades de personas.** Los días son `lunes`, `martes`, `miercoles`, `jueves`,
   `viernes`, `sabado` y `domingo`; el período dice cuáles están habilitados. Las horas son texto
   `HH:MM`, de 24 horas. Las duraciones van en minutos. La validación exige que toda hora y toda
   duración se alineen con la grilla del período ([[0004]]): los inicios se cuentan desde el
   inicio de la jornada, y las duraciones son cantidades enteras positivas de bloques. La
   jornada contiene una cantidad entera de bloques y no cruza medianoche. Los rangos son
   semiabiertos: `desde` incluido, `hasta` excluido; una clase puede terminar justo al cierre.
   `dias` es una lista no vacía y sin repetidos. Se conservan como valores por defecto lunes a
   sábado, 08:00–22:00 y bloques de 30 minutos, con la procedencia de [[0004]]. Admitir otros
   valores explícitos no resuelve la grilla por carrera pendiente de la Fase 6.

   Los turnos tienen nombre único y rangos dentro de la jornada. Como regla de este contrato
   propuesto, la carga rechaza una grilla cuyos turnos dejan huecos o se solapan. Así, cada
   inicio admisible pertenece a un único turno para evaluar B3 ([[0011]]).
   Los valores por defecto son mañana 08:00–13:00, tarde 13:00–18:00 y noche 18:00–22:00,
   con la procedencia de [[0011]]. La conversión de horas a bloques es una utilidad de los
   modelos de datos, compartible sin compartir la comprobación de restricciones ([[0026]]).

4. **Identificadores.** Cada entidad lleva un `id` de texto que pone quien arma la instancia (la
   base, la planilla o el simulador). Las entidades se referencian por `id`. Los ids son únicos
   dentro de su tipo de entidad, y toda referencia tiene que apuntar a una entidad existente.
   Los ids no son vacíos. Una referencia de salida se interpreta junto con la instancia que
   se entrega al validador; no se consulta la base de datos para resolverla ([[0012]]).

5. **Forma de la instancia.** Las claves van en español, en `snake_case` y sin tildes (`anio`).

   ```json
   {
     "version_esquema": "1.0",
     "periodo": {
       "nombre": "2027-1C",
       "dias": ["lunes", "martes", "miercoles", "jueves", "viernes", "sabado"],
       "jornada": {"desde": "08:00", "hasta": "22:00"},
       "bloque_minutos": 30,
       "turnos": [{"nombre": "manana", "desde": "08:00", "hasta": "13:00"},
                  {"nombre": "tarde", "desde": "13:00", "hasta": "18:00"},
                  {"nombre": "noche", "desde": "18:00", "hasta": "22:00"}]
     },
     "carreras": [{"id": "ISI", "nombre": "Ingeniería en Sistemas de Información"}],
     "materias": [{"id": "PROG1", "nombre": "Programación I",
                   "planes": [{"carrera": "ISI", "anio": 1, "cuatrimestre": 1}]}],
     "docentes": [{"id": "D01", "nombre": "…",
                   "no_disponible": [{"dia": "lunes", "desde": "08:00", "hasta": "12:00"}],
                   "preferencias": []}],
     "tipos_aula": [{"id": "TEO", "nombre": "Aula común"}],
     "edificios": [{"id": "LP", "nombre": "Sede Los Poetas"}],
     "aulas": [{"id": "A101", "edificio": "LP", "tipo": "TEO", "capacidad": 60,
                "bloqueos": [{"dia": "sabado", "desde": "08:00", "hasta": "13:00",
                              "motivo": "…"}]}],
     "comisiones": [{"id": "PROG1-T1", "materia": "PROG1", "actividad": "teoria",
                     "teoria": null, "docentes": ["D01"], "duracion_minutos": 120,
                     "dictados_por_semana": 2, "tipo_aula": "TEO",
                     "tipos_aula_alternativos": [], "alumnos": 55,
                     "prefijados": [{"dictado": 1, "dia": "martes", "desde": null,
                                     "aula": null}]}]
   }
   ```

   Lo que fija cada decisión: `planes` es la tabla Materia_Carrera, y la materia no tiene carrera
   propia ([[0006]]); `actividad` es `teoria`, `practica` o `teorico_practica`, y solo una
   práctica lleva `teoria`, que apunta a una comisión de teoría de la misma materia ([[0006]], R4);
   `docentes` tiene al menos uno ([[0007]]) y `dictados_por_semana` vale 1 por defecto.
   La carga rechaza más dictados semanales que días habilitados en el período: el límite se
   deduce de exigir días distintos para los dictados de una misma comisión ([[0007]]).
   La disponibilidad real de cada docente es otra comprobación, cuyo tratamiento se discute
   en 0029. `alumnos` es una sola cifra ([[0005]]).
   Se propone exigir alumnos y capacidades enteros mayores que cero como criterio del contrato;
   [[0005]] no fija por sí misma ese límite inferior.
   `preferencias` es solo del Proyecto B, y el A la ignora ([[0010]]); `prefijados` es opcional y
   sus campos `dia`, `desde` y `aula` pueden omitirse o ser nulos ([[0015]]).
   `dictado` es obligatorio y usa los números de 1 a `dictados_por_semana`, por criterio de
   presentación de esta propuesta. Hay a lo sumo un prefijado por número de dictado y cada
   prefijado fija al menos uno de los tres campos. Sin fijaciones se usa la lista vacía.

   Cada materia declara al menos un grupo en `planes`, sin ternas repetidas; cada práctica
   requiere su referencia `teoria` y las otras actividades llevan `teoria` nula u omitida.
   La lista de docentes no repite ids. `no_disponible`, `preferencias`, `bloqueos`,
   `tipos_aula_alternativos` y `prefijados` tienen lista vacía por defecto. Una preferencia
   tiene la misma forma temporal que una no-disponibilidad: `dia`, `desde` y `hasta`; su
   penalización pertenece al Proyecto B y no se define aquí ([[0010]]).

   Las colecciones de entidades existen aunque estén vacías. En particular, cero comisiones
   es una entrada válida y puede producir una solución factible vacía, como exige la Fase 2.

6. **Tipos de aula alternativos (AUL-39).** Cada comisión lleva `tipos_aula_alternativos`: una
   lista de ids de tipos de aula, vacía por defecto. No tiene orden ni repetidos, y no incluye el
   `tipo_aula` requerido. Sin alternativas, el tipo es exacto ([[0009]]). Si el Proyecto B
   necesita preferir una alternativa sobre otra, se agrega un peso en una versión menor; hoy no lo
   pide ninguna decisión.

7. **Qué valida cada capa.** El JSON Schema valida la estructura: tipos, campos obligatorios,
   valores permitidos y patrón de horas `HH:MM` de 00:00 a 23:59. Las comprobaciones entre
   entidades y contra una grilla configurable las realiza Pydantic al cargar la instancia:
   ids únicos, referencias existentes, horas y duraciones dentro de la grilla, rangos no vacíos,
   turnos que cubren la jornada sin huecos ni solapamientos, teoría de la misma materia para
   una práctica, dictados contra días habilitados del período y prefijados con número válido
   y aula existente del tipo requerido o alternativo.

   Según [[0015]], los prefijados se validan **antes de resolver**, sin invocar CP-SAT: capacidad
   si se fija aula; no-disponibilidades de todos los docentes si se fijan día e inicio; bloqueos
   del aula si además se fija aula. Una fijación parcial no inventa los valores libres para
   comprobar un choque concreto. La compatibilidad conjunta entre prefijados y el resto de la
   planificación se resuelve en el modelo; sus conflictos no se convierten automáticamente en
   errores estructurales. Los dos conflictos documentales abiertos se detallan más abajo.

   Cargar una solución valida su forma y los tipos de sus campos. La comprobación de referencias,
   asignaciones completas y únicas por dictado, duración, grilla, días distintos y restricciones
   frente a la instancia corresponde a `validar(instancia, solucion)`. Debe poder recibir una
   asignación con hora bien formada pero fuera de jornada, con referencia inexistente o con
   superposición, y reportar el error: rechazarla al deserializar impediría los casos de prueba
   del validador previstos en las Fases 2 y 3. Compartir formatos no implica compartir lógica
   de verificación con el modelo.

8. **Configuración y solución — inventario preliminar, pendiente de definición.**
   La configuración de una corrida es un documento aparte de la
   instancia, como en `arquitectura.md` §3.1: `modelo` (`A` o `B`), `limite_tiempo_segundos`,
   `semilla`, y los pesos y el tope de sobrecupo del Proyecto B. Ninguno lleva valor por defecto
   en el código hasta que su decisión lo fije con procedencia ([[0010]]; AUL-37 para el límite,
   AUL-51 para pesos y tope). La solución lleva `version_esquema`, `estado` (`FACTIBLE`,
   `INFACTIBLE` o `TIEMPO_AGOTADO`), `asignaciones` (comisión, número de dictado, día, `desde`,
   `hasta` y aula), `violaciones` (solo B), `diagnostico` (solo A infactible) y `metricas` (tiempo
   y valor objetivo por nivel). La forma de cada violación la fija AUL-50 y la del diagnóstico la
   Fase 3. Hasta entonces quedan con una forma mínima (restricción, entidades y magnitud, para la
   violación; lista de restricciones, para el diagnóstico), que esas tareas pueden cambiar con una
   versión menor si solo agregan campos opcionales. Antes de codificar se escribirá la forma
   exacta de cada campo de configuración y salida: este párrafo todavía es un inventario, no
   un contrato completo. No se inventan pesos, topes, semilla ni límite de tiempo por defecto.

9. **Lo que se toma de la ITC2019.** Del [formato oficial](https://www.itc2019.org/format)
   se toman las entidades identificadas y sus referencias, los bloqueos en las aulas y una
   solución que enumera asignaciones. Nuestra separación por dictado es una adaptación de
   Aulero ([[0007]]): ITC2019 asigna a cada clase un patrón de días y semanas, un inicio y un
   aula compartidos por sus encuentros. Su solución puede estar en un documento separado o
   incluida en el problema. Aulero elige documentos separados ([[0012]]) y un aula e inicio por
   dictado. Tampoco adopta XML, inscripciones de alumnos, días y semanas binarios, penalidades
   por opción ni el catálogo de restricciones de distribución.

10. **Fuera del esquema.** Las excepciones de aula por semana, la cantidad de semanas y la fecha
    de inicio del período ([[0008]]) no entran al solver: las resuelve la API después de la
    corrida. La corrida y su historia son de la base (PPS).

## Puntos abiertos antes de implementar

- **Prefijado con capacidad insuficiente en B.** [[0015]] exige error de entrada por capacidad
  insuficiente del aula prefijada, mientras [[0010]] permite relajar R7 con un tope.
  [Propuesta 0028](0028-el-modelo-b-admite-sobrecupo-acotado-en-aulas-prefijadas.md): se recomienda
  admitirlo dentro del tope en B y mantener el rechazo en A. La alternativa más viable es
  conservar el rechazo en ambos. Pendiente de revisión del equipo; 0015 no cambia todavía.
- **Más dictados que días disponibles del docente.** [[0007]], en sus consecuencias, exige
  rechazar esa entrada; el caso borde de Fase 3 pide `INFACTIBLE` con diagnóstico de R6 y 0007.
  [Propuesta 0029](0029-los-dias-docentes-insuficientes-producen-infactibilidad-con-diagnostico.md):
  se recomienda `INFACTIBLE` con diagnóstico en A y B. La alternativa más viable es mantener el
  error de entrada y ajustar el plan. Pendiente de revisión del equipo; el conflicto sigue
  abierto. El límite estructural contra la cantidad de días del período sí queda definido.
- **Contrato exacto de salida y configuración.** Falta detallar tipos, obligatoriedad y ejemplos
  JSON; en particular, qué contiene `TIEMPO_AGOTADO` si se encontró una solución, cómo se distingue
  de no haberla encontrado y qué métricas indican el progreso de los niveles de B. También falta
  acordar con AUL-50 la forma inicial de violaciones y con AUL-37/AUL-51 sus parámetros. Los
  formatos mínimos del punto 8 siguen siendo propuestas; no cierran esas tareas.

## Consecuencias

**A favor:** el caso acotado y las instancias simuladas se escriben y se revisan a mano; la PPS
exporta sin convertir horarios; el esquema publicado y el código no se pueden desalinear; los
huecos de AUL-37, AUL-50, AUL-51 y la Fase 3 están identificados para acordarlos antes de
implementar los campos afectados.

**En contra:** el modelo y el validador necesitan convertir horas a bloques; la conversión vive
en los modelos de datos para no romper la regla 3 de la [[0026]]. La validación que no
expresa el JSON Schema solo la tiene quien usa el paquete de Python: un consumidor en otro lenguaje
puede armar un documento que pasa el esquema y falla al cargarse.

**Riesgo abierto:** que la Fase 6 decida que la grilla o los turnos son por carrera y no por
período (señales activadas de la [[0004]] y la [[0011]]). **La señal:** que esa definición se tome.
Ahí `periodo` cambia de forma y la versión sube la mayor, porque las instancias anteriores dejan de
ser válidas.
