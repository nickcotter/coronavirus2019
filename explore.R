library(tidyverse)
library(R0)

confirmed <- read.csv(url("https://raw.githubusercontent.com/CSSEGISandData/2019-nCoV/master/time_series/time_series_2019-ncov-Confirmed.csv"))

sums <- colSums(confirmed[,-match(c("Province.State", "Country.Region", "Lat", "Long"), names(confirmed))], na.rm=TRUE)

sumsByDateCode <- as.data.frame(t(t(sums)))
colnames(sumsByDateCode) <- c("count")

sumsByDateCode$datecode <- rownames(sumsByDateCode)

sumsByDate <- mutate(sumsByDateCode, datetime = mdy_hm(substring(datecode,2)))

dailyCounts <- aggregate(sumsByDate$count, by=list(as.Date(sumsByDate$datetime)), FUN=tail, n=1)

colnames(dailyCounts) <- c("date", "count")

dailyCounts$day <- seq.int(nrow(dailyCounts))


mgt <- generation.time("gamma", c(3, 1.5))

est <- estimate.R(dailyCounts$count, methods=c("TD", "EG", "ML", "SB"), GT=mgt)

dailyCountAndPrediction <- merge(dailyCounts, est$estimates$TD$pred, by="row.names", sort=FALSE, all=TRUE)
names(dailyCountAndPrediction)[5] <- "prediction"


plot(dailyCountAndPrediction$day, dailyCountAndPrediction$count)
lines(dailyCountAndPrediction$day, dailyCountAndPrediction$prediction, col="green")