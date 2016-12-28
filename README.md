[![Travis-CI Build Status](https://travis-ci.org/r-gris/manifoldr.svg?branch=master)](https://travis-ci.org/r-gris/manifoldr)

<!-- README.md is generated from README.Rmd. Please edit that file -->
manifoldr
=========

Manifoldr allows direct connection to Manifold .map projects from R via ODBC. We can read tables in full, or issue SQL queries to select or dynamically create new tables.

``` r
library(manifoldr)
mapfile <- system.file("extdata", "AreaDrawing.map", package = "manifoldr")
(x <- Drawing(mapfile))
#> Simple feature collection with 31 features and 2 fields
#> geometry type:  GEOMETRY
#> dimension:      XY
#> bbox:           xmin: -615.2802 ymin: -565.2889 xmax: 1334.871 ymax: 612.3995
#> epsg (SRID):    NA
#> proj4string:    NA
#> First 20 features:
#>    ID Name                       geometry
#> 1  10    L POLYGON((-178 168, -169 -27...
#> 2  11    E POLYGON((10 177, 11 167, 27...
#> 3  12    G POLYGON((183.5 98, 199.5 -7...
#> 4  13    I POLYGON((406.5 182, 413.5 -...
#> 5  14    O POLYGON((513.5 142, 526.5 3...
#> 6  15    N POLYGON((732.5 201, 754.5 -...
#> 7  22      LINESTRING(-615.28015075376...
#> 8  24      LINESTRING(1315.8756281407 ...
#> 9  26    O               POINT(513.5 142)
#> 10 27                     POINT(526.5 38)
#> 11 28                    POINT(548.5 -21)
#> 12 29                    POINT(634.5 -36)
#> 13 30                    POINT(668.5 -17)
#> 14 31                     POINT(687.5 38)
#> 15 32                    POINT(687.5 122)
#> 16 33                    POINT(682.5 161)
#> 17 34                    POINT(660.5 189)
#> 18 35                    POINT(628.5 200)
#> 19 36                    POINT(576.5 199)
#> 20 37                    POINT(551.5 183)
```

Note the mixed types which are now available in R via [sf]()

Basic Manifold queries work, using the "WHERE" argument.

``` r
Drawing(mapfile, WHERE = "WHERE [Type (I)] = 2")
#> Simple feature collection with 2 features and 2 fields
#> geometry type:  LINESTRING
#> dimension:      XY
#> bbox:           xmin: -615.2802 ymin: -565.2889 xmax: 1334.871 ymax: 612.3995
#> epsg (SRID):    NA
#> proj4string:    NA
#>   ID Name                       geometry
#> 1 22   NA LINESTRING(-615.28015075376...
#> 2 24   NA LINESTRING(1315.8756281407 ...

Drawing(mapfile, WHERE = "WHERE IsLine(ID) AND [Length (I)] < 2500")
#> Simple feature collection with 1 feature and 2 fields
#> geometry type:  LINESTRING
#> dimension:      XY
#> bbox:           xmin: -111.9133 ymin: -321.5201 xmax: 1334.871 ymax: 612.3995
#> epsg (SRID):    NA
#> proj4string:    NA
#>   ID Name                       geometry
#> 1 24   NA LINESTRING(1315.8756281407 ...
```

Exciting!

Installation
------------

1.  `manifoldr` relies on [Manifold® System](http://www.manifold.net) GIS, it's of no use if you don't have this installed and working.

2.  `manifoldr` is only available from GitHub: the easiest way to install it is to use the `devtools` package.

``` r
if (packageVersion("devtools") < 1.6) {
  install.packages("devtools")
}
devtools::install_github("mdsumner/manifoldr")
```

(Future versions may become available on CRAN. )

NOTES:
------

-   The ODBC driver for Manifold is *read-only*, so we cannot modify the contents of an existing file.

-   Please take care not to modify a Manifold project while an R session has a open connection to it. If you try to save such a project, you will get an error seen below. If you see this, and you want to save your changes you must choose "Yes", and save the file to a new location. There is no other option that I know of:

![alt text](inst/extdata/openCon.png)

-   Drawings that use a Local Scale different from 1.0 and/or a Local Offset different from 0.0 will not be read with correct geometry. I'm not sure how to work through this yet.

-   There are many issues with the conversion from Manifold to WKT or PROJ.4 strings, there's a lot of work to do here.

All the [standard Manifold SQL](http://www.georeference.org/doc/manifold.htm#sql_in_manifold_system.htm) is available.

NOTE: this will be merged with mdsumnner/dplrodbc in some way. Was originally called RforManifold.

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

See the package vignettes for examples.

Problems
--------

-   Large Geoms and other binary types are stored as the `ODBC_binary` type from the `RODBC` package. Be careful with these columns as they do not have compact printing methods. This is something to added to a future version of this package.

TODO
----

-   illustrate this example in both R and Manifold

<https://github.com/mdsumner/talks/blob/master/SQL_3/SQL_3.rmd>

-   dig up the RODBC reader <https://github.com/mdsumner/mdsutils/blob/master/R/odbcReadManifold.R>

-   get rClr working with Manifold: install from here <https://github.com/jmp75/rClr>

-   parallel CGAL triangulation code with Manifold's DecomposeToTrianglesAdv

-   <https://github.com/mdsumner/dplyrodbc>
