# scripts for analyzing variant output data
# created by jamilla a
# updated: 2019-02-11

#load libraries ---------
library(tidyverse)

## analyzing missingness and mean depth -------------------
#set working directory
setwd("~/Thermotaxis Two Choice/autotracker_data/repository/genetic-diversity/data/frac_missing")

#load in data
missing_2L_df = read_tsv('missing_indv_2L.imiss')
missing_all_df = read_tsv('missing_indv_all.imiss')

setwd("~/Thermotaxis Two Choice/autotracker_data/repository/genetic-diversity/data/mean_depth")
meanDepth_2L_df = read_tsv('meanDepth_2L.idepth')
meanDepth_all_filt_df = read_tsv('meanDepth_all_filt.idepth')

#plot
qplot(F_MISS, data = missing_all_df)
qplot(MEAN_DEPTH, data = meanDepth_all_filt_df)
qplot(missing_all_df$F_MISS, meanDepth_all_filt_df$MEAN_DEPTH)
      
#how many individuals have mean depth < 2?
meanDepth_all_filt_df %>% filter(MEAN_DEPTH < 2) %>% tally()

#how many individuals have missing fraction > 0.25?
missing_all_df %>% filter(F_MISS > 0.25) %>% tally()

#how many individuals have both MEAN_DEPTH > 2 and F_MISS > 0.25?
high_miss = missing_all_df %>% filter(F_MISS > 0.25)
low_depth = meanDepth_all_filt_df %>% filter(MEAN_DEPTH < 2)

bad_indvs = inner_join(high_miss, low_depth)
bad_indvs$LOC = str_split_fixed(bad_indvs$INDV, '_', 2)[,1] #add pop information

qplot(bad_indvs$F_MISS, bad_indvs$MEAN_DEPTH, color=as.factor(bad_indvs$LOC))


## load in heritability and bh adv estimates ---------------

#advantage estimates calculated using geographicBetHedging.m - gaussian convolution of BH advantages of ~7000 stations across the U.S. + territories that is centered at the sampling location 

#BH adv = ln (final BH pop / final AT pop)
#note: FL had 3 closely spaced (within 1km) sampling locations. FL sampling location BH advantage was taken as the average of the 3 sampling locations. 

herit = tibble(loc=c('FL','MA','VA','CA','TX','PA'), 
               h = c(0.49592, 0.062889, 0.21373, 0.01488, 0.085997, 0.15748), 
               h_lci = c(0.2424, -0.0997, -0.0070, -0.3680, -0.1554,-0.0507),
               h_uci = c(0.7494, 0.2255, 0.4344, 0.3978, 0.3274, 0.3657),
               adv = c(-0.5387, 0.004249, 0.002031, 0.004439, 0.001737, 0.001649))



## load in PoPOOLation theta estimates ------------
setwd("~/Thermotaxis Two Choice/autotracker_data/repository/genetic-diversity/data/popoolation/herit")

#see notes on output columns here: https://sourceforge.net/p/popoolation/code/HEAD/tree/trunk/Variance-sliding.pl#l693

ca_herit = read_tsv('ca_herit.theta',
                    col_names=c('chr','pos','snp_count','frac_cov','theta'),
                    col_types='cdddd', na='na')
fl_herit = read_tsv('fl_herit.theta',
                    col_names=c('chr','pos','snp_count','frac_cov','theta'),
                    col_types='cdddd', na='na')
ma_herit = read_tsv('ma_herit.theta',
                    col_names=c('chr','pos','snp_count','frac_cov','theta'),
                    col_types='cdddd', na='na')
pa_herit = read_tsv('pa_herit.theta',
                    col_names=c('chr','pos','snp_count','frac_cov','theta'),
                    col_types='cdddd', na='na')
tx_herit = read_tsv('tx_herit.theta',
                    col_names=c('chr','pos','snp_count','frac_cov','theta'),
                    col_types='cdddd', na='na')
va_herit = read_tsv('va_herit.theta',
                    col_names=c('chr','pos','snp_count','frac_cov','theta'),
                    col_types='cdddd', na='na')



theta_herit = tibble(VA=va_herit$theta[1:2680], 
                     FL=fl_herit$theta[1:2680],
                     MA=ma_herit$theta[1:2680], 
                     PA=pa_herit$theta[1:2680], 
                     TX=tx_herit$theta[1:2680],
                     CA=ca_herit$theta[1:2680]) %>% 
  gather(key='loc', value = 'theta')

