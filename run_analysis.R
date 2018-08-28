#1. read tables
datasubtest<-read.csv(".\\test\\subject_test.txt",sep="")

dataxtest<-read.csv(".\\test\\X_test.txt",sep="")
dataytest<-read.csv(".\\test\\Y_test.txt",sep="")


datasubtrain<-read.csv(".\\train\\subject_train.txt",sep="")
dataxtrain<-read.csv(".\\train\\X_train.txt",sep="")
dataytrain<-read.csv(".\\train\\Y_train.txt",sep="")

#2. apply headers; extract only the variables with "mean" or "std" in title
names(dataytest)<-c("Activity")
names(dataytrain)<-c("Activity")
names(datasubtrain)<-c("SubjectID")
names(datasubtest)<-c("SubjectID")
features<-read.csv("features.txt",sep="",header=FALSE,stringsAsFactors=FALSE)

featurenames<-features[,2]
library(dplyr)
measures<-filter(features, grepl('mean|std', V2))
featureIDs<-measures[,1]
colnames(dataxtest)<-c(featurenames)
colnames(dataxtrain)<-c(featurenames)
dataxtrain<-dataxtrain[,featureIDs]
dataxtest<-dataxtest[,featureIDs]
featurenames2<-measures[,2]


#3. add "sample" column with values "test" or "train" 
#library(dplyr)
dataxtest<-dataxtest %>% mutate (Sample="Test")
dataxtrain<-dataxtrain %>% mutate (Sample="Train")

#4. include subject ID for both train and test data sets, include activity
dataxtest<-cbind(dataxtest,datasubtest,dataytest)
dataxtrain<-cbind(dataxtrain,datasubtrain,dataytrain)


#5. merge data
mergedata<-rbind(dataxtest,dataxtrain)



#6. name the activities
mergedata$Activity<-plyr::mapvalues(mergedata$Activity,
	from=c(1:6),
	to=c("WALKING", "WALKING_UP", "WALKING_DOWN", "SITTING", "STANDING", "LAYING"))

#7. second data set - average by activity and subject

tidydata<-select(mergedata,-Sample)
tidydata<- tidydata %>%
  group_by(SubjectID, Activity) %>%
  summarise_at(.vars = c(featurenames2), .funs = mean)

#8. export data
write.table(tidydata,"tidydata.txt",sep="\t",row.names=F)
write.table(tidydata,"tidydata.csv",sep=",",row.names=F)
