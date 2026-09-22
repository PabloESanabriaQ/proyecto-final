from typing import Literal

from pydantic import BaseModel


class Salud(BaseModel):
    estado: Literal["ok"]
    version_api: str
    version_solver: str
