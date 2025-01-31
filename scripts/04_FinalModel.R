library(dplyr)
library(readr)
library(brms)
library(cmdstanr)

data <- read_tsv('data.tsv') %>% 
  mutate(sound_class = paste(voicing, sound_class),
         word_initial = as.factor(word_initial),
         utt_initial = as.factor(utt_initial))

# TODO: See other set_cmdstan_path comment.
# If necessary, set path to specific cmdstan installation
set_cmdstan_path(path = "/data/tools/stan/cmdstan-2.32.2/")
print(cmdstan_path())

cl_max <- 
  brm(data=data,
      family=lognormal(),
      formula=Duration ~ 1 + utt_initial + word_initial + 
        (1 + utt_initial + word_initial | Language / (sound_class + Speaker)) +
        z_speech_rate + z_num_phones + z_word_freq,
      prior=c(prior(normal(4.4, 0.2), class=Intercept),
              prior(exponential(12), class=sigma),
              prior(normal(0, 0.3), class=b),
              prior(exponential(12), class=sd),
              prior(lkj(5), class=cor)),    
      iter=4000, warmup=2000, chains=4, cores=4,
      control = list(adapt_delta=0.80, max_treedepth=10),
      seed=42,
      silent=0,
      file="models/cl_final",
      backend="cmdstanr"
  )
