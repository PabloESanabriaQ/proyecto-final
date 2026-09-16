"""Verifica que el entorno del solver funciona: el paquete importa y CP-SAT resuelve.

No prueba ninguna regla del dominio; eso empieza en la Fase 2.
"""

from ortools.sat.python import cp_model

import aulero_solver


def test_el_paquete_expone_su_version() -> None:
    assert aulero_solver.__version__


def test_cp_sat_resuelve_un_modelo_trivial() -> None:
    modelo = cp_model.CpModel()
    x = modelo.new_int_var(0, 10, "x")
    y = modelo.new_int_var(0, 10, "y")
    modelo.add(x + y == 10)
    modelo.add(x - y == 4)

    solver = cp_model.CpSolver()
    estado = solver.solve(modelo)

    assert estado == cp_model.OPTIMAL
    assert solver.value(x) == 7
    assert solver.value(y) == 3
