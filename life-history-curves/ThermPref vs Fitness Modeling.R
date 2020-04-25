# thermal preference vs fitness at different temperatures - modeling
# jamilla a
# created: 2019-07-16
# updated: 2020-04-23

# libraries ---------
library(tidyverse)
library(lme4) #regression modeling for glms and lms
library(countreg) #zero inflated model for regression
library(gamlss) #zero inflated models
library(betareg) #beta regression
library(fitdistrplus) #fits distributions using maximum likelihood
library(performance) #regression model checks
library(MASS) #dist fits
library(car)

## load in data ------------------
setwd('~/Thermotaxis Two Choice/autotracker_data/repository/life-history-curves/data')
load('Fitness.RData')

## egg counts: which distribution should I choose? --------------

#normal qq plot
param.est <- fitdistr(eggCount.tPref$TotalEggs, "normal") #look at logLik (want +++)
qqp(eggCount.tPref$TotalEggs, distribution = "norm") 

#poisson qq plot
param.est <- fitdistr(eggCount.tPref$TotalEggs, "poisson")
qqp(eggCount.tPref$TotalEggs, distribution = "pois", 
    lambda = param.est$estimate[[1]]) #overall

#neg binom qq plot
param.est <- fitdistr(eggCount.tPref$TotalEggs, "negative binomial")
qqp(eggCount.tPref$TotalEggs, distribution = "nbinom", 
    size = param.est$estimate[[1]], mu = param.est$estimate[[2]]) #overall

#zero inflated negative binomial
qqp(eggCount.tPref$TotalEggs, distribution = "ZINBI", 
    mu = 63.77, sigma = 0.46, nu = 0.065) #overall


#MLE distribution fits

descdist(eggCount.tPref$TotalEggs, discrete=T, boot=500) #plots moments of observed data compared to theoretical distributions

fit_nb = fitdist(eggCount.tPref$TotalEggs, 'nbinom')
fit_norm = fitdist(eggCount.tPref$TotalEggs, 'norm')
fit_pois = fitdist(eggCount.tPref$TotalEggs, 'pois')

summary(fit_nb)
plot(fit_nb)

#zero inflated models
fit_ZINB = fitdist(eggCount.tPref$TotalEggs, 'ZINBI', 
                   start = list(mu = 60, sigma = 0.5, nu = 0.1),
                   discrete = T, method = 'mle', #method="mge", gof = 'KS',
                   lower = c(0, 0, 0),
                   upper = c(Inf, Inf, 1)) #zero infl neg binomial
summary(fit_ZINB) #can't compute standard errors numerically
plot(fit_ZINB)

fit_ZIP = fitdist(eggCount.tPref$TotalEggs, 'ZIP', 
                  start = list(mu = 60, sigma = 0.1),
                  discrete = T,
                  lower = c(0, 0),
                  upper = c(Inf,1)) #zero infl poisson
summary(fit_ZIP) #can't compute standard errors numerically
plot(fit_ZIP)

#goodness of fit
gofstat(list(fit_nb, fit_norm, fit_pois, fit_ZINB), 
        fitnames = c("nbinom", "norm", "pois", 'ZINB'))

## viability: which distribution should I choose? --------------

#filter out viabilities > 1
offNum.tPref = offNum.tPref %>% filter(Viability <= 1)
offNum.tPref$ViabilityT = (offNum.tPref$Viability*(dim(offNum.tPref)[1] - 1) + 0.5)/dim(offNum.tPref)[1] #transform to get rid of 1s and 0s by shrinking to center - need for beta fit

#MLE distribution fits

descdist(offNum.tPref$ViabilityT, discrete=F, boot=500) #plots moments of observed data compared to theoretical distributions

plotdist(offNum.tPref$ViabilityT)

fit_beta = fitdist(offNum.tPref$ViabilityT, 'beta')
fit_norm = fitdist(offNum.tPref$ViabilityT, 'norm')
fit_gamma = fitdist(offNum.tPref$ViabilityT, 'gamma')

summary(fit_gamma)
plot(fit_gamma)