theta_herit$loc = factor(theta_herit$loc, levels = c('FL','MA','VA','CA','TX','PA'))

## load in bootstrapped estimates of seg sites -------------
#set working directory
setwd("~/Thermotaxis Two Choice/autotracker_data/repository/genetic-diversity/data/new bootstrapping/herit_boot_all_sites")

ca_herit = read_tsv('boot_ca_herit_segsites_all.table')
fl_herit = read_tsv('boot_fl_herit_segsites_all.table')
ma_herit = read_tsv('boot_ma_herit_segsites_all.table')
pa_herit = read_tsv('boot_pa_herit_segsites_all.table')
tx_herit = read_tsv('boot_tx_herit_segsites_all.table')
va_herit = read_tsv('boot_va_herit_segsites_all.table')

#Watterson's Theta sample size correction: 17 chromosomes (indvs) in heritability pops after downsampling
n_chr = 1:(17-1) 

seg_sites_herit = tibble(VA=va_herit$seg_sites, FL=fl_herit$seg_sites,
                         MA=ma_herit$seg_sites, PA=pa_herit$seg_sites, 
                         TX=tx_herit$seg_sites, CA=ca_herit$seg_sites) %>% 
  gather(key='loc', value = 'num_sites')
seg_sites_herit$loc = factor(seg_sites_herit$loc, levels = c('FL','MA','VA','CA','TX','PA'))
seg_sites_herit$theta = (seg_sites_herit$num_sites)/sum(1/n_chr)

## save as RData file -----------
save(seg_sites_herit, theta_herit, 'Heritability Theta Estimates.RData')


## load in theta est., bh adv, and heritability est for heritability pops ------------------
setwd("~/Thermotaxis Two Choice/autotracker_data/repository/genetic-diversity/data/")
load('Heritability Theta Estimates.RData')

#summary table for PoPoolation estimates
theta_mean = theta_herit %>% group_by(loc) %>% 
  summarize(mean = mean(theta, na.rm=T), std = sd(theta, na.rm=T))
theta_mean$h = herit$h
theta_mean$h_lci = herit$h_lci
theta_mean$h_uci = herit$h_uci
#theta_mean$h_adj = herit$h/theta_mean$mean #herit/theta
#theta_mean$h_adj_lci = herit$h_lci/theta_mean$mean
#theta_mean$h_adj_uci = herit$h_uci/theta_mean$mean
theta_mean$adv = herit$adv

theta_mean$loc = factor(theta_mean$loc, levels = c('CA','FL','MA','PA','TX','VA'))

#summary table for resampled estimates
seg_sites_mean = seg_sites_herit %>% group_by(loc) %>% 
  summarize(mean = mean(theta), std = sd(theta))
seg_sites_mean$h = herit$h
seg_sites_mean$h_lci = herit$h_lci
seg_sites_mean$h_uci = herit$h_uci
#seg_sites_mean$h_adj = herit$h/seg_sites_mean$mean #herit/theta
#seg_sites_mean$h_adj_lci = herit$h_lci/seg_sites_mean$mean
#seg_sites_mean$h_adj_uci = herit$h_uci/seg_sites_mean$mean
seg_sites_mean$adv = herit$adv

seg_sites_mean$loc = factor(seg_sites_mean$loc, levels = c('CA','FL','MA','PA','TX','VA'))

## plotting of heritability and theta estimates -------------

#histogram plots of number of segregating sites (num_sites) or theta (theta)

q = ggplot(aes(x=theta), data = seg_sites_herit) + 
  geom_histogram(aes(fill = loc)) + facet_wrap(~loc, 2, 3)
q

#heritability vs theta estimate
pal = c('#D86F27','#068E8C','#C82E6B','#364285','#00A757','#E5BA52')

q = ggplot(aes(x=mean, y=h, color = loc), data = seg_sites_mean) + 
  geom_point(size = 5) + 
  geom_errorbarh(aes(xmin = mean - 2*std, xmax = mean+2*std)) + 
  geom_errorbar(aes(ymin = h_lci, ymax = h_uci)) + 
  theme_bw()+
  ylab('Heritability') + xlab('Genome θ')+
  theme(axis.text = element_text(size = 16),
        axis.title = element_text(size = 20),
        legend.text = element_text(size = 18),
        legend.title = element_text(size = 18),
        panel.grid = element_blank()) +
  scale_color_manual(values = pal)
q

