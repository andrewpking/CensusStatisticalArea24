library(tidyverse)
library(tidygeocoder)
library(geosphere)

cities <- read_csv("preprocessing-for-viz/cities.csv")

cities <- cities %>%
  select(CSAFP, geo_id, csa_name, csa_pop, city_name, city_pop)

# Filter by most populous city and change the city name to have abbreviations
# IE Seattle, Washington should be Seattle, WA and Bellevue, Washington should be Bellevue, WA
csa_filtered <- cities %>%
  filter(city_name != "Nashville-Davidson metropolitan government (balance), Tennessee") %>%
  filter(city_name != "Lexington-Fayette urban county, Kentucky") %>%
  filter(city_name != "Indianapolis city (balance), Indiana") %>%
  group_by(CSAFP) %>%
  filter(city_pop == max(city_pop)) %>%
  mutate(
    state = str_trim(str_extract(city_name, ",\\s*.+$") %>% str_remove(",\\s*"))
  ) %>%
  mutate(
    city = str_replace(city_name, ",\\s*.+$", paste0(""))
  ) %>%
  select(-city_name)

write_csv(csa_filtered, "preprocessing-for-viz/csa_filtered.csv")

city_tagged <- csa_filtered %>% geocode(city = city, state = state, method = "osm")

write_csv(city_csa, "preprocessing-for-viz/city_csa_geocoded.csv")

for_the_join <- city_tagged %>%
  mutate(city = paste0(city, ", ", state)) %>%
  select(-state)

# For each valid city add a row that is a link to all other cities
links <- city_tagged %>%
  rename(city1 = city, csafp1 = CSAFP, geo_id1 = geo_id, city_pop1 = city_pop, lat1 = lat, long1 = long) %>%
  expand_grid(geo_id1, .name_repair = "unique")

# Map other variables to name2, ensure variables are not destroyed
city_to_city <- links %>%
  rename(geoid1 = geo_id1...2, geoid2 = geo_id1...10) %>% 
  full_join(for_the_join, by = c("geoid2" = "geo_id"), relationship = "many-to-many") %>%
  rename(csafp2 = CSAFP, city_pop2 = city_pop, lat2 = lat, long2 = long) %>%
  filter(geoid1 != geoid2)

# Calculate the distance between each city in miles.
# Filter out cities that are too far away or are the same city.
distance_to_city <- city_to_city %>%
  mutate(distance = distHaversine(cbind(long1, lat1), cbind(long2, lat2))/1000) %>%
  filter(distance != 0)

# Calculate the estimated ridership as (city_pop1 * city_pop2) / distance^2
hsr_coeffecient <- distance_to_city %>%
  mutate(est_ridership = (csa_pop.x^0.8 * csa_pop.y^0.8)/(distance^2)/(1*10^6))

write_csv(hsr_coeffecient, "preprocessed_edges.csv")
