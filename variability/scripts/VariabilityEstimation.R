## Variability STAN analysis ------

library(tidyverse)
library(rstan)
library(bayesplot)
library(gridExtra)
library(shinystan)

## load data ------------------

## set the working directory
setwd("/Users/jamillaakhund-zade/Thermotaxis Two Choice/autotracker_data/repository/variability/data/input-data")

dat2018 = read.csv('variability2018StanInput_degC.csv', header = T) #Nov/Dec 2018
dat2019 = read.csv('variability2019StanInput_degC.csv', header = T) #Jan 2019
datApr2019 = read.csv('variabilityApr2019StanInput_degC.csv', header = T) #Apr 2019

#batch vector - 2019 total data only (batch=1(Jan), batch=2(Apr)) - to correct for batch effects in var; values calculated in "get correction for batch effects in variability" section
dat2018$offset = rep(0, dim(dat2018)[1]) #2018 data - no offset
dat2019$offset = rep(-0.1427938, dim(dat2019)[1]) #jan data 
datApr2019$offset = rep(-0.3300957, dim(datApr2019)[1]) #apr data 

##combine Jan and Apr 2019 datasets into one
dat2019.total = rbind(dat2019, datApr2019)
dat2019.total = dat2019.total %>% filter(origin != 'MA') #filter out MA internal controls
dat2019.total$origin = droplevels(dat2019.total$origin)
dat2019.total$line = droplevels(dat2019.total$line) #remove factor levels

## make Stan input list -----------------------

dat = dat2018 #specify your dataset
#outcome vector
y = as.numeric(dat$degC) #occ (0-1 metric), degC (ºC metric)
#distance vector
dist = as.numeric(dat$dist)
#batch vector 
offset = as.numeric(dat$offset)

#predictor matrices
#line predictor matrix
x_line = model.matrix(degC ~ line + 0, data = dat) #one hot encoding

origin2018 = c('VA','VA','VA','VA','FL','FL','MA','MA','MA','MA','FL','FL',
           'TX','TX','TX','TX') #Nov/Dec 2018

origin2019 = c('BE','BE','CA','CA','MA','MA','PA') #Jan 2019

originApr2019 = c('BE','CA','CA','MA','MA','PA','PA','PA') #Apr 2019

origin2019.total = c('BE','BE','CA','CA','PA', 
                     'BE','CA','CA','PA','PA','PA') #total 2019 minus MA controls

#site predictor matrix
lines = colnames(x_line)
x_site = model.matrix(lines ~ origin2018 + 0,
                      data = data.frame(lines, origin2018)) #one hot

#get sampling error vs distance relationship from tempofftracking.m script 
#best fit by least abs resid power fit to temp off tracks
#make sure to choose the right phi,psi! they differ based on metric (ºC or 0-1)

##degC
phi = 219.6 
psi = -0.6327

##occ (0-1)
phi = 4.393 
psi = -0.7352
  
#make Stan list
wildIsolates_dat = list(N = length(y),
                        L = dim(x_line)[2],
                        K = dim(x_site)[2],
                        x_line, x_site, 
                        y, dist, phi, psi, offset)


## run STAN ---------------

setwd("/Users/jamillaakhund-zade/Thermotaxis Two Choice/autotracker_data/repository/variability/scripts")

#thermo model
#melanogaster from 2018/2019 - hierarchical model with sampling error estimation
fit <- stan(file = 'stanThermoHierarchicalWSampEst_degC.stan', data = wildIsolates_dat, 
            iter=25000, chains=4, thin = 2, 
            control = list(adapt_delta = 0.9, max_treedepth = 10))

pairs(fit, pars = c("m_site[1]", "m_site[2]"), las = 1) # below the diagonal

#launch shiny stan for diagnostics
library(shinystan)
my_sso <- launch_shinystan(fit)


## extract raw values --------------------
post_dist_raw2018 = as.matrix(fit, pars = c('m_line','v_line','m_site','v_site',
                                            'sigma_m_site','sigma_v_site')) 

#extract simulated response
sim_tempPref2018 = as.matrix(fit, pars = c("y_rep"))

#save output
setwd("/Users/jamillaakhund-zade/Thermotaxis Two Choice/autotracker_data/repository/variability/data")
save(post_dist_raw2018,file = 'Variability2018HierModel_FixedPhiPsi.RData')
save(sim_tempPref2018, file = 'Simulated2018Vals_FixedPhiPsi.RData')

#separate factors --------------------

