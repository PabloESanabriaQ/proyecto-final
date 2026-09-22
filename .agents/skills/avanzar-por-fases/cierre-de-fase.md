# Cerrar una fase

Una fase no está terminada cuando compila: está terminada cuando pasa esta revisión **y** los
documentos vivos quedaron actualizados.

**Cumplir la letra a medias es no cumplir.** Una casilla que se marca "en espíritu" —el test
existe pero no cubre el caso borde, el informe se actualiza "en la próxima"— deja la fase abierta.

## 1. Verificación, con la salida a la vista

Correr la verificación completa del proyecto y **pegar la salida real**. No la de hace un rato:
la de ahora.

```
<comando de verificación completo>
→ pegar el resumen: cantidad de tests, fallas, resultado del build
```

Sin salida no hay verificación. Es la regla que más se saltea y la que más barato sale cumplir.

Revisar además:

- [ ] Cada caso borde de la fase tiene **un test que lo nombra**. Uno por caso.
- [ ] Los cambios de esquema o de contrato aplican sobre un entorno limpio **y** sobre uno que
      viene de las fases anteriores.
- [ ] Las interfaces nuevas están documentadas donde se documentan las demás.
- [ ] Ninguna violación de las convenciones del proyecto.
- [ ] Si la fase tomó una decisión de diseño no registrada, **está registrada** (ver el skill
      `registrar-decisiones`).

## 2. Documento de nivel gestión

Público: quien evalúa el trabajo. Sin código, sin nombres de clases, sin jerga de framework.

- [ ] Marcar la fase en la tabla de estado y actualizar la fecha del encabezado.
- [ ] En una o dos frases: **qué capacidad nueva tiene el sistema** que antes no tenía, contada
      desde quien lo usa.
- [ ] Si la fase cambió una regla del dominio, explicarla en lenguaje llano y decir por qué se
      eligió así.
- [ ] Actualizar el ejemplo narrado de punta a punta, si la fase lo hizo avanzar.

## 3. Documento de nivel técnico

Público: quien se suma al proyecto, o la defensa técnica del trabajo.

- [ ] Modelo, tablas o módulos nuevos.
- [ ] Interfaces nuevas: qué son y para qué sirven.
- [ ] Enlace a las decisiones que la fase aplicó o creó.
- [ ] Marcar la fase y actualizar la fecha.
- [ ] Cobertura de tests de la fase y las decisiones técnicas que valga la pena defender.
- [ ] **La deuda que la fase deja abierta**, con la señal que indicaría que hay que pagarla.

## 4. Un commit por fase

Con un mensaje que la identifique y diga qué entra:

```
Fase N — Nombre de la fase

- Qué se agregó
- Qué decisión se aplicó
- Tests: los casos borde cubiertos
```

## 5. Handoff

El mensaje final al usuario lleva estas cuatro líneas, todas:

```
Funciona: <qué capacidad quedó andando>
Abierto: <qué falta, o "nada">
Decisiones: <registrada en X | ninguna nueva | tomada sin registrar: cuál y por qué>
Sigue: <la fase siguiente, o lo que destraba esta>
```

## Si la fase no se puede cerrar en esta sesión

Pasa cuando algo del paso 1 no se cumple y no se resuelve ahora: un caso borde sin regla
definida, un test que falta, una decisión que es del usuario. La fase queda **en curso**, y se
deja así:

1. **Commit del avance**, con el estado en el título y lo que falta en el cuerpo:
   ```
   Fase N (en curso) — Nombre de la fase

   - Qué se agregó
   - Tests: los casos borde cubiertos
   - Falta para cerrar: <qué, y qué lo destraba>
   ```
   Al cerrar, el commit `Fase N — Nombre` completa la fase.
2. **Los dos documentos actualizados con la fase "en curso"**: qué permite hoy y qué queda
   pendiente, cada uno en su lenguaje. El informe de gestión nunca muestra la fase como hecha.
3. **Handoff** con las cuatro líneas; en `Sigue:` va lo que destraba la fase.

Una regla de negocio que no está definida es del usuario: se propone una opción con su porqué,
no se implementa.

## Excusas y realidad

Estas aparecen justo cuando la fase "ya está". Todas significan que sigue abierta.

| Excusa | Realidad |
|---|---|
| "Compila y los tests pasan, los informes los actualizo al final" | Escritos al final se escriben de memoria y salen genéricos. Son la presentación del trabajo. |
| "Esta fase no cambia el informe de gestión" | Si no agregó ninguna capacidad visible, o no está terminada, o no era una fase. |
| "El caso borde está cubierto indirectamente" | Cubierto indirectamente = nadie sabe que se rompió cuando se rompa. Un test nombrado por caso. |
| "El test de integración lo agrego en la fase que viene" | La fase siguiente asume estos datos. La deuda se paga con el esquema ya cargado. |
| "Esta decisión es obvia, no amerita registrarla" | Obvia hoy, inexplicable dentro de tres meses. Si hubo alternativa descartada, hay decisión que registrar. |
| "La verificación la corrí hace un rato y pasaba" | Correrla de nuevo y pegar la salida. |
| "Falta un detalle menor, lo dejo anotado y cierro" | Anotarlo en la deuda es válido; cerrar sin anotarlo, no. |

## Parar y volver al paso 1

- Marcar una casilla sin haber abierto el archivo que menciona.
- Escribir "todo pasa" sin la salida a la vista.
- Actualizar un solo documento de los dos.
- Commitear como `Fase N — …`, sin "(en curso)", antes de terminar los pasos 1 a 3.
- Decir "cerrada" y en la misma frase "sólo falta…".