#adjusted heritability vs bh advantage
library(scales)
q = ggplot(aes(x=adv, y=h), data = seg_sites_mean) + 
  geom_point(aes(color = loc), size = 5) + 
  geom_errorbar(aes(ymin = h_lci, ymax = h_uci, color=loc)) + 
  theme_bw()+
  ylab('Heritability') + xlab('BH advantage')+
  theme(axis.text = element_text(size = 14),
        axis.title = element_text(size = 16),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 14),
        panel.grid = element_blank()) +
  scale_color_manual(values = pal)+
  scale_x_continuous(trans=pseudo_log_trans(sigma = 0.001, base = 10),
                     breaks=c(-0.5, -0.05, -0.005, 0, 0.005))
q



## load in variability estimates --------------

#set your working directory to Stan output for the degC metric or degC metric - batch correct
setwd("/Users/jamillaakhund-zade/Thermotaxis Two Choice/autotracker_data/repository/variability/data/stan-output")

#load and process posterior distributions
load('Site Averages Variablity.RData')
load('Line Averages Variablity.RData')

## load in poPOOLation theta estimates for var pops-------
setwd("~/Thermotaxis Two Choice/autotracker_data/repository/genetic-diversity/data/popoolation/var")

#see notes on output columns here: https://sourceforge.net/p/popoolation/code/HEAD/tree/trunk/Variance-sliding.pl#l693

berk_var = read_tsv('berk_var.theta',
                  col_names=c('chr','pos','snp_count','frac_cov','theta'),
                  col_types='cdddd', na='na')
ca_var = read_tsv('ca_var.theta',
                    col_names=c('chr','pos','snp_count','frac_cov','theta'),
                    col_types='cdddd', na='na')
fl_var = read_tsv('fl_var.theta',
                    col_names=c('chr','pos','snp_count','frac_cov','theta'),
                    col_types='cdddd', na='na')
ma_var = read_tsv('ma_var.theta',
                    col_names=c('chr','pos','snp_count','frac_cov','theta'),
                    col_types='cdddd', na='na')
pa_var = read_tsv('pa_var.theta',
                    col_names=c('chr','pos','snp_count','frac_cov','theta'),
                    col_types='cdddd', na='na')
tx_var = read_tsv('tx_var.theta',
                    col_names=c('chr','pos','snp_count','frac_cov','theta'),
                    col_types='cdddd', na='na')
va_var = read_tsv('va_var.theta',
                    col_names=c('chr','pos','snp_count','frac_cov','theta'),
                    col_types='cdddd', na='na')


theta_var = tibble(VA=va_var$theta[1:2680], 
                     FL=fl_var$theta[1:2680],
                     MA=ma_var$theta[1:2680], 
                     PA=pa_var$theta[1:2680], 
                     TX=tx_var$theta[1:2680],
                     CA=ca_var$theta[1:2680],
                    BE=berk_var$theta[1:2680]) %>% 
  gather(key='loc', value = 'theta')

theta_var$loc = factor(theta_var$loc, levels = c('BE','CA','FL','MA','PA','TX','VA'))

## load in bootstrapped estimates of seg sites -------------
#set working directory
setwd("~/Thermotaxis Two Choice/autotracker_data/repository/genetic-diversity/data/new bootstrapping/var_boot_all_sites")

brk_var_site = read_tsv('boot_berk_var_segsites_all.table')
ca_var_site = read_tsv('boot_ca_var_segsites_all.table')
fl_var_site = read_tsv('boot_fl_var_segsites_all.table')
ma_var_site = read_tsv('boot_ma_var_segsites_all.table')
pa_var_site = read_tsv('boot_pa_var_segsites_all.table')
tx_var_site = read_tsv('boot_tx_var_segsites_all.table')
va_var_site= read_tsv('boot_va_var_segsites_all.table')

n_chr = 1:(8-1)
seg_sites_var = tibble(VA=va_var_site$seg_sites, FL=fl_var_site$seg_sites,
                       MA=ma_var_site$seg_sites, PA=pa_var_site$seg_sites, 
                       TX=tx_var_site$seg_sites, CA=ca_var_site$seg_sites,
                       BE=brk_var_site$seg_sites) %>% 
  gather(key='loc', value = 'num_sites')

seg_sites_var$loc = factor(seg_sites_var$loc, levels = c('BE','CA','FL','MA','PA','TX','VA'))
seg_sites_var$theta = (seg_sites_var$num_sites)/sum(1/n_chr)


