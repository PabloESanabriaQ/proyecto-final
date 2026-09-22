"""Aulero UNViMe — API.

Organizada en capas (decisión 0013): routers → services → repositories → models. `services` es
el único lugar que llama a `aulero_solver.solve` (decisión 0012).
"""

__version__ = "0.1.0"
