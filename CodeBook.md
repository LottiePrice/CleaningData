---
title: "Codebook"
author: "Lottie"
date: "Saturday, May 23, 2015"
output: html_document
---

#Definitions of variables used:

##Main variables

###dataSubset

The tbl_df set of observations we are interested in. These include any that have the substrings "mean" or "std"; in addition, we are interested in the activity and subject. There are 81 variables (81 columns) altogether in this set.

The observations in dataSubset combine both the train and test data. Format:

|data points       | (variables) | subject | activity    |
-------------------|-------------|---------|-------------|
|training examples |(lots of #s) |(subj. #)|(a. by name) |
|test examples     |(lots of #s) |(subj. #)|(a. by name) |

Where variables represents multiple columns of the various things measurements taken.


###summary

Summary is the tbl_df table of means. For each combination of subject, activity and variable, a row is created. For that row, we collect the relevant observations from dataSubset and calculate the mean of those observations. This is a narrow table of 4 variables (subject, activity, variable, mean) and 14220 combinations listed as the rows. Format:


|activity      | subject |variable                    | mean            |
|--------------|---------|----------------------------|-----------------|
|(e.g. WALKING)|(e.g.24) |(e.g. tGravityAcc-mean()-X) |(e.g. 0.22104384)|



##Secondary (intermediate) variables

###allY

Y-values are the activities. allY combines the training and testing activities into a single column. 

###data

data is used to collect the data in data.table form rather than tbl_df format. Data contains all the data, not just the columns we're interested in. It includes the data from train_X, test_X, train_Y, test_Y, subject_train, and subject_test. The activity column (the Y's) has been changed to include strings as the activities instead of numbers, to make the summary data more transparent.
Columns in this table are not properly named.

###dfData

Converts the data into a tbl_df format so we can do the appropriate modifications. It contains all the data, not just the columns we're interested in.

###dfNames

The list of all variable names from the full dataset. Appended on are subject and activity.

###grouped

dataSubset is grouped by activity, subject and variable in this table. Used in making the summary.

###labels

labels contains the six activity labels and their corresponding number (1= walking, etc.). Used to make the activity column more readable.

###meanStdQuery

This is a list of all the variables we are interested in keeping in our subset. meanStdQuery contains both the column number (as a string) and the column name.

###melted

A variation of dataSubset, used to make the data more malleable for later processing.

###names

The column names for the full dataset, plus the column number associated with that name (in string format).

###subjects

A single column identifying which subject the testX/testY/trainX/TrainY data came from. This gets joined into the dfData table.

###testSubject, testX, testY, trainSubject, trainX, trainY

These are the raw data being read in as a table. They get joined into the dfData table.

