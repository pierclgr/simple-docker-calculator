import tkinter as tk


class CalculatorGUI:
    @staticmethod
    def build():
        """
        Create a new instance of :class:`CalculatorGUI`.

        Returns
        -------
        root : tkinter.Tk
            The root window of the GUI.

        """
        root = tk.Tk()
        app = CalculatorGUI(root)

        # Optional: make grid responsive
        for i in range(6):
            root.rowconfigure(i, weight=1)
        for i in range(4):
            root.columnconfigure(i, weight=1)

        root.mainloop()

        return root

    def __init__(self, master):
        self.master = master
        master.title("Calculator")

        self.expression = ""
        self.display = tk.Entry(master, width=20, font=('Arial', 24), borderwidth=2, relief="solid", justify='right')
        self.display.grid(row=0, column=0, columnspan=4, padx=10, pady=10, ipady=10)

        self._create_buttons()

    def _create_buttons(self):
        """
        Create all the buttons on the calculator.

        """
        # Button labels in grid format
        buttons = [
            ('7', 1, 0), ('8', 1, 1), ('9', 1, 2), ('/', 1, 3),
            ('4', 2, 0), ('5', 2, 1), ('6', 2, 2), ('*', 2, 3),
            ('1', 3, 0), ('2', 3, 1), ('3', 3, 2), ('-', 3, 3),
            ('0', 4, 0), ('.', 4, 1), ('C', 4, 2), ('+', 4, 3),
            ('=', 5, 0, 1, 4)  # Span 4 columns
        ]

        for btn in buttons:
            text = btn[0]
            row = btn[1]
            col = btn[2]
            rowspan = btn[3] if len(btn) > 3 else 1
            colspan = btn[4] if len(btn) > 4 else 1
            self._add_button(text, row, col, rowspan, colspan)

    def _add_button(self, text, row, column, rowspan=1, colspan=1):
        """
        Add a single button to the calculator.

        Parameters
        ----------
        text : str
            The text to be displayed on the button.
        row : int
            The row of the button in the grid.
        column : int
            The column of the button in the grid.
        rowspan : int, optional
            The number of rows to span. Default is 1.
        colspan : int, optional
            The number of columns to span. Default is 1.

        """
        btn = tk.Button(self.master, text=text, width=5, height=2,
                        font=('Arial', 18), command=lambda: self._on_button_click(text))
        btn.grid(row=row, column=column, rowspan=rowspan, columnspan=colspan, padx=5, pady=5, sticky="nsew")

    def _on_button_click(self, char):
        """
        Handle a button click event.

        Parameters
        ----------
        char : str
            The character of the button that was clicked.

        """
        if char == 'C':
            self.expression = ""
            self._update_display()
        elif char == '=':
            try:
                result = str(eval(self.expression))
                self.expression = result
                self._update_display()
            except Exception:
                self.expression = ""
                self.display.delete(0, tk.END)
                self.display.insert(0, "Error")
        else:
            self.expression += str(char)
            self._update_display()

    def _update_display(self):
        """
        Update the display with the current expression.

        """
        self.display.delete(0, tk.END)
        self.display.insert(0, self.expression)

