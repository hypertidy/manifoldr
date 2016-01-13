[![Travis-CI Build Status](https://travis-ci.org/mdsumner/manifoldr.svg?branch=master)](https://travis-ci.org/mdsumner/manifoldr) [![](http://www.r-pkg.org/badges/version/manifoldr)](http://www.r-pkg.org/pkg/manifoldr) [![](http://cranlogs.r-pkg.org/badges/manifoldr)](http://www.r-pkg.org/pkg/manifoldr)

<!-- README.md is generated from README.Rmd. Please edit that file -->
R for Manifold
==============

Installation
------------

``` r
devtools::install_github("mdsumner/manifoldr")
```

Basic Usage
-----------

Open a connection to a .map file an issue a query.

``` r
library(manifoldr)
library(RODBC)
con <- odbcConnectManifold("E:\\ManifoldDVD\\Data\\World\\Medium Resolution\\World Provinces.map")
Provinces <- sqlQuery(con, "SELECT [ID], [Country], [Province]
                                FROM [Provinces_] WHERE [Longitude (I)] > 100 AND [Latitude (I)] < 0")
close(con)
```

All the [standard Manifold SQL](http://www.georeference.org/doc/manifold.htm#sql_in_manifold_system.htm) is available. NOTE: this will be merged with mdsumnner/dplrodbc in some way. Was originally called RforManifold.

Manifold GIS and R make for a powerful partnership, but the coupling between them has been relatively loose and sketchy.

Two key recent R packages make the coupling more compelling:

-   [wkb](http://cran.rstudio.com/web/packages/wkb/index.html): Convert Between Spatial Objects and Well-Known Binary (WKB) Geometry
-   [rClr](https://rclr.codeplex.com)

The main ways we connect R and Manifold are

1.  read drawing layers with data from Manifold .map files via SQL queries
2.  drive the Manifold API directly via .Net.
3.  (developing) simplify the queries via dplyr

The first provides a pretty tight mapping of high-level data types, i.e. in Manifold we have a drawing and in R we have a Spatial layer and moving from one to the other is easy.

The second provides a lot more power but we need to do more work to transfer data between the systems.

There are lots of other pathways, including GDAL as a third/fourth party and via file transfer.

Examples
--------

-   illustrate this example in both R and Manifold

<https://github.com/mdsumner/talks/blob/master/SQL_3/SQL_3.rmd>

-   dig up the RODBC reader <https://github.com/mdsumner/mdsutils/blob/master/R/odbcReadManifold.R>

-   get rClr working with Manifold: install from here <https://github.com/jmp75/rClr>

-   parallel CGAL triangulation code with Manifold's DecomposeToTrianglesAdv

### Manifold geometry via RODBC

We can read from Manifold map files using a bit of SQL and the wkb R package.

``` r
## extensions we need
library(wkb)    ## for parsing WKB blobs as Spatial R objects
library(sp)     ## Spatial R objects
library(RODBC)  ## ODBC in R
library(raster) ## just for nice print methods for sp objects
library(manifoldr)
## open a connection to a map file
## original  file has Local Scale 0.0001, so I use a modified copy "Provinces_"
con <- odbcConnectManifold("E:\\ManifoldDVD\\Data\\World\\Medium Resolution\\World Provinces.map")
## list the available tables if needed
##sqlTables(con)

## read in just the ID and the Geom (I) as WKB 
## (Manifold's Geom includes the CRS so we cast to OGC using CGeomWKB)
## remember this is just a data.frame
ProvincesGeom <- sqlQuery(con, "SELECT [ID], [Country], [Province], CGeomWKB(Geom(ID)) AS [geom] FROM [Provinces_] WHERE [Longitude (I)] > 100 AND [Latitude (I)] < 0")
## get the CRS (somehow)
## . . .
close(con)

## construct an R spatial object from the raw geometry
## this is just SpatialPolygons/Lines/Points (what happens to mixed geom layers?)
Rsp <- readWKB(ProvincesGeom$geom)

## reconstruct our original layer
Countries <- SpatialPolygonsDataFrame(Rsp, subset(ProvincesGeom, select = c("ID", "Country", "Province")))
Countries
#> class       : SpatialPolygonsDataFrame 
#> features    : 3453 
#> extent      : 99.1389, 180, -78.3533, 2.0833  (xmin, xmax, ymin, ymax)
#> coord. ref. : NA 
#> variables   : 3
#> names       :     ID, Country,                Province 
#> min values  : 359690,        ,              Antarctica 
#> max values  : 392515,  Tuvalu, Yogyakarta [Jogjakarta]

plot(Countries)
```

![](README-unnamed-chunk-2-1.png)

``` r
devtools::session_info()
#>  setting  value                                      
#>  version  R version 3.2.3 Patched (2015-12-22 r69809)
#>  system   x86_64, mingw32                            
#>  ui       RTerm                                      
#>  language (EN)                                       
#>  collate  English_Australia.1252                     
#>  tz       Australia/Hobart                           
#>  date     2016-01-14                                 
#> 
#>  package   * version    date       source                         
#>  devtools    1.9.1      2015-09-11 CRAN (R 3.2.3)                 
#>  digest      0.6.9      2016-01-08 CRAN (R 3.2.3)                 
#>  evaluate    0.8        2015-09-18 CRAN (R 3.2.3)                 
#>  foreign     0.8-66     2015-08-19 CRAN (R 3.2.3)                 
#>  formatR     1.2.1      2015-09-18 CRAN (R 3.2.3)                 
#>  htmltools   0.3        2015-12-29 CRAN (R 3.2.3)                 
#>  knitr       1.12.1     2016-01-11 Github (yihui/knitr@f610bc5)   
#>  lattice     0.20-33    2015-07-14 CRAN (R 3.2.3)                 
#>  magrittr    1.5        2014-11-22 CRAN (R 3.2.3)                 
#>  manifoldr * 0.0.2.9000 2016-01-13 local                          
#>  maptools    0.8-37     2015-09-29 CRAN (R 3.2.3)                 
#>  memoise     0.2.1      2014-04-22 CRAN (R 3.2.3)                 
#>  raster    * 2.5-2      2015-12-19 CRAN (R 3.2.3)                 
#>  Rcpp        0.12.2     2015-11-15 CRAN (R 3.2.3)                 
#>  rgdal       1.1-4      2016-01-05 local                          
#>  rgeos       0.3-15     2015-11-04 CRAN (R 3.2.3)                 
#>  rmarkdown   0.9.2      2016-01-01 CRAN (R 3.2.3)                 
#>  RODBC     * 1.3-12     2015-06-29 CRAN (R 3.2.3)                 
#>  sp        * 1.2-1      2015-10-18 CRAN (R 3.2.3)                 
#>  stringi     1.0-1      2015-10-22 CRAN (R 3.2.3)                 
#>  stringr     1.0.0.9000 2016-01-11 Github (hadley/stringr@a67f8f0)
#>  wkb       * 0.2-0      2015-09-28 CRAN (R 3.2.3)                 
#>  yaml        2.1.13     2014-06-12 CRAN (R 3.2.3)
```
