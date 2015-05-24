---
title: "Details about run_analysis"
author: "Lottie"
date: "Saturday, May 23, 2015"
output: html_document
---
#Resource Info
Course project: cleaning data
 Data source:
 https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
 
 Data format & info: 
 http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
 
 Date accessed: 5/22/2015

 The data is a collection of motion statistics gathered over a number of subjects and a number of activities. For example:  tBodyAcc-std()-Z : The standard deviation in the z dimension of the body.  There are more details about what the variables mean in the uci archive listed above.

Some details about the file structures:

subject_test: 
  size 2947* 1 
  content: numbers 1:24, with gaps 
  (I think each row represents a test point for a user of that number) 
  
X_test:
  size 2947* features (561?)
  content: piles of real numbers, mostly pretty small. 
  separator: space. 
  These are the calculated values for all the features.
  
features.txt
   the names of the 561 features (body acceleration mean-x,y,z; std-x,y,z, etc.;
   gravity acceleration mean, std, etc.;tBodyAccJerk_mean, etc.... )

Y_test
  size 2947 * 1
  values: numbers 1-6, which represent the activity types.

The training data is similar: there is an X_train and a Y_train that are larger
than the thest files, but similarly organized, with the same number of features.

# Goal

Create a tidy data subset of observations. Use it to generate another tidy dataset of summary statistics.

The observation data set, dataSubset, will look about like this:


|data points       | (variables) | subject | activity    |
-------------------|-------------|---------|-------------|
|training examples |(lots of #s) |(subj. #)|(a. by name) |
|test examples     |(lots of #s) |(subj. #)|(a. by name) |

The summary data set, summary, looks about like this:

|activity      | subject |variable                    | mean            |
|--------------|---------|----------------------------|-----------------|
|(e.g. WALKING)|(e.g.24) |(e.g. tGravityAcc-mean()-X) |(e.g. 0.22104384)|

#Implementation

##Read in the data 
There are 3 basic components that will need to be reassembled: the x values, the y values, and the subjects.Here we read them into variables.
```{r}
testX = read.table("test/X_test.txt", header = FALSE )
trainX = read.table("train/X_train.txt" , header = FALSE )

testY = read.table("test/Y_test.txt", header = FALSE )
trainY = read.table("train/Y_train.txt" , header = FALSE )

trainSubject = read.table("train/subject_train.txt", header = FALSE)
testSubject = read.table("test/subject_test.txt", header = FALSE)
```

Now we merge the training and the test sets to create one data set.
Similarly, we build a column each of activity labels and subjects. 
At this point, as long as we merge them all in the same order, 
they will attach together correctly.


```{r}
library(dplyr)

allY = rbind(trainY, testY)
colnames(allY)= "activity"

#Similarly, build a column of subjects
subjects = rbind(trainSubject, testSubject)
colnames(subjects) = "subject"

#build the table of features. Attach the feature labels as column names
#The feature labels will need to be inverted from a column to a row.

data = rbind(trainX, testX)
data = cbind(data, subjects)
data = cbind(data, allY)
dfData = tbl_df(data)
```

##Find the variable names

I find the names early so I can work with the features by name instead of by 
number, but I don't attach them to the table until later because there are 
duplicates (which are not in the set of variables we care about) that confuse the algorithm.
```{r}
#Find the appropriate names for the variables. They  are found
#in the "features" file. Add the name for activities. THere are 561 features,
#so subject will be number 562 and activity will be number 563.
#Do not rename the dfData table yet, because there are duplicated names
#and it messes things up.

names = read.table("features.txt", stringsAsFactors = FALSE)
names = rbind(names,c("562", "subject"))
names = rbind(names, c("563", "activity"))
dfNames = tbl_df(names)
colnames(dfNames) = c("column", "column.name")

```
##Collect the columns we care about 

Extract only the measurements on the mean (mean) and standard deviation (std) for each measurement. 
Find all of those that contain the substring "mean" or "std" in their name.
Hold onto activity and subject as well; discard all others.
The desired columns end up in meanStdQuery, which lists both their column 
number and the name of that column.
```{r}
meanStdQuery = filter(dfNames, grepl("mean|std|activity|subject", column.name) )
relevantColumns = meanStdQuery$column

#relevantColumns are characters. Need to convert them to numbers.
relevantColumns = as.numeric(relevantColumns)
dataSubset = select(dfData, relevantColumns)

```
##Add the descriptive variable names back in
I am using the names from the original data; anyone who cares about a 
particular variable can go to the source documents to find out 
precisely what it means.
```{r}
#Appropriately label the data set with descriptive variable names 
headers = meanStdQuery$column.name
names(dataSubset) <- headers
```

##Name the activities in the data set
So far, they are numbers. 
From the file activity_labels.txt:

 1 WALKING
 2 WALKING_UPSTAIRS
 3 WALKING_DOWNSTAIRS
 4 SITTING
 5 STANDING
 6 LAYING

I will use these labels.

When I read in the files and merge them, I get two columns in dataSubset that are both about activity: one that indicates activities by label, and  one that indicates the activities by number. For tidy data purposes (and to avoid redundancy,) I remove the column indicating activities by number. I also need to reset the names on the dataset, since the new (less descriptive) table name is kept instead of the old one. I checked, and the columns are in the same order still.

```{r}
labels = read.table("activity_labels.txt")
dataSubset = merge(dataSubset, labels, by.x = "activity", by.y = "V1")
dataSubset = select(dataSubset, -activity)
names(dataSubset) <- headers
```
We now have a table like this:

|data points       | (variables) | subject | activity    |
-------------------|-------------|---------|-------------|
|training examples |(lots of #s) |(subj. #)|(a. by name) |
|test examples     |(lots of #s) |(subj. #)|(a. by name) |

##Create the table of averages

From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject. 

Creates an independent, tidy table of 4 columns. Each row represents one combination of activity, subject, and variable. The fourth column gives the mean value for that combination.


|activity      | subject |variable                    | mean            |
|--------------|---------|----------------------------|-----------------|
|(e.g. WALKING)|(e.g.24) |(e.g. tGravityAcc-mean()-X) |(e.g. 0.22104384)|


```{r}
library(reshape2)

#melting the data allows us to reformat it.
melted <- melt(dataSubset, id.vars=c("activity", "subject"))

#Now we define the groupings that each row will represent, which is per
#activity, per subject, per variable.
#The "variable" in the next line incorporates all the other columns.
grouped <-  group_by(melted, activity, subject, variable)

#Summarise calculates a function for each group. The funtion we want is mean.
#"value" is what's passed in by summarize: the set of values from the 
#table that match that particular group.
summary <-  summarise(grouped, mean = mean(value)) 
#save to a file.
write.table(summary, "summaryStats.txt", row.name = FALSE)
```