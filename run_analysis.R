# The script makes heavy use of dplyr 0.4.3, hence check for its availability.
if (!(require(dplyr)))
    stop("Please install dplyr 0.4.3 for progressing with this script!")

# Set the working directory to where this file is. 
# Note that the UCI HAR Dataset.zip file is assumed to be in this directory.
setwd(dirname(parent.frame(2)$ofile))

read.dataset <- function(path = ".", file = "UCI HAR Dataset.zip", dataset = "train", features) {
    # Reads a dataset within the UCI HAR Dataset.zip file
    #
    # Args:
    #   path: Defaults to the current directory, where the UCI HAR Dataset.zip file is contained
    #   file: Defaults to the UCI HAR Dataset.zip, the dataset that contains the Samsung data
    #   dataset: Defaults to the training dataset, but test is also a valid value
    #   features: List of features that need to be extracted from the dataset (mean and std. dev)
    #
    # Returns: 
    # The dataset, a data.frame
    full_path = paste(path, file, sep = "/")
    if (!file.exists(full_path) || (dataset != "train" && dataset != "test"))
        stop("Invalid path to Samsung dataset. File does not exist.")
    
    # The unz function allows reading a zipped file
    # This line reads the data in data, train/X_train.txt or test/X_test.txt in the zip file and selects
    # the required features (the feature dataset contains the mean and std. dev. columns only)
    data <- read.table(unz(full_path, 
                    paste("UCI HAR Dataset/", dataset, "/X_", dataset, ".txt", sep = "")), 
                    header = F) %>% select(features$position)
    
    # The column names of the dataset is assigned as the feature names in the feature.txt file
    colnames(data) <- features$measurement
    
    # A new column is added the data.frame called id, which is the row number of the observation in the file
    data <- data %>% mutate(id = seq.int(nrow(data)))
    
    # The dataset is returned
    data
}

read.labels <- function(path = ".", file = "UCI HAR Dataset.zip", dataset = "train") {
    # Reads the labels within the UCI HAR Dataset.zip file
    #
    # Args:
    #   path: Defaults to the current directory, where the UCI HAR Dataset.zip file is contained
    #   file: Defaults to the UCI HAR Dataset.zip, the dataset that contains the Samsung data
    #   dataset: Defaults to the training dataset, but test is also a valid value
    #
    # Returns: 
    # The labels, a data.frame
    full_path = paste(path, file, sep = "/")
    if (!file.exists(full_path) || (dataset != "train" && dataset != "test"))
        stop("Invalid path to Samsung dataset. File does not exist.")

    # The unz function allows reading a zipped file
    # This line reads the labels, train/y_train.txt or test/y_test.txt in the zip file
    labels <- read.table(unz(full_path, 
                             paste("UCI HAR Dataset/", dataset, "/y_", dataset, ".txt", sep = "")), 
                         header = F)
    
    # The column names of the dataset is assigned as "label"
    colnames(labels) <- c("label")
    
    # A new column is added the data.frame called id, which is the row number of the label in the file
    labels <- labels %>% mutate(id = seq.int(nrow(labels)))

    # The label data.frame is returned
    labels
}

read.subjects <- function(path = ".", file = "UCI HAR Dataset.zip", dataset = "train") {
    # Reads the subjects within the UCI HAR Dataset.zip file
    #
    # Args:
    #   path: Defaults to the current directory, where the UCI HAR Dataset.zip file is contained
    #   file: Defaults to the UCI HAR Dataset.zip, the dataset that contains the Samsung data
    #   dataset: Defaults to the training dataset, but test is also a valid value
    #
    # Returns: 
    # The subjects, a data.frame
    full_path = paste(path, file, sep = "/")
    if (!file.exists(full_path) || (dataset != "train" && dataset != "test"))
        stop("Invalid path to Samsung dataset. File does not exist.")

    # The unz function allows reading a zipped file
    # This line reads the subjects, train/subject_train.txt or test/subject_test.txt in the zip file
    subjects <- read.table(unz(full_path, 
                        paste("UCI HAR Dataset/", dataset, "/subject_", dataset, ".txt", sep = "")), 
                        header = F)
 
    # The column names of the dataset is assigned as "subject"
    colnames(subjects) <- c("subject")

    # A new column is added the data.frame called id, which is the row number of the subject in the file
    subjects <- subjects %>% mutate(id = seq.int(nrow(subjects)))

    # The subject data.frame is returned
    subjects
}

