#histgram

setwd("D:/working/teaching/�������ݷ�����Ӧ��/code") # use one forward slash

d <- read.csv("E:\\data\\����\\�㶫վ��\\gd_obs.csv")
d[d==-9999] <- NA
hist(d$T)
hist(d$T,breaks=10,col="blue")
hist(d$T,breaks=100,col="blue")


hist(d$T,freq=F)
lines(density(d$T,na.rm=T),col="blue")


cum = ecdf(d$T)
plot(cum)


