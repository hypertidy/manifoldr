<!-- README.md is generated from README.Rmd. Please edit that file -->
Examples
--------

-   illustrate this example in both R and Manifold

<https://github.com/mdsumner/talks/blob/master/SQL_3/SQL_3.rmd>

-   dig up the RODBC reader <https://github.com/mdsumner/mdsutils/blob/master/R/odbcReadManifold.R>

-   get rClr working with Manifold

-   parallel CGAL triangulation code with Manifold's DecomposeToTrianglesAdv

### Manifold geometry via RODBC

We can read from Manifold map files using a bit of SQL and the wkb R package.

``` r
## extensions we need
library(wkb)    ## for parsing WKB blobs as Spatial R objects
library(sp)     ## Spatial R objects
library(RODBC)  ## ODBC in R
library(raster) ## just for nice print methods for sp objects
## pull in the odbcConnectManifold function
source("https://raw.githubusercontent.com/mdsumner/mdsutils/master/R/odbcReadManifold.R")

## open a connection to a map file
## remember, this file has Local Scale 0.0001
con <- odbcConnectManifold("E:\\DATA\\Manifold\\ManifoldCD\\Data\\World\\Medium Resolution\\World Provinces.map")
## list the available tables if needed
##sqlTables(con)

## read in just the ID and the Geom (I) as WKB 
## (Manifold's Geom includes the CRS so we cast to OGC using CGeomWKB)
## remember this is just a data.frame
ProvincesGeom <- sqlQuery(con, "SELECT [ID], [Country], [Province], CGeomWKB(Geom(ID)) AS [geom] FROM [Provinces] WHERE [Longitude (I)] > 100 AND [Latitude (I)] < 0")
## get the CRS (somehow)
## . . .
close(con)

## construct an R spatial object from the raw geometry
## this is just SpatialPolygons/Lines/Points (what happens to mixed geom layers?)
Rsp <- readWKB(ProvincesGeom$geom)

## reconstruct our original layer
## remember, this file has Local Scale 0.0001
Countries <- SpatialPolygonsDataFrame(Rsp, subset(ProvincesGeom, select = c("ID", "Country", "Province")))
Countries
#class       : SpatialPolygonsDataFrame 
#features    : 3453 
#extent      : 991389, 1800000, -783533, 20833  (xmin, xmax, ymin, ymax)
#coord. ref. : NA 
#variables   : 3
#names       :     ID, Country,                Province 
#min values  : 262126,        ,              Antarctica 
#max values  : 316877,  Tuvalu, Yogyakarta [Jogjakarta] 
devtools::session_info()
```
