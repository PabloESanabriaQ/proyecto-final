# 0012 — El solver es un paquete Python independiente de la API y de la base de datos, y es el límite entre PPS y Proyecto Final

**Estado:** Aceptada — 2026-09-16

## Contexto

El trabajo lo hacen cuatro personas con dos encuadres académicos distintos: tres en el Proyecto
Final (optimización con CP-SAT) y una en PPS (aplicación alrededor del motor), que se aprueba de
forma independiente. `docs/AULERO.md` pide "una capa de servicio en la cual correrá todo lo de
CP-SAT para la gente que trabaja en proyecto final". Había que fijar dónde está exactamente esa
frontera, porque de eso depende que las dos partes puedan avanzar en paralelo y defenderse por
separado.

Alternativas evaluadas:

- **El solver como módulo interno de la aplicación FastAPI** — un solo paquete. Se descarta porque
  acopla el modelo a la base de datos y a la API: el equipo CP-SAT no podría iterar el modelo sin
  levantar la aplicación, y la frontera entre PPS y Proyecto Final quedaría en un directorio, no en
  un contrato.
- **El solver como microservicio separado** (HTTP propio) — máxima separación. Se descarta porque
  agrega red, despliegue y serialización para cuatro personas y un solo consumidor.
- **Paquete Python independiente, importado por la API** — la elegida.

## Decisión

El solver vive en un **paquete Python propio** (`solver/`), con estas reglas:

- **No importa nada** de la API ni de la base de datos. No conoce SQLAlchemy, FastAPI ni el
  esquema de tablas.
- **Expone una interfaz única:** `solve(instancia, configuracion) → solucion`, donde `instancia`,
  `configuracion` y `solucion` son estructuras de datos propias del paquete (modelos Pydantic),
  serializables a JSON. El formato de `instancia` y de `solucion` **lo define el equipo CP-SAT**:
  es la normalización de la entrada para CP-SAT y el formato de almacenamiento de resultados.
- Incluye el **validador independiente** de soluciones (verifica R1–R11 sobre una solución sin
  usar el solver) y una **CLI** para correr sobre archivos JSON, para desarrollar sin la web.
- Se puede correr y testear solo, con el juguete como instancia de referencia.

**Reparto de responsabilidades:**

| Equipo | Responsable de |
|---|---|
| Proyecto Final (CP-SAT) | El paquete `solver/` completo: modelos A y B, formato de instancia y de solución, validador, CLI, juguete y su documentación. |
| PPS | La aplicación: importación y validación de la entrada (Excel y formularios), base de datos, API, conversión BD ↔ instancia/solución, frontend de carga y de visualización. |

La API es el único lugar que llama a `solve`. La conversión entre tablas y estructuras del solver
es responsabilidad de la API y se prueba contra el formato publicado por el paquete.

## Consecuencias

**A favor:** los dos equipos avanzan en paralelo desde la Fase 1 con un contrato escrito; el
solver se defiende solo; el modelo se prueba con archivos, sin base de datos.

**En contra:** hay que mantener el contrato (instancia/solución) versionado y sincronizado con el
esquema de la base; un cambio en el formato es un cambio para los dos equipos.

**Riesgo abierto:** que la ejecución del solver bloquee la API (corridas de minutos). **La señal:**
que una corrida deje la web sin responder. Está previsto que la API ejecute el solver como tarea
en segundo plano (a decidir en la Fase 4, ver `docs/plan-de-fases.md`); si eso no alcanza, se
evalúa una cola de trabajos, que sería una decisión nueva y no toca este contrato.
