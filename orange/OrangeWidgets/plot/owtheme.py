from PyQt4.Qt import QFont, QColor

class PlotTheme(object):
    '''Collection of color and font settings.'''

    def __init__(self):
        self.labels_font = QFont('Helvetice', 8)
        self.helper_font = self.labels_font
        self.helpers_color = QColor(0, 0, 0, 255)
        self.background_color = QColor(255, 255, 255, 255)
        self.axis_title_font = QFont('Helvetica', 10, QFont.Bold)
        self.axis_font = QFont('Helvetica', 9)
        self.labels_color = QColor(0, 0, 0, 255)
        self.axis_color = QColor(30, 30, 30, 255)
        self.axis_values_color = QColor(30, 30, 30, 255)

class ScatterPlotTheme(PlotTheme):
    def __init__(self):
        super(ScatterPlotTheme, self).__init__()
        self.grid_color = QColor(200, 200, 200, 255)

class ScatterLightTheme(ScatterPlotTheme):
    pass

class ScatterDarkTheme(ScatterPlotTheme):
    def __init__(self):
        super(ScatterDarkTheme, self).__init__()
        self.grid_color = QColor(80, 80, 80, 255)
        self.labels_color = QColor(230, 230, 230, 255)
        self.helpers_color = QColor(230, 230, 230, 255)
        self.axis_values_color = QColor(180, 180, 180, 255)
        self.axis_color = QColor(200, 200, 200, 255)
        self.background_color = QColor(0, 0, 0, 255)

