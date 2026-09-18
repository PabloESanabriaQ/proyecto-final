# Los dos documentos vivos

Dos documentos, **dos públicos**, actualizados al cerrar cada fase. Son dos porque los lectores
son dos: uno solo termina siendo demasiado técnico para quien evalúa y demasiado vago para quien
programa.

Cada uno declara en su encabezado **para quién es** y **cuándo se actualizó por última vez**. Sin
eso, el lector no sabe si lo que lee sigue valiendo ni si le está hablando a él.

```markdown
> Documento vivo. Se actualiza al cerrar cada fase.
> Público: <quién lo lee y para qué>. <Qué NO va acá>.
>
> **Última actualización:** AAAA-MM-DD — <en una línea, dónde está el proyecto>
```

## Documento de gestión

Para quien evalúa el trabajo, contrata, o va a usar el sistema. **Sin código, sin nombres de
clases, sin jerga de framework.**

Se escribe en términos de **qué problema se resuelve** y **qué puede hacer alguien ahora que antes
no podía**.

| Sección | Qué va |
|---|---|
| El problema | Qué cuesta hoy hacerlo sin el sistema. Concreto, con el costo nombrado. |
| Qué hace | En un párrafo, sin detalle de implementación. |
| Quiénes lo usan | Los roles reales, y qué hace cada uno. |
| Decisiones de negocio | Las que no estaban definidas y hubo que resolver, en lenguaje llano y con el porqué. |
| Estado de avance | Qué permite hacer hoy, fase por fase. |
| Fuera de alcance | Lo que no hace y no va a hacer en esta versión. |

**La prueba de que está bien escrito:** alguien que no programa lo lee entero y entiende qué
compró.

## Documento técnico

Para quien se suma al proyecto, o para defenderlo técnicamente.

| Sección | Qué va |
|---|---|
| Stack y arquitectura | Qué se usa y cómo está organizado. |
| Modelo | Las entidades y sus relaciones, con las decisiones que las explican enlazadas. |
| Interfaces | Qué expone el sistema y para qué. |
| Estrategia de tests | Qué se prueba con qué, y por qué así. |
| Cómo correrlo | Los comandos exactos, sin pasos implícitos. |
| Estado por fase | Qué entró en cada una. |
| **Deuda técnica anotada** | Cada una con **la señal que indicaría que hay que pagarla**. |

## La deuda se anota con su señal

Una lista de deuda sin criterio de disparo es una lista de culpas. Cada punto lleva **qué la
haría urgente**:

> El listado carga las relaciones de a una. Con el volumen actual es irrelevante. Si la lista
> crece, la salida es un fetch conjunto. **La señal es que el listado tarde en abrir.**

Y cuando una deuda se salda, no se borra: se tacha y se dice dónde se resolvió. El registro de
que existió explica decisiones posteriores.

## Qué NO va en estos documentos

El **estado de avance** va acá, y sólo acá. El archivo de contexto del proyecto —el que lee la
herramienta al abrir— apunta al próximo paso y a dónde está cada cosa, pero no lleva la tabla de
fases. Un hecho en dos lugares es un hecho que va a quedar viejo en uno de los dos.

Si el usuario pidió explícitamente la tabla también en el archivo de contexto, se respeta el
pedido (ver `SKILL.md`) y el cierre de cada fase actualiza las dos copias.

## Por qué al cerrar cada fase y no al final

Escritos al final, se escriben de memoria. Sale un resumen genérico que no distingue lo que costó
decidir de lo que fue obvio, y las razones —que son lo único que sirve meses después— ya se
olvidaron. Escribirlos en el momento cuesta veinte minutos por fase y es lo que después se
presenta.