q = ggplot(aes(x=theta), data = seg_sites_var) + 
  geom_histogram(aes(fill = loc)) + facet_wrap(~loc, 3, 3)
q
## save as RData file ------------------
setwd("~/Thermotaxis Two Choice/autotracker_data/repository/genetic-diversity/data/")
save(theta_var, seg_sites_var, file='Variability Theta Estimates.RData')
## load in theta est, bh adv, and variability metrics for var pops-------------
setwd("~/Thermotaxis Two Choice/autotracker_data/repository/genetic-diversity/data/")
load('Variability Theta Estimates.RData')

#summary table
theta_mean = theta_var %>% group_by(loc) %>% 
  summarize(mean = mean(theta, na.rm=T), std = sd(theta, na.rm=T))
theta_mean$var_mean = summary_site_mean$mean #mean estimates
theta_mean$var_mean_sd = summary_site_mean$sd
theta_mean$var_var = summary_site_var$mean #variance estimates
theta_mean$var_var_sd = summary_site_var$sd
theta_mean$var_sd = summary_site_sd$mean #standard deviation estimates
theta_mean$var_sd_sd = summary_site_sd$sd
theta_mean$bh_adv = c(0.005457, 0.004439, -0.5387, 0.004249, 0.001649, 0.001737, 0.002031)

theta_mean$loc = factor(theta_mean$loc, levels = c('BE','CA','FL','MA','PA','TX','VA'))

#make new data frame with seg sites and behavior metrics
seg_sites_mean = seg_sites_var %>% group_by(loc) %>% 
  summarize(mean = mean(theta), std = sd(theta))
seg_sites_mean$var_mean = summary_site_mean$mean #mean estimates
seg_sites_mean$var_mean_sd = summary_site_mean$sd
seg_sites_mean$var_var = summary_site_var$mean #variance estimates
seg_sites_mean$var_var_sd = summary_site_var$sd
seg_sites_mean$var_sd = summary_site_sd$mean #standard deviation estimates
seg_sites_mean$var_sd_sd = summary_site_sd$sd
seg_sites_mean$bh_adv = c(0.005457, 0.004439, -0.5387, 0.004249, 0.001649, 0.001737, 0.002031)

seg_sites_mean$loc = factor(seg_sites_mean$loc, levels = c('BE','CA','FL','MA','PA','TX','VA'))

## plotting of estimates -------------

#variability (mean/var) vs mean num seg sites
pal = c('#65BADA','#D86F27','#068E8C','#C82E6B','#364285','#00A757','#E5BA52')

q = ggplot(aes(x=mean, y=var_sd, color = loc), data = theta_mean) + 
  geom_point(size = 5) + 
  #geom_errorbarh(aes(xmin = mean - 2*std, xmax = mean+2*std, height=0.03)) + 
  geom_errorbar(aes(ymin = var_sd-2*var_sd_sd, ymax = var_sd+2*var_sd_sd)) + 
  theme_bw()+
  ylab('SD in Temp Pref') + xlab('Mean Num Seg Sites')+
  theme(axis.text = element_text(size = 14),
        axis.title = element_text(size = 16),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 14),
        panel.grid = element_blank()) +
  scale_color_manual(values = pal) 
q

#variability vs bet-hedging advantage
library(scales)
q = ggplot(aes(x=bh_adv, y=var_sd, color = loc), data = seg_sites_mean) + 
  geom_point(size = 5) + 
  geom_errorbar(aes(ymin = var_sd-2*var_sd_sd, ymax = var_sd+2*var_sd_sd)) + 
  theme_bw()+
  ylab('SD in Temp Pref') + xlab('BH advantage')+
  theme(axis.text = element_text(size = 14),
        axis.title = element_text(size = 16),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 14),
        panel.grid = element_blank()) +
  scale_color_manual(values = pal) + 
  scale_x_continuous(trans=pseudo_log_trans(sigma = 0.001, base = 10),
                     breaks=c(-0.5, -0.05, -0.005, 0, 0.005))
q




## load in line estimates of seg sites -------------
#set working directory
setwd("~/Thermotaxis Two Choice/autotracker_data/repository/genetic-diversity/data/new bootstrapping/var_line_all_sites")

brk_var_line = read_tsv('count_berk_var_segsites_all.table')
ca_var_line = read_tsv('count_ca_var_segsites_all.table')
fl_var_line = read_tsv('count_fl_var_segsites_all.table')
ma_var_line = read_tsv('count_ma_var_segsites_all.table')
pa_var_line = read_tsv('count_pa_var_segsites_all.table')
tx_var_line = read_tsv('count_tx_var_segsites_all.table')
va_var_line = read_tsv('count_va_var_segsites_all.table')


