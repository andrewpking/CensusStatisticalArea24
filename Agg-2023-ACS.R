library(tidyverse)

csaEst23 <- read_csv('csa-est2023-alldata.csv')

filteredEst <- csaEst23 %>%
  filter(is.na(CBSA)) %>%
  select(CSAFP = CSA, Name = NAME, Pop2020 = ESTIMATESBASE2020, Pop2021 = POPESTIMATE2021, Pop2022 = POPESTIMATE2022, Pop2023 = POPESTIMATE2023)

write_csv(filteredEst, 'CSAPopulation-20-23.csv')