#set your working directory to Stan output
setwd("/Users/jamillaakhund-zade/Thermotaxis Two Choice/autotracker_data/repository/variability/data/stan-output")

load('Variability2018HierModel_FixedPhiPsi.RData') #Nov/Dec 2018
load('Variability2019HierModel_FixedPhiPsi.RData') #Jan 2019
load('VariabilityApr2019HierModel_FixedPhiPsi.RData') #Apr 2019
load('VariabilityTotal2019HierModel_FixedPhiPsi.RData') #total Jan/Apr 2019

#extract parameters of interest
#Jan 2019 batch
post_dist_var2019 = post_dist_raw2019[,c(8:14)] 
post_dist_mu2019 = post_dist_raw2019[,c(1:7)] 
post_dist_muSite2019 = post_dist_raw2019[,c(15:18)] 
post_dist_varSite2019 = post_dist_raw2019[,c(19:22)] 

#Nov/Dec 2018 batch
post_dist_var2018 = post_dist_raw2018[,c(17:32)] 
post_dist_mu2018 = post_dist_raw2018[,c(1:16)] 
post_dist_muSite2018 = post_dist_raw2018[,c(33:36)] 
post_dist_varSite2018 = post_dist_raw2018[,c(37:40)] 

#Apr 2019 batch
post_dist_varApr2019 = post_dist_rawApr2019[,c(9:16)] 
post_dist_muApr2019 = post_dist_rawApr2019[,c(1:8)] 
post_dist_muSiteApr2019 = post_dist_rawApr2019[,c(17:20)] 
post_dist_varSiteApr2019 = post_dist_rawApr2019[,c(21:24)] 

# all 2019 batches combined
post_dist_varTotal2019 = post_dist_raw2019Total[,c(12:22)] 
post_dist_muTotal2019 = post_dist_raw2019Total[,c(1:11)] 
post_dist_muSiteTotal2019 = post_dist_raw2019Total[,c(23:25)] 
post_dist_varSiteTotal2019 = post_dist_raw2019Total[,c(26:28)] 

## compare var of internal controls, MA_11_38 and MA_3_33 across batches ---------------
library(HDInterval)
internalCtrls = tibble(line = c(rep('MA_11_38',3), rep('MA_3_33',3)),
                       batch = rep(c('2018','2019J', '2019A'), 2))

internalCtrls$varMean = c(mean(post_dist_var2018[,7]), mean(post_dist_var2019[,5]), 
                       mean(post_dist_varApr2019[,4]),  mean(post_dist_var2018[,8]),
                       mean(post_dist_var2019[,6]), mean(post_dist_varApr2019[,5]))

internalCtrls$muMean = c(mean(post_dist_mu2018[,7]), mean(post_dist_mu2019[,5]), 
                          mean(post_dist_muApr2019[,4]),  mean(post_dist_mu2018[,8]),
                          mean(post_dist_mu2019[,6]), mean(post_dist_muApr2019[,5]))

internalCtrls$varlowerHDI = c(hdi(post_dist_var2018[,7])[1],hdi(post_dist_var2019[,5])[1],
                           hdi(post_dist_varApr2019[,4])[1], hdi(post_dist_var2018[,8])[1],
                           hdi(post_dist_var2019[,6])[1],hdi(post_dist_varApr2019[,5])[1])

internalCtrls$mulowerHDI = c(hdi(post_dist_mu2018[,7])[1],hdi(post_dist_mu2019[,5])[1],
                              hdi(post_dist_muApr2019[,4])[1], hdi(post_dist_mu2018[,8])[1],
                              hdi(post_dist_mu2019[,6])[1],hdi(post_dist_muApr2019[,5])[1])

internalCtrls$varupperHDI = c(hdi(post_dist_var2018[,7])[2],hdi(post_dist_var2019[,5])[2],
                           hdi(post_dist_varApr2019[,4])[2], hdi(post_dist_var2018[,8])[2],
                           hdi(post_dist_var2019[,6])[2],hdi(post_dist_varApr2019[,5])[2])

internalCtrls$muupperHDI = c(hdi(post_dist_mu2018[,7])[2],hdi(post_dist_mu2019[,5])[2],
                              hdi(post_dist_muApr2019[,4])[2], hdi(post_dist_mu2018[,8])[2],
                              hdi(post_dist_mu2019[,6])[2],hdi(post_dist_muApr2019[,5])[2])

internalCtrls$batch = factor(internalCtrls$batch, levels=c('2018','2019J','2019A'))
qplot(x = batch, y = varMean, color = line, data = internalCtrls) +
  geom_errorbar(aes(ymin=varlowerHDI, ymax=varupperHDI), width=.2) 

