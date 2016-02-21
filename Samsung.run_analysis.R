# Samsung Data Wrangling Project 
### Downloading and unzipping the data set 
### need utils library to work with ZIP archives
require(utils)

### download UCI archive into local directory
zipFileName <- file.path("getdata-projectfiles-UCI HAR Dataset.zip")
if (!file.exists(zipFileName)) {
  zipUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(zipUrl, destfile = zipFileName, method = "curl", mode = "wb")
  print(paste(Sys.time(), "archive downloaded"))
}

### unzip overwriting existing directory to ensure clean setup
if (file.exists(zipFileName)) {
  unzip(zipFileName, list = TRUE)
  unzip(zipFileName, overwrite = TRUE)
  print(paste(Sys.time(), "unpacked archive"))
}

### download UCI dataset names#
namesFileName <- file.path("UCI HAR Dataset.names")
if (!file.exists(namesFileName)) {
  namesUrl = "http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.names"
  download.file(namesUrl, destfile = namesFileName, method = "curl")
  print(paste(Sys.time(), "data set names downloaded"))
}

##Basic Set-Up Details
###Libraries and Packages Required
####We use dplyr and data.table as data.table is better for large data tables and dplyr for aggregation after tidying#
install.packages("data.table")
install.packages("dplyr")
install.packages("reshape2")


library(data.table)
library(dplyr)
library(reshape2)

##Understanding the variables in this dataset
###The available variables are the following:

####subject: Assumes a value from 1 to 30, representing the subject tested.
#### activity: Describes the action made by the subject, being WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING.
####(measurement: What measurement the column value will contain.
####value: A number correspondent to measurement label.)

##Assigning labels 
### Need to assign labels for the activity and features variables from the features and activity_labels dataset

featureNames <- read.table("UCI HAR Dataset/features.txt")
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)

##Formating the Train and Test Data 
###Organizing the Train and Test data which are each broken up by features, activity and subject. Conducting this reading/organization separately and then merging the data into one variable each as "features" "activity" and "subject"

###Read Train Data 

subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
activityTrain <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE)
featuresTrain <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)

###Read Test Data 

subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
activityTest <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)
featuresTest <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)



## PART 1: Merging into one data set for each variable 
subject <- rbind(subjectTrain, subjectTest)
activity <- rbind(activityTrain, activityTest)
features <- rbind(featuresTrain, featuresTest)



###Assigning Column Names to the "features", "activity" and "subject" data sets 
###featureNames file needs to be tranposed (rows to columns and then assigned as names to the rows in "features")
colnames(features) <- t(featureNames[2])



###assigning labels to activity and subject
colnames(activity) <- "Activity"
colnames(subject) <- "Subject"


###Create one complete dataset by merging "activity", "features" and "subject"
CompleteSet <- cbind(features, activity, subject)


##------------

##PART 2: Extracts columns containing mean and standard deviation for each measurement
### Need to create unique columns for features since they are probably repeated 
###Create vector "NonDuplicateColumns" 
NonDuplicateColumns <- (CompleteSet[, !duplicated(colnames(CompleteSet), fromLast = TRUE)])

###now selecting those columns that have mean and standard deviation and call it ColumnswithMSD
ColumnswithMSD <- select(NonDuplicateColumns, contains("mean"), contains("std"))

###Since, this only refined the columns (features) with mean and std, we now need to add Activity and Subject Variables back in 
RequiredColumnSet <- c(ColumnswithMSD, 562, 563)

###Now, in order to create a "FinalCompiledSet", we need the 
FinalCompiledSet <- CompleteSet[, RequiredColumnSet]
### (Error in .subset(x, j) : invalid subscript type 'list')
### Tried: RequiredCSDF <- tbl_df(RequiredCLdf)
### Same Error as Above





##PART 3: Uses descriptive activity names to name the activities in the data set

### Create Activity Table
Activity_Label = c(1,2,3,4,5,6)
Activity_Name = c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING")
Activity = data.frame(Activity_Label,Activity_Name)

### Join Activity with features 
xy <- bind_cols(x,y)
setnames(xy,"V1","Activity_Label")
xy_name <- left_join(xy, Activity)
xy_subject_name <- bind_cols(subject,xy_name)



