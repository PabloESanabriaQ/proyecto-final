# 0013 — El stack es FastAPI en capas, React con Vite y TypeScript, y PostgreSQL

**Estado:** Aceptada — 2026-09-16

## Contexto

`docs/AULERO.md` fija React para el frontend, FastAPI para el backend y Python para CP-SAT, y pide
"una arquitectura común y recomendada" para cada uno. PostgreSQL aparecía solo en el Anexo A del
estado del arte y el equipo lo confirmó. Faltaba fijar la organización interna de cada parte, que
es lo que cuatro personas necesitan para no armar cuatro estructuras distintas.

Alternativas evaluadas:

- **Django + Django REST Framework** — más batería incluida (admin, auth). Se descarta porque el
  equipo ya eligió FastAPI y el proyecto es principalmente una API sobre un motor, no un CRUD
  grande.
- **SQLite en desarrollo, PostgreSQL en producción** — se descarta porque el dominio es
  fuertemente relacional y las diferencias entre motores aparecen justo en lo relacional
  (restricciones, tipos). Un solo motor en todos los entornos.
- **Next.js / Remix** para el frontend — se descarta porque no hay renderizado en servidor que
  justificar; el frontend es una SPA contra una API.
- **JavaScript sin tipos** — se descarta por el tamaño del equipo y la duración del proyecto.

## Decisión

- **Backend:** FastAPI en Python, organizado en capas: `routers` (HTTP), `schemas` (Pydantic,
  contratos de la API), `services` (casos de uso), `repositories` (acceso a datos con SQLAlchemy),
  `models` (tablas). Migraciones con Alembic. Ejecución del solver como tarea en segundo plano
  desde un servicio (mecanismo a fijar en la Fase 4).
- **Frontend:** React con Vite y TypeScript en modo estricto, organizado por *features*
  (`features/<nombre>/` con sus componentes, hooks y llamadas a la API), estado de servidor con
  TanStack Query, enrutamiento con React Router.
- **Base de datos:** PostgreSQL en todos los entornos, levantado con Docker Compose en
  desarrollo.
- **Solver:** paquete Python separado según [[0012]].
- **Repositorio:** monorepo con `backend/`, `frontend/`, `solver/` y `docs/`.

La estructura concreta de directorios está en `docs/arquitectura.md`.

## Consecuencias

**A favor:** estructuras conocidas y documentadas para cada tecnología; la capa `services` es el
único lugar que habla con el solver; TypeScript estricto atrapa errores de contrato con la API.

**En contra:** tres entornos de herramientas (Python backend, Python solver, Node) que hay que
tener instalados; Docker necesario para la base.

**Riesgo abierto:** que la separación en capas del backend resulte excesiva para el tamaño real
de la API. **La señal:** servicios que solo reenvían al repositorio sin lógica propia en la mayoría
de los casos. Ahí se simplifica (servicio y repositorio en uno) y se registra.
