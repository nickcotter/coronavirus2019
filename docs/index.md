---
title: "R0 Estimation"
author: "Nick Cotter"
date: "2020-02-26"
knit: (function(inputFile, encoding) { 
      rmarkdown::render(inputFile,
                        encoding=encoding, 
                        output_file=file.path(dirname(inputFile), 'docs', 'index.html')) })
output: 
      html_document:
        keep_md: yes
---



Here I take the [R0 package](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3582628/) to estimate the reproduction number for COVID-19. NOTE: my aim is to investigate the R0 package rather than provide sound predictions of COVID-19's future behaviour. In particular I have guessed the generation time.


Load the data from the [2019 Novel Coronavirus COVID-19 (2019-nCoV) Data Repository by Johns Hopkins CSSE](https://github.com/CSSEGISandData/COVID-19):




```r
confirmed <- read.csv(url("https://raw.githubusercontent.com/CSSEGISandData/2019-nCoV/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv"))
```

This data contains a row per state/province and a column per reported case numbers - on a particular date. Let's tidy this into count per day number since the start.


```r
sums <- colSums(confirmed[,-match(c("Province.State", "Country.Region", "Lat", "Long"), names(confirmed))], na.rm=TRUE)

sumsByDateCode <- as.data.frame(t(t(sums)))
colnames(sumsByDateCode) <- c("count")

sumsByDateCode$datecode <- rownames(sumsByDateCode)

dailyCounts <- mutate(sumsByDateCode, date = mdy(substring(datecode,2)))

dailyCounts$day <- seq.int(nrow(dailyCounts))
```


Now use the R0 package to estimate the reproduction number. I need a generation time, which we don't have to hand, so I take the values use for SARS - a mean of 8.4, standard deviation 3.8 - as [described here](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3816335/). The different estimation methods (time dependent, exponential growth etc.) are described there too.


```r
mgt <- generation.time("gamma", c(8.4, 3.8))

est <- estimate.R(dailyCounts$count, methods=c("TD", "EG", "ML", "SB"), GT=mgt)
```








We can plot the actual and predicted values using the different estimation methods:

![](/home/datascience/coronavirus2019/docs/index_files/figure-html/plot-predictions-1.png)<!-- -->

The time-dependent method seems to fit the best. Here are the RMSE values for the different methods:


       TD         EG         ML   SB
---------  ---------  ---------  ---
 4500.802   12234.55   17184.78   NA


Here is the range of the reproduction number thus estimated using the "time dependendent" method:


```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##   1.174   1.335   1.961   3.292   3.762  15.023
```

Finally, here is a plot of estimated reproduction number (using the time-dependent method) over time:

![](/home/datascience/coronavirus2019/docs/index_files/figure-html/plot-estimates-1.png)<!-- -->

The reproduction number has been reduced considerably over the last month or so, but is still above 1.