## get correction for batch effects in variability-----------------

#average 2018-Jan 2019 batch effect (MA_11_38 and MA_3_33)
jan2019Offset = mean(c((mean(post_dist_var2018[,7])-mean(post_dist_var2019[,5])),
                   (mean(post_dist_var2018[,8]) -mean(post_dist_var2019[,6]))))

#average 2018-Apr 2019 batch effect (MA_11_38 and MA_3_33)
apr2019Offset = mean(c((mean(post_dist_var2018[,7])-mean(post_dist_varApr2019[,4])),
                     (mean(post_dist_var2018[,8])-mean(post_dist_varApr2019[,5]))))



## calculate CoV ----------------------
post_dist_cv2018 = sqrt(post_dist_var2018)/post_dist_mu2018
#post_dist_cv2019 = sqrt(post_dist_var2019)/post_dist_mu2019
#post_dist_cvApr2019 = sqrt(post_dist_varApr2019)/post_dist_muApr2019
post_dist_cvTotal2019 = sqrt(post_dist_varTotal2019)/post_dist_muTotal2019

#2019 site var estimates are off, even though the simulated data is fine - likely due to the effect of one line - one site. must check (yep I'm right, fixed when Jan/Apr combined)
post_dist_cvSite2018 = sqrt(post_dist_varSite2018)/post_dist_muSite2018
post_dist_cvSiteTotal2019 = sqrt(post_dist_varSiteTotal2019)/post_dist_muSiteTotal2019

## calculate standard deviation --------------------------
post_dist_sd2018 = sqrt(post_dist_var2018)
post_dist_sdTotal2019 = sqrt(post_dist_varTotal2019)

post_dist_sdSite2018 = sqrt(post_dist_varSite2018)
post_dist_sdSiteTotal2019 = sqrt(post_dist_varSiteTotal2019)

## plotting posterior ---------------------------

#make posterior estimate array for lines and exclude Jan/Apr 2019 MA lines ------------

# when combining across batches
# plot_data = cbind(post_dist_cv2018, post_dist_cv2019[,c(1:4,7)],
#                   post_dist_cvApr2019[,c(1:3,6:8)]) 
# lines = c(levels(dat2018$line),levels(dat2019$line), levels(datApr2019$line))
# lines = lines[-c(21:22,27:28)]
# colnames(plot_data) = lines
# 
# plot_data = plot_data %>% as_tibble() %>% gather(key=line,value=var)
# 
# origins = rbind(unique(dat2018[,3:4]),unique(dat2019[,3:4]), 
#                 unique(datApr2019[,3:4]))
# origins = origins[-c(17,22,29,31),]

#when using precombined dataset
plot_data = cbind(post_dist_sd2018, post_dist_sdTotal2019)
lines = c(levels(dat2018$line),levels(dat2019.total$line))
colnames(plot_data) = lines

origins = rbind(unique(dat2018[,4:5]),unique(dat2019.total[,4:5]))

plot_data = plot_data %>% as_tibble() %>% gather(key=line,value=var)
plot_data = plot_data %>% inner_join(origins)

plot_data$line = factor(plot_data$line, 
                        levels = c('BERK_14','BERK_7','BERK_1',
                                   'CA_14','CA_2','CA_26','CA_22',
                                   'FL_7_3','FL_9_8','MIA_3_76','MIA_5_155',
                                   'MA_11_38','MA_3_33','MA_5_73','MA_9_52',
                                   'PA_6','PA_8','PA_18','PA_10',
                                   'TX_11_1','TX_12_2','TX_12_4','TX_13_5',
                                   'CM0705.036','CM0719.026','CM0802.061','CM0816.031'))

plot_data$origin = factor(plot_data$origin, 
                        levels = c('BE','CA','FL','MA','PA','TX','VA'))

#make posterior estimate array for origins ---------------- 
plot_data = cbind(post_dist_sdSite2018, post_dist_sdSiteTotal2019)
lines = c(levels(dat2018$origin), levels(dat2019.total$origin))
colnames(plot_data) = lines

plot_data = plot_data %>% as_tibble() %>% gather(key=origin,value=var)
plot_data$origin = factor(plot_data$origin, 
                          levels = c('BE','CA','FL','MA','PA','TX','VA'))

#calculate differences between locations ----------

