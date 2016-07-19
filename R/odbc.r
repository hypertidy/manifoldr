#' ODBC connection to Manifold map files.
#' 
#' Create an ODBC connection for Manifold GIS. 
#' 
#' See \code{\link[RODBC]{odbcDriverConnect}}
#' @param mapfile character string, path to Manifold project *.map file
#' @param unicode logical
#' @param ansi logical
#' @param opengis logical
#' @details See the documentation for the underlying driver:
#' \url{http://www.georeference.org/doc/using_the_manifold_odbc_driver.htm}
#' Be sure to set ansi = FALSE for some string escape cases like CoordSys("Drawing" AS COMPONENT). 
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
#' }
#' @return RODBC object
#' @importFrom RODBC odbcDriverConnect
#' @importFrom tools toTitleCase 
#' @export
odbcConnectManifold <- function (mapfile, unicode = TRUE, ansi = FALSE, opengis = TRUE)
  
{
  
  full.path <- function(filename) {
    
    fn <- chartr("\\", "/", filename)
    
    is.abs <- length(grep("^[A-Za-z]:|/", fn)) > 0
    
    chartr("/", "\\", if (!is.abs)
      
      file.path(getwd(), filename)
      
      else filename)
    
  }
  unicode <- tools::toTitleCase(tolower(format(unicode)))
  ansi <- tools::toTitleCase(tolower(format(ansi)))
  opengis <- tools::toTitleCase(tolower(format(opengis)))
  
  parms <- sprintf(";Unicode=%s;Ansi=%s;OpenGIS=%s;DSN=Default", unicode, ansi, opengis)
  
  con <- if (missing(mapfile))
    
    "Driver={Manifold Project Driver (*.map)};Dbq="
  
  else {
    
    fp <- full.path(mapfile)
    
    paste("Driver={Manifold Project Driver (*.map)};DBQ=",
          
          fp, ";DefaultDir=", dirname(fp), parms, ";", sep = "")
    
  }
  RODBC::odbcDriverConnect(con)
  
}

#' ManifoldODBCDriver and methods.
#'
#' @export
#' @keywords internal 
setClass("ManifoldODBCDriver", contains = "DBIDriver")

#' Generate an object of ManifoldODBCDriver class
#' @rdname ManifoldODBCDriver-class
#' @export
ManifoldODBC <- function() {new("ManifoldODBCDriver")}

#' Class ODBCConnection.
#'
#' \code{ODBCConnection} objects are usually created by \code{\link[DBI]{dbConnect}}
#' @keywords internal
#' @export
setClass(
  "ManifoldODBCConnection",
  contains="ODBCConnection"
)

#' Connect/disconnect to a ODBC data source
#'
#' These methods are straight-forward implementations of the corresponding generic functions.
#'
#' @param drv an object of class ODBCDriver
#' @param dsn Data source name you defined by ODBC data source administrator tool.
#' @param user User name to connect as.
#' @param password Password to be used if the DSN demands password authentication.
#' @param ... Other parameters passed on to methods
#' @import methods
#' @import DBI
#' @export
setMethod(
  "dbConnect",
  "ManifoldODBCDriver",
  function(drv, dsn, user = NULL, password = NULL, ...){
    connection <- odbcConnectManifold(dsn, ...)
    new("ManifoldODBCConnection", odbc=connection)
  }
)

setMethod("dbReadTable", c("ManifoldODBCConnection", "character"), function(conn, name, row.names = NA, check.names = TRUE, select.cols = "*") {
  qu <- sprintf("SELECT %s FROM [%s]", select.cols,  name)
  print(qu)
  out <- dbGetQuery(conn, qu, row.names = row.names)
  if (check.names) {
    names(out) <- make.names(names(out), unique = TRUE)
  }  
  out
})


.cleanup <- function(x) {
  if (x > -1) RODBC::odbcClose(x)
  invisible(NULL)
}
