# Course project: clean data.
# Data source:
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# Data format & info: 
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
# Date accessed: 5/22/2015

# The data is a collection of motion statistics gathered over a number of subjects
#and a number of activities. For example: 

#Data format
#Subject test: 
#  size 2947* 1 
#  content: numbers 1:24, with gaps 
#  (I think each row represents a test point for a user of that number) 
#  
#X_test:
#  size 2947* features (561?)
#  content: piles of real numbers, mostly pretty small. 
#  separator: space. 
#features.txt
#   the names of the 561 features (body acceleration mean-x,y,z; std-x,y,z, etc.;
#   gravity acceleration mean, std, etc.;tBodyAccJerk_mean, etc.... )
#Y_test
#  size 2947 * 1
#  values: numbers 1-6, which represent the activity types.

library(dplyr)
# Part 1: load in the files
#setwd("C://Users/Superduck/Documents/Lottie Local/Courses/CleaningDataInR")
#setwd("UCI HAR Dataset")

#Read in the data 
testX = read.table("test/X_test.txt", header = FALSE )
trainX = read.table("train/X_train.txt" , header = FALSE )

testY = read.table("test/Y_test.txt", header = FALSE )
trainY = read.table("train/Y_train.txt" , header = FALSE )

trainSubject = read.table("train/subject_train.txt", header = FALSE)
testSubject = read.table("test/subject_test.txt", header = FALSE)
# Merge the training and the test sets to create one data set.

#build a column of activity labels. Attach the training and test
#labels together and rename the column.
allY = rbind(trainY, testY)
colnames(allY)= "activity"

#Similarly, build a column of subjects.
subjects = rbind(trainSubject, testSubject)
colnames(subjects) = "subject"

#build the table of features. Attach the feature labels as column names.
#The feature labels will need to be inverted from a column to a row.

data = rbind(trainX, testX)
data = cbind(data, subjects)
data = cbind(data, allY)
dfData = tbl_df(data)

#Find the appropriate names for the variables. They  are found
#in the "features" file. Add the name for activities. THere are 561 features,
#so activity will be number 561.
#Do not rename the dfData table yet, because there are duplicated names
#and it messes things up.

#names = t(names)
names = read.table("features.txt", stringsAsFactors = FALSE)
names = rbind(names,c("562", "subject"))
names = rbind(names, c("563", "activity"))
dfNames = tbl_df(names)
colnames(dfNames) = c("column", "column.name")

#Extract only the measurements on the mean (mean) and standard deviation (std) for each measurement. 
#Find those that contain the substring "mean" or "std" in their name.
#Hold onto the activity as well; discard all others.

meanStdQuery = filter(dfNames, grepl("mean|std|activity|subject", column.name) )
relevantColumns = meanStdQuery$column

#relevantColumns are characters. Need to convert them to numbers.
relevantColumns = as.numeric(relevantColumns)
dataSubset = select(dfData, relevantColumns)

#Appropriately label the data set with descriptive variable names. 
headers = meanStdQuery$column.name
names(dataSubset) <- headers


#Use descriptive activity names to name the activities in the data set.
#Fix the labels on the dataSubset, since the merge messes things up.
#From the file activity_labels.txt:
# 1 WALKING
# 2 WALKING_UPSTAIRS
# 3 WALKING_DOWNSTAIRS
# 4 SITTING
# 5 STANDING
# 6 LAYING
#

labels = read.table("activity_labels.txt")
dataSubset = merge(dataSubset, labels, by.x = "activity", by.y = "V1")
dataSubset = select(dataSubset, -activity)
names(dataSubset) <- headers

#From the data set in step 4, create a second, independent tidy data set with the 
#average of each variable for each activity and each subject. 

#Creates a table of 4 columns. Each row represents one combination of activity,
#subject, and variable. The fourth column gives the mean for that combination.

library(reshape2)

melted <- melt(dataSubset, id.vars=c("activity", "subject"))
grouped <-  group_by(melted, activity, subject, variable)
summary <-  summarise(grouped, mean = mean(value)) 
write.table(summary, "summaryStats.txt", row.name = FALSE)

