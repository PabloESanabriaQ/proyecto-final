"""La API levanta y responde; la base de datos no interviene todavía."""

from fastapi.testclient import TestClient

import aulero_solver
from aulero_api.main import app


def test_salud_responde_ok_con_versiones() -> None:
    with TestClient(app) as cliente:
        respuesta = cliente.get("/salud")

    assert respuesta.status_code == 200
    cuerpo = respuesta.json()
    assert cuerpo["estado"] == "ok"
    assert cuerpo["version_solver"] == aulero_solver.__version__
