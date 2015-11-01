# Set Directory 
setwd('C:/Users/user/Study/DataIncubator/ChallengeData/csv' )

#Load Libraries 
library(ggplot2)
library(ggthemes)
library(data.table)
library(GGally)
library(sqldf)


# Load the Ontime Performance Data 
df <- read.csv(file="On_Time_On_Time_Performance_2014_1.csv", quote = "\"") # remove the nrows for the actual answer

#Get Dimension of df
dim(df)

# Look at  few lines of data 
head(df, n = 5)

# look at str function for column names and sample data 
str(df)

# Get some catogories of columns
levels(df$UniqueCarrier)
levels(df$SecurityDelay)
levels(df$Dest)

# Look at th summary of the data 
summary(df)


# Get Only records that has a delay (DOT defines late as 15mins or more)
dfdelay <- df[which(df$ArrDelayMinutes> 15), ]
dim(dfdelay)
head(dfdelay, n = 5)

dfDelaysCount <- sqldf("SELECT UniqueCarrier, Origin, Dest,
              CASE WHEN CarrierDelay > 0  THEN 1 ELSE 0 END AS CarrierDelay_count,
              CASE WHEN WeatherDelay > 0  THEN 1 ELSE 0 END AS WeatherDelay_count,
              CASE WHEN NASDelay > 0  THEN 1 ELSE 0 END AS NASDelay_count,
              CASE WHEN SecurityDelay > 0  THEN 1 ELSE 0 END AS SecurityDelay_count,
              CASE WHEN LateAircraftDelay > 0  THEN 1 ELSE 0 END AS LateAircraftDelay_count
             FROM dfdelay") 

dfDelaysCountSummary  <- sqldf("SELECT UniqueCarrier, Origin, Dest,
              sum(CarrierDelay_count) as CarrierDelayCount,
              sum(WeatherDelay_count) as WeatherDelayCount,
              sum(NASDelay_count) as NASDelayCount,
              sum(SecurityDelay_count) as SecurityDelayCount,
              sum(LateAircraftDelay_count) as LateAircraftDelayCount
             FROM dfDelaysCount   GROUP BY UniqueCarrier, Origin, Dest") 

## Selected the flights from HOU to DAL (Worst performing flights)
dfHOU_DAL <- sqldf("select Origin, Dest, CarrierDelayCount, WeatherDelayCount,NASDelayCount , SecurityDelayCount ,
              LateAircraftDelayCount from dfDelaysCountSummary WHERE Origin ='HOU' AND Dest ='DAL'") 
dfRawHOU_DAL <- sqldf("select *  from df WHERE Origin ='HOU' AND Dest ='DAL'") 

dfchartDataTemp <- sqldf("select CarrierDelayCount, WeatherDelayCount,NASDelayCount , SecurityDelayCount ,LateAircraftDelayCount 
                     from dfHOU_DAL") 

DelayType = c("CarrierDelay", "WeatherDelay", "NASDelay", "SecurityDelay", "LateAircraftDelay" ) 
DelayCount = c(188,3,75,0,189)
dfchartData = data.frame(DelayType,DelayCount)

barplot(dfchartData$DelayCount, names.arg=dfchartData$DelayType, xlab = "Delay Type", ylab="Number of flights delayed") 
title("Count of Types of Delay in flights from HOU to DAL in Jan 2014 ") 
dev.copy(png, file="plot1.png") 
dev.off() 

# Chart 2 

dfAirlineCountSummary  <- sqldf("SELECT UniqueCarrier, 
                               sum(CarrierDelay_count) as CarrierDelayCount,
                               sum(WeatherDelay_count) as WeatherDelayCount,
                               sum(NASDelay_count) as NASDelayCount,
                               sum(SecurityDelay_count) as SecurityDelayCount,
                               sum(LateAircraftDelay_count) as LateAircraftDelayCount
                               FROM dfDelaysCount   GROUP BY UniqueCarrier") 

dfAADelays <- sqldf("select UniqueCarrier, CarrierDelayCount, WeatherDelayCount,NASDelayCount , SecurityDelayCount ,
              LateAircraftDelayCount from dfDelaysCountSummary WHERE UniqueCarrier ='AA' ") 

DelayType1 = c("CarrierDelay", "WeatherDelay", "NASDelay", "SecurityDelay", "LateAircraftDelay" ) 
DelayCount1 = c(4776,1408,4585,6,4865)
dfchartData1 = data.frame(DelayType1,DelayCount1)


barplot(dfchartData1$DelayCount1, names.arg=dfchartData1$DelayType1, xlab = "Delay Type", ylab="Number of AA flights delayed") 
title("Number and Type of DELAYS in American Airlines Flights That operated in the US in Jan 2014 ") 
dev.copy(png, file="plot2.png") 
dev.off() 

