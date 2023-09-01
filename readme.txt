CreateLegend-function

Purpose of this project is to provide a function to create a legend for two y-axis. 
It's for data with one property on one y-axis, and another property on the other
y-axis, but both are connected in a certain way.
Currently it's only working for a fixed usecase (no further change is possible, when the legend is already set).

A example use-case could be: 
The time-resolved measurement of an exhaust-gas-component on the left y-axis,
and on the other y-axis the acumulated value of it.

Please feel free to use this function and if you have an improvement proposal then let me know about it.
I hope this helps someone.

Things still ToDo:
-Automatic color-detection of the lines in a plot
-Automatic side-detection (which side is used in the plot whith how much plotted lines in it?)
-Automatic resizing of the legend
-Add ability to change settings of the legend after first creation (Give handles back to change things. Is that even possible?)
