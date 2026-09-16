"""El solver no importa la API (decisión 0012). Caso borde de la Fase 0: si alguien lo hace,
`lint-imports` falla.

Se planta un módulo temporal dentro del paquete y se corre la herramienta real; el módulo se
borra siempre, pase lo que pase.
"""

import subprocess
import sys
from pathlib import Path

PAQUETE = Path(__file__).resolve().parent.parent / "aulero_solver"
RAIZ = PAQUETE.parent.parent


def correr_lint_imports() -> subprocess.CompletedProcess[str]:
    # El script `lint-imports` del mismo entorno que corre los tests (`python -m importlinter`
    # no tiene punto de entrada).
    ejecutable = Path(sys.executable).parent / "lint-imports"
    return subprocess.run(
        [str(ejecutable), "--no-cache"],
        cwd=RAIZ,
        capture_output=True,
        text=True,
        check=False,
    )


def test_solver_importando_backend_hace_fallar_lint_imports() -> None:
    intruso = PAQUETE / "_intruso_de_prueba.py"
    try:
        intruso.write_text("import aulero_api  # noqa: F401\n")
        resultado = correr_lint_imports()
    finally:
        intruso.unlink(missing_ok=True)

    assert resultado.returncode != 0, resultado.stdout
    assert "BROKEN" in resultado.stdout


def test_sin_intruso_lint_imports_pasa() -> None:
    resultado = correr_lint_imports()
    assert resultado.returncode == 0, resultado.stdout
