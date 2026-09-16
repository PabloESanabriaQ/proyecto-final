from fastapi import APIRouter

import aulero_solver
from aulero_api import __version__
from aulero_api.schemas.salud import Salud

router = APIRouter(tags=["salud"])


@router.get("/salud", response_model=Salud)
def salud() -> Salud:
    """Confirma que la API responde y con qué versión del solver está enlazada."""
    return Salud(estado="ok", version_api=__version__, version_solver=aulero_solver.__version__)
