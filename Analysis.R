
# Libraries
library(dplyr)
library(ggplot2)
library(tidyr)
library(dplyr)
library(ggplot2)
library(caret)      # For data splitting and model evaluation
library(e1071)      # For SVM model
library(Metrics)    # For calculating accuracy and metrics
library(corrplot)   # For correlation visualization
library(nnet)
library(caret)
library(caretEnsemble)
library(randomForest)
library(pROC)


# Step 1. IMPORT ORIGINAL DATASET
dataset_original <- read.csv("/Users/mariaivanova/Downloads/cleaned_dataset.csv")

dataset <- dataset_original

# Step 2. CLEANING REASSURANCE

# Ensure to exclude NA 
dataset <- dataset[!is.na(dataset$spkts) & !is.infinite(dataset$spkts), ]
dataset <- dataset[!is.na(dataset$dpkts) & !is.infinite(dataset$dpkts), ]

# Ensure label is numeric (0 or 1)
dataset <- dataset %>% mutate(label = as.numeric(as.character(label)))

# Ensure metrics are numeric
dataset <- dataset %>%
  mutate(spkts = as.numeric(spkts), dpkts = as.numeric(dpkts))


# Step 3.  STATISTICS DATA
dataset %>%
  group_by(attack_cat) %>%
  summarise(
    count = n(),
    mean_dpkts = mean(dpkts),
    median_dpkts = median(dpkts),
    mean_spkts = mean(spkts),
    median_spkts = median(spkts)
  )

# Observations:
# Medians are low for attacks,  attacks are mostly sparse/short.
# Means are high for some attacks, there are occasional bursts.
# Normal traffic has higher median, continuous traffic generates more consistent packets.

# Step 4. SPKTS / DPKTS RATIO
dataset_ratio <- dataset %>%
  mutate(sd_ratio = ifelse(dpkts == 0, NA, spkts / dpkts))

dataset_ratio %>%
  group_by(attack_cat) %>%
  summarise(avg_ratio = mean(sd_ratio, na.rm = TRUE))

# Hypothesis pattern for future use 
#1) ratio around  1.13 2) median dpkt is 10 median spkts is 12 


# Step 5. HISTOGRAMS OF SPKTS AND DPKTS

# 1000 bins total 
num_bins <- 1000
bin_width_spkts <- (max(dataset$spkts) - min(dataset$spkts)) / num_bins
bin_width_dpkts <- (max(dataset$dpkts) - min(dataset$dpkts)) / num_bins

# Observation: historgram with full range of spkts and dpkts is not informative 
#due to large outliers. 
#For visualization purposes the histograms are zoomed to 300
hist(dataset$spkts,
     main = "Histogram of spkts (zoomed to 300)",
     xlab = "spkts",
     col = "lightgreen",
     border = "black",
     xlim = c(0, 300), # zoom to 300
     breaks = seq(min(dataset$spkts), max(dataset$spkts), by = bin_width_spkts)
)

hist(dataset$dpkts,
     main = "Histogram of dpkts (zoomed to 300)",
     xlab = "spkts",
     col = "lightgreen",
     border = "black",
     xlim = c(0, 300),   # zoom to 300
     breaks = seq(min(dataset$dpkts), max(dataset$dpkts), by = bin_width_dpkts)
)
#Observation: the vast majority of repeated spkts and dpkts lays within 0:50 range


# Step 6. VISUALIZE NORMAL DISTRIBUTION

# Deep visualization - manual process 
manual_qq_plot <- function(data) {
  print(data)
  # Step 1: Sort the data
  sorted_data <- sort(data)
  # Step 2: Calculate the number of data points
  n <- length(data)
  
  # Step 3: qnorm function to get quantiles from a standard normal distribution
  theoretical_quantiles <- qnorm((1:n) / (n + 1))
  
  # Step 4: Plot the data quantiles against the theoretical quantiles
  plot(theoretical_quantiles, sorted_data,
       xlab = "Normal Distribution",
       ylab = "Data",
       main = "",
       pch = 16, col = "blue")
  
}

manual_qq_plot(dataset$dpkts)
manual_qq_plot(dataset$spkts)


# Step 7. SCATTER SPKTS VS DPKTS COLORED BY ATTACK 
p_scatter <- ggplot(dataset, aes(x = spkts, y = dpkts, color = factor(label))) +
  geom_point(alpha = 0.4, size = 1.2, na.rm = TRUE) +
  labs(title = "spkts vs dpkts (color = label)", color = "Attack") +
  theme_minimal()

p_scatter

#Observation: the normal attack has a ratio closer to value a bit above 1 (timidly higher
#than 1:1 ratio)




# Step 8.1 CORRELATIONS BY ATTACK CATEGORY
ggplot(dataset, aes(x = dpkts, y = spkts)) +
  geom_point(alpha = 0.3) +       # Scatter points with some transparency
  facet_wrap(~attack_cat, scales = "free") +  
  labs(
    title = "Correlation between spkts and dpkts by attack category",
    x = "dpkts (destination packets)",
    y = "spkts (source packets)"
  ) +
  theme_minimal()

# Observation:
# Easy to identify the Analysis, Backdoor, DoS, Exploits, Reconnaissanse, Shellcode. 
# Harder: Fuzzers, Generic, Worms.


