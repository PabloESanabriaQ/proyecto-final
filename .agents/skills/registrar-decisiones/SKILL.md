---
name: registrar-decisiones
description: Use when a project has no decision record and will outlive its authors' memory, when changing or reverting a recorded decision, when two project documents contradict each other, or when something references a decision record that does not exist — cuando hay que instalar o mantener el registro de decisiones de diseño de un proyecto.
---

# Registrar decisiones

## Principio

**El registro se instala escribiendo bien los dos primeros, no pidiendo que se escriban.**

Quien entra a un proyecto que ya tiene dos registros bien formados los imita sin que nadie se lo
pida. Quien entra a uno que no tiene ninguno resuelve bien y deja el razonamiento en un mensaje
que se evapora. La práctica la enseña el artefacto, no la instrucción.

Por eso esta skill se ocupa de **arrancar** el registro y de **mantenerlo cuando cambia**, y no de
recordar que hay que escribirlo.

## Cuándo usarla

- El proyecto **no tiene** registro de decisiones y va a durar más que la memoria de quien lo hizo.
  Es el caso principal.
- Hay que **cambiar, acotar o revertir** una decisión ya registrada.
- **Dos documentos se contradicen** y no está dicho cuál manda.
- Algo **referencia un registro que no existe**.

**Cuándo no:** proyectos de días, elecciones sin alternativa real —usar la librería estándar para
lo que la librería estándar hace— o convenciones de estilo, que van en el documento de
convenciones.

## Antes de escribir cualquier registro: el número

Se buscan los números ya citados en el repo, **antes** de elegir el nuevo:

```bash
grep -rnoE '(decisi[oó]n|ADR)[ -]?[0-9]{4}' --exclude-dir=.git .
```

El número nuevo es el siguiente que no esté **ni en el directorio ni en esa búsqueda**. Un número
citado sin archivo está ocupado: se saltea y lleva su fila `Sin documentar` en el índice (ver
sección 4). Reusarlo deja la cita apuntando a otra decisión.

## 1. Arrancar el registro

Un directorio, un archivo por decisión numerado, y un índice con **la política en la cabecera**:
qué formato tienen, que se escriben antes de codificar, y que no se editan para cambiar de opinión.

Lo que hace que la práctica prenda no es el directorio: son **los dos primeros archivos**. Elegí
las dos decisiones ya tomadas con más criterio adentro —donde hubo alternativa real y alguien
eligió— y escribilas completas. No las dos más fáciles: las dos más cargadas. Son el ejemplar que
todo el que venga después va a copiar, y se copia lo que está, no lo que se pide.

**Completas quiere decir con el razonamiento de quien decidió, no con uno reconstruido.** Si el
motivo o las alternativas de una decisión no están escritos en el repo, se le preguntan al
usuario **antes** de escribir su registro. Se procede así:

1. Se arma lo que no depende de la respuesta: el directorio, el índice con la política, y lo
   demás que pida la tarea.
2. Para cada decisión elegida, se le pregunta al usuario, en concreto: qué alternativas hubo, por
   qué se descartaron, qué se sabía que se perdía, y de dónde sale cada número.
3. Los registros se escriben con las respuestas. Lo que el usuario no sabe se escribe como "no
   quedó registrado", sin completarlo.

La anatomía, el procedimiento y de dónde puede salir legítimamente un número están en
[plantilla.md](plantilla.md).

## 2. Cuando una decisión cambia

**Se escribe una nueva y se enlazan en los dos sentidos.** Editar la vieja borra el registro de que
hubo un cambio de criterio, que suele ser la parte más informativa. Un registro revertido no se
borra nunca.

Hay **tres** situaciones, y confundir la tercera con las otras dos es el error común:

| Situación | En el nuevo | En el afectado |
|---|---|---|
| Cambia la regla, acotándola o extendiéndola | `Modifica: NNNN` | `Modificada por: NNNN` + el motivo |
| La deja sin efecto por completo | `Reemplaza a: NNNN` | `Reemplazada por: NNNN` |
| **Cambia el mecanismo; la regla sigue en pie** | `Implementa de otro modo: NNNN` | una nota al pie, y **sigue Aceptada** |

La tercera se reconoce preguntando qué ve quien consume la decisión desde afuera. Si para él nada
cambió —la garantía es la misma, se logra de otra manera—, la decisión original no se tocó.

**El cruce en un solo sentido es peor que no cruzar:** quien llega al registro viejo se lleva la
regla derogada sin enterarse.

## 3. Cuando dos documentos se contradicen

Primero, **quién dice cuál manda.** La respuesta depende de lo que hay:

- **Hay una fuente que lo resuelve** —una decisión registrada, o una indicación de quien tiene la
  autoridad, como el usuario que transmite lo que acordó con el cliente—: se registra esa
  decisión y se declara la jerarquía como se explica abajo.
- **Ninguna fuente lo resuelve:** elegir cuál manda es una decisión del usuario, no del agente.
  Los documentos **no se alinean**: se marca el conflicto en cada uno, sin cambiar lo que dicen,
  y se le pregunta al usuario cuál vale, con lo que dice cada fuente. No se escribe un registro
  que elija.

  > ⚠ EN CONFLICTO con \<otro documento\>: \<qué dice cada uno\>. Sin resolver; no avanzar sobre
  > esto hasta que se decida.

Cuando hay fuente, la jerarquía **se declara por escrito, en el documento que pierde**. Y cómo se
declara depende de quién es dueño del documento:

- **Material propio del proyecto** (especificaciones internas, notas, esquemas de arranque): se
  marca en el lugar y no se borra. Borrarlo pierde por qué existía; dejarlo sin marcar lo deja
  mintiendo en silencio.

  > ⚠ MATERIAL HISTÓRICO — no es el estado vigente. Se conserva porque \<motivo\>. Donde esto
  > contradiga un registro de decisión, **manda el registro**.

- **Documento acordado con otra parte** (un cliente, otro equipo, un área): **no se anota
  unilateralmente.** Se explica la contradicción en el registro nuevo, y la nota al documento
  ajeno se propone, no se aplica. Reescribir a espaldas de quien lo acordó borra de qué se habló.

## 4. El registro que falta

Si algo referencia un registro que no existe —un comentario en el código, otro registro, el
índice—: **no se inventa.** Reconstruir el razonamiento de otro produce un registro que parece
autoridad y no lo es.

Se deja el hueco **visible** en el índice, con una fila que lo diga:

```
| 0003 | *(referenciada en el código como política de reintentos, sin archivo)* | Sin documentar |
```

Un hueco explicado es información. Un salto mudo en la numeración es un error que nadie sabe si
es error.

## Los dos errores que vacían el registro

**Documentar sólo lo elegido.** Sin las alternativas descartadas no se entiende el criterio, y el
criterio es lo único que sirve para revisar la decisión o defenderla después.

**Consecuencias sólo favorables.** Un registro sin costo asumido es publicidad. Va también qué se
pierde y **qué señal indicaría revisar la decisión** — esa señal es lo que lo vuelve accionable en
vez de un monumento, y es lo que hace que meses después alguien sepa que le llegó el turno.

## Por qué esta skill no insiste en "escribilo antes"

Se probó. Cinco corridas con el mismo escenario bajo presión de entrega: en las cuatro donde el
repo ya tenía dos registros bien formados, se escribió el registro antes de codificar —con
alternativas, costo y señal de revisión— sin ninguna instrucción. En la única sin convención, no
quedó registro alguno: el razonamiento existió y fue bueno, pero vivió en un mensaje que
desapareció.

La falla no está en la disciplina de quien escribe. Está en que no haya nada que imitar.
