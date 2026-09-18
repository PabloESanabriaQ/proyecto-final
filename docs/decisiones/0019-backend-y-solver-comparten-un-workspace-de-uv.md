# 0019 — `backend/` y `solver/` comparten un workspace de uv con un solo entorno y un solo lock

**Estado:** Aceptada — 2026-09-16

## Contexto

Son dos paquetes Python independientes por diseño ([[0012]]): el solver no puede importar la
API. Había que decidir si esa independencia se lleva también al entorno (dos `.venv`, dos locks)
o si comparten uno. Apareció al armar la Fase 0 y no estaba registrado.

Alternativas evaluadas:

- **Dos entornos separados** — refuerza la frontera: desde el solver no se *puede* importar
  FastAPI porque no está instalado. Se descarta porque duplica `uv sync`, `ruff`, `mypy` y
  `pytest` en el hook, en CI y en el README, y porque el backend necesita tener el solver
  instalado igual (lo importa), así que los dos entornos no serían simétricos.
- **Un workspace de uv** — la elegida.

## Decisión

La raíz del repo es un *workspace* de uv con miembros `backend/` y `solver/`, un solo `.venv` y
un solo `uv.lock`. La raíz depende de ambos para que `uv sync` instale todo. La frontera del
solver se garantiza con **import-linter** (`solver/` no importa `aulero_api`, `fastapi`,
`sqlalchemy` ni `alembic`), verificado en el hook, en CI y en `solver/tests/test_frontera.py`,
no por ausencia del paquete.

Ruff, pytest e import-linter se configuran una vez en el `pyproject.toml` de la raíz; mypy en
el de cada paquete, porque el backend usa el plugin de Pydantic y el solver no.

## Consecuencias

**A favor:** un comando para instalar, un lock, una configuración de herramientas; el backend
importa el solver en editable sin publicarlo.

**En contra:** la frontera es una regla verificada, no una imposibilidad física; un `import
fastapi` en el solver funciona hasta que corre el linter.

**Riesgo abierto:** que el solver se quiera publicar o correr solo (por ejemplo, en una máquina
de cómputo sin la API). **La señal:** un `pip install solver/` fuera del repo. Sigue funcionando
—`solver/pyproject.toml` es un paquete completo—, pero ahí conviene un lock propio y se revisa.