# Step 8.2 SCATTER PLOT FOR GENERIC, GENERIC, WORMS AND NORMAL
selected_data <- dataset %>%
  filter(attack_cat %in% c("Fuzzers", "Generic", "Worms", "Normal"))

# Scatter plot for specified data categories
ggplot(selected_data, aes(x = dpkts, y = spkts, color = attack_cat)) +
  geom_point(alpha = 0.5) +                 # points
  labs(
    title = "spkts vs dpkts for attack categories: Fuzzers, Generic, Normal, Worms",
    x = "dpkts (destination packets)",
    y = "spkts (source packets)",
    color = "Attack Category"
  ) +
  theme_minimal() +
  theme(legend.position = "right")



# biggest confusion may occur where the variation of skpts and dpkts are between 0 and 50
# MAIN CONCLUSIONS
# My observation, 
# there are some outliers with values 2500 and more ( 2.4 to 4 normality), and there are not common, all outliers belong to categories of attack 
# beween -3 to 2 of normality ( data is nto normally distibuted for both spkts and dpkts)
# 
# Medians are low for attacks → attacks are mostly sparse/short.
# Means are high for some attacks → there are occasional bursts.
# Normal traffic has higher median → continuous traffic generates more consistent packets.
# biggest confusion may occur where the variation of skpts and dpkts are between 0 and 50
# for normaL attack_cat (no attack) the ration spkts /dpkts about 1.13 , the median for spkts - 10 for spkts - 12


# Exploratory Data Analysis (EDA)
# You visually and numerically explored the distributions of spkts and dpkts.
# Observed patterns like outliers (values > 2500), sparsity of attacks, and typical ranges for normal traffic.
# Compared different attack_cat groups to understand how traffic differs.
# Noted potential confusion areas where attack and normal traffic overlap.
# Descriptive Statistics
# Calculated medians and means to summarize the data for each attack_cat.
# Interpreted the relationship between mean and median to identify sparsity vs bursts in traffic.
# Calculated ratios like spkts/dpkts for normal traffic to understand packet flow characteristics.
# Outlier Detection / Distribution Analysis
# Noted extreme values (outliers) in attack categories.
# Assessed normality (data is not normally distributed between -3 and 2) to understand the spread of traffic.



# ADDITIONAL FEATURES: SUPERVISED LEARNING (LOGREG AND RANDOM FOREST)

# Step 9. CREATE LOG_SPKTS AND LOG_DPKTS
# Explanatation: to reduce the outliers influence on models
dataset <- dataset_original %>%
  mutate(
    spkts = as.numeric(spkts),
    dpkts = as.numeric(dpkts),
    log_spkts = log1p(spkts),
    log_dpkts = log1p(dpkts),
  ) %>%
  filter(!is.na(spkts), !is.na(dpkts), !is.na(label), !is.na(attack_cat))


# because the label is 0 or 1 = numeric, algorithm will perceive it 
# as a regression (continuous)
# To prevent mismatching the flag feature is created: 0=NoAttack, 1= Attack.
dataset$flag <- factor(dataset$label, levels = c(0,1), labels = c("NoAttack","Attack"))
head(dataset)

# Step 10. TRAIN/TEST SPLIT (80%/20%) STRATIFIER
train_index <- createDataPartition(
  dataset$label, 
  p = 0.8, 
  list = FALSE
)

train_data <- dataset[train_index, ]
test_data  <- dataset[-train_index, ]
 

#Step 11.CREATE TRAINCONTROL OBJECTS (logic for training models)

#Used for Logistic Regression
ctrl_bal <- trainControl(
  method = "repeatedcv",
  number = 5,
  repeats = 2,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  sampling = "up"
)


#Used for Random Forest
ctrl_two <- trainControl(
  method = "repeatedcv",
  number = 5,
  repeats = 2,
  classProbs = TRUE,
  summaryFunction = twoClassSummary
)


# Step 12. TRAIN LOGISTIC REGRESSION
# settings the seed
set.seed(345)
glm_fit <- train(
  flag ~ spkts + dpkts + log_spkts + log_dpkts,
  data = train_data,
  method = "multinom",
  metric = "ROC",
  trControl = ctrl_bal,
  maxit = 200
)

#train
glm_fit

#predict
glm_preds_class <- predict(glm_fit, test_data)


#Confusion Matrix 
confusionMatrix(
  glm_preds_class,
  test_data$flag   # actual labels
)


# RESULTS
# ACCURACY AROUND 0.78 
# POSSIBLE CAUSE BIASED DATASET TO ATTACK TYPE



# STEP 13. TRAIN RANDOM FOREST
set.seed(456)
rf_model <- train(
  flag ~ spkts + dpkts + log_spkts + log_dpkts,
  data = train_data,
  method = "ranger",
  metric = "ROC",
  trControl = ctrl_two,
  tuneLength = 10,
  num.trees = 1000
)

# train
rf_model
# predict
rf_pred_class <- predict(rf_model, test_data)


results <- data.frame(
  Actual = test_data$flag,
  Pred_Prob_Attack = rf_pred_prob,
  Pred_Class = ifelse(rf_pred_prob > 0.5, "Attack", "NoAttack")
)


# Which predictions are wrong
results$Correct <- results$Actual == results$Pred_Class
head(results)
table(results$Correct)
confusionMatrix(rf_pred_class, test_data$flag)


# RESULTS
# ACCURACY AROUND 0.86