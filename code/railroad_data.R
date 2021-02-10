#Map railroad shapefiles

rm(list=ls())
library(rgdal)
library(tidyverse)
library(ggplot2)
library(maps)
setwd("/Users/clairenelson/Documents/Research/great_migration")

#Read in shapefiles
railroad_map <- readOGR(dsn = "data/railroad_shapefiles", layer = "RR1826-1911Modified050916")

#Fortify to data frame
railroad_fortified <- fortify(railroad_map)

#Plot and save as PNG
ggplot() +
  geom_path(data = railroad_fortified, mapping=aes( x = long, y = lat, group = group)) +
  theme_bw() + ggtitle("Railroads, 1826-1911") + theme(axis.title=element_blank(),
                     axis.text=element_blank(),
                     axis.ticks=element_blank(),
                     panel.grid.minor = element_blank(),
                     panel.grid.major = element_blank())

ggsave("output/railroad_map.png")
