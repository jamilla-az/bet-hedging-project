# life history curves for MA, VA, FL
# jamilla a
# created: 2019-07-30
# updated: 2020-04-23

# libraries -------------
library(tidyverse)

#load in data ----------------

setwd('~/Thermotaxis Two Choice/autotracker_data/repository/life-history-curves/data')
load('Fitness.RData') #load in viability, eclosion, egg counts
load('Site Specific Lifespan 2019.RData') #load in lifespan data

#update columns
#eggCount.tPref$IncTemp = as.factor(eggCount.tPref$IncTemp)
eggCount.tPref$Location = as.factor(eggCount.tPref$Location)

#offNum.tPref$IncTemp = as.factor(offNum.tPref$IncTemp)
offNum.tPref$Location = as.factor(offNum.tPref$Location)

lifespan$Location = as.factor(lifespan$Location)

#filter out viabilities > 1
offNum.tPref = offNum.tPref %>% filter(Viability <= 1)



# Ashburner (1978) Dev Time and Miquel et al (1976) Lifespan Data ----------------

Ashburn.DevTime = tibble(temp = c(12, 16, 18, 20, 22, 25, 28, 30), 
                         devTime = c(50, 25, 19, 14.5, 11, 8.5, 7, 11))

Ashburn.DevTime2 = tibble(temp = c(12, 18, 25, 28, 30), 
                         devTime = c(50, 19, 8.5, 7, 11)) #Kain et al dataset

Miquel.Lifespan = tibble(temp = c(18, 21, 27, 30), 
                         lifespan = c(130, 86, 42, 20)) #male flies only

setwd('~/Thermotaxis Two Choice/autotracker_data/Seasonal_Collections')
save(Ashburn.DevTime, Miquel.Lifespan, file = 'Kain 2015 Life History Curves.RData')

# compare MA, VA, FL time to eclosion (dev time) to Ashburner data ----------------
setwd('~/Thermotaxis Two Choice/autotracker_data/Seasonal_Collections')
load('Kain 2015 Life History Curves.RData')

q = ggplot(aes(x = IncTemp, y = TimeToEclose), data = offNum.tPref)
q + stat_summary(fun.data = "mean_cl_normal", mapping = aes(color = Location)) + 
  geom_point(aes(x=temp, y=devTime), data = Ashburn.DevTime) +
  stat_smooth(aes(x=temp, y=devTime), formula = y ~ poly(x,2, raw =T), 
              data = Ashburn.DevTime, se = F, method = 'lm', linetype = 'dotted',
              color = 'black', size = 0.75) + 
  theme_minimal() #ashburner fitted line

q = ggplot(aes(x = IncTemp, y = TimeToEclose), data = offNum.tPref)
q + stat_summary(fun.data = "mean_cl_normal", mapping = aes(color = Location)) + 
  geom_point(aes(x=temp, y=devTime), data = Ashburn.DevTime) +
  geom_smooth(aes(x=temp, y=devTime), formula = y ~ poly(x,2, raw = T), 
              data = Ashburn.DevTime, se = F, method = 'lm', linetype = 'dashed',
              color = 'black', size = 0.75, fullrange=T) + 
  stat_smooth(aes(x=IncTemp, y=TimeToEclose, color = Location), 
              formula = y ~ poly(x,2, raw=T),data = offNum.tPref,
              se = F, method = 'lm',
              size = 0.75, fullrange=T) + 
  xlim(12,30)+
  theme_bw() +
  theme(
    panel.grid = element_blank(),
    axis.text = element_text(size=14),
    axis.title = element_text(size=16),
    legend.text = element_text(size=14),
    legend.title = element_blank()
  ) #observed fitted lines + ashburner fitted line

q = ggplot(aes(x = IncTemp, y = TimeToEclose), data = offNum.tPref)
q + stat_summary(fun.data = "mean_cl_normal") + 
  stat_smooth(aes(x=IncTemp, y=TimeToEclose), formula = y ~ poly(x,2, raw=T),
              data = offNum.tPref, se = F, method = 'lm',
              size = 0.75, fullrange=T, color='black', linetype = 'dotted') + 
  xlim(12,30)+
  theme_bw() +
  theme(
    panel.grid = element_blank(),
    axis.text = element_text(size=14),
    axis.title = element_text(size=16),
    legend.text = element_text(size=14),
    legend.title = element_blank()
  ) #observed fitted line only




