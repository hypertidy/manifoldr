
#' @importFrom RODBC sqlQuery
manifoldCRS <- function(connection, componentname) {
  qu <- sprintf('SELECT TOP 1 CoordSysToWKT(CoordSys(\"%s\" AS COMPONENT)) AS [CRS] FROM [%s]',  
                componentname, 
                componentname)
  RODBC::sqlQuery(connection, qu, stringsAsFactors = FALSE)$CRS
}

#' #' @importFrom RODBC sqlQuery
#' manifoldDrawingCRS <- function(connection, componentname) {
#'    qu <- sprintf('SELECT TOP 1 CoordSysToWKT(CCoordSys([Geom (I)])) AS [CRS] FROM [%s]',  componentname)
#'   RODBC::sqlQuery(connection, qu, stringsAsFactors = FALSE)$CRS
#' }
#' 
#' #' @importFrom RODBC sqlQuery
#' manifoldRasterCRS <- function(connection, componentname) {
#'   ## this should work but does not
#'   ##qu <- sprintf('SELECT TOP 1 CoordSysToWKT(CoordSys("%s" AS COMPONENT)) AS [CRS] FROM [%s]', componentname, componentname)
#'  # TOP 1 CCoordSys(NewPoint([Easting (I)], [Northing (I)]))
#'   qu <- sprintf('OPTIONS COORDSYS("[%s]" AS COMPONENT);SELECT TOP 1 CoordSysToWKT(CCoordSys(NewPoint([Easting (I)], [Northing (I)]))) AS [CRS] FROM [%s];',  componentname, componentname)
#'   #print(qu)
#'   RODBC::sqlQuery(connection, qu, stringsAsFactors = FALSE)$CRS
#' }

#' @param CRS coordinate reference system in WKT form
#'
#' @rawNamespace 
#' if ( packageVersion("rgdal") >= "1.1.4") {
#' importFrom("rgdal", showP4)
#' }
#' @importFrom utils packageVersion
#' @importFrom rgdal writeOGR readOGR
#' @importFrom sp proj4string SpatialPoints SpatialPointsDataFrame
wktCRS2proj4 <- function(CRS) {
  
  if ( packageVersion("rgdal") >= "1.1.4") {
    return(rgdal::showP4(CRS))
  }
  dsn <- tempdir()
  f <- basename(tempfile())
  writeOGR(SpatialPointsDataFrame(SpatialPoints(cbind(1, 1)), data.frame(x = 1)), dsn, f, "ESRI Shapefile", overwrite_layer = TRUE)
  writeLines(CRS, paste(file.path(dsn, f), ".prj", sep = ""))
  proj4 <- proj4string(readOGR(dsn, f, verbose = FALSE))
  proj4
  
}

#' @importFrom methods is
#' @importFrom rgeos readWKT
#' @importFrom maptools spRbind
#' @importFrom sp SpatialPolygonsDataFrame
wkt2Spatial <- function(x, id = NULL, p4s = NULL, data = data.frame(x = 1:length(x), row.names = id), ...) {
  if (is.null(id)) id <- as.character(seq_along(x))
  for (i in seq_along(x)) {
    a1 <- rgeos::readWKT(x[i], id = id[i], p4s = p4s)
    if (i == 1) {
      res <- a1
    } else {
      res <- maptools::spRbind(res, a1)
    }
  }
  if (is(res, "SpatialPolygons")) {
    res <- sp::SpatialPolygonsDataFrame(res, data, ...)
  }
  
  res
}
