"""Punto de entrada de la aplicación FastAPI."""

from fastapi import FastAPI

import aulero_solver
from aulero_api import __version__
from aulero_api.routers import salud

app = FastAPI(
    title="Aulero UNViMe",
    version=__version__,
    description=(
        "Asignación de horarios y aulas para todas las carreras de la UNViMe. "
        f"Motor: aulero-solver {aulero_solver.__version__}."
    ),
)

app.include_router(salud.router)
