# Network Traffic Data Analysis: Identifying Attack Signatures

A data-driven approach to analyzing network traffic patterns and identifying cyberattack signatures using machine learning techniques in R.

## Overview

This project performs comprehensive analysis of network traffic data to identify and classify various types of cyberattacks. Using source packets (spkts) and destination packets (dpkts) as primary features, the analysis includes data cleaning, exploratory data analysis (EDA), and supervised machine learning models to distinguish between normal traffic and attack patterns.

## Project Structure

```
Network-Traffic-Data-Analysis/
├── Analysis.R                                              # Main analysis and ML modeling script
├── Cleaning.R                                              # Data preprocessing and cleaning script
├── Data-Driven-Network-Traffic-Analysis-Identifying-Attack-Signatures.pdf
└── data_cleaning_documentation.docx                        # Data cleaning documentation
```

## Dataset

The project analyzes a cyberattacks dataset containing network traffic data with the following key features:

- **spkts**: Source packets - number of packets sent from source
- **dpkts**: Destination packets - number of packets sent to destination
- **label**: Binary indicator (0 = No Attack, 1 = Attack)
- **attack_cat**: Attack category classification

### Attack Categories

The dataset includes the following attack types:
- Analysis
- Backdoor
- DoS (Denial of Service)
- Exploits
- Reconnaissance
- Shellcode
- Fuzzers
- Generic
- Worms
- Normal (no attack)

### Dataset Statistics

- Total records: 175,341
- Attack records: 120,483 (68.7%)
- Missing values after cleaning: ~3,523 (2%)

## Requirements

### R Dependencies

```r
library(dplyr)           # Data manipulation
library(ggplot2)         # Data visualization
library(tidyr)           # Data tidying
library(caret)           # Machine learning framework
library(e1071)           # Support Vector Machine
library(Metrics)         # Model evaluation metrics
library(corrplot)        # Correlation visualization
library(nnet)            # Neural networks
library(caretEnsemble)   # Ensemble methods
library(randomForest)    # Random Forest implementation
library(pROC)            # ROC curve analysis
```

Install all dependencies:
```r
install.packages(c("dplyr", "ggplot2", "tidyr", "caret", "e1071",
                   "Metrics", "corrplot", "nnet", "caretEnsemble",
                   "randomForest", "pROC"))
```

## Usage

### 1. Data Cleaning and Preprocessing

Run [Cleaning.R](Cleaning.R) to prepare the raw dataset:

```r
source("Cleaning.R")
```

This script performs:
- Data type validation and conversion
- Removal of whitespaces and invalid characters
- Handling missing values (NA, NAAN, empty strings)
- Range validation (ensuring non-negative packet counts)
- Z-score standardization for spkts and dpkts
- Data export to cleaned CSV format

### 2. Analysis and Modeling

Run [Analysis.R](Analysis.R) to perform comprehensive analysis and build predictive models:

```r
source("Analysis.R")
```

**Note**: Update the file path in line 20 to point to your cleaned dataset location:
```r
dataset_original <- read.csv("path/to/your/cleaned_dataset.csv")
```

## Analysis Pipeline

### Step 1: Data Import and Validation
- Import cleaned dataset
- Additional NA and infinite value removal
- Data type conversion and validation

### Step 2: Exploratory Data Analysis (EDA)

#### Statistical Summary
- Group-wise statistics by attack category
- Mean and median calculations for packet counts
- Ratio analysis (spkts/dpkts)

**Key Findings**:
- Attack traffic: Low medians (sparse/short connections), high means (occasional bursts)
- Normal traffic: Higher median values (continuous, consistent packets)
- Normal traffic ratio: ~1.13 (spkts/dpkts)

#### Distribution Analysis
- Histogram visualization (1000 bins, zoomed to 0-300 range)
- Q-Q plots for normality assessment
- Outlier detection (values >2500 predominantly in attack categories)
- Most frequent packet counts fall within 0-50 range

**Normality Assessment**:
- Data is not normally distributed for both spkts and dpkts
- Distribution ranges between -3 to 2 standard deviations
- Significant outliers exist in attack categories

### Step 3: Visualization

#### Scatter Plot Analysis
- spkts vs dpkts colored by attack label
- Faceted plots by attack category
- Focused comparison of Fuzzers, Generic, Worms, and Normal traffic

