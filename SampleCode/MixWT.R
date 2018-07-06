setwd("D:/WorkingArea/Programming/R/½Õ½¦")

library(ggplot2)
library(dplyr)
library(corrplot)

MONO<-read.csv(file='MONO.csv',header = T)
MixWT<-read.csv(file='GlueD.csv',header = T,stringsAsFactors=F)
MixWT$WT<-as.double(MixWT$WT)
MixWT$GR<-as.double(MixWT$GR)
MixWT$CIE_X_AVG<-as.double(MixWT$CIE_X_AVG)
MixWT$CIE_Y_AVG<-as.double(MixWT$CIE_Y_AVG)
MixWT$PRE_CIE_X_AVG<-as.double(MixWT$PRE_CIE_X_AVG)
MixWT$PRE_CIE_Y_AVG<-as.double(MixWT$PRE_CIE_Y_AVG)
MixWT$CIE_X_GAP<-MixWT$CIE_X_AVG-MixWT$PRE_CIE_X_AVG
MixWT$CIE_Y_GAP<-MixWT$CIE_Y_AVG-MixWT$PRE_CIE_Y_AVG


group_by(MixWT,PRODUCTNO)%>%
summarise(n=n())%>%
arrange(desc(n))

P3806<-filter(MixWT,PRODUCTNO=='95.S3806.W0A0C8Z')
P3806<-left_join(P3806,MONO,by=c('MONO'='MONO'))

g<-ggplot(data=P3806)
g+geom_point(aes(x=CIE_X_AVG,y=CIE_Y_AVG,col='red'))+
geom_point(aes(x=PRE_CIE_X_AVG,y=PRE_CIE_Y_AVG,col='blue'))+
  geom_point(aes(x=CIE_X_GAP,y=CIE_Y_GAP,col='green'))
  
group_by(P3806,PRODUCTNO,WDD)%>%
summarise(n=n())%>%
arrange(desc(n))

P3806W50<-filter(P3806,WDD=="452.5-450")
P3806W50<-na.omit(P3806W50)



g<-ggplot(data=P3806W50)
g+geom_point(aes(x=CIE_X_AVG,y=CIE_Y_AVG,col='blue'))+
geom_point(aes(x=PRE_CIE_X_AVG,y=PRE_CIE_Y_AVG,col='red'))+
geom_point(aes(x=CIE_X_GAP,y=CIE_Y_GAP,col='green'))



corP3806<-select(P3806W50,WT,SPC_VALUE,SPC_RANGE,PRE_CIE_X_AVG,PRE_CIE_Y_AVG,CIE_X_AVG,CIE_Y_AVG)


corP3806<-cor(corP3806)
corrplot(corr=corP3806,order = "AOE",addCoef.col = "grey")



g<-ggplot(data=corP3806)
g+geom_point(aes(x=CIE_X_AVG,y=CIE_Y_AVG,col='blue'))+
  geom_point(aes(x=PRE_CIE_X_AVG,y=PRE_CIE_Y_AVG,col='red'))+
  geom_point(aes(x=CIE_X_GAP,y=CIE_Y_GAP,col='green'))

