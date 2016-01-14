#' ODBC connection to Manifold map files.
#' 
#' Create an ODBC connection for Manifold GIS. 
#' 
#' See \code{\link[RODBC]{odbcDriverConnect}}
#' @param mapfile Manifold project *.map file
#' @examples
#' \dontrun{
#' f <- system.file("extdata", "AreaDrawing.map", package = "manifoldr")
#' con <- odbcConnectManifold(f)
#' tab <- RODBC::sqlQuery(con, "SELECT * FROM [Drawing]")
#' ## drop [Geom (I)] and give a summary
#' summary(subset(tab, select = -`Geom (I)`))
#' 
#' ## issue a spatial query
#' qtx <- "SELECT [ID], [Name], [Length (I)] AS [Perim], 
#'      BranchCount([ID]) AS [nbranches] FROM [Drawing Table]"
#' sq <- RODBC::sqlQuery(con, qtx)
#' sq
#'
#' }
#' @return RODBC object
#' @importFrom RODBC odbcDriverConnect
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



readmfd <- function(dsn, table, query = NULL) {
  if (!checkAvailability()) {stop("Manifold is not installed, but is required for connection to project files.")}
  con <- odbcConnectManifold(dsn)
  if (is.null(query)) {
    query <- sprintf("SELECT * FROM [%s]", table)
  }
 x <-  RODBC::sqlQuery(con, query)
 x
}

read_area <- function(mapfile, dwgname) {
  query <- sprintf("SELECT [ID], [Name] FROM [%s] WHERE IsArea([ID])", dwgname)
  cat(query)
  readmfd(mapfile, query = query)
}
#' @importFrom RODBC sqlQuery
manifoldCRS <- function(connection, componentname) {
  RODBC::sqlQuery(connection, sprintf('SELECT TOP 1 CoordSysToWKT(CoordSys("%s" AS COMPONENT)) AS [CRS] FROM [%s]', componentname, componentname), stringsAsFactors = FALSE)$CRS
}

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
