run_analysis <- function(){
## Set the working directory
  setwd("~/Coursera-Specialization/03 Getting and Cleaning Data/project")
#To download the dataset from the link provided
if(!file.exists("UCI HAR Dataset")){         
  dir.create("UCI HAR Dataset")
}
fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./UCI HAR Dataset.zip", method ="curl")

## Zip file was extracted manually to the working directory

## Load the packages eventually need to manipulate the data sets
library(plyr)
library(dplyr)
library(tidyr)

## Step 1 - Merge the data sets to create only one:
## from the "train" folder:
x_train <- read.table("train/X_train.txt")
y_train <- read.table("train/y_train.txt")
subject_train <- read.table("train/subject_train.txt")

## and from the "test" folder:
x_test <- read.table("test/X_test.txt")
y_test <- read.table("test/y_test.txt")
subject_test <- read.table("test/subject_test.txt")

## create a 'x' data set
x_data <- rbind(x_train, x_test)

## create a 'y' data set
y_data <- rbind(y_train, y_test)

## create a 'subject' data set from both files
subject_data <- rbind(subject_train, subject_test)

## Step 2 - Extract only the measurements on the mean and standard deviation
## Looking at features_info.txt we know that each signal was estimated with mean or std () variables.
## We load the 'features' file
features <- read.table("features.txt")

## and search for matches to variable's names with 'mean' or 'std' 
mean_and_std_features <- grep("-(mean|std)\\(\\)", features[, 2])

## subset the desired columns
x_data <- x_data[, mean_and_std_features]

## correct the column names
names(x_data) <- features[mean_and_std_features, 2]

## Step 3 - Use descriptive activity names to name the activities in the data set
activities <- read.table("activity_labels.txt")

## update the values with correct activity names
y_data[, 1] <- activities[y_data[, 1], 2]

## and rename the respective column
names(y_data) <- "activity"

## Step 4 - Appropriately label the data set with descriptive variable names:
## correcting the column name
names(subject_data) <- "subject"

## binding all the data in one data set
all_data <- cbind(x_data, y_data, subject_data)

## Step 5 - Create a second, independent tidy data set with the average of each variable
## for each activity and each subject
average_data <- ddply(all_data, .(subject, activity), function(x) colMeans(x[, 1:66]))

## Print(averages_data) to a *.txt file
write.table(average_data, "average_data.txt", row.name=FALSE)
