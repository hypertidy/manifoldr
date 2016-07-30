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


.cleanup <- function(x) {
  if (x > -1) RODBC::odbcClose(x)
  invisible(NULL)
}
