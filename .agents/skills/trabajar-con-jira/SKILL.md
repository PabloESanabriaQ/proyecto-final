---
name: trabajar-con-jira
description: Use when working in the Aulero UNViMe repository and a branch, commit, pull request or merge touches an AUL issue; when work appears that the phase plan does not contain; or when a story is about to be split into subtasks.
---

# Trabajar con Jira

## Principio

El estado de una issue de AUL sale de un **hecho de git** —rama con clave, PR abierto, PR
mergeado—, no de lo que se dijo en la conversación.

**Las reglas están en [`docs/convenciones.md`](../../../docs/convenciones.md) §7 y acá no se
repiten.** Esto es el procedimiento: cuándo despertar, qué llamada hacer, y las cinco cosas que un
agente con contexto fresco hace mal.

## Cuándo

- Empezás a trabajar algo: rama nueva o `checkout`.
- Abrís el PR. Se mergea el PR.
- Aparece trabajo que `docs/plan-de-fases.md` no tiene.
- Vas a partir una Historia en subtareas.

## La clave de la issue

```bash
git branch --show-current | tr 'a-z' 'A-Z' | /usr/bin/grep -oE 'AUL-[0-9]+'
```

Devuelve **una clave por línea**, en orden. Cero líneas ⇒ no hay nada que hacer, sin avisar. Dos o
más ⇒ **preguntá**, no elijas. No se adivina una clave parecida, y si la clave es de un epic, la
rama está mal nombrada (§7.2, regla 5).

Si el trabajo se cerró por un merge hecho desde GitHub, la rama ya no existe: la clave sale del PR
mergeado (`gh pr list --state merged --limit 5 --json number,title,headRefName`), no de la rama.

## Llamadas

MCP de Atlassian, `cloudId: aulero.atlassian.net`.

| Para | Llamada |
|---|---|
| Ver estado y tipo antes de tocar | `getJiraIssue` |
| Mover | `transitionJiraIssue` — `21` *En curso*, `31` *En revisión*, `41` *Finalizada*, `11` *Tareas por hacer* |
| Asignar | `editJiraIssue` — **llamada aparte**: `assignee` junto a la transición devuelve 400 ("not on the appropriate screen") |
| Subtarea | `createJiraIssue` con `issueTypeName: "Subtask"` y `parent` |

**No hay borrado:** el MCP no lo expone. Una issue creada por error se corrige a mano.

## Lo que se hace mal

Las demás reglas de la §7 ya se cumplen sin leer esto; estas cuatro no (ver
[verificacion.md](verificacion.md)).

1. **El merge cierra la Historia; las subtareas no.** Aunque estén todas en *Finalizada*, la
   Historia espera el merge.
2. ***Finalizada* sale únicamente de un merge.** Ni "ya está hecho", ni "el PR está por salir".
3. **Una sola subtarea *En curso*.** Al pasar a otro paso: o finalizás la anterior, o la devolvés a
   *Tareas por hacer* (`11`).
4. **No se retrocede un estado,** ni con el PR cerrado sin mergear. Se avisa y decide la persona.
5. **Entre 2 y 6 subtareas por Historia** (§7.4, que es donde viven estos tres números). Si salen
   más de 8, decilo en vez de crearlas.

## Cuando te escuchés justificando

**REQUIRED:** si estás por saltear una de las cinco, leé
[racionalizaciones.md](racionalizaciones.md): están ahí con lo que significa cada una.