## plotting of estimates -------------
n_chr=1:(4-1)
seg_sites_line = rbind(brk_var_line,ca_var_line,fl_var_line,ma_var_line,
                       pa_var_line,tx_var_line,va_var_line)
seg_sites_line$theta = (seg_sites_line$seg_sites)/sum(1/n_chr)
colnames(seg_sites_line) = c('line','loc','seg_sites','theta')

#join with summary statistics table - mean
seg_sites_line_mean = inner_join(summary_line_mean, seg_sites_line, by="line")

seg_sites_line_mean$loc = factor(seg_sites_line_mean$loc, 
                                 levels = c("berk_var", "ca_var", "fl_var",
                                             "ma_var","pa_var","tx_var","va_var"))
levels(seg_sites_line_mean$loc) = c('BE','CA','FL','MA','PA','TX','VA')

seg_sites_line_mean$line = factor(seg_sites_line_mean$line, 
                                  levels = c('BERK_7','BERK_1',
                                             'CA_14','CA_2','CA_22',
                                             'FL_7_3','FL_9_8','MIA_3_76','MIA_5_155',
                                             'MA_5_73','PA_6','PA_8','PA_18','PA_10',
                                             'TX_11_1','TX_13_5','CM0705.036',
                                             'CM0719.026','CM0802.061','CM0816.031'))
#join with summary statistics table - var
seg_sites_line_var = inner_join(summary_line_var, seg_sites_line, by="line")

seg_sites_line_var$loc = factor(seg_sites_line_var$loc, 
                                 levels = c("berk_var", "ca_var", "fl_var",
                                            "ma_var","pa_var","tx_var","va_var"))
levels(seg_sites_line_var$loc) = c('BE','CA','FL','MA','PA','TX','VA')

seg_sites_line_var$line = factor(seg_sites_line_var$line, 
                                  levels = c('BERK_7','BERK_1',
                                             'CA_14','CA_2','CA_22',
                                             'FL_7_3','FL_9_8','MIA_3_76','MIA_5_155',
                                             'MA_5_73','PA_6','PA_8','PA_18','PA_10',
                                             'TX_11_1','TX_13_5','CM0705.036',
                                             'CM0719.026','CM0802.061','CM0816.031'))


#join with summary statistics table - sd
seg_sites_line_sd = inner_join(summary_line_sd, seg_sites_line, by="line")

seg_sites_line_sd$loc = factor(seg_sites_line_sd$loc, 
                                levels = c("berk_var", "ca_var", "fl_var",
                                           "ma_var","pa_var","tx_var","va_var"))
levels(seg_sites_line_sd$loc) = c('BE','CA','FL','MA','PA','TX','VA')

seg_sites_line_sd$line = factor(seg_sites_line_sd$line, 
                                 levels = c('BERK_7','BERK_1',
                                            'CA_14','CA_2','CA_22',
                                            'FL_7_3','FL_9_8','MIA_3_76','MIA_5_155',
                                            'MA_5_73','PA_6','PA_8','PA_18','PA_10',
                                            'TX_11_1','TX_13_5','CM0705.036',
                                            'CM0719.026','CM0802.061','CM0816.031'))


#variability (mean/var) vs mean num seg sites
q = ggplot(aes(x=theta, y=mean, color = loc), data = seg_sites_line_sd) + 
  geom_point(size = 5) + 
  geom_errorbar(aes(ymin = mean - 2*sd, ymax = mean+2*sd)) + 
  theme_bw()+
  ylab('SD in Temp Pref') + xlab('Num Seg Sites')+
  theme(axis.text = element_text(size = 14),
        axis.title = element_text(size = 16),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 14),
        panel.grid = element_blank()) +
  scale_color_manual(values = pal) 
q





## correlation tests -----
cor.test(seg_sites_mean$adv, seg_sites_mean$h_adj)
cor.test(seg_sites_mean$adv, seg_sites_mean$h)
cor.test(seg_sites_mean$mean, seg_sites_mean$h)

#filter out FL and do correlation tests
noFL = theta_mean %>% filter(loc != 'FL')
cor.test(noFL$adv, noFL$h_adj) #adv and adjusted heritabiliy
cor.test(noFL$adv, noFL$h) #adv and heritability
cor.test(noFL$mean, noFL$h) #theta and heritability