#goodness of fit
gofstat(list(fit_beta, fit_norm, fit_gamma), 
        fitnames = c("beta", "norm", "gamma"))

## eclosion time: which distribution should I choose? --------------

#MLE distribution fits

descdist(offNum.tPref$TimeToEclose, discrete=T, boot=500) #plots moments of observed data compared to theoretical distributions

plotdist(offNum.tPref$TimeToEclose) #bimodal distribution - two gaussians?

## egg counts: regression model -----------------

eggCount.tPref$IncTemp = as.factor(eggCount.tPref$IncTemp)
eggCount.tPref$Location = as.factor(eggCount.tPref$Location)


data = eggCount.tPref #pick your dataset 

#X = model.matrix(TotalEggs ~ Pref*IncTemp, data = data)

eggCount_pois= glm(TotalEggs ~ Location + IncTemp + Pref,
                   data = eggCount.tPref, family = 'poisson') #poisson
# dispersiontest(eggCount_pois) #test for overdispersion of poisson - this tells you to use a neg bin model!

eggCount_zinb = zeroinfl(TotalEggs ~ Pref + IncTemp + Location |IncTemp + Location, 
                         dist = 'negbin', data = data) #zero inflated negative binomial

# eggCount_zip = zeroinfl(TotalEggs ~ Pref + IncTemp + Location | IncTemp + Location, 
#                          dist = 'pois', data = data) #zero inflated poisson - bad fit!

# eggCount_hnb = hurdle(TotalEggs ~ Pref + IncTemp + Location, dist = 'negbin',
#                        data = data) #hurdle negative binomial - identical to zinb

#zero inflated negative binomial with interactions - interactions not sigf. 
eggCount_zinb2 = zeroinfl(TotalEggs ~ Pref + Location*IncTemp | IncTemp + Location,
                           dist = 'negbin', data = data)

#negative binomial with heterogenous dispersion parameter (formula2)
# eggCount_nb = nbinomial(TotalEggs ~ Pref + IncTemp + Location,
#                         formula2 = ~ Location,
#                         data = data,
#                         family = "nb2",
#                         mean.link = "log",
#                         scale.link = "log_s")


# eggCount_norm= lm(TotalEggs ~ Location + IncTemp + Pref,
#                    data = eggCount.tPref) #normal


vuong(eggCount_zinb, eggCount_zinb2) #test whether models are different

summary(eggCount_zinb)
summary(eggCount_zinb2)

AIC(eggCount_zinb)
AIC(eggCount_zinb2)

qqrplot(eggCount_zinb2, type = 'random') #check residuals for normality (use random quantile residuals for count data)

r2_zeroinflated(eggCount_zinb2) #calculate r2 for a zero infl model (uses pearson, not raw resid - estimate is inflated; can use method='correlation' for just correlation between fitted and obsv. values)

## viability: regression model -----------------

offNum.tPref$IncTemp = as.factor(offNum.tPref$IncTemp)
offNum.tPref$Location = as.factor(offNum.tPref$Location)


data = offNum.tPref #pick your dataset 

#beta regression - logit link
offNum_beta = betareg(ViabilityT ~ TotalEggs + Pref + Location + IncTemp, 
                      data = data, link='logit')

#beta regression with interaction, logit link
offNum_beta2 = betareg(ViabilityT ~ TotalEggs + Pref*Location + IncTemp, 
                      data = data)

#quasibinomial glm - outcome of multiple binomial trials ('independence of trials' is a bad assumption here, but the model generally agrees with the betareg model)
# offNum_norm = glm(ViabilityT ~ TotalEggs + Pref + Location + IncTemp, 
#                        data = data, family=quasibinomial(logit))

#diagnostic checks
plot(offNum_beta2, which = 1:6, type = 'pearson')

qqp(residuals(offNum_norm), distribution = 'norm')

lrtest(offNum_beta, offNum_beta2) #likelihood ratio test

#check fits against observed
a = tibble(fit=fitted(offNum_beta), obs = offNum.tPref$ViabilityT, loc=offNum.tPref$Location, temp=offNum.tPref$IncTemp)
a %>% group_by(loc) %>%summarise(mean(fit), mean(obs))

