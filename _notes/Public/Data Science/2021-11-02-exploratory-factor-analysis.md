---
layout: Post
title:  "R - Exploratory Factor Analysis"
date:   2021-11-02 01:51:27
categories: r
tags: [r, data science]
---

Factor analysis is a statistical method used to search for some unobserved variables called factors from observed variables called factors. There are two variations: exploratory factor analysis (EFA) and confirmatory factor analysis (CFA).

We will review the preliminary steps to factor analysis including examining the data and the assumptions required for factor analysis and how to determine the number of factors to retain.

In R we need to use the packages `psych` [link](https://cran.r-project.org/web/packages/psych/index.html), `corrplot` [link](https://cran.r-project.org/web/packages/corrplot/vignettes/corrplot-intro.html)and `rms` [link](https://rdocumentation.org/packages/rms/versions/6.2-0) . For plotting we use `ggplot2`.

```
library(psych)
library(corrplot)
library(rms) # used for vif
library(ggplot2)
```

## 1. Describing Data

### Fetching data from the server

We first need to fetch sample data from the server. This is a raw data set, so each row row represents a person’s survery.

```
url <- "https://raw.githubusercontent.com/housecricket/data/main/efa/sample1.csv"
data_survey <- read.csv(url, sep = ",")
```

### Describing the data

We also look at the dataset before we run any analysis.

```
describe(data_survey)
```

We use the dim function to retrieve the dimension of the dataset.

```
dim(data_survey)
```

### Cleaning data

In our data frame, we have an ID variable in the first column. So, we can use a -1 in the column index to remove the first column and save our data to a new object.

```
data <- data_survey[ , -1] 
head(data)
```

### Correlation matrix

We also should take a look at the correlations among our variables to determine if factor analysis is appropriate.

```
datamatrix <- cor(data[,c(-13)])
corrplot(datamatrix, method="number")
```

## 2. Factorability of the Data

```
X <- data[,-c(13)]
Y <- data[,13]
```

### KMO
The Kaiser-Meyer-Olkin (KMO) used to measure sampling adequacy is a better measure of factorability.

```
KMO(r=cor(X))
```

According to Kaiser’s 1974 guidelines (Kaiser, H.F. An index of factorial simplicity. Psychometrika 39, 31–36 (1974)), a suggested cutoff for determining the factorability of the sample data is KMO ≥ 60. The total KMO is 0.83, indicating that, based on this test, we can probably conduct a factor analysis.

### Bartlett’s Test of Sphericity

```
cortest.bartlett(X)
```

Small values (8.84e-290 < 0.05) of the significance level indicate that a factor analysis may be useful with our data.

```
det(cor(X))
```

We have a positive determinant, which means the factor analysis will probably run.

## 3. Number of Factors to Extract

### Scree Plot

```
fafitfree <- fa(data, nfactors = ncol(X), rotate = "none")
n_factors <- length(fafitfree$e.values)
scree     <- data.frame(
  Factor_n =  as.factor(1:n_factors), 
  Eigenvalue = fafitfree$e.values)
ggplot(scree, aes(x = Factor_n, y = Eigenvalue, group = 1)) + 
  geom_point() + geom_line() +
  xlab("Number of factors") +
  ylab("Initial eigenvalue") +
  labs( title = "Scree Plot", 
        subtitle = "(Based on the unreduced correlation matrix)")+
  theme_minimal()
```

### Parallel Analysis

We can use the parallel() function from the nFactors package [(Raiche & Magis, 2020)](http://www2.hawaii.edu/~georgeha/Handouts/meas/Exercises/_book/efa.html#ref-R-nFactors) to perform a parallel analysis.

```
parallel <- fa.parallel(X)
```

Parallel analysis suggests that the number of factors =  4 and the number of components =  3

## 4. Conducting the Factor Analysis

### Factor analysis using fa method

```
fa.none <- fa(r=X, 
 nfactors = 4, 
 # covar = FALSE, SMC = TRUE,
 fm="pa", # type of factor analysis ("pa" is principal axis factoring)
 max.iter=100, # (default is 50)
 rotate="varimax") # none rotation
print(fa.none)
```

### Factor analysis using the factanal method

```
factanal.none <- factanal(X, factors=4, 
  scores = c("regression"), 
  rotation = "varimax")
print(factanal.none)
```

### Graph Factor Loading Matrices

```
fa.diagram(fa.none)
```

---

## 5. Regression analysis

Scores for all the rows

```
head(fa.var$scores)
```

### Labeling the data

```
regdata <- cbind(data["QD"], fa.var$scores)
#Labeling the data
names(regdata) <- c("QD", "F1", "F2", "F3", "F4")
head(regdata)
```

### Splitting the data to train and test set

```
#Splitting the data 70:30
#Random number generator, set seed.
set.seed(100)
indices= sample(1:nrow(regdata), 0.7*nrow(regdata))
train=regdata[indices,]
test = regdata[-indices,]
```

### Regression Model using train data

```
model.fa.score = lm(Satisfaction~., train)
summary(model.fa.score)
```

Our model equation can be written as: Y = 3.55309 + 0.72628 x F1 + 0.29138 x F2 + 0.06935 x F3 + 0.62753 x F4

### Check Variance Inflation Factor

```
vif(model.fa.score)
```

### Check prediction of the model in the test dataset

```
#Model Performance metrics:
pred_test <- predict(model.fa.score, newdata = test, type = "response")
pred_test
test$QD_Predicted <- pred_test
head(test[c("QD","QD_Predicted")], 10)
```