**Observations**:
- Easy to distinguish: Analysis, Backdoor, DoS, Exploits, Reconnaissance, Shellcode
- More challenging: Fuzzers, Generic, Worms
- Greatest confusion occurs in 0-50 packet range

### Step 4: Feature Engineering

Created logarithmic transformations to reduce outlier influence:
- **log_spkts**: log1p(spkts)
- **log_dpkts**: log1p(dpkts)

### Step 5: Machine Learning Models

#### Data Splitting
- Training set: 80%
- Test set: 20%
- Stratified sampling based on label distribution

#### Model 1: Logistic Regression (Multinomial)

**Configuration**:
- Method: Multinomial logistic regression
- Features: spkts, dpkts, log_spkts, log_dpkts
- Cross-validation: 5-fold repeated CV (2 repeats)
- Sampling: Upsampling to handle class imbalance
- Metric: ROC

**Performance**:
- Accuracy: ~78%
- Note: Results may be affected by dataset bias toward attack types

#### Model 2: Random Forest

**Configuration**:
- Method: Ranger (fast implementation of Random Forest)
- Features: spkts, dpkts, log_spkts, log_dpkts
- Trees: 1000
- Cross-validation: 5-fold repeated CV (2 repeats)
- Tuning: 10 parameter combinations
- Metric: ROC

**Performance**:
- Accuracy: ~86%
- Superior performance compared to logistic regression
- Better handling of non-linear relationships

## Key Insights

### Traffic Pattern Characteristics

1. **Normal Traffic**:
   - Median spkts: ~12
   - Median dpkts: ~10
   - spkts/dpkts ratio: ~1.13
   - Continuous, consistent packet flow

2. **Attack Traffic**:
   - Lower medians (sparse connections)
   - Higher means (burst patterns)
   - Greater variability in packet counts
   - Presence of extreme outliers (>2500 packets)

3. **Classification Challenges**:
   - Overlap in 0-50 packet range between normal and attack traffic
   - Fuzzers, Generic, and Worms harder to distinguish
   - Data imbalance favoring attack samples

### Model Comparison

| Model | Accuracy | Strengths | Limitations |
|-------|----------|-----------|-------------|
| Logistic Regression | ~78% | Simple, interpretable | Affected by class imbalance |
| Random Forest | ~86% | Better accuracy, handles non-linearity | Potential dataset bias |

## Methodology

1. **Data Preprocessing**: Comprehensive cleaning, validation, and standardization
2. **Exploratory Analysis**: Statistical summaries, distribution analysis, visualization
3. **Feature Engineering**: Logarithmic transformations to handle outliers
4. **Model Training**: Supervised learning with cross-validation
5. **Evaluation**: Confusion matrices, accuracy metrics, ROC analysis

## Files Description

### Analysis.R
Main analysis script containing:
- Statistical analysis and EDA
- Distribution visualization
- Correlation analysis
- Machine learning model training and evaluation

### Cleaning.R
Data preprocessing script that:
- Validates and converts data types
- Handles missing and invalid values
- Performs range checks
- Applies z-score standardization
- Exports cleaned dataset

## Future Improvements

Potential enhancements to consider:
1. Address class imbalance using SMOTE or other advanced techniques
2. Feature expansion (add network protocol features, time-based features)
3. Ensemble methods combining multiple models
4. Deep learning approaches for complex pattern recognition
5. Real-time traffic analysis capabilities
6. Multi-class classification for specific attack types

## Results Summary

The analysis successfully demonstrates that network traffic patterns can be used to identify cyberattacks with reasonable accuracy. The Random Forest model achieved 86% accuracy in distinguishing between normal traffic and various attack types using only packet count features. The project highlights the importance of:

- Proper data cleaning and preprocessing
- Feature engineering for outlier management
- Understanding distribution characteristics
- Selecting appropriate algorithms for non-linear patterns

## Author

Maria Ivanova

## License

This project is available for educational and research purposes.

## References

See [Data-Driven-Network-Traffic-Analysis-Identifying-Attack-Signatures.pdf](Data-Driven-Network-Traffic-Analysis-Identifying-Attack-Signatures.pdf) for detailed analysis and findings.
