[![Travis-CI Build Status](https://travis-ci.org/mdsumner/manifoldr.svg?branch=master)](https://travis-ci.org/mdsumner/manifoldr) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/mdsumner/manifoldr?branch=master&svg=true)](https://ci.appveyor.com/project/mdsumner/manifoldr) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/manifoldr)](https://cran.r-project.org/package=manifoldr) [![Coverage Status](https://img.shields.io/codecov/c/github/mdsumner/manifoldr/master.svg)](https://codecov.io/github/mdsumner/manifoldr?branch=master)

<!-- README.md is generated from README.Rmd. Please edit that file -->
manifoldr
=========

Manifoldr allows direct connection to Manifold .map projects from R via ODBC. We can read tables in full, or issue SQL queries to select or dynamically created new tables.

NOTE: The ODBC driver for Manifold is *read-only*, so we cannot modify the contents of an existing file.

Please take care not to modify a Manifold project while an R session has a open connection to it. If you try to save such a project, you will get an error like this:

![alt text](inst/extdata/openCon.png)

If you see this, and you want to save your changes you must choose "Yes", and save the file to a new location. There is no other option that I know of.

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

Problems
--------

-   Large Geoms and other binary types are stored as the `ODBC_binary` type from the `RODBC` package. Be careful with these columns as they do not have compact printing methods. This is something to added to a future version of this package.

Basic Usage
-----------

Open a connection to a built-in .map file and issue a query.

``` r
library(manifoldr)
library(RODBC)
mapfile <- system.file("extdata", "AreaDrawing.map", package = "manifoldr")
con <- odbcConnectManifold(mapfile)
tab <- sqlQuery(con, "SELECT [ID], [Name], BranchCount([ID]) AS [nBranch] FROM [Drawing] ORDER BY [nBranch]")
close(con)

print(tab)
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

See the package vignettes for examples.

TODO
----

-   illustrate this example in both R and Manifold

<https://github.com/mdsumner/talks/blob/master/SQL_3/SQL_3.rmd>

-   dig up the RODBC reader <https://github.com/mdsumner/mdsutils/blob/master/R/odbcReadManifold.R>

-   get rClr working with Manifold: install from here <https://github.com/jmp75/rClr>

-   parallel CGAL triangulation code with Manifold's DecomposeToTrianglesAdv

-   <https://github.com/mdsumner/dplyrodbc>
