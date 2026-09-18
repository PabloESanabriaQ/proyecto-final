# Marco reglamentario

> Qué nos aplica del Reglamento de Proyecto Final de ISI (Resol. C.Esc.Ing. y Cs.Amb.
> N.º 12/2023, [`reglamento-proyecto-final-resol-12-2023.pdf`](reglamento-proyecto-final-resol-12-2023.pdf))
> y cómo lo cumplimos. El reglamento manda; este documento es nuestra lectura de él. Si algo acá
> contradice al PDF, está mal acá.
>
> **Última actualización:** 2026-09-16.

## 1. Modalidad y equipos

- **Modalidad:** "Proyecto de Desarrollo de Software o Producto Tecnológico innovador" (§3, §4).
- **Equipos de hasta dos personas** de la misma carrera; más exige autorización de la Comisión
  de Carrera (§5.a). Somos tres en Proyecto Final más una en PPS (que se rige por su propio
  reglamento). Por eso el trabajo se presenta como **dos Proyectos Finales**:

  | Proyecto | Integrantes | Propuesta |
  |---|---|---|
  | **A** — Factibilidad bajo restricciones duras | 1 persona | [`propuestas/proyecto-a.md`](propuestas/proyecto-a.md) |
  | **B** — Relajación de restricciones y calidad de solución | 2 personas | [`propuestas/proyecto-b.md`](propuestas/proyecto-b.md) |

  Decisión [0020](decisiones/0020-el-trabajo-se-presenta-como-dos-proyectos-finales-en-paralelo-sobre-una-base-comun.md).
  Los dos comparten dominio, instancia, API y frontend ([0002](decisiones/0002-el-trabajo-se-divide-en-proyecto-a-duras-y-proyecto-b-relajacion.md))
  y **cada uno tiene que ser defendible solo**: su informe muestra su contribución propia; la
  base común se declara como tal en ambos.

## 2. La propuesta (§5.a)

Cada proyecto presenta por Mesa de Entrada una propuesta con: tema, alumnos, Profesor Guía (y
Asesor si hay) con CV resumido y notas de aceptación, descripción, objetivo general y
específicos, alcance y limitaciones, cronograma **de no más de un año**, y lugar de desarrollo.
La Comisión de Carrera la evalúa y el Consejo de Escuela la protocoliza.

**Lo que esto nos impone:**

- **El contenido del informe "nunca podrá ser distinto a la propuesta aprobada"** (§9.1). Todo
  cambio de alcance después de la aprobación va por escrito, fundamentado, del Profesor Guía a
  la Comisión. En nuestros términos: **una decisión que cambie el alcance de un proyecto después
  de aprobada su propuesta se registra en `decisiones/` y además se comunica a la Comisión**; no
  alcanza con el registro. Las tablas "Fuera de alcance" de `plan-de-fases.md` y de cada
  propuesta tienen que coincidir.
- Falta definir **Profesor Guía** (y si conviene un Profesor Asesor en optimización). Es
  requisito de la propuesta, no del código.

## 3. Plazos (§9.2.a)

| Hito | Plazo |
|---|---|
| Cronograma de la propuesta | ≤ 12 meses |
| Presentación del informe | ≤ 18 meses desde la aprobación de la propuesta |
| Prórroga (con aval del Profesor Guía, autoriza la Comisión) | 6 meses, una sola vez |
| Entrega de 3 copias al Comité Evaluador | ≥ 20 días hábiles antes de la defensa |
| Correcciones del Comité | hasta 15 días hábiles antes de la defensa |

Los cronogramas de las propuestas están en meses relativos a la aprobación (M1 = primer mes
después de aprobada), porque la fecha de aprobación no depende de nosotros.

## 4. El informe final (§9.1.a y Anexo)

Estructura mínima y en este orden: páginas preliminares (tapa, resumen ≤ 300 palabras,
dedicatoria opcional, índice, índice de figuras y tablas), cuerpo con **Introducción** (el
problema), **revisión de la literatura / antecedentes**, **metodología**, **resultados y
conclusiones** (el último capítulo se llama "Conclusiones"), bibliografía, anexos.

Formato: A4, 80 g, una cara; márgenes 4 cm derecha, 2,5 cm superior e inferior (el izquierdo
está cortado en la copia escaneada: confirmar); interlineado 1,5; 6 pt entre párrafos; sangría
1,2 cm; justificado; Arial 10 o Times New Roman 12; títulos en mayúscula y resaltados; citas y
bibliografía **según IEEE**; paginación arábiga al pie, centrada, desde después del índice.
Encuadernado cosido de tapa dura con los datos de tapa y lomo del anexo.

**De dónde sale cada capítulo con lo que ya tenemos:**

| Capítulo del informe | Fuente en el repo |
|---|---|
| Introducción | `informe-de-gestion.md` §"El problema", §"Qué hace" |
| Antecedentes | `aulero_estado_del_arte.pdf` §1 (ya cita en estilo numérico) |
| Metodología / diseño | `decisiones/` (cada decisión con sus alternativas es una sección de metodología), `arquitectura.md`, `plan-de-fases.md` |
| Resultados | Cierres de fase con su verificación pegada; instancias de referencia y tiempos (Fase 6); comparación A vs B (Fases 7–8) |
| Conclusiones | Se escriben al final, pero las señales de revisión de cada decisión son su punto de partida |

## 5. Derechos de autor y licencia (§8)

El informe es un documento público; la UNViMe se reserva el derecho de publicarlo. Sobre el
producto (el software), los alumnos y su director son "los legítimos propietarios de cualquier
producto, derivado, beneficio o resultado" en la proporción que acuerden. Por eso el repositorio
público **no lleva licencia hasta que se acuerde con el Profesor Guía**
([0021](decisiones/0021-el-codigo-no-lleva-licencia-hasta-acordarla-con-el-profesor-guia.md)):
sin licencia, todos los derechos quedan reservados.

## 6. Roles (§4, §6)

- **Profesor Guía:** dirige, fija fechas de asesoría, controla el cronograma, decide por escrito
  si el alcance mínimo quedó satisfecho para presentar el informe. No integra el Comité
  Evaluador pero participa de la defensa.
- **Profesor Asesor:** especialista en la temática; puede ser de otra universidad. Conviene
  evaluar uno en optimización / investigación operativa para ambos proyectos.
- **Comité Evaluador:** docentes de la Escuela; evalúa presentación y defensa.

## 7. Lo que el reglamento no cubre y decidimos nosotros

- La persona de PPS: reglamento de PPS, no este. Su porción está delimitada en la decisión
  [0012](decisiones/0012-el-solver-es-un-paquete-python-independiente-de-la-api-y-la-base.md).
- La convivencia de dos Proyectos Finales en un mismo repositorio: cada informe cita el commit
  o *tag* del repo que corresponde a su entrega, y la autoría por archivo sale del historial de
  git. Módulos compartidos (`solver/aulero_solver/instancia.py`, `validador.py`, `cli.py`) se
  declaran "base común" en ambos informes.

## 8. Pendientes que dependen de la institución

| Pendiente | Quién lo destraba |
|---|---|
| Profesor Guía y, si hay, Asesor de cada proyecto (con notas de aceptación) | El equipo con la Escuela |
| Fecha de presentación de las propuestas (fija M1 de cada cronograma) | Mesa de Entrada / Comisión |
| Confirmar el margen izquierdo del formato (ilegible en la copia) | Escuela |
| Rangos reales de turnos, tope de sobrecupo, pesos (datos de secretaría académica, decisiones 0010 y 0011) | Secretaría académica |
