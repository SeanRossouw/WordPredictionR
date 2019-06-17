#SeanR 2019

library(data.table)
library(quanteda)
library(stringr)
library(tm)

setwd("Data Science Capstone 2")

con <- file("Coursera-SwiftKey\\final\\en_US\\en_US.blogs.txt", open = "rb")
blogs <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
close(con)

con <- file("Coursera-SwiftKey\\final\\en_US\\en_US.news.txt", open = "rb")
news <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
close(con)

con <- file("Coursera-SwiftKey\\final\\en_US\\en_US.twitter.txt", open = "rb")
twits <- readLines(con, encoding = "UTF-8", skipNul = TRUE)
close(con)

frac<-0.5

subblogs<-blogs[sample(length(blogs),length(blogs)*frac)]
subnews<-news[sample(length(news),length(news)*frac)]
subtwits<-twits[sample(length(twits),length(twits)*frac)]

rm(blogs,news,twits)

corp<-corpus(c(subblogs,subnews,subtwits))
maintoks<-tokens(x=tolower(corp),remove_numbers=TRUE,remove_punct=TRUE,remove_symbols=TRUE,remove_url=TRUE,remove_twitter=TRUE,remove_hyphens=TRUE)
#stemtoks<-tokens_wordstem(maintoks,language="english")
#did not stem, lost vowels on words
rm(subblogs,subnews,subtwits)
rm(corp)

saveRDS(maintoks,"maintoks.rds")
maintoks<-readRDS("maintoks.rds")

#gram1<-dfm(stemtoks)
#gram2<-dfm(tokens_ngrams(stemtoks, n=2))
#gram3<-dfm(tokens_ngrams(stemtoks, n=3))
#rm(maintoks,stemtoks)

gram1<-dfm(maintoks)
gram1<-dfm_trim(gram1,5)
sgram1<-colSums(gram1)
tabOne<-data.table(w1=names(sgram1),count=sgram1)
saveRDS(sgram1,"sgram1.rds")
saveRDS(tabOne,"tabOne.rds")



gram2<-dfm(tokens_ngrams(maintoks, n=2))
gram2<-dfm_trim(gram2,5)
sgram2<-colSums(gram2)
tabTwo<-data.table(w1=sapply(strsplit(names(sgram2), "_",fixed=TRUE), '[[',1),
                   w2=sapply(strsplit(names(sgram2), "_",fixed=TRUE), '[[',2),
                   count=sgram2)
saveRDS(sgram2,"sgram2.rds")
saveRDS(tabTwo,"tabTwo.rds")

gram3<-dfm(tokens_ngrams(maintoks, n=3))
gram3<-dfm_trim(gram3,5)
sgram3<-colSums(gram3)
tabThree<-data.table(w1=sapply(strsplit(names(sgram3), "_",fixed=TRUE), '[[',1),
                     w2=sapply(strsplit(names(sgram3), "_",fixed=TRUE), '[[',2),
                     w3=sapply(strsplit(names(sgram3), "_",fixed=TRUE), '[[',3),
                     count=sgram3)
saveRDS(sgram3,"sgram3.rds")
saveRDS(tabThree,"tabThree.rds")



rm(maintoks,stemtoks)
rm(gram1,gram2,gram3)


sgram1<-readRDS("sgram1.rds")
sgram2<-readRDS("sgram2.rds")
sgram3<-readRDS("sgram3.rds")


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

inStr<-"and then"
inStr<-stripWhitespace(removePunctuation(removeNumbers(tolower(inStr))))
inList<-strsplit(inStr, " ")[[1]]
tail<-inList[(length(inList)-1):(length(inList))]


biP<-bi[bi$w1==tail[2]]

triP<-tri[tri$w1==tail[1] & tri$w2==tail[2]]

uniP<-uni

weighting<-c(0.001,1,10)

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
preDT<-as.character(preD$X1[1:4])


print((preDT[1:4]))
#######ORDER THIS 






#Kneser Kney Smoothing

discount<-0.7

#Find the probability of a word by number of times it was the w2 in the bigrams. 
num2<-nrow(tabTwo[by=.(w1,w2)])

prob2<-tabTwo[ , .(Prob=((.N)/num2)),by=w2]
setkey(prob2,w2)

tabOne[, Prob:=prob2[w1, Prob]]
tabOne<-tabOne[!is.na(tabOne$Prob)]

prob1<-tabTwo[, .(N=.N),by=w1]
setkey(prob1,w1)

tabTwo[, n1 := tabOne[w1,count]]
tabTwo[, Prob := ((count-discount)/n1 +discount/n1 * prob1[n1, N]*tabOne[w2, Prob])]

#Find the probability of a word by the number of times it was the w3 in the trigrams.
tabThree[,n2 := tabTwo[.(w1,w2),count]]

prob12<-tabThree[, .N, by= .(w1,w2)]
setkey(prob12,w1,w2)

tabThree[, Prob := (count -discount) /n2 +discount/n2 * prob12[.(w1,w2), N]*tabTwo[.(w1,w2), Prob]]
backup<-tabOne[order(-Prob)][1:20]
