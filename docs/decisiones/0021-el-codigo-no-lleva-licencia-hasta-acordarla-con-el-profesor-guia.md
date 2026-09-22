# 0021 — El código no lleva licencia hasta acordarla con el Profesor Guía

**Estado:** Aceptada — 2026-09-16

## Contexto

El repositorio pasó a ser público el 2026-09-16 (para poder proteger `main`, ver Fase 0 en
`docs/plan-de-fases.md`). Un repositorio público sin archivo de licencia queda con todos los
derechos reservados: se puede leer, no se puede reutilizar. El Reglamento de Proyecto Final
(§8) establece que, cuando el proyecto produce tecnología, los alumnos **y su director** son los
propietarios "en la proporción que ellos acuerden", y que la UNViMe se reserva el derecho de
publicar el informe. Todavía no hay Profesor Guía designado.

Alternativas evaluadas:

- **MIT ahora** — permisiva, simple. Se descarta porque fija unilateralmente algo que el
  reglamento dice que se acuerda con el director, antes de que exista.
- **GPL-3.0 ahora** — copyleft. Se descarta por el mismo motivo.
- **Sin licencia hasta acordarla** — la elegida.

## Decisión

El repositorio no lleva archivo de licencia. El README lo dice explícitamente: código
públicamente visible, todos los derechos reservados a los autores, licencia a definir con el
Profesor Guía al presentar las propuestas. Cuando se acuerde, se agrega `LICENSE`, se
actualiza el README y se escribe la decisión que reemplaza a esta.

## Consecuencias

**A favor:** no se regala nada antes de tiempo; no hay que rehacer un acuerdo.

**En contra:** mientras tanto, nadie externo puede reutilizar el código legalmente, aunque lo
vea; si alguien quisiera contribuir desde afuera, no hay marco.

**Riesgo abierto:** que se olvide. **La señal:** la presentación de las propuestas sin licencia
acordada, o el primer pedido externo de uso. La firma de las propuestas es el momento de
cerrarlo.