read.features <- function(path = ".", file = "UCI HAR Dataset.zip") {
    # Reads the feature.txt file within the UCI HAR Dataset.zip
    #
    # Args:
    #   path: Defaults to the current directory, where the UCI HAR Dataset.zip file is contained
    #   file: Defaults to the UCI HAR Dataset.zip, the dataset that contains the Samsung data
    #
    # Returns: 
    # The features, a data.frame
    full_path = paste(path, file, sep = "/")
    if (!file.exists(full_path))
        stop("Invalid path to Samsung dataset. File does not exist.")

    # The unz function allows reading a zipped file
    # This line reads feature.txt in the zip file
    features <- read.table(unz(full_path, 
                        "UCI HAR Dataset/features.txt"), 
                         header = F, stringsAsFactors = F)

    # The feature.txt file is structured with a position (the position of the column in the train/test dataset)
    # and the measurement, which is the variable name of the measurement (e.g. tBodyAcc-mean())
    colnames(features) <- c("position", "measurement")

    # The features data.frame
    features
}

read.activities <- function(path = ".", file = "UCI HAR Dataset.zip") {
    # Reads the activity_labels.txt file within the UCI HAR Dataset.zip
    #
    # Args:
    #   path: Defaults to the current directory, where the UCI HAR Dataset.zip file is contained
    #   file: Defaults to the UCI HAR Dataset.zip, the dataset that contains the Samsung data
    #
    # Returns: 
    # The activities, a data.frame
    full_path = paste(path, file, sep = "/")
    if (!file.exists(full_path))
        stop("Invalid path to Samsung dataset. File does not exist.")

    # The unz function allows reading a zipped file
    # This line reads activity_labels.txt in the zip file
    activities <- read.table(unz(full_path, 
                                 "UCI HAR Dataset/activity_labels.txt"), 
                             header = F, stringsAsFactors = F)

    # The activity_labels.txt file is structured with label (the same labels read in train/y_train.txt and
    # test/y_test.txt), and the descriptive activity name. These are assigned as the column names
    colnames(activities) <- c("label", "activity")

    # The activities data.frame
    activities
}

parse.codebook <- function(path = ".", file = "CodeBook.md") {
    # A CodeBook.md file has been written which contains descriptive names of the mean and 
    # standard deviation measurements for both the time and frequency domain. This file is in the
    # same directory as this script. This file is structured in three space separated columns. 
    # The first column, Actual, contains the actual measurement name, a subset of the 
    # data in the feature.txt file in the dataset (only those with mean() or std() in their names)
    # The second column, Description, contains the descriptive measurement name, that is asked according
    # to the project specification.
    # The third column, Unit, is the unit in which these measurements are taken, g for acceleration and
    # rad/sec for angular velocity. It is assumed the same for both the frequency and time domain signals.
    #
    # The use of the code book itself to both explain what the variable are, and also to provide the
    # descriptive names in the code is inspired by the following post in R bloggers
    # http://www.r-bloggers.com/reading-codebook-files-in-r/
    # Args:
    #   path: Defaults to the current directory, where the UCI HAR Dataset.zip file is contained
    #   file: Defaults to CodeBook.md, that has been written to provide descriptive names to measurements
    #
    # Returns: 
    # The descriptive column names, a data.frame
    full_path = paste(path, file, sep = "/")
    if (!file.exists(full_path))
        stop("Invalid path to column name file. File does not exist.")

    # This line reads CodeBook.md file
    col_names <- read.table(full_path, 
                            header = T, stringsAsFactors = F)

    # The row name is assigned as the "Actual" column name in the code book file, the same name
    # thats contained in the features.txt file in the dataset (only the mean and std dev subset)
    row.names(col_names) <- col_names[["Actual"]]

    # The column names data.frame
    col_names
}

rename.columns <- function(dataset, col_names, name_as = "Description") {
    # Takes the dataset columns, and renames them from the Actual column name
    # in the features.txt file to the descriptive column names that are in the
    # CodeBook.md file.
    #
    # Args:
    #   dataset: The dataset whose column names need to be changed to descriptive ones
    #   col_names: The Actual nae, Description, and Units of the measurements read from the CodeBook.md file
    #   name_as: The column name to rename columns to, which defaults to Long
    #
    # Returns: 
    # The dataset with the new column names    
    for (i in 1:ncol(dataset)) {
        colnames(dataset)[i] <- col_names[colnames(dataset)[i],][[name_as]]
    }
    dataset
}

# Read the activity_labels.txt file within the UCI HAR Samsung dataset. 
# Refer to the function further down this script.
activities <- read.activities()

