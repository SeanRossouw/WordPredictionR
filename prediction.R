#SeanR 2019

library(data.table)
library(quanteda)
library(stringr)
library(tm)

#setwd("Data Science Capstone 2")
#setwd("PredWordShiny")

tabOne<-readRDS("tabOne.rds")
tabTwo<-readRDS("tabTwo.rds")
tabThree<-readRDS("tabThree.rds")

setkey(tabOne,w1)
setkey(tabTwo,w1,w2)
setkey(tabThree,w1,w2,w3)

tabOne<-tabOne[order(-count)]
tabTwo<-tabTwo[order(-count)]
tabThree<-tabThree[order(-count)]

uni<-tabOne[1:50]
bi<-tabTwo[1:200000]
tri<-tabThree[1:200000]

f.predict=function(s,n){
  
  s<-stripWhitespace(removePunctuation(removeNumbers(tolower(s))))
  inList<-strsplit(s, " ")[[1]]
  tail<-inList[(length(inList)-1):(length(inList))]
  
  biP<-bi[bi$w1==tail[2]]
  
  triP<-tri[tri$w1==tail[1] & tri$w2==tail[2]]
  
  uniP<-uni
  
  weighting<-c(0.000001,1000,10000)
  
  uniP$count<-weighting[1]*uniP$count
  colnames(uniP)<-c("pre","score")
  uniP<- data.frame(matrix(unlist(uniP), ncol=length(uniP)))
  
  biP$count<-weighting[2]*biP$count
  colnames(biP)<-c("w1","pre","score")
  biP<-biP[,2:3]
  biP<-data.frame(matrix(unlist(biP), ncol=length(biP)))
  
  triP$count<-weighting[3]*triP$count
  colnames(triP)<-c("w1","w2","pre","score")
  triP<-triP[,3:4]
  triP<-data.frame(matrix(unlist(triP), ncol=length(triP)))
  
  
  
  preD<-(rbind(uniP,biP,triP))
  preD[,2]<-as.numeric(as.character(preD[,2]))
  preD<-aggregate(X2~X1,data=preD,FUN=sum)
  preD<-preD[order(preD$X2,decreasing=T), ]
  preDT<-as.character(preD$X1[1:n])
  
  return(preDT)
}
