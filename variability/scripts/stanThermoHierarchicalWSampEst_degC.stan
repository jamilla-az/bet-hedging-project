// Stan model specification for thermal preference
// hierarchical model for estimation of site effects - degC metric
// power sampling error curve
// created by Jamilla Akhund-Zade
// last date modified: 2019-08-27

functions {
}

data {
  int<lower=0> N; // number of observations
  int<lower=0> L; // number of lines
  int<lower=0> K; // number of sites
  matrix[N, L] x_line; // predictor matrix for lines
  matrix[L, K] x_site; // predictor matrix for sites
  vector[N] y;    // outcome vector - thermal pref on degC scale
  vector[N] dist; // distance traveled
  real<lower=0> phi;    // scaling coefficient in sampling err model
  real<upper=0> psi;    // exp coefficient in sampling err model
  vector<upper=0>[N] offset; // batch offset: 0 for 2018 and negative for Jan and Apr 2019

}


parameters {
  vector[L] m_line;          // mean of each line
  vector<lower=0>[L] v_line; // var of each line

  vector[K] m_site;          // mean of each site
  vector<lower=0>[K] v_site; // var of each site
  
  //vector<lower=0>[K] sigma_m_site; //sigma for line mean prior
  real<lower=0> sigma_m_site; //sigma for line mean prior
  //vector<lower=0>[K] sigma_v_site; //sigma for line var prior
  real<lower=0> sigma_v_site; //sigma for line var prior


}


transformed parameters {
  vector<lower=0>[N] sigma;
  for (n in 1:N) {	
  	sigma[n] = sqrt(x_line[n]*v_line + phi*pow(dist[n], psi) + offset[n]);
  }

}


model {
    // Priors

    sigma_m_site ~ gamma(2, 0.5);
    sigma_v_site ~ gamma(2, 0.5);

    m_site ~ normal(24, 1);	//normal prior on site means
    v_site ~ gamma(2, 0.5);	//gamma prior on site vars

    m_line ~ normal(x_site*m_site, sigma_m_site); //normal prior on line means
    v_line ~ normal(x_site*v_site, sigma_v_site); //normal prior on line vars

    // Likelihood for data
    y ~ normal(x_line*m_line, sigma);
    
}

generated quantities {
  vector[N] log_lik;
  vector[N] y_rep;
  for (n in 1:N) {

    log_lik[n] = normal_lpdf(y[n] | x_line[n]*m_line, sqrt(x_line[n]*v_line + phi*pow(dist[n],psi)));

    y_rep[n] = normal_rng(x_line[n]*m_line, sqrt(x_line[n]*v_line + phi*pow(dist[n],psi)));

  }
}