#add in 12C point to observed data from Ashburn data
offNum.12C = rbind(offNum.tPref %>% 
                     dplyr::select(Location, Batch, FlyID, IncTemp, TimeToEclose), 
                   tibble(Location = c('VA','VA','VA','MA','MA','MA','FL','FL','FL'), 
                          Batch = rep(0,9),FlyID = rep(0,9), 
                          IncTemp = rep(12,9),
                          TimeToEclose = rep(50,9)))

q = ggplot(aes(x = IncTemp, y = TimeToEclose), data = offNum.12C)
q + stat_summary(fun.data = "mean_cl_normal", mapping = aes(color = Location)) + 
  geom_point(aes(x=temp, y=devTime), data = Ashburn.DevTime) +
  geom_smooth(aes(x=temp, y=devTime), formula = y ~ poly(x,2, raw = T), 
              data = Ashburn.DevTime, se = F, method = 'lm', linetype = 'dotted',
              color = 'black', size = 0.75) + 
  stat_smooth(aes(x=IncTemp, y=TimeToEclose, color = Location), formula = y ~ poly(x,2, raw=T),
              data = offNum.12C, se = F, method = 'lm', linetype = 'dotted',
              size = 0.75, fullrange=T) + 
  theme_minimal() #observed fitted lines + ashburner fitted line


#coefficients for different fits
fit.Ashburn = lm(devTime~poly(temp,2, raw =T), data = Ashburn.DevTime)
fit.Ashburn

fit.Observed_dev = lm(TimeToEclose~poly(IncTemp,2, raw=T), 
                  data = offNum.tPref %>%  filter(Location == 'VA'))
fit.Observed_dev

# compare MA, VA, FL lifespan to Miquel data ----------------

#y~log(x)
q = ggplot(aes(x = IncTemp, y = Lifespan), data = lifespan)
q + stat_summary(fun.data = "mean_cl_normal", mapping = aes(color = Location)) + 
  geom_point(aes(x=temp, y=lifespan), data = Miquel.Lifespan) +
  geom_smooth(aes(x=temp, y=lifespan), formula = y ~ log(x), 
              data = Miquel.Lifespan, se = F, method = 'lm', linetype = 'dashed',
              color = 'black', size = 0.75, fullrange=T) + 
  stat_smooth(aes(x=IncTemp, y=Lifespan, color = Location), formula =y~log(x),
              data = lifespan, se = F, method = 'lm',
              size = 0.75, fullrange=T) + 
  xlim(12,30)+
  theme_bw() +
  theme(
    panel.grid = element_blank(),
    axis.text = element_text(size=14),
    axis.title = element_text(size=16),
    legend.text = element_text(size=14),
    legend.title = element_blank()
  ) #observed fitted lines + miquel fitted line


q = ggplot(aes(x = IncTemp, y = Lifespan), data = lifespan)
q + stat_summary(fun.data = "mean_cl_normal") + 
  stat_smooth(aes(x=IncTemp, y=Lifespan), formula =y~log(x),
              data = lifespan, se = F, method = 'lm',
              size = 0.75, fullrange=T, color='black', linetype='dotted') + 
  xlim(12,30)+
  theme_bw() +
  theme(
    panel.grid = element_blank(),
    axis.text = element_text(size=14),
    axis.title = element_text(size=16),
    legend.text = element_text(size=14),
    legend.title = element_blank()
  ) #observed fitted line only


#coefficients for different fits
fit.Miquel = lm(lifespan~poly(temp,2, raw =T), data = Miquel.Lifespan)
fit.Miquel

fit.Miquel = lm(lifespan~temp, data = Miquel.Lifespan)
fit.Miquel

fit.Observed_life = lm(Lifespan~IncTemp, 
                  data = lifespan)
fit.Observed_life

x=c(10:40)
qplot(x, 463.5-125.5*log(x)) +
  geom_line(aes(x, 727.6-208.4*log(x)),color='blue') +
  geom_line(aes(x, 0.4074*x^2-28.356*x+506.2), color='red')
