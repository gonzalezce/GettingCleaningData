#Import files into R 
#Assumes user has downloaded zip into their working directory 
setwd("./UCI HAR Dataset/")
testSub<- read.table("test/subject_test.txt")
testX<- read.table("test/X_test.txt")
testY<- read.table("test/Y_test.txt")
trainSub<- read.table("train/subject_train.txt")
trainX<- read.table("train/X_train.txt")
trainY<- read.table("train/Y_train.txt")
features<- read.table("features.txt")
activityL<- read.table("activity_labels.txt")

#Merge train and test data and subset for just mean/std statistics 
both<- rbind(trainX, testX)
colnames(both)<- features[,2]
bothMS<- both[,grep("mean|std", colnames(both))]

subT<- rbind(trainSub, testSub)
actT<- rbind(trainY, testY)
GROUP<- factor(c(rep("TRAIN", 7352), rep("TEST",2947)))
bothMSF<- cbind(subT, GROUP, actT, bothMS)
colnames(bothMSF)[1:3]<- c("subT","GROUP","actT")

# Re-code activity 
bothMSF$actT<- factor(bothMSF$actT)
levels(bothMSF$actT)<- c("WALKING","WALKING_UPSTAIRS","WALKING_DOWNSTAIRS","SITTING","STANDING","LAYING")
bothMSF$subT<- factor(bothMSF$subT)


#Find the average for each subject and each activity 
tidy<- data.frame(matrix(data=NA, nrow=180, ncol=79))
newRow<- paste(bothMSF$subT, "_",bothMSF$actT,sep="")
bothMSF$subAct<- newRow

for(i in 1:length(unique(newRow))){
  subset<- bothMSF[bothMSF$subAct==unique(newRow)[i],]
  tidy[i,1:79]<- as.numeric(apply(subset[,4:82], 2, mean))
}
tidyF<- cbind(unique(newRow), tidy)
colnames(tidyF)[2:80]<- colnames(bothMSF)[4:82]

#Clean up column names 
cNames<- colnames(tidyF)
cNames1<- gsub("-mean()-X", "MeanX", cNames, fixed=T)
cNames2<- gsub("-mean()-Y", "MeanY", cNames1, fixed=T)
cNames3<- gsub("-mean()-Z", "MeanZ", cNames2, fixed=T)
cNames4<- gsub("-std()-X", "StdX", cNames3, fixed=T)
cNames5<- gsub("-std()-Y", "StdY", cNames4, fixed=T)
cNames6<- gsub("-std()-Z", "StdZ", cNames5, fixed=T)
cNames7<- gsub("Acc","Accelerometer",cNames6)
cNames8<- gsub("-mean()","Mean",cNames7, fixed=T)
cNames9<- gsub("-std()","Std",cNames8, fixed=T)
cNames10<- gsub("-meanFreq()-X", "MeanfreqX", cNames9, fixed=T)
cNames11<- gsub("-meanFreq()-Y", "MeanfreqY", cNames10, fixed=T)
cNames12<- gsub("-meanFreq()-Z", "MeanfreqZ", cNames11, fixed=T)
cNames13<- gsub("-meanFreq()", "Meanfreq", cNames12, fixed=T)
cNames14<- gsub("Gyro","Gyroscope", cNames13)
cNames14[1]<- "subjectActivity"
colnames(tidyF)<- cNames14
write.table(tidyF, "~/Desktop/tidydata.txt", row.names=F)
