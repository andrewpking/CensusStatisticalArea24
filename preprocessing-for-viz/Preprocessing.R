library(tidyverse)
library(tidygeocoder)

cities <- read_csv("preprocessing-for-viz/cities.csv")
csa <- read_csv("preprocessing-for-viz/csaPopulation-20-23.csv")

csa <- csa %>%
  select(csafp = CSAFP, csa_name = Name, CSA_Pop = Pop2023)

cities <- cities %>%
  select(csafp, city_name = name, City_Pop = population)

city_csa <- csa %>%
  left_join(cities)
