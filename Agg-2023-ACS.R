library(tidyverse)

csaEst23 <- read_csv('csa-est2023-alldata.csv')

csaEst <- csaEst23 %>%
  filter(LSAD == "Combined Statistical Area") %>%
  select(CSAFP = CSA, csa_name = NAME, csa_pop = POPESTIMATE2023)

write_csv(csaEst, 'CSAPop.csv')
