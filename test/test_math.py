from simple_docker_calculator.logic.math import add, sub, mul, div
import pytest


def test_add():
    assert add(2, 3) == 5
    assert add(0, 0) == 0
    assert add(-1, 1) == 0
    assert add(1, -1) == 0
    assert add(-1, -1) == -2


def test_sub():
    assert sub(2, 3) == -1
    assert sub(0, 0) == 0
    assert sub(-1, 1) == -2
    assert sub(1, -1) == 2
    assert sub(-1, -1) == 0


def test_mul():
    assert mul(2, 3) == 6
    assert mul(0, 0) == 0
    assert mul(-1, 1) == -1
    assert mul(1, -1) == -1
    assert mul(-1, -1) == 1


def test_div():
    assert div(2, 3) == 0.6666666666666666
    assert div(-1, 1) == -1
    assert div(1, -1) == -1
    assert div(-1, -1) == 1

    with pytest.raises(ValueError):
        div(2, 0)
