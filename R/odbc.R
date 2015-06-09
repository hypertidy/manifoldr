#' ODBC connection to Manifold map files.
#' 
#' Create an ODBC connection for Manifold GIS. 
#' 
#' See \code{\link[RODBC]{odbcDriverConnect}}
#' @param mapfile 
#'
#' @return RODBC object
## @importFrom RODBC odbcDriverConnect
#' @export
odbcConnectManifold <- function (mapfile)
  
{
  
  full.path <- function(filename) {
    
    fn <- chartr("\\", "/", filename)
    
    is.abs <- length(grep("^[A-Za-z]:|/", fn)) > 0
    
    chartr("/", "\\", if (!is.abs)
      
      file.path(getwd(), filename)
      
      else filename)
    
  }
  
  con <- if (missing(mapfile))
    
    "Driver={Manifold Project Driver (*.map)};Dbq="
  
  else {
    
    fp <- full.path(mapfile)
    
    paste("Driver={Manifold Project Driver (*.map)};DBQ=",
          
          fp, ";DefaultDir=", dirname(fp), ";Unicode=False;Ansi=False;OpenGIS=False;DSN=Default", ";", sep = "")
    
  }
  
  RODBC::odbcDriverConnect(con)
  
}




manifoldCRS <- function(connection, componentname) {
  sqlQuery(connection, sprintf('SELECT TOP 1 CoordSysToWKT(CoordSys("%s" AS COMPONENT)) AS [CRS] FROM [%s]', componentname, componentname), stringsAsFactors = FALSE)$CRS
}

wktCRS2proj4 <- function(CRS) {
  require(rgdal)
  dsn <- tempdir()
  f <- basename(tempfile())
  writeOGR(SpatialPointsDataFrame(SpatialPoints(cbind(1, 1)), data.frame(x = 1)), dsn, f, "ESRI Shapefile", overwrite = TRUE)
  writeLines(CRS, paste(file.path(dsn, f), ".prj", sep = ""))
  proj4 <- proj4string(readOGR(dsn, f, verbose = FALSE))
  proj4
  
}


wkt2Spatial <- function(x, id = NULL, p4s = NULL, data = data.frame(x = 1:length(x), row.names = id), ...) {
  ##res <- vector("list", length(x))
  require(rgeos)
  require(maptools)
  if (is.null(id)) id <- as.character(seq_along(x))
  for (i in seq_along(x)) {
    a1 <- readWKT(x[i], id = id[i], p4s = p4s)
    if (i == 1) {
      res <- a1
    } else {
      res <- spRbind(res, a1)
    }
  }
  if (is(res, "SpatialPolygons")) {
    res <- SpatialPolygonsDataFrame(res, data, ...)
  }
  
  res
}