---
title: "R0 Estimation"
author: "Nick Cotter"
date: "2020-02-13"
output: 
      html_document:
        keep_md: yes
        output_dir: "./docs"
---



Here I take the [R0 package](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3582628/) to estimate the reproduction number for COVID-19. NOTE: my aim is to investigate the R0 package rather than provide sound predictions of COVID-19's future behaviour. In particular I have guessed the generation time.


Load the data from the [2019 Novel Coronavirus COVID-19 (2019-nCoV) Data Repository by Johns Hopkins CSSE](https://github.com/CSSEGISandData/COVID-19):


```r
confirmed <- read.csv(url("https://raw.githubusercontent.com/CSSEGISandData/2019-nCoV/master/time_series/time_series_2019-ncov-Confirmed.csv"))
```

This data contains a row per state/province and a column per reported case numbers - on a particular date and time. There may be more than report per day at different times for a given location. 

Let's transform this into a daily count using the last total count for each day:


```r
sums <- colSums(confirmed[,-match(c("Province.State", "Country.Region", "Lat", "Long"), names(confirmed))], na.rm=TRUE)

sumsByDateCode <- as.data.frame(t(t(sums)))
colnames(sumsByDateCode) <- c("count")

sumsByDateCode$datecode <- rownames(sumsByDateCode)

sumsByDate <- mutate(sumsByDateCode, datetime = mdy_hm(substring(datecode,2)))

dailyCounts <- aggregate(sumsByDate$count, by=list(as.Date(sumsByDate$datetime)), FUN=tail, n=1)

colnames(dailyCounts) <- c("date", "count")

dailyCounts$day <- seq.int(nrow(dailyCounts))
```


Now use the R0 package to estimate the reproduction number. I need a generation time, which we don't have to hand, so I take the values use for SARS - a mean of 8.4, standard deviation 3.8 - as [described here](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3816335/). The different estimation methods (time dependent, exponential growth etc.) are described there too.


```r
mgt <- generation.time("gamma", c(8.4, 3.8))

est <- estimate.R(dailyCounts$count, methods=c("TD", "EG", "ML", "SB"), GT=mgt)
```








We can plot the actual and predicted values using the different estimation methods:

![](R0-estimation_files/figure-html/plot-predictions-1.png)<!-- -->

The time-dependent method seems to fit the best. Here are the RMSE values for the different methods:


       TD         EG         ML         SB
---------  ---------  ---------  ---------
 3301.667   4225.228   8428.734   41073.53


Here is the range of the reproduction number thus estimated using the "time dependendent" method:


```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##   2.290   2.431   3.168   4.831   5.263  17.533
```

Finally, here is a plot of estimated reproduction number (using the time-dependent method) over time:

![](R0-estimation_files/figure-html/plot-estimates-1.png)<!-- -->

At this time it seems to be tending towards some value between 2 and 3.
