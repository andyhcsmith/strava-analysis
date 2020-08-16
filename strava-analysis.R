# This script analyses strava data

#install.packages(c("devtools", "mapproj", "tidyverse", "gtools"))
devtools::install_github("marcusvolz/strava")
devtools::install_github('fawda123/rStrava')

library(tidyverse)
library(yaml)
library(httr)
library(jsonlite)
library(devtools)
library(strava)
library(rStrava)
library(googlePolylines)
library(ggmap)

setwd('C:/Users/sma8lw/OneDrive - BP/Documents/Andrew/Other/strava-app')

# Setting up credentials, authorization and tokens
credentials = suppressWarnings(read_yaml('credentials.yaml'))

app <- oauth_app("strava", credentials$client_id, credentials$secret)
endpoint <- oauth_endpoint(
  request = NULL,
  authorize = "https://www.strava.com/oauth/authorize",
  access = "https://www.strava.com/oauth/token"
)

token <- oauth2.0_token(endpoint, app, as_header = FALSE,
                        scope = "activity:read_all")


###### Summary statistics for strava activities

acts <- get_activity_list(token)
acts <- acts %>% compile_activities()

## Adding in new features
# Average speed against length of run
acts <- acts %>% mutate(speed_min_km = (moving_time/60)/distance)

# removing outlier run
acts <- acts %>% filter(speed_min_km > 3 & speed_min_km < 5.5)


acts <- acts %>% 
        mutate(distance_bucket = case_when(
                                            distance < 6 ~ "< 6km",
                                            distance < 9 ~ "6km - 9km",
                                            distance < 12 ~ "9km - 12km",
                                            distance < 15 ~ "12km - 15km",
                                            distance >= 15 ~ "> 15km",
                                          )
        )
acts$distance_bucket = factor(acts$distance_bucket, levels=c("< 6km", "6km - 9km", "9km - 12km", "12km - 15km", "> 15km"))

speed_distance <- acts %>% 
                    ggplot(aes(x = speed_min_km, fill = distance_bucket)) + 
                    geom_density(alpha = 0.5) + 
                    labs(title = "Average speed (min/km) against Distance RUn", x = "Speed (min/km)", y = "Density") +
                    xlim(3.5, 5.5) +
                    facet_grid(rows = vars(distance_bucket))

# Linear plot
speed_distance_linear <- acts %>% 
                          ggplot(aes(x = speed_min_km, y = distance)) + 
                          geom_point() +
                          geom_point(data = acts %>% filter(distance > 35),
                                     pch=21, fill=NA, size=5, colour="red", stroke=2) 

########### Using Marcus Volz plotting functions

# Reading all gpx files
data <- process_data('activities/')

p1 <- plot_facets(data)
ggsave("plots/facets001.png", p1, width = 20, height = 20, units = "cm")
  
mapgilbert <- get_map(location = c(lon = mean(data$lon), lat = mean(data$lat)), zoom = 4,
                      maptype = "satellite", scale = 2)

ggmap(mapgilbert) +
  geom_point(data = data, aes(x = lon, y = lat, fill = "red", alpha = 0.8), size = 5, shape = 21) +
  guides(fill=FALSE, alpha=FALSE, size=FALSE)

data %>% ggplot(aes(lon, lat, group = id)) + 
  geom_path(data = data, alpha = 0.3,size = 0.3, lineend = "round") + 
  coord_map(xlim = c(lon_min,lon_max), ylim = c(lat_min, lat_max))

p_map <- plot_map(data, lon_min = 144.75, lon_max = 145.16, lat_min = -38, lat_max = -37.7)
p_day <- plot_calendar(data, unit = "distance")
p_pre_covid <- plot_ridges(data %>% filter(time <= "2020-03-01"))
p_post_covid <- plot_ridges(data %>% filter(time >= "2020-03-01"))


