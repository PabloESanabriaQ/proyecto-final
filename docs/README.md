# Documentación — Aulero UNViMe

| Documento | Para quién | Qué es |
|---|---|---|
| [`informe-de-gestion.md`](informe-de-gestion.md) | Quien evalúa o usa el sistema | Documento vivo, nivel gestión: problema, qué hace, decisiones en lenguaje llano, **estado de avance**, fuera de alcance. |
| [`arquitectura.md`](arquitectura.md) | Quien se suma o defiende el proyecto | Documento vivo, nivel técnico: stack, modelo, interfaces, tests, cómo correrlo, deuda. |
| [`plan-de-fases.md`](plan-de-fases.md) | El equipo | Fases, historias de usuario para Jira, casos borde, **definiciones pendientes por fase**, fuera de alcance. |
| [`decisiones/`](decisiones/README.md) | El equipo | Registro de decisiones de diseño, una por archivo (17 al 2026-09-16). **Cuando contradice a cualquier otro documento, manda el registro.** |
| [`convenciones.md`](convenciones.md) | El equipo | Ramas, las dos puertas de revisión, linters por parte, accesibilidad, tests. |

## Material histórico

Estos documentos son el punto de partida del proyecto. **No son el estado vigente**: donde
contradigan al registro de decisiones, manda el registro. Se conservan porque documentan el
estado del arte, la definición original del problema y el razonamiento inicial del equipo.

| Documento | Qué es | Qué quedó superado |
|---|---|---|
| [`aulero_estado_del_arte.pdf`](aulero_estado_del_arte.pdf) | Estado del arte, definición del problema (R1–R11, B1–B3), seis definiciones pendientes, Anexo A con tecnologías y roles. Versión preliminar, agosto 2026. | Las seis definiciones pendientes están resueltas (decisiones 0001, 0004, 0005, 0006, 0008, 0010). El Anexo A proponía algoritmo genético y RL: descartados (0003). El reparto de roles cambió (0012). |
| [`AULERO.md`](AULERO.md) | Notas de definición del equipo (2026-09): stack, división en Proyecto A/B, pipeline, pedidos de plan y reglas. | Todo lo pedido está hecho en los documentos de arriba. La descripción del juguete sigue vigente hasta que existan sus datos (Fase 2). |
| [`ejemplo_inputs_aulero_unvime-1.xlsx`](ejemplo_inputs_aulero_unvime-1.xlsx) | Ejemplo de estructura de Excel de entrada. Datos ficticios. | Asumía bloque de 60 min (ahora 30, decisión 0004), una carrera por materia (ahora `Materia_Carrera`, 0006), dos columnas de alumnos (ahora una, 0005), sin dictados por semana (0007). La plantilla definitiva se hace en la Fase 1; ver `arquitectura.md` §2. |
