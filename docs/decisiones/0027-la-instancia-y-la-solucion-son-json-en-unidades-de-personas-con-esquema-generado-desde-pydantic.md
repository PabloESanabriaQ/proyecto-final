# 0027 — La instancia y la solución son JSON en unidades de personas, con esquema generado desde Pydantic

**Estado:** Propuesta — 2026-11-24 (borrador; se acepta al mergear el PR de AUL-41)

## Contexto

AUL-20 pide fijar el esquema exacto del JSON de instancia, y AUL-39 cómo se expresan en él los
tipos de aula alternativos de una comisión ([[0009]]). Lo consumen el modelo (Hugo), el validador y
las instancias simuladas (Pablo), la línea de comandos (Nico) y, del lado de la PPS, la exportación
desde la base (HU-1.5, AUL-17). Las entidades ya están fijadas por las decisiones [[0004]] a
[[0011]] y [[0015]], y resumidas en `arquitectura.md` §2; lo que falta es la forma concreta, cómo
se escriben los horarios, cómo se referencian las entidades entre sí, qué valida el esquema y cómo
se versiona. La referencia de diseño que pide AUL-41 es la formulación de instancias de la ITC2019.

Alternativas evaluadas:

- **Horarios en índices de la grilla** (`"dia": 0`, `"bloque": 1`). Es compacto y es lo que usa
  el modelo, pero un número solo significa algo junto con la configuración del período, y el caso
  acotado (AUL-43) se arma a mano desde una planilla. Se descarta.
- **Horarios en unidades de personas** (`"dia": "lunes"`, `"desde": "08:30"`). Lo lee cualquiera,
  sale directo de la planilla y de la base, y no cambia si cambia la grilla. Cuesta una conversión
  a bloques y una validación de alineación. **Se elige.**
- **El formato XML de la ITC2019 tal cual.** Tiene herramientas y validadores, pero representa el
  tiempo como cadenas de bits de semanas y días, y sus restricciones son un catálogo genérico de
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
   `1.0`. Un cambio que hace inválido un documento que antes era válido sube la mayor; uno que solo
   agrega campos opcionales sube la menor. El paquete rechaza una mayor distinta de la suya. La
   versión del esquema es independiente de la del paquete.

3. **Horarios en unidades de personas.** Los días son `lunes`, `martes`, `miercoles`, `jueves`,
   `viernes`, `sabado` y `domingo`; el período dice cuáles están habilitados. Las horas son texto
   `HH:MM`, de 24 horas. Las duraciones van en minutos. La validación exige que toda hora y toda
   duración caigan en múltiplos del bloque del período ([[0004]]) y dentro de la jornada. Los
   rangos son semiabiertos: `desde` incluido, `hasta` excluido.

4. **Identificadores.** Cada entidad lleva un `id` de texto que pone quien arma la instancia (la
   base, la planilla o el simulador). Las entidades se referencian por `id`. Los ids son únicos
   dentro de su tipo de entidad, y toda referencia tiene que apuntar a una entidad existente.

