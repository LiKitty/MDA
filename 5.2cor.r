
#correlation
x=c(7,8,9,10,11) 
y=c(0.25,0.28,0.65,0.7,1.14)
xm<- mean(x)
ym<-mean(y)
r<- sum((x-xm)*(y-ym))/ (sum((x-xm)^2)*sum((y-ym)^2))^0.5
cor(x,y)

#adjusted r
r2<-r-r*(1-r^2)/(2*5)


## Spearman's rho  and  Kendall's tau, (��Ҫ������)
?cor
?longley
symnum(clS <- cor(longley, method = "spearman"))
symnum(clK <- cor(longley, method = "kendall"))


#autocorrelation
?lh
lh
t<-acf(lh)
t
?acf


#Partial correlation
#install.packages("ppcor")
library(ppcor)
# data
y.data <- data.frame(
  hl=c(7,15,19,15,21,22,57,15,20,18),
  disp=c(0.000,0.964,0.000,0.000,0.921,0.000,0.000,1.006,0.000,1.011),
  deg=c(9,2,3,4,1,3,1,3,6,1),
  BC=c(1.78e-02,1.05e-06,1.37e-05,7.18e-03,0.00e+00,0.00e+00,0.00e+00 ,4.48e-03,2.10e-06,0.00e+00)
)
# partial correlation
pcor(y.data) 

