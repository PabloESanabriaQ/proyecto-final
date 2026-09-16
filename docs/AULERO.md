> ⚠ MATERIAL HISTÓRICO — no es el estado vigente. Se conserva porque son las notas de definición
> con las que arrancó el proyecto (septiembre 2026). Donde esto contradiga un registro de
> decisión, **manda el registro** (`docs/decisiones/`). Lo que acá se pide está hecho en
> `docs/plan-de-fases.md`, `docs/convenciones.md` y `docs/arquitectura.md`; ver `docs/README.md`.

# Definiciones concretas

1. Tenemos el problema definido,
2. Debemos dividirlo en "2 proyectos". Seguirá siendo el mismo, pero las hipótesis de partida serán distintas.
3. Utilizaremos React para el frontend, FastAPI para el backend y para utilizar CP-SAT también utilizaremos Python.
4. Utilizando las skills de avanzar por fases y registrar decisiones, el problema y las soluciones propuestas (CP-SAT). 


Quiero: 

1. definir reglas de codereview y accesibilidad en la web.
2. Definir un plan de trabajo con distintas fases y que cada fase esté dividida en historias de usuario que cargaremos después en jira para seguir el avance del proyecto.
3. Definir las reglas básicas para el CP-SAT de juguete, que será la partida para evaluar las restricciones duras y ver si el alcance está bien definido.
4. Sabiendo que el proyecto consta de la siguiente definición:
Definición inicial:
Excel / Formulario
      ↓
 Validación
      ↓
     BD
      ↓
Preparación para CP-SAT
      ↓
  Algoritmo
      ↓
Guardar optimización
      ↓
     BD
      ↓
    API
      ↓
   Frontend
Definición dividida en 2 grupos:

UCTP
                     │
          ┌──────────┴──────────┐
          │                     │
     Proyecto A            Proyecto B
     CP-SAT Hard           CP-SAT Soft
          │                     │
          └──────────┬──────────┘
                     │
              misma instancia
              mismo dominio
              misma API
              mismo frontend
              distintos modelos

Proyecto A: estudiar la factibilidad del UCTP bajo un conjunto de restricciones consideradas obligatorias.
Proyecto B: estudiar cómo la relajación de determinadas restricciones y su incorporación como penalizaciones permite obtener soluciones de mayor calidad cuando el problema es infactible bajo el modelo duro.


## CP-SAT de Juguete
Primer cuatrimestre de 1er y 2do año de la carrera Ing en Sistemas: 9 materias con sus respectivos profesores, comisiones, cant. aulas disponibles, los datos de las aulas (tipo, asientos, cuánto dura la clase), cant. alumnos esperada, rango horario disponible.
