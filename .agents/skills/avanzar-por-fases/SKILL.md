---
name: avanzar-por-fases
description: Use when planning or advancing a multi-phase project, closing a phase, or deciding what to build next — al armar un roadmap, al arrancar o cerrar una fase, o cuando el avance de un proyecto largo se vuelve difícil de mostrar o de retomar.
---

# Avanzar por fases

## Principio

**Una fase es una rebanada vertical que se puede demostrar sola, y no está terminada hasta que
la documentación que deja también lo está.**

Partir el trabajo en capas —"primero toda la base de datos, después toda la API"— produce meses
sin nada que mostrar y una integración final donde aparecen todos los problemas juntos. Partirlo
en rebanadas produce, en cada corte, algo que alguien puede usar y criticar.

## Cuándo usarla

- Proyectos de varias semanas o meses con un alcance que se puede ordenar.
- Trabajos que hay que defender, entregar o retomar después de un tiempo.
- Cuando cuesta responder "¿en qué estamos?" sin leer el código.

**Cuándo no:** tareas de un día, exploraciones donde el objetivo es aprender algo y descartar el
código, o correcciones puntuales sobre algo ya cerrado.

## La fase

Cada fase se define por **qué permite hacer que antes no se podía**, no por qué componentes toca.

| Bien | Mal |
|---|---|
| "Ver el estado de un turno" | "La capa de persistencia" |
| "Recibir candidatos filtrados, sin puntaje todavía" | "El módulo de recomendación" |

Tres reglas que hacen que el orden funcione:

1. **Cada fase se apoya en la anterior y es demostrable sola.** Si no se puede mostrar
   funcionando, no es una fase: es media fase.
2. **Se entrega la versión simple antes de invertir en la compleja.** Una fase que filtra
   candidatos sin puntuarlos vale la pena por sí sola: valida el circuito completo antes de
   gastar en la fórmula. Si el circuito estaba mal pensado, se descubre ahí y no después.
3. **El alcance excluido se escribe.** Lo que queda afuera del proyecto, y por qué, se anota
   junto al roadmap. Sin eso, todo pedido nuevo parece razonable.

## Los casos borde se nombran antes de programar

Antes de escribir código de la fase, se listan los casos borde que esa fase tiene que sostener:
el registro sin relación, el período sin datos, el valor en cero, el que rompe la regla general.

Esa lista es el contrato de la fase. Al cerrar, **cada caso borde tiene un test que lo nombra**.
"Está cubierto indirectamente por otro test" significa que nadie va a saber que se rompió cuando
se rompa.

## El cierre

Una fase no termina cuando compila. Termina cuando pasa su checklist **y** la documentación quedó
al día. Lo segundo no es un trámite: escrito al final, de memoria, sale genérico y no sirve para
defender nada.

**REQUIRED:** el detalle está en [cierre-de-fase.md](cierre-de-fase.md) — el checklist, la regla
de la evidencia y la tabla de excusas que aparecen justo cuando la fase "ya está".

La regla que sostiene todo el ritual: **sin la salida pegada, no hay verificación.** "Lo corrí
hace un rato y pasaba" no es haber verificado.

## Los documentos que la fase deja

Dos documentos vivos, **dos públicos distintos**, actualizados al cerrar cada fase. Ver
[documentos-vivos.md](documentos-vivos.md) para la estructura y qué va en cada uno.

- **Nivel gestión** — qué puede hacer el usuario que antes no podía. Sin jerga, sin nombres de
  clases. Es lo que se lee para evaluar el trabajo.
- **Nivel técnico** — modelo, interfaces, decisiones que vale la pena defender, deuda anotada.
  Es lo que lee quien se suma al proyecto.

Son dos porque los públicos son dos. Un solo documento termina siendo malo para ambos.

## El archivo de contexto es un puntero, no un registro

El archivo que lee la herramienta al abrir el proyecto (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md` o equivalente)
apunta al próximo paso y a dónde está cada cosa. **El estado de avance no se lleva ahí**: vive en
el informe. Un hecho, un solo lugar. Si está en dos, uno de los dos va a quedar viejo y no se
sabrá cuál.

**Si el usuario pide explícitamente llevar el estado en el archivo de contexto:** se hace como lo
pide, y en la misma respuesta se avisa en una línea que ahora hay dos lugares que actualizar al
cerrar cada fase. Desde ese momento, el cierre actualiza los dos.

## Errores frecuentes

| Error | Qué pasa |
|---|---|
| Fases por capa en vez de por funcionalidad | Nada demostrable hasta el final, y todos los problemas juntos en la integración |
| Actualizar los documentos "todos juntos al final" | Escritos de memoria salen genéricos; es el trabajo que se presenta, no un trámite |
| Cerrar con un caso borde sin test nombrado | La fase siguiente asume esos datos; la deuda se paga con el esquema ya cargado |
| Declarar verde sin pegar la salida | La mitad de las veces algo cambió desde la última corrida |
| Llevar el estado en dos lugares sin que el usuario lo pida | Uno queda viejo y nadie sabe cuál |
| No escribir lo que queda afuera | Todo pedido nuevo parece razonable y el alcance se corre solo |

Las excusas que aparecen justo cuando la fase "ya está", y qué significa cada una, están en
[cierre-de-fase.md](cierre-de-fase.md).
