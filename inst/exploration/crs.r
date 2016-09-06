
library(manifoldr)
library(RODBC)
library(raster)
mapfile2 <- system.file("extdata", "Montara_20m.map", package= "manifoldr")
componentname <- "Montara"
connection <- odbcConnectManifold(mapfile2)
## this should work but does not
##qu <- sprintf('SELECT TOP 1 CoordSysToWKT(CoordSys("%s" AS COMPONENT)) AS [CRS] FROM [%s]', componentname, componentname)
# TOP 1 CCoordSys(NewPoint([Easting (I)], [Northing (I)]))
#qu <- sprintf('OPTIONS COORDSYS("%s" AS COMPONENT);SELECT TOP 1 CoordSysToWKT(CCoordSys(NewPoint([Easting (I)], [Northing (I)]))) AS [CRS] FROM [%s];',  componentname, componentname)
#cat(qu)
RODBC::sqlQuery(connection, qu, stringsAsFactors = FALSE) #$CRS

mfile <- manifoldr:::instmapfiles()[1]
con <- odbcConnectManifold(mfile)
qu <- 'SELECT TOP 1 CoordSysToWKT(CoordSys("Drawing" AS COMPONENT)) AS [CRS] FROM [Drawing]'
sqlQuery(con, qu)
