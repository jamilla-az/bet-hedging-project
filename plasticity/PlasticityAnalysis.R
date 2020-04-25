##############################
## Plasticity STAN analysis ##
##############################


library(tidyverse)
library(rstan)
library(bayesplot)
library(gridExtra)
library(shinystan)

## load data ------------------

## set the working directory
setwd("/Users/jamillaakhund-zade/Thermotaxis Two Choice/autotracker_data/repository/plasticity/data")

dat = read.csv('plasticityStanInput_degC.csv', header = T)
dat$inctemp = as.factor(dat$inctemp)
## make Stan input list -----------------------
#outcome vector
y = as.numeric(dat$degC) #occ (0-1 metric), degC (ºC metric)
#distance vector
dist = as.numeric(dat$dist)
#predictor matrix
x_trt = model.matrix(degC ~ inctemp + 0, data = dat) #one hot encoding

##degC
phi = 219.6 
psi = -0.6327

#make Stan list
plasticity_dat = list(N = length(y),
                      L = dim(x_trt)[2],
                      x_trt, y, dist, phi, psi)

## run STAN ---------------

setwd("/Users/jamillaakhund-zade/Thermotaxis Two Choice/autotracker_data/repository/plasticity")

#thermo model
#melanogaster - simple linear model with sampling error estimation
fit <- stan(file = 'stanThermoWSampEst_degC.stan', data = plasticity_dat, 
            iter=50000, chains=4, thin=2,  
            control = list(adapt_delta = 0.9, max_treedepth = 10))

#launch shiny stan

my_sso <- launch_shinystan(fit)

## extract raw values --------------------
post_dist_raw = as.matrix(fit, pars = c('m_trt','v_trt')) 

#extract simulated response
sim_tempPref = as.matrix(fit, pars = c("y_rep"))

#save output
setwd("/Users/jamillaakhund-zade/Thermotaxis Two Choice/autotracker_data/repository/plasticity/stan-output")

save(post_dist_raw,file = 'Plasticity_FixedPhiPsi.RData')
save(sim_tempPref, file = 'SimulatedPlasticityVals_FixedPhiPsi.RData')

#separate factors --------------------

#set your working directory to Stan output for the degC metric
setwd("/Users/jamillaakhund-zade/Thermotaxis Two Choice/autotracker_data/repository/plasticity/stan-output")

load('Plasticity_FixedPhiPsi.RData')

#extract parameters of interest
post_dist_var = post_dist_raw[,c(4:6)] #var
post_dist_mu = post_dist_raw[,c(1:3)] #mean
post_dist_cv = sqrt(post_dist_var)/post_dist_mu #cv 
post_dist_sd = sqrt(post_dist_var) #st dev

treatments = levels(dat$inctemp)
colnames(post_dist_mu) = treatments
colnames(post_dist_var) = treatments
colnames(post_dist_cv) = treatments
colnames(post_dist_sd) = treatments

## PLOTTING POSTERIOR ---------------------------
#pick your dataset 
plot_data = post_dist_sd %>% as_tibble() %>% gather(key=trt,value=var)

#plotting violin plots -----------------
library(RColorBrewer)
library(scales)
#display.brewer.all()
pal = brewer.pal(8,"Set2")
labels = c('18ºC','22ºC','26ºC')

q = ggplot(data = plot_data, aes(y = var, x = trt)) # x = inc temp treatment

q + 
  geom_violin(aes(fill = trt), trim=T) +
  theme_classic() +
  labs(x = 'Rearing Temperature (ºC)', y = 'Variability in Temperature Preference') +
  theme(axis.text.y = element_text(size=12),
        axis.text.x = element_text(size=12),
        axis.title.y = element_text(size = 14, vjust = 0.7),
        axis.title.x = element_text(size = 14, vjust = 0.2),
        legend.position = 'none',
        axis.ticks.length = unit(.25, "cm"),
        axis.line.x = element_line(lineend = 'butt'),
        axis.line.y = element_line(lineend = 'butt'),
        plot.margin = margin(t = 20, r = 20, b = 20, l = 20, unit = "pt")) +
  scale_y_continuous(breaks = seq(0.75,2.25,0.5), labels = seq(0.75,2.25,0.5), 
                     limits = c(0.75,2.25), expand = c(0,0)) +
  scale_fill_manual(name = 'Rearing Temp',labels = labels, 
                    values = pal[c(3,1,2)]) 


## DIAGNOSTICS -----------------------

## comparing original dist to simulated dist
setwd("/Users/jamillaakhund-zade/Thermotaxis Two Choice/autotracker_data/Plasticity/Stan Output") 
load('SimulatedPlasticityVals_FixedPhiPsi.RData')

x_trt = model.matrix(degC ~ inctemp + 0, data = dat) #one hot encoding
y = as.numeric(dat$degC)

color_scheme_set("brightblue")
p1=ppc_dens_overlay(y[as.logical(x_trt[,1])], sim_tempPref[1:50,as.logical(x_trt[,1])])
p2=ppc_dens_overlay(y[as.logical(x_trt[,2])], sim_tempPref[1:50,as.logical(x_trt[,2])])
p3=ppc_dens_overlay(y[as.logical(x_trt[,3])], sim_tempPref[1:50,as.logical(x_trt[,3])])

grid.arrange(p1, p2, p3, nrow=1)

#group by treatment
ppc_stat_grouped(y, sim_tempPref, group = dat$inctemp, stat='sd')
ppc_stat_grouped(y, sim_tempPref, group = dat$inctemp, stat='mean')





