from gui.calculator_gui import CalculatorGUI


def main():
    """Launch the calculator GUI."""
    main_window = CalculatorGUI.build()
    main_window.mainloop()


if __name__ == "__main__":
    main()
