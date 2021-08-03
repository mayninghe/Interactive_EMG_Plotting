# Interactive_EMG_Plotting
A simple interactive dashboard built with R Shiny. Users are able to zoom into torque and surface EMG signals to visualize experimental data.

This project is hosted on shinyapps.io and you can find it at: https://mayninghe.shinyapps.io/Interactive_EMG_Plotting/
The default option is to use sample data, which is a .txt file containing torque and sEMG traces sampled at 1kHz.
You can also upload your own experimental data, with the caveat noted below. 

This dashboard is made specifically for preliminary data analyses in the Gurari Lab, so that uploaded data shoulde follow the following structure:
column 1 - time, column 2 - state, column 3 & 4 - torque / load cell signals, column 5:12 - eight sEMG signals. 

It currently does not have ability to generalize to other data structures. Uploaded data not following the structure specified above may not get displayed correctly. However, you can modify the loadSensorData.R to fit your data structure if needed.

This dashboard has two main functions: 
1) Plot and the elbow and shoulder torque traces, and users can select time frame of interest from the lower panel and zoom into the corresponding torque traces. This function is particularly useful for visually inspecting whether individuals maintained torques at any given time point of the experiment. 
2) Plot sEMG signals, and users can zoom into specific time segments by selecting on any of the EMG traces. Users can also adjust the y-axis limits. This function is useful for visually inspecting all the EMG signal quality as well as observing the change in all eight muscles activiities at the same time.

