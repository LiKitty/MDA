#you need to change to your own working directory
setwd("D:/working/teaching/�������ݷ�����Ӧ��/code")
#descriotion of the data is here: http://fluxnet.fluxdata.org/data/fluxnet2015-dataset/subset-data-product/
#lae <- read.csv("./data/FLX_CH-Lae_FLUXNET2015_SUBSET_DD_2004-2014_1-3.csv")
#blo <- read.csv("./data/FLX_US-Blo_FLUXNET2015_SUBSET_DD_1997-2007_1-3.csv")
kru <- read.csv("./data/FLX_ZA-Kru_FLUXNET2015_SUBSET_DD_2000-2010_1-3.csv")

# get out irrelavant variables
#kru <- kru[,1:36]
kru <- kru[,-grep("_QC",names(kru))]
names(kru)

#set -9999 to NA
kru[kru==-9999] <-NA
summary(kru)
#seprate the dataset into training and testing dataset
set.seed ( 1 )
index <- sample ( nrow (kru ) , 3500) 
train <- kru [ index , ]
test <- kru [ - index , ]
summary ( train $ SWC_F_MDS_1 )
summary ( test $ SWC_F_MDS_1 )


#formular to be used
#use only atmospere forcing
f1 <- SWC_F_MDS_1 ~TA_F+SW_IN_POT+SW_IN_F+LW_IN_F+VPD_F+PA_F+P_F+WS_F
#adding co2, GPP and soil temperature
f2 <-  SWC_F_MDS_1 ~ TA_F+SW_IN_POT+SW_IN_F+LW_IN_F+VPD_F+PA_F+P_F+WS_F+CO2_F_MDS +GPP_DT_VUT_REF+ TS_F_MDS_1


# only use varibales without too many NA, as many as possible
summary(kru)
f3 <-  SWC_F_MDS_1 ~ TA_F+SW_IN_POT+SW_IN_F+LW_IN_F+VPD_F+PA_F+P_F+WS_F+CO2_F_MDS + TS_F_MDS_1+  LE_F_MDS + H_F_MDS+  NEE_VUT_REF +NEE_VUT_25+NEE_VUT_50+ NEE_VUT_75+RECO_NT_VUT_REF+RECO_NT_VUT_25+RECO_NT_VUT_50+RECO_NT_VUT_75+GPP_NT_VUT_REF+GPP_NT_VUT_25+GPP_NT_VUT_50+GPP_NT_VUT_75+RECO_DT_VUT_REF+RECO_DT_VUT_25 +RECO_DT_VUT_50+RECO_DT_VUT_75+GPP_DT_VUT_REF+ GPP_DT_VUT_25+GPP_DT_VUT_50 +GPP_DT_VUT_75 




#############################################
#the flowing use f3  as an example, you may try f1,f2 with a simple model
########################
#decision tree
#install.packages("tree",repos ="https://mirrors.tuna.tsinghua.edu.cn/CRAN/")
library ( tree )
tree.swc1 <- tree ( f3, train)
summary ( tree.swc1 )
plot ( tree.swc1 )
text ( tree.swc1 , pretty = 0 )
tree.swc1
tree.pred <- predict ( tree.swc1 , test )

cv.swc1 <- cv.tree ( tree.swc1 )
cv.swc1
plot ( cv.swc1 $ size , cv.swc1 $ dev , type = "b" , xlab = "Tree size" , ylab = "Error" )
prune.swc1 <- prune.tree ( tree.swc1 , best = 13)
plot ( prune.swc1 )
text ( prune.swc1 , pretty = 0)
cv.tree.pred <- predict ( prune.swc1 , test)
#MSE
sum(( cv.tree.pred - test $ SWC_F_MDS_1 )^2,na.rm=T)/length(na.omit(cv.tree.pred))
# 3.490548
#R2
tse <- sum((test$SWC_F_MDS_1-mean(test$SWC_F_MDS_1,na.rm=T))^2,na.rm=T)
sse <- sum((test$SWC_F_MDS_1-cv.tree.pred)^2,na.rm=T)
1-sse/tse
#0.6373356


