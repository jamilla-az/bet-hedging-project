# thermal preference vs fitness at different temperatures
# jamilla a
# created: 2019-07-16
# updated: 2020-04-23

# libraries -------------
library(tidyverse)

# load data --------------

setwd('~/Thermotaxis Two Choice/autotracker_data/repository/life-history-curves/data')

tpref = read_csv('thermPref_fitness_total.csv', col_names = T) #load thermo data

#load fitness data
eggCount = read_csv('Fitness Phenotype Record Sheet - EggCounts.csv', col_names = T)
#eclTime = read_csv('Fitness Phenotype Record Sheet - EclosionTime.csv', col_names = T)
offNum = read_csv('Fitness Phenotype Record Sheet - OffspringNum.csv', col_names = T)

# transform location labels for therm pref data ---------------

tpref$line = str_replace_all(tpref$line, c('CM0816.031' = 'VA', 'MA_9_52' = 'MA', 'FL_9_8' = 'FL'))

colnames(tpref) = c('Occ','Pref','Location','Batch','FlyID')

# filter out bad vials from fitness records ------------------

eggCount = eggCount %>% filter(is.na(Notes))
#eclTime = eclTime %>% filter(is.na(Notes))
offNum = offNum %>% filter(is.na(Notes))

offNum = offNum %>% mutate(TotalCount = FemaleCount + MaleCount + InFood)

# join fitness and therm pref data together ------------------

## 2 vials without tpref VA_1_86 and FL_2_92 ##

eggCount.tPref = inner_join(eggCount, tpref)
#eclTime.tPref = inner_join(eclTime, tpref)
offNum.tPref = inner_join(offNum, eggCount)
offNum.tPref = offNum.tPref %>% mutate(Viability = TotalCount/TotalEggs) #egg2adult viability
offNum.tPref = inner_join(offNum.tPref, tpref)

noViability = anti_join(eggCount.tPref, offNum.tPref) %>% 
              filter(TotalEggs > 0) #vials with eggs but no viable offspring

save(offNum.tPref, eggCount.tPref, file = 'Fitness.RData') #save the data

# egg counts for MA, FL, VA at 3 diff temps ------------------

eggCount.tPref$IncTemp = as.factor(eggCount.tPref$IncTemp)
eggCount.tPref$Location = as.factor(eggCount.tPref$Location)

q = ggplot(aes(x=Location, y = TotalEggs, fill = IncTemp), data = eggCount.tPref)
q  + geom_violin(aes(color = IncTemp)) + 
     geom_point(aes(group=IncTemp), size = 1, position=position_dodge(0.9)) +
    theme_minimal() +
    scale_fill_manual(values = c('#00BFC4', '#7CAE00', '#F8766D')) +
    scale_color_manual(values = c('#00BFC4', '#7CAE00', '#F8766D'))

# egg counts for diff thermal prefs at 3 diff temps for each location ------------------

q = ggplot(aes(x=Pref, y = TotalEggs, color = IncTemp), data = eggCount.tPref)
q + geom_point() + 
  facet_grid(vars(Location), vars(IncTemp)) +
  geom_smooth(method = 'lm', se = T, alpha = 0.2) +
  theme_bw() +
  scale_color_manual(values = c('#00BFC4', '#7CAE00', '#F8766D'))

# viability for MA, FL, VA at 3 diff temps ------------------

offNum.tPref$IncTemp = as.factor(offNum.tPref$IncTemp)
offNum.tPref$Location = as.factor(offNum.tPref$Location)

#filter out viabilities > 1
offNum.tPref = offNum.tPref %>% filter(Viability <= 1)

q = ggplot(aes(x=Location, y = Viability, fill = IncTemp), data = offNum.tPref)
q  + geom_violin(aes(color = IncTemp)) + 
  geom_point(aes(group=IncTemp), size = 1, position=position_dodge(0.9)) +
  theme_minimal() +
  scale_fill_manual(values = c('#00BFC4', '#7CAE00', '#F8766D')) +
  scale_color_manual(values = c('#00BFC4', '#7CAE00', '#F8766D'))

# viability for diff thermal prefs at 3 diff temps for each location ------------------

q = ggplot(aes(x=Pref, y = Viability, color = IncTemp), data = offNum.tPref)
q + geom_point() + 
  facet_grid(vars(Location), vars(IncTemp)) +
  geom_smooth(method = 'lm', se = T, alpha = 0.2) +
  theme_bw() +
  scale_color_manual(values = c('#00BFC4', '#7CAE00', '#F8766D'))

# time to eclose for MA, FL, VA at 3 diff temps ------------------

q = ggplot(aes(x=Location, y = TimeToEclose, fill = IncTemp), data = offNum.tPref)
q  + geom_violin(aes(color = IncTemp)) + 
  geom_point(aes(group=IncTemp), size = 1, position=position_dodge(0.9)) +
  theme_minimal() +
  scale_fill_manual(values = c('#00BFC4', '#7CAE00', '#F8766D')) +
  scale_color_manual(values = c('#00BFC4', '#7CAE00', '#F8766D'))

# time to eclose for diff thermal prefs at 3 diff temps for each location ------------------

q = ggplot(aes(x=Pref, y = TimeToEclose, color = IncTemp), data = offNum.tPref)
q + geom_point() + 
  facet_wrap(vars(Location), nrow = 3) +
  geom_smooth(method = 'lm', se = T, alpha = 0.2) +
  theme_bw() +
  scale_color_manual(values = c('#00BFC4', '#7CAE00', '#F8766D'))


