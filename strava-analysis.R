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

setwd('C:/Users/sma8lw/OneDrive - BP/Documents/Andrew/Other/strava-app')

# Setting up credentials, authorization and tokens
credentials = read_yaml('credentials.yaml')

app <- oauth_app("strava", credentials$client_id, credentials$secret)
endpoint <- oauth_endpoint(
  request = NULL,
  authorize = "https://www.strava.com/oauth/authorize",
  access = "https://www.strava.com/oauth/token"
)

token <- oauth2.0_token(endpoint, app, as_header = FALSE,
                        scope = "activity:read_all")


# Reading all gpx files
data <- process_data('activities/')

# Summary statistics for strava activities
length(unique(data$id))
# New line for testing git


p1 <- plot_facets(data)
ggsave("plots/facets001.png", p1, width = 20, height = 20, units = "cm")
  

p2 <- plot_map(data, lon_min = 144.75, lon_max = 145.16, lat_min = -38, lat_max = -37.7)
ggsave("plots/map001.png", p2, width = 20, height = 15, units = "cm", dpi = 600)


p4 <- plot_calendar(data, unit = "distance")
ggsave("plots/calendar001.png", p4, width = 20, height = 20, units = "cm")

p5 <- plot_ridges(data %>% filter(time <= "2020-03-01"))
ggsave("plots/ridges001.png", p5, width = 20, height = 20, units = "cm")
p6 <- plot_ridges(data %>% filter(time >= "2020-03-01"))
ggsave("plots/ridges002.png", p6, width = 20, height = 20, units = "cm")


