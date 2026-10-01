# Racionalizaciones

Las excusas de abajo son textuales de las corridas de baseline y GREEN
([verificacion.md](verificacion.md)): son las que un agente con contexto fresco realmente usó para
saltear una regla de [`docs/convenciones.md`](../../../docs/convenciones.md) §7, no las que
imaginamos que usaría.

## Excusas

| Excusa | Realidad |
|---|---|
| "Las subtareas están todas listas, cierro la Historia" | El merge es la puerta. Sin merge, nadie revisó nada |
| "El trabajo parcial existe; dejo la subtarea *En curso* y arranco la otra" | Dos *En curso* dicen que perdiste el hilo. Devolvela a *Por hacer* con un comentario que diga qué falta |
| "El PR se cerró sin mergear; la vuelvo a *En curso* para que no muestre falso progreso" | El PR puede reabrirse, y retroceder borra lo que alguien ya leyó. Avisá |
| "Una subtarea por caso borde, así no se olvida ninguno" | El contrato de un caso borde es un test que lo nombra (§5). Veinte subtareas no se leen |
| "Jira no responde, paro hasta poder registrarlo" | Jira nunca bloquea el trabajo. Decí qué falta y seguí |

## Red flags

- "ya terminé, después muevo Jira"
- "la Historia se cierra sola cuando cierren las subtareas"
- "dejo la subtarea *En curso* que total vuelvo"
- "esto es muy chico para una issue"
