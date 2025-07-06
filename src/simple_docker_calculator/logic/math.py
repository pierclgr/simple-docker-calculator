def add(a, b):
    """
    Element-wise addition of two arrays.

    Parameters
    ----------
    a : array_like
        First array to add.
    b : array_like
        Second array to add.

    Returns
    -------
    out : array_like
        Element-wise sum of `a` and `b`.

    Examples
    --------
    >>> add(1, 2)
    3
    >>> add([1, 2], [2, 3])
    [3, 5]
    """
    return a + b


def sub(a, b):
    """
    Element-wise subtraction of two arrays.

    Parameters
    ----------
    a : array_like
        First array to subtract from.
    b : array_like
        Second array to subtract.

    Returns
    -------
    out : array_like
        Element-wise difference of `a` and `b`.

    Examples
    --------
    >>> sub(1, 2)
    -1
    >>> sub([1, 2], [2, 3])
    [-1, -1]
    """
    return a - b


def mul(a, b):
    """
    Element-wise multiplication of two arrays.

    Parameters
    ----------
    a : array_like
        First array to multiply.
    b : array_like
        Second array to multiply.

    Returns
    -------
    out : array_like
        Element-wise product of `a` and `b`.

    Examples
    --------
    >>> mul(2, 3)
    6
    >>> mul([2, 3], [3, 4])
    [6, 12]
    """
    return a * b


def div(a, b):
    """
    Element-wise division of two arrays.

    Parameters
    ----------
    a : array_like
        First array to divide.
    b : array_like
        Second array to divide by.

    Returns
    -------
    out : array_like
        Element-wise quotient of `a` and `b`.

    Examples
    --------
    >>> div(4, 2)
    2.0
    >>> div([4, 6], [2, 3])
    [2.0, 2.0]
    """
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b
