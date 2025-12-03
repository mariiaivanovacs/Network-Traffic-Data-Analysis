# Data import plus cleaning + preprocessing

# import all data 
df <- read.csv("/Users/mariaivanova/Downloads/cyberattacks_dataset.csv")
typeof(df)
# Display rows where label is NA

# Plan 
# 1. Validate data type 
# 2. Missing values inspection
# 3. Range and validity checks 
# 4. Visualize to catch outliers (if yes - long-transforming) 
# 5. Scaling
# 6. Store cleaned dataset

# Step 1 
str(df$dpkts)
str(df$spkts)
# current type - character

# Step 2
# remove whitespaces, replace blanks and NAAN with NA 
df$dpkts <- trimws(df$dpkts)

# look for instances if they have punctiation characters on letters 
length(df$dpkts[grepl("[^A-Za-z0-9.-]", df$dpkts) ]) # current 35069


# remove all characters expect of 0-9 , "."
df$dpkts <- gsub("[^0-9.]", "", df$dpkts)

# if "" left, replace them with NA
df$dpkts[df$dpkts == ""] <- NA

length(df$dpkts[grepl("[^A-Za-z0-9.]", df$dpkts) ]) # now 0


# Additional in case if some instances are "NAAN"
df$dpkts[df$dpkts == "NAAN"] <- NA

# convert to float (numeric)
df$dpkts <- as.numeric(df$dpkts)

#check type 
class(df$dpkts) # now corrent - float
df$dpkts
# Step 3 

# dpkts - validation boundaries  dpkts > 0 
length(df$dpkts[ ! is.na(df$dpkts) & df$dpkts < 0]) # no negative values 

# Step 4 
# boxplot(df$dpkts, main = "Boxplot of dpkts", ylab = "dpkts")
hist(df$spkts, breaks = 500, main = "Distribution of dpkts", xlab = "dpkts", xlim = range(0, 1000), ylim = range(0, 1000))
# Step 5 
#values for dpkts are ranging from 0 to 10974 and above , better with scaling
# chosen scaling - z-score standartization
min(df$dpkts, na.rm=TRUE)
max(df$dpkts, na.rm=TRUE)
df$dpkts_z <- scale(df$dpkts)
# Do the same  for skpts , but convert to int

# Step 2
df$spkts <- trimws(df$spkts)
length(df$spkts[grepl("[^A-Za-z0-9.]", df$spkts) ]) # current 35069
df$spkts <- gsub("[^e0-9.]", "", df$spkts)
df$spkts[df$spkts == ""] <- NA
df$spkts[df$spkts == "NAAN"] <- NA
#convert to integer
df$spkts <- as.integer(df$spkts)
length(df$spkts[grepl("[^A-Za-z0-9.]", df$spkts) ]) # now 0 

#check type 
class(df$spkts) # now corrent - float
df$spkts

# Step 3

# spkts - validation boundaries  spkts > 0 
length(df$spkts[ ! is.na(df$spkts) & df$spkts < 0]) # no negative values 

# Step 4 visualize to find outliers 

# hist(df$spkts, breaks = 500, main = "Distribution of spkts", xlab = "spkts", xlim = range(0, 1000), ylim = range(0, 50000))
hist(df$spkts, breaks = 500, main = "Distribution of spkts", xlab = "spkts", xlim = range(0, 1000), ylim = range(0, 10))

# Step 5 
# spkts values varies from 1 to 9616, better apply scaling 
# chosen scaling - z-score standartization
min(df$spkts, na.rm=TRUE)
max(df$spkts, na.rm=TRUE)
df$spkts_z <- scale(df$spkts)


# For id column assign sequence from scratch
df$id <- seq_len(nrow(df))
# check so no NA 
str(df$id)
length(df$id[is.na(df$id)]) # no negative values 

# APPLY STEPS 1-3 to label column (feature) o - absence of attack, 1 - presence of attack 

df$label <- trimws(df$label)
df$label <- gsub("[^0-1]", "", df$label)
df$label[df$label == ""] <- NA
df$label[df$label == "NAAN"] <- NA
length(df$label[is.na(df$label)]) # label results have 3523 states - NA out of 175341 = 0.02 %

df$label <- as.integer(df$label)

nrow(df[df$label == 1, ]) # in dataset 120483 rows are with label 1 - presence of attack

# Store cleaned dataset

write.csv(df, "/Users/mariaivanova/Downloads/cleaned_dataset.csv", row.names = FALSE)