calcLocHDI <- function(loc1, loc2, cred_int){
  l1 = plot_data %>% filter(origin == loc1)
  l2 = plot_data %>% filter(origin == loc2)
  diff = l1$var - l2$var
  return(HDInterval::hdi(diff,credMass=cred_int))
}

calcLocHDI('BE', 'VA', 0.95)

#plotting violin plots -----------------

library(RColorBrewer)
library(scales)
#display.brewer.all()
#pal = brewer.pal(8,"Set2")
pal = c('#65BADA','#D86F27','#068E8C','#C82E6B','#364285','#00A757','#E5BA52')
  
breaks = levels(plot_data$origin)
labels = c('North CA','South CA','FL','MA','PA','TX','VA')


q = ggplot(data = plot_data, aes(y = var, x = line)) # x = line or origin

q + 
  geom_violin(aes(fill = origin), trim=T) +
  theme_classic() +
  theme(axis.text.y = element_text(size=14),
        axis.text.x = element_text(size=14, angle = 45),
        axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        axis.ticks.x = element_blank(),
        legend.title = element_text(size = 14),
        legend.text = element_text(size = 12),
        axis.ticks.length = unit(.25, "cm"),
        axis.line.x = element_line(lineend = 'butt'),
        axis.line.y = element_line(lineend = 'butt'),
        plot.margin = margin(t = 20, r = 20, b = 20, l = 20, unit = "pt")) +
  #scale_fill_brewer(name = 'Origin',labels = labels, palette = 'Set2') +
  scale_fill_manual(name = 'Origin',labels = labels, 
                    values = pal) 

## Diagnostics -----------------------

## comparing original dist to simulated dist
setwd("/Users/jamillaakhund-zade/Thermotaxis Two Choice/autotracker_data/Variability/Stan Output/degC metric")
load('SimulatedTotal2019Vals_FixedPhiPsi.RData')

dat = dat2019.total
X = model.matrix(line ~ origin + 0, data = dat)
y = as.numeric(dat2019.total$degC) #occ (0-1 metric), degC (ºC metric)

color_scheme_set("brightblue")
p1=ppc_dens_overlay(y[as.logical(X[,1])], sim_tempPref[1:50,as.logical(X[,1])])
p2=ppc_dens_overlay(y[as.logical(X[,2])], sim_tempPref[1:50,as.logical(X[,2])])
p3=ppc_dens_overlay(y[as.logical(X[,3])], sim_tempPref[1:50,as.logical(X[,3])])
p4=ppc_dens_overlay(y[as.logical(X[,4])], sim_tempPref[1:50,as.logical(X[,4])])

grid.arrange(p1, p2, p3, p4, nrow=1)

#group by line
ppc_stat_grouped(y, sim_tempPref2019Total, group = dat$line, stat='sd')
ppc_stat_grouped(y, sim_tempPref2019Total, group = dat$line, stat='mean')

#group by site (origin)
ppc_stat_grouped(y, sim_tempPref2019Total, group = dat$origin, stat='sd')
ppc_stat_grouped(y, sim_tempPref2019Total, group = dat$origin, stat='mean')


## extract mean and variance for bet-hedging modeling (not used) -------------

##mean
plot_data = cbind(post_dist_muSite2018, post_dist_muSiteTotal2019)
lines = c(levels(dat2018$origin), levels(dat2019.total$origin))
colnames(plot_data) = lines

plot_data = plot_data %>% as_tibble() %>% gather(key=origin,value=var)
plot_data$origin = factor(plot_data$origin, 
                          levels = c('BE','CA','FL','MA','PA','TX','VA'))
summary_data_mean = plot_data %>% group_by(origin) %>% 
               summarise(mean = mean(var)) %>%
               mutate(transf.mean = (mean-18)/12) #do linear transform for BH fxns

write_csv(summary_data_mean, 'VariabilitySites_Mean_PosteriorEstimates.csv') #write to file

##var
plot_data = cbind(post_dist_varSite2018, post_dist_varSiteTotal2019)
lines = c(levels(dat2018$origin), levels(dat2019.total$origin))
colnames(plot_data) = lines

plot_data = plot_data %>% as_tibble() %>% gather(key=origin,value=var)
plot_data$origin = factor(plot_data$origin, 
                          levels = c('BE','CA','FL','MA','PA','TX','VA'))
summary_data_var = plot_data %>% group_by(origin) %>% 
               summarise(var = mean(var)) %>%
               mutate(transf.var = (1/144)*var) #do linear transform for BH fxns

write_csv(summary_data_var, 'VariabilitySites_Var_PosteriorEstimates.csv')





