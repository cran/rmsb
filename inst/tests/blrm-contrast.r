require(rmsb)
cstanSet()
n <- 1000
set.seed(8)
y <- sample(1:5, n, prob=c(.1, .2, .35, .35, .05), replace=TRUE)
table(y)
mean(y)
x <- sample(0:1, n, replace=TRUE)
means <- tapply(y, x, mean)
means
dd <- datadist(x); options(datadist='dd')
f <- orm(y ~ x)
M <- Mean(f)
M
lp <- Predict(f)
lp
lp <- lp$yhat
lp
M(lp)
means

g <- blrm(y ~ x)
M <- Mean(g)
g
k <- contrast(g, list(x=1), list(x=0), fun=M)
k
plot(k)

# Y is too discrete for quantiles here but do the median anyway
qu <- Quantile(g)
med <- function(lp, intercepts, lptau, codes)
  qu(0.5, lp, intercepts=intercepts, lptau=lptau, codes=codes)
contrast(g, list(x=1), list(x=0), fun=med)