# Read the features.txt file within the UCI HAR Samsung dataset. 
# Refer to the function further down in this script.
# The function, read_features, assigns column names to the dataset, position and measurement,
# as defined by the structure of the features.txt file within the dataset.
# After reading this file, only those feature names are extracted, which have mean() or 
# std() in their name. This is as instructed in the project specification, to only work with the 
# mean() and standard deviation for each measurement.
features <- read.features() %>% filter(grepl("mean\\(|std\\(", measurement))

# A file has been written, CodeBook.md, that assigns descriptive names to the mean and standard
# deviation column names. This is as per the requirements in the project specification.
# For example, instead of "tBodyAcc-mean()-X", the descritors.txt file maps this to
# "Mean Linear Acceleration on X Axis - Time". In addition, a short abbreviation is also present in the file,
# for the long description. In the example above, the short description is MLAXAT.
# In the following function, this CodeBook.md file is read.
col_names <- parse.codebook()

# Two similar blocks of code below reads the training and test data contained in the compressed dataset.
# The training data block: -
# The read_train_data function takes the features dataset read above, and reads these features from the 
# training data file, train/X_train.txt.
train_data <- read.dataset(features = features)

# The read_train_labels function reads the training labels file, train/y_train.txt.
train_labels <- read.labels()

# The read_train_subjects function reads the training subjects file, train/subject_train.txt.
train_subjects <- read.subjects()

# The three datasets are then joined using the id column, that is assigned to the datasets
# by the functions that read these files in. The id column is just the row number of each
# line in the file.
train <- train_data %>%
    inner_join(train_labels, by = "id") %>% 
    inner_join(train_subjects, by = "id")

# To conserve the physical memory, the unnecessary datasets are then deleted.
rm(train_data, train_labels, train_subjects)

# The test data block: -
# The read_test_data function takes the features dataset read above, and reads these features from the 
# test data file, test/X_test.txt.
test_data <- read.dataset(features = features, dataset = "test")

# The read_test_labels function reads the test labels file, test/y_test.txt.
test_labels <- read.labels(dataset = "test")

# The read_test_subjects function reads the test subjects file, test/subject_test.txt.
test_subjects <- read.subjects(dataset = "test")

# The three datasets are then joined using the id column, that is assigned to the datasets
# by the functions that read these files in. The id column is just the row number of each
# line in the file.
test <- test_data %>%
    inner_join(test_labels, by = "id") %>% 
    inner_join(test_subjects, by = "id")

# To conserve the physical memory, the unnecessary datasets are then deleted.
rm(test_data, test_labels, test_subjects)

