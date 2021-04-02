## A generic code to construct your own crosswalk, from two shapefiles

import pandas as pd
import geopandas as gpd
import os

## defining variables - change the things in ALL_CAPS
reporting_path = '/Users/clairenelson/Dropbox/great-outmigration/claire/great_migration/data/nhgis0003_shapefile_tl2008_us_county_1900'
reporting_fname = 'US_county_1900_conflated.shp'
reporting_geoid = 'ICPSRCTY'

reference_path = '/Users/clairenelson/Dropbox/great-outmigration/claire/great_migration/data/nhgis0003_shapefile_tl2008_us_county_1940'
reference_fname = 'US_county_1940_conflated.shp'
reference_geoid = 'ICPSRCTY'

output_path = '/Users/clairenelson/Dropbox/great-outmigration/claire/great_migration/output'
output_fname = 'county_concordances'

# A note: the reporting and reference geo_ids should be different.

## read in starting shapefile
os.chdir(reporting_path)
shp_reporting = gpd.GeoDataFrame.from_file(reporting_fname)
shp_reporting['area_base'] = shp_reporting.area

## read in ending shapefile
os.chdir(reference_path)
shp_reference = gpd.GeoDataFrame.from_file(reference_fname)


## intersecting the file
intersect = gpd.overlay(shp_reporting, shp_reference, how = 'intersection')
intersect['area'] = intersect.area

## computing weights
intersect['weight'] = intersect['area'] / intersect['area_base']

## renormalizing weights - this isn't necesary, but without it, if the shapefiles do not perfectly line up where they should, you may lose small fractions of area here and there
reweight = intersect.groupby(reporting_geoid)['weight'].sum().reset_index()
reweight['new_weight'] = reweight['weight']
reweight = reweight.drop('weight', axis = 1)

intersect = intersect.merge(reweight, left_on = reporting_geoid, right_on = reporting_geoid)
intersect['weight'] = intersect['weight'] / intersect['new_weight']

intersect = intersect.drop('new_weight', axis =1)


## keeping only relevant columns - again isn't necessary, but will help trim down the size of the crosswalk at the end
output = intersect[[reporting_geoid, reference_geoid, 'weight']]


## saving output
os.chdir(output_path)
output.to_csv(output_fname, index = False)
