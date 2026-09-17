# Plantilla y procedimiento

## Procedimiento

0. **Escribirlo antes de codificar la decisión.** Escrito después deja de ser una decisión
   documentada y pasa a ser la justificación de lo que ya se hizo. Si la decisión aparece a mitad
   de la implementación —y es lo habitual—, se para, se escribe y se sigue.
1. **Numerar** con la búsqueda de `SKILL.md` ("Antes de escribir cualquier registro"): el
   siguiente que no esté ni en el directorio ni citado en el repo. Cuatro dígitos. Archivo
   `NNNN-titulo-en-kebab-case.md`.
2. **Escribir el archivo** con la plantilla de abajo. Formato fijo: Contexto → Decisión →
   Consecuencias.
3. **Agregar la fila al índice**, en orden, con su estado.
4. **Cerrar los cruces en los dos sentidos** y actualizar el estado de los afectados en el índice.
5. **Propagar a los documentos vivos.** Si cambia una regla del dominio, va al documento de
   gestión en lenguaje llano; si cambia estructura o contrato, al técnico con el enlace.
6. **Revisar el archivo de contexto del proyecto.** Si la decisión agrega o cambia una regla de
   las que no se pueden romper, actualizar esa sección.

## Plantilla

```markdown
# NNNN — Título afirmativo de la decisión

**Estado:** Aceptada — AAAA-MM-DD
<!-- Si corresponde, y SIEMPRE con su recíproca en el afectado. Las tres situaciones y cuál
     corresponde a cada caso están en el SKILL.md:
**Modifica:** NNNN — en una línea, qué le cambia.
**Reemplaza a:** NNNN
**Implementa de otro modo:** NNNN — la regla sigue en pie, cambia cómo se logra.
-->

## Contexto

Qué situación obliga a decidir. Qué dice —o qué calla— el material previo. Cuál es el problema
concreto si no se decide nada.

Las alternativas que se evaluaron, con su punto fuerte y por qué no se eligieron:

- **Alternativa A** — qué proponía, qué costaba, por qué se descarta.
- **Alternativa B** — ídem.

## Decisión

Qué se decidió, en presente y sin condicionales. Los números, escalas o umbrales concretos si los
hay, y **de dónde sale cada uno**: un ancla del enunciado, una deducción, un criterio propio.

## Consecuencias

**A favor:** qué se gana, qué queda más simple, qué habilita más adelante.

**En contra:** qué se pierde o qué se vuelve más rígido. Qué caso queda peor atendido.

**Riesgo abierto:** qué podría obligar a revisar esta decisión, y **qué señal lo indicaría**.
```

## El índice

Una tabla, en un `README` junto a los archivos, con la política arriba:

```markdown
| # | Decisión | Estado |
|---|---|---|
| [0001](0001-....md) | Título de la decisión | Aceptada |
| [0005](0005-....md) | Otra | Aceptada — modificada por 0011 |
| [0011](0011-....md) | Otra más | Aceptada — modifica 0005, 0006 |
```

La columna Estado es lo que permite ver, de un vistazo, cuáles siguen vigentes tal como se
escribieron y cuáles hay que leer junto con otra.

## Sobre el título

Afirmativo y en presente: **qué se decidió**, no qué se discutió ni qué se evaluó.

| Bien | Mal |
|---|---|
| "La antigüedad se deriva de la fecha de ingreso" | "Cómo calcular la antigüedad" |
| "El token no transporta permisos" | "Análisis de estrategias de autenticación" |
| "Los datos de prueba no se aplican en producción" | "Datos de prueba" |

El título se lee en el índice, y el índice es lo que alguien recorre buscando si una decisión ya
fue tomada. Un título que no afirma nada obliga a abrir el archivo para saber de qué se trata.

## Sobre los números

Cuando la decisión fija un número —un peso, un tope, un margen, un piso— el registro tiene que
decir **de dónde sale**. Las tres procedencias legítimas:

- **Ancla del enunciado o del cliente:** "el material fija secundario técnico = 4 puntos".
- **Deducción a partir de un ancla:** "de ese 4 sale la escala completa con paso constante".
- **Criterio propio, declarado como tal:** "se elige 1 escalón porque más de uno ya es un perfil
  que nadie mueve de su puesto real".

Lo que no es legítimo es un número sin procedencia. Si no se puede escribir de dónde sale, la
decisión todavía no está tomada: está postergada con un valor puesto.
