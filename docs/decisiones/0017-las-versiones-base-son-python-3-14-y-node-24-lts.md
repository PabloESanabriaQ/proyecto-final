# 0017 — Las versiones base son Python 3.14 y Node 24 LTS

**Estado:** Aceptada — 2026-09-16

## Contexto

Cuatro personas con máquinas distintas y tres entornos de herramientas (backend, solver,
frontend). Sin una versión fijada, cada uno instala lo que tiene y los errores aparecen en CI o
en la máquina de otro. Había que elegir antes de la Fase 0, que arma los esqueletos.

Datos verificados el 2026-09-16:

- Python: la última versión estable es **3.14** (3.14.7). 3.15 no fue publicada. OR-Tools
  9.15.6755, la última en PyPI, publica *wheels* para CPython 3.10 a 3.14.
- Node: **24** es el LTS activo (LTS desde 2025-10-28, mantenimiento desde 2026-10-20, fin de
  soporte 2028-04-30). 26 entra en LTS el 2026-10-28. 22 está en mantenimiento hasta 2027-04.

Alternativas evaluadas:

- **Python 3.13** — un año más de rodaje; se descarta porque 3.14 tiene soporte oficial de
  OR-Tools y no hay motivo para arrancar un proyecto nuevo una versión atrás.
- **Node 26** — LTS en seis semanas y soporte hasta 2029; se descarta como base porque hoy no es
  LTS. Subir de 24 a 26 cuando lo sea es cambiar un archivo.
- **Node 22** — se descarta por estar ya en mantenimiento.

## Decisión

- **Python 3.14** para `backend/` y `solver/`. Se fija en `.python-version` (o `mise.toml`) y en
  `requires-python = ">=3.14,<3.15"` de cada `pyproject.toml`.
- **Node 24** para `frontend/`. Se fija en `.nvmrc` (o `mise.toml`) y en `engines.node` del
  `package.json`.
- CI usa exactamente esas versiones. No se prueba contra otras.

## Consecuencias

**A favor:** un solo entorno que reproducir; OR-Tools con soporte oficial; Node con soporte hasta
2028.

**En contra:** Node 24 entra en mantenimiento en octubre de 2026; en algún momento del proyecto
convendrá pasar a 26.

**Riesgo abierto:** una dependencia sin soporte para 3.14 (más probable en el backend que en el
solver). **La señal:** una instalación que falle por falta de *wheel* para cp314. Ahí se evalúa
esa dependencia antes que bajar de versión. Para Node, la señal de subir a 26 es que Vite, ESLint
y TypeScript lo soporten en sus versiones estables y 26 sea LTS.