5. **Forma de la instancia.** Las claves van en español, en `snake_case` y sin tildes (`anio`).

   ```json
   {
     "version_esquema": "1.0",
     "periodo": {
       "nombre": "2027-1C",
       "dias": ["lunes", "martes", "miercoles", "jueves", "viernes", "sabado"],
       "jornada": {"desde": "08:00", "hasta": "22:00"},
       "bloque_minutos": 30,
       "turnos": [{"nombre": "manana", "desde": "08:00", "hasta": "13:00"}]
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
   `docentes` tiene al menos uno ([[0007]]); `dictados_por_semana` vale 1 por defecto y no puede
   superar los días habilitados ([[0007]]); `alumnos` es una sola cifra, mayor que cero ([[0005]]);
   `preferencias` es solo del Proyecto B, y el A la ignora ([[0010]]); `prefijados` es opcional y
   cada campo de un prefijado también ([[0015]]).

6. **Tipos de aula alternativos (AUL-39).** Cada comisión lleva `tipos_aula_alternativos`: una
   lista de ids de tipos de aula, vacía por defecto. No tiene orden ni repetidos, y no incluye el
   `tipo_aula` requerido. Sin alternativas, el tipo es exacto ([[0009]]). Si el Proyecto B
   necesita preferir una alternativa sobre otra, se agrega un peso en una versión menor; hoy no lo
   pide ninguna decisión.

7. **Qué valida cada capa.** El JSON Schema valida la estructura: tipos, campos obligatorios,
   valores permitidos y formato de las horas. No puede validar referencias ni la grilla. Eso lo
   valida el modelo Pydantic al cargar la instancia: ids únicos, referencias existentes, horas y
   duraciones alineadas a la grilla y dentro de la jornada, `desde` antes que `hasta`, la teoría de
   una práctica, los dictados contra los días habilitados, y que un prefijado apunte a un dictado
   que exista y a un aula del tipo requerido o alternativo. La coherencia de un prefijado con la
   capacidad, la no disponibilidad del docente y los bloqueos del aula ([[0015]]) se agrega con
   `solve` (AUL-44), porque cruza más de una entidad y no cambia el esquema.

8. **Configuración y solución.** La configuración de una corrida es un documento aparte de la
   instancia, como en `arquitectura.md` §3.1: `modelo` (`A` o `B`), `limite_tiempo_segundos`,
   `semilla`, y los pesos y el tope de sobrecupo del Proyecto B. Ninguno lleva valor por defecto
   en el código hasta que su decisión lo fije con procedencia ([[0010]]; AUL-37 para el límite,
   AUL-51 para pesos y tope). La solución lleva `version_esquema`, `estado` (`FACTIBLE`,
   `INFACTIBLE` o `TIEMPO_AGOTADO`), `asignaciones` (comisión, número de dictado, día, `desde`,
   `hasta` y aula), `violaciones` (solo B), `diagnostico` (solo A infactible) y `metricas` (tiempo
   y valor objetivo por nivel). La forma de cada violación la fija AUL-50 y la del diagnóstico la
   Fase 3. Hasta entonces quedan con una forma mínima (restricción, entidades y magnitud, para la
   violación; lista de restricciones, para el diagnóstico), que esas tareas pueden cambiar con una
   versión menor si solo agregan campos.

9. **Lo que se toma de la ITC2019.** Instancia y solución en documentos separados; entidades con
   id y referencias por id; las aulas con sus bloqueos como entidad propia; la solución como lista
   plana de asignaciones de un dictado a un horario y un aula. Lo que no se toma: el formato XML,
   el tiempo como cadenas de bits, las penalidades por opción de horario o aula y el catálogo de
   restricciones de distribución.

10. **Fuera del esquema.** Las excepciones de aula por semana, la cantidad de semanas y la fecha
    de inicio del período ([[0008]]) no entran al solver: las resuelve la API después de la
    corrida. La corrida y su historia son de la base (PPS).

## Consecuencias

**A favor:** el caso acotado y las instancias simuladas se escriben y se revisan a mano; la PPS
exporta sin convertir horarios; el esquema publicado y el código no se pueden desalinear; los
huecos de AUL-50, AUL-51 y la Fase 3 están marcados y no frenan a nadie.

**En contra:** el modelo y el validador convierten horas a bloques cada uno, y la conversión tiene
que vivir en los modelos de datos para no romper la regla 3 de la [[0026]]. La validación que no
expresa el JSON Schema solo la tiene quien usa el paquete de Python: un consumidor en otro lenguaje
puede armar un documento que pasa el esquema y falla al cargarse.

**Riesgo abierto:** que la Fase 6 decida que la grilla o los turnos son por carrera y no por
período (señales activadas de la [[0004]] y la [[0011]]). **La señal:** que esa definición se tome.
Ahí `periodo` cambia de forma y la versión sube la mayor, porque las instancias anteriores dejan de
ser válidas.