# Bagging
#install.packages("randomForest",repos ="https://mirrors.tuna.tsinghua.edu.cn/CRAN/")
library ( randomForest )
set.seed ( 1 )
bag.swc1 <- randomForest ( f3 , data = train ,mtry=32, importance = TRUE ,na.action=na.omit)
bag.pred.swc1 <- predict ( bag.swc1 , newdata = test )
#MSE
sum(( bag.pred.swc1 - test $ SWC_F_MDS_1 )^2,na.rm=T)/length(na.omit(bag.pred.swc1))
#1.826828
#R2
tse <- sum((test$SWC_F_MDS_1-mean(test$SWC_F_MDS_1,na.rm=T))^2,na.rm=T)
sse <- sum((test$SWC_F_MDS_1-bag.pred.swc1)^2,na.rm=T)
1-sse/tse
# 0.8142329
varImpPlot ( bag.swc1, n.var=10)


#randomForest
set.seed ( 1 )
#you may change mtry to get better results
rf.swc1 <- randomForest ( f3, data = train , importance = TRUE,na.action=na.omit )
rf.pred.swc1 <- predict ( rf.swc1 , newdata = test )
#MSE
sum(( rf.pred.swc1 - test $ SWC_F_MDS_1 )^2,na.rm=T)/length(na.omit(rf.pred.swc1))
#1.923969
#R2
sse <- sum((test$SWC_F_MDS_1-rf.pred.swc1)^2,na.rm=T)
1-sse/tse
#0.8043547
#number of NA value 
length(rf.swc1$na.action)
rf.swc1
t <- importance ( rf.swc1 )
varImpPlot ( rf.swc1,n.var=10 )

plot(kru[,"SWC_F_MDS_1"],kru[,"TS_F_MDS_1"])
plot(kru[,"SWC_F_MDS_1"],kru[,"LE_F_MDS"])
plot(kru[,"SWC_F_MDS_1"],kru[,"SW_IN_POT"])
plot(kru[,"SWC_F_MDS_1"],kru[,"H_F_MDS"])
plot(kru[,"SWC_F_MDS_1"],kru[,"CO2_F_MDS"])
plot(kru[,"SWC_F_MDS_1"],kru[,"GPP_DT_VUT_REF"])
plot(kru[,"SWC_F_MDS_1"],kru[,"P_F"])
  

################################################################
#the following is optional

#model with 20 covariates
rn <- rownames(t[order(t[,1],decreasing = T),])
f4 <-  as.formula(paste("SWC_F_MDS_1 ~ ",paste(rn[1:20],collapse = '+')))
rf.swc2<- randomForest ( f4, data = train , importance = TRUE,na.action=na.omit )
rf.pred.swc2 <- predict ( rf.swc2, newdata = test  )
#MSE
sum(( rf.pred.swc2 - test $ SWC_F_MDS_1 )^2,na.rm=T)/length(rf.pred.swc2)
#1.911
#R2
sse <- sum((test$SWC_F_MDS_1-rf.pred.swc2)^2,na.rm=T)
1-sse/tse
#0.801
rf.swc2
length(rf.swc2$na.action)
varImpPlot ( rf.swc2 )

#model with 10 covariates
rn <- rownames(t[order(t[,1],decreasing = T),])
f5 <-  as.formula(paste("SWC_F_MDS_1 ~ ",paste(rn[1:10],collapse = '+')))
rf.swc3<- randomForest ( f5, data = train , importance = TRUE,na.action=na.omit )
rf.pred.swc3 <- predict ( rf.swc3, newdata = test )
##MSE
sum(( rf.pred.swc3 - test $ SWC_F_MDS_1 )^2,na.rm=T)/length(rf.pred.swc2)
#2.075
#R2
sse <- sum((test$SWC_F_MDS_1-rf.pred.swc3)^2,na.rm=T)
1-sse/tse
#0.784
length(rf.swc3$na.action)
varImpPlot ( rf.swc3 )