# This section of the code follows the project specification: -
# - Merges the training and test data, as instructed in the project specification
# - Renames the columns of the merged dataset with the long description of column names read in Section 1. 
# - Joins it with the activities dataset read in Section 1, by the label column (read via the label datasets)
# - Selects only the required columns (id and label are no longer required)
# - Groups by activity and subject, as instructed in the project specification
# - Summarises the groups by mean of the variables, as instructed in the project specification
# - Writes the summarised dataset out to a file, which needs to be uploaded to the project site.
rbind(train, test) %>%
    rename.columns(col_names) %>%
    inner_join(activities, by = "label") %>%
    select(-c(id, label)) %>%
    group_by(activity, subject) %>%
    summarise("Avg. Mean Accln on X Axis - Time" = mean(`Mean Linear Acceleration on X Axis - Time`),
              "Avg. Mean Accln on Y Axis - Time" = mean(`Mean Linear Acceleration on Y Axis - Time`),
              "Avg. Mean Accln on Z Axis - Time" = mean(`Mean Linear Acceleration on Z Axis - Time`),
              "Avg. Std. Dev. of Accln on X Axis - Time" = mean(`Std. Dev. of Linear Acceleration on X Axis - Time`),
              "Avg. Std. Dev. of Accln on Y Axis - Time" = mean(`Std. Dev. of Linear Acceleration on Y Axis - Time`),
              "Avg. Std. Dev. of Accln on Z Axis - Time" = mean(`Std. Dev. of Linear Acceleration on Z Axis - Time`),
              "Avg. Mean Gravity Accln on X Axis - Time" = mean(`Mean Gravity Acceleration on X Axis - Time`),
              "Avg. Mean Gravity Accln on Y Axis - Time" = mean(`Mean Gravity Acceleration on Y Axis - Time`),
              "Avg. Mean Gravity Accln on Z Axis - Time" = mean(`Mean Gravity Acceleration on Z Axis - Time`),
              "Avg. Std. Dev. of Gravity Accln on X Axis - Time" = mean(`Std. Dev. of Gravity Acceleration on X Axis - Time`),
              "Avg. Std. Dev. of  Gravity Accln on Y Axis - Time" = mean(`Std. Dev. of Gravity Acceleration on Y Axis - Time`),
              "Avg. Std. Dev. of  Gravity Accln on Z Axis - Time" = mean(`Std. Dev. of Gravity Acceleration on Z Axis - Time`),
              "Avg. Mean Jerk Accln on X Axis - Time" = mean(`Mean Jerk Accleration on X Axis - Time`),
              "Avg. Mean Jerk Accln on Y Axis - Time" = mean(`Mean Jerk Accleration on Y Axis - Time`),
              "Avg. Mean Jerk Accln on Z Axis - Time" = mean(`Mean Jerk Accleration on Z Axis - Time`),
              "Avg. Std. Dev. of Jerk Accln on X Axis - Time" = mean(`Std. Dev. of Jerk Accleration on X Axis - Time`),
              "Avg. Std. Dev. of Jerk Accln on Y Axis - Time" = mean(`Std. Dev. of Jerk Accleration on Y Axis - Time`),
              "Avg. Std. Dev. of Jerk Accln on Z Axis - Time" = mean(`Std. Dev. of Jerk Accleration on Z Axis - Time`),
              "Avg. Mean Angular Velocity on X Axis - Time" = mean(`Mean Angular Velocity on X Axis - Time`),
              "Avg. Mean Angular Velocity on Y Axis - Time" = mean(`Mean Angular Velocity on Y Axis - Time`),
              "Avg. Mean Angular Velocity on Z Axis - Time" = mean(`Mean Angular Velocity on Z Axis - Time`),
              "Avg. Std. Dev. of Angular Velocity on X Axis - Time" = mean(`Std. Dev. of Angular Velocity on X Axis - Time`),
              "Avg. Std. Dev. of Angular Velocity on Y Axis - Time" = mean(`Std. Dev. of Angular Velocity on Y Axis - Time`),
              "Avg. Std. Dev. of Angular Velocity on Z Axis - Time" = mean(`Std. Dev. of Angular Velocity on Z Axis - Time`),
              "Avg. Mean Jerk Angular Velocity on X Axis - Time" = mean(`Mean Jerk Angular Velocity on X Axis - Time`),
              "Avg. Mean Jerk Angular Velocity on Y Axis - Time" = mean(`Mean Jerk Angular Velocity on Y Axis - Time`),
              "Avg. Mean Jerk Angular Velocity on Z Axis - Time" = mean(`Mean Jerk Angular Velocity on Z Axis - Time`),
              "Avg. Std. Dev. of Jerk Angular Velocity on X Axis - Time" = mean(`Std. Dev. of Jerk Angular Velocity on X Axis - Time`),
              "Avg. Std. Dev. of Jerk Angular Velocity on Y Axis - Time" = mean(`Std. Dev. of Jerk Angular Velocity on Y Axis - Time`),
              "Avg. Std. Dev. of Jerk Angular Velocity on Z Axis - Time" = mean(`Std. Dev. of Jerk Angular Velocity on Z Axis - Time`),
              "Avg. Mean Magnitude of Accln - Time" = mean(`Mean Magnitude of Linear Accleration - Time`),
              "Avg. Std. Dev. of Magnitude of Accln - Time" = mean(`Std. Dev. of Magnitude of Linear Accleration - Time`),
              "Avg. Mean Magnitude of Gravity Accln - Time" = mean(`Mean Magnitude of Gravity Accleration - Time`),
              "Avg. Std. Dev. of Magnitude of Gravity Accln - Time" = mean(`Std. Dev. of Magnitude of Gravity Accleration - Time`),
              "Avg. Mean Magnitude of Jerk Accln - Time" = mean(`Mean Magnitude of Jerk Accleration - Time`),
              "Avg. Std. Dev. of Magnitude of Gravity Accln - Time" = mean(`Std. Dev. of Magnitude of Jerk Accleration - Time`),
              "Avg. Mean Magnitude of Angular Velocity - Time" = mean(`Mean Magnitude of Angular Velocity - Time`),
              "Avg. Std. Dev. of Magnitude of Angular Velocity - Time" = mean(`Std. Dev. of Magnitude of Angular Velocity - Time`),
              "Avg. Mean Magnitude of Jerk Angular Velocity - Time" = mean(`Mean Magnitude of Jerk Angular Velocity - Time`),
              "Avg. Std. Dev. Magnitude of Jerk Angular Velocity - Time" = mean(`Std. Dev. of Magnitude of Jerk Angular Velocity - Time`),
              "Avg. Mean Accln on X Axis - Frequency" = mean(`Mean Linear Acceleration on X Axis - Frequency`),
              "Avg. Mean Accln on Y Axis - Frequency" = mean(`Mean Linear Acceleration on Y Axis - Frequency`),
              "Avg. Mean Accln on Z Axis - Frequency" = mean(`Mean Linear Acceleration on Z Axis - Frequency`),
              "Avg. Std. Dev. of Accln on X Axis - Frequency" = mean(`Std. Dev. of Linear Acceleration on X Axis - Frequency`),
              "Avg. Std. Dev. of Accln on Y Axis - Frequency" = mean(`Std. Dev. of Linear Acceleration on Y Axis - Frequency`),
              "Avg. Std. Dev. of Accln on Z Axis - Frequency" = mean(`Std. Dev. of Linear Acceleration on Z Axis - Frequency`),
              "Avg. Mean Jerk Accln on X Axis - Frequency" = mean(`Mean Jerk Acceleration on X Axis - Frequency`),
              "Avg. Mean Jerk Accln on Y Axis - Frequency" = mean(`Mean Jerk Acceleration on Y Axis - Frequency`),
              "Avg. Mean Jerk Accln on Z Axis - Frequency" = mean(`Mean Jerk Acceleration on Z Axis - Frequency`),
              "Avg. Std. Dev. of Jerk Accln on X Axis - Frequency" = mean(`Std. Dev. of Jerk Acceleration on X Axis - Frequency`),
              "Avg. Std. Dev. of Jerk Accln on Y Axis - Frequency" = mean(`Std. Dev. of Jerk Acceleration on Y Axis - Frequency`),
              "Avg. Std. Dev. of Jerk Accln on Z Axis - Frequency" = mean(`Std. Dev. of Jerk Acceleration on Z Axis - Frequency`),
              "Avg. Mean Angular Velocity on X Axis - Frequency" = mean(`Mean Angular Velocity on X Axis - Frequency`),
              "Avg. Mean Angular Velocity on Y Axis - Frequency" = mean(`Mean Angular Velocity on Y Axis - Frequency`),
              "Avg. Mean Angular Velocity on Z Axis - Frequency" = mean(`Mean Angular Velocity on Z Axis - Frequency`),
              "Avg. Std. Dev. of Angular Velocity on X Axis - Frequency" = mean(`Std. Dev. of Angular Velocity on X Axis - Frequency`),
              "Avg. Std. Dev. of Angular Velocity on Y Axis - Frequency" = mean(`Std. Dev. of Angular Velocity on Y Axis - Frequency`),
              "Avg. Std. Dev. of Angular Velocity on Z Axis - Frequency" = mean(`Std. Dev. of Angular Velocity on Z Axis - Frequency`),
              "Avg. Mean Magnitude of Accln - Frequency" = mean(`Mean Magnitude of Linear Acceleration - Frequency`),
              "Avg. Std. Dev. of Magnitude of Accln - Frequency" = mean(`Std. Dev. of Magnitude of Linear Acceleration - Frequency`),
              "Avg. Mean Magnitude of Jerk Accln - Frequency" = mean(`Mean Magnitude of Jerk Acceleration - Frequency`),
              "Avg. Std. Dev. of Magnitude of Jerk Accln - Frequency" = mean(`Std. Dev. of Magnitude of Jerk Acceleration - Frequency`),
              "Avg. Mean Magnitude of Angular Velocity - Frequency" = mean(`Mean Magnitude of Angular Velocity - Frequency`),
              "Avg. Std. Dev. of Magnitude of Angular Velocity - Frequency" = mean(`Std. Dev. of Magnitude of Angular Velocity - Frequency`),
              "Avg. Mean Magnitude of Jerk Angular Velocity - Frequency" = mean(`Mean Magnitude of Jerk Angular Velocity - Frequency`),
              "Avg. Std. Dev. of Magnitude of Jerk Angular Velocity - Frequency" = mean(`Std. Dev. of Magnitude of Jerk Angular Velocity - Frequency`)
    ) %>%
    write.table(file = "tidy_dataset.txt", row.names = F)

# Remove all unnecessary datasets from memory
rm(activities, col_names, features, test, train)