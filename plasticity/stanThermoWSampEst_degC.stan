// Stan model specification for thermal preference
// linear model for estimation of plasticity effects - degC metric
// power sampling error curve
// created by Jamilla Akhund-Zade
// last date modified: 2019-09-25

functions {
}

data {
  int<lower=0> N; // number of observations
  int<lower=0> L; // number of treatments
  matrix[N, L] x_trt; // predictor matrix for treatments
  vector[N] y;    // outcome vector - thermal pref on degC scale
  vector[N] dist; // distance traveled
  real<lower=0> phi;    // scaling coefficient in sampling err model
  real<upper=0> psi;    // exp coefficient in sampling err model
  
}


parameters {
  vector[L] m_trt;          // mean of each treatment
  vector<lower=0>[L] v_trt; // var of each treatment

}


transformed parameters {
  vector<lower=0>[N] sigma;
  for (n in 1:N) {	
  	sigma[n] = sqrt(x_trt[n]*v_trt + phi*pow(dist[n], psi));
  }

}


model {
    // Priors

    m_trt ~ normal(24, 1); //normal prior on treatment means
    v_trt ~ gamma(2, 0.5); //gamma prior on treatment vars

    // Likelihood for data
    y ~ normal(x_trt*m_trt, sigma);
    
}

generated quantities {
  vector[N] log_lik;
  vector[N] y_rep;
  for (n in 1:N) {

    log_lik[n] = normal_lpdf(y[n] | x_trt[n]*m_trt, sqrt(x_trt[n]*v_trt + phi*pow(dist[n],psi)));

    y_rep[n] = normal_rng(x_trt[n]*m_trt, sqrt(x_trt[n]*v_trt + phi*pow(dist[n],psi)));

  }
}
