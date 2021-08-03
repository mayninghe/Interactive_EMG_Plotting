loadSensorData <- function(statPath) {
  
  # identify the data to load
  path.sensorData <- statPath
  namesSensor <- c("time", "state", "Elbow_Torque", "Shoulder_Torque", 
                   "EFx", "EFy", "EFz", "EMx", "EMy", "EMz", 
                   "Bicep", "TriLat", "AntDel","MidDel",
                   "PosDel", "Pec", "LowTrap", "MidTrap")
  
  # load the data
  sensorData <- read.table(path.sensorData)
  colnames(sensorData) <- namesSensor
  
  # store elapsed time
  sensorData$t<-sensorData$time-sensorData$time[1]	
  sensorData$diffT<-c(0,diff(sensorData$t))
  sensorData<-sensorData[(diff(sensorData$t)>0.0005),]  # keep data when at least 0.0005ms passed between measurements 
  
  subset <- sensorData %>% select(c('t', 'state', 'Elbow_Torque', 
                                    'Shoulder_Torque', "Bicep", "TriLat", "AntDel","MidDel",
                                    "PosDel", "Pec", "LowTrap", "MidTrap"))
  subset$state <- factor(subset$state)
  return(subset)
}