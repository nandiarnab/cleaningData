# cleaningData
A new repo for the Coursera Getting and Cleaning Data project

---
title: "Getting and Cleaning Data - Course Project - Explanation"
author: "Arnab Nandi"
date: "24 September 2015"
output: html_document
---

This document explains the working of the run_analysis.R code, that is a part of the Coursera John Hopkins Getting and Cleaning Data course project. 

The code expects that the dplyr version  0.4.3 or later to be installed on the machine in which it is run. It also expects that the couse data (https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) be downloaded and saved on the same directory on which it is run. Note that the zip file does not need to be unzipped. The script will work with the compressed file itself.

An additional file, descriptors.txt has been created, which will be used to add descriptive names to the variables, as instructed in the project specification. This file takes only the mean and standard deviation variables in the features file in the UCI HAR Dataset and then adds a description to each variable.

The overall structure of the code is broken down into the following sections: -

Section 1: -

- Read the activity_labels.txt file within the zip
- Read the features.txt file within the zip and extract all features that contain with mean() or std()
- Read the codebook, written by adding a description and unit to the features read in the above step
- Read the training dataset within the train/X_train.txt file
- Read the training label within the train/y_train.txt file
- Read the training subjects within the train/subject_train.txt file
- Read the test dataset within the test/X_test.txt file
- Read the test label within the test/y_test.txt file
- Read the test subjects within the test/subject_test.txt file

Section 2: -

While reading the train and test datasets (data, label, and subject), the code also adds the rownumbers in these files as the id column to the datasets so that they can be easily joined together by using the dplyr inner_join function by the id column.

To preserve memory, the code deletes unnecessary datasets, that are no longer required.

Section 3: -

In this section, the code does the following: -
- Merges the training and test data, as instructed in the project specification, by the id column.
- Renames the columns of the merged dataset with the long description of column names read in Section 1. 
- Joins it with the activities dataset read in Section 1, by the label column (read via the label datasets)
- Selects only the required columns (id and label are no longer required)
- Groups by activity and subject, as instructed in the project specification
- Summarises the groups by mean of the variables, as instructed in the project specification
- Writes the summarised dataset out to a tidy_dataset.txt, which needs to be uploaded to the project site.
