

#' Read a Drawing from a Manifold project. 
#'
#' @param mapfile Manifold project file
#' @param dwgname Drawing name to read
#'
#' @return drawingA returns a 'SpatialPolygonsDataFrame', drawingL a 'SpatialLinesDataFrame' and drawingP a 'SpatialPointsDataFrame'
#' @export
#' 
#' @examples
#' mapfile <- system.file("extdata", "AreaDrawing.map", package = "manifoldr")
#' #geom2D <- DrawingA(mapfile, "Drawing")
#' #geom2D
#' 
#' #geom1D <- DrawingL(mapfile, "Drawing")
#' #geom1D
#' 
#' #geom0D <- DrawingP(mapfile, "Drawing")
#' #geom0D
DrawingA <- function(mapfile, dwgname) {
  
  readmfd(mapfile, dwgname, topol = "area", spatial = TRUE)
}


#' @rdname DrawingA
#' @export
DrawingL <- function(mapfile, dwgname) {
  readmfd(mapfile, dwgname, topol = "line", spatial = TRUE)
}

#' @rdname DrawingA
#' @export
DrawingP <- function(mapfile, dwgname) {
  readmfd(mapfile, dwgname, topol = "point", spatial = TRUE)
}




#' Read a Surface from a Manifold project file. 
#'
#' @param mapfile Manifold project file
#' @param rastername Surface name to read 
#'
#' @return RasterLayer
#' @export
#'
#' @examples
#' mapfile2 <- system.file("extdata", "Montara_20m.map", package= "manifoldr")
#' #gg <- Surface(mapfile2, "Montara")
#' @importFrom raster extent ncol nrow raster setValues
Surface <- function(mapfile, rastername) {
  if (!requireNamespace("raster", quietly = TRUE)) {
    stop("raster package not available, please install it with install.packages(\"raster\")")
  } else {
    if (!"raster" %in% .packages()) {
      if (interactive()) {warning("raster package is loaded but not attached, you'll need to run library(\"raster\") to use it") }
    }
  }
  on.exit(.cleanup(con))
  # if (!checkAvailability()) {stop("Manifold is not installed, but is required for connection to project files.")}
  con <- odbcConnectManifold(mapfile)
  
  row1 <- sqlQuery(con, sprintf("SELECT TOP 1 * FROM [%s]", rastername))
  zz <- sqlQuery(con, sprintf("SELECT [Height (I)] FROM [%s]", rastername))
  georef <- getGeoref(con, rastername)
  crswkt <- manifoldCRS(con, rastername)
  #print(crswkt)
  crs <- wktCRS2proj4(crswkt)
  #  print(crs)
  #crs <- NA_character_
  setValues(rasterFromManifoldGeoref(georef, crs), zz$`Height (I)`)
}


#' Read an Image from a Manifold project file. 
#'
#' For now we are assuming we just get an RGB 3-layer object. 
#' 
#' @param mapfile Manifold project file
#' @param rastername Image name to read 
#'
#' @return RasterBrick
#' @export
#'
#' @examples
#' fmap <- "V20160202016022.L3m_R3QL_NPP_CHL_chlor_a_9km.map"
#' mapfile <- system.file("extdata", fmap, package= "manifoldr")
#' #im <- Image(mapfile, "V20160202016022.L3m_R3QL_NPP_CHL_chlor_a_9km")
#' @importFrom raster brick extent ncol nrow raster setValues
Image <- function(mapfile, rastername) {
  if (!requireNamespace("raster", quietly = TRUE)) {
    stop("raster package not available, please install it with install.packages(\"raster\")")
  } else {
    if (!"raster" %in% .packages()) {
      if (interactive()) {warning("raster package is loaded but not attached, you'll need to run library(\"raster\") to use it") }
    }
  }
  on.exit(.cleanup(con))
  # if (!checkAvailability()) {stop("Manifold is not installed, but is required for connection to project files.")}
  con <- odbcConnectManifold(mapfile)
  
  row1 <- sqlQuery(con, sprintf("SELECT TOP 1 * FROM [%s]", rastername))
  zz <- sqlQuery(con, sprintf("SELECT [Red (I)], [Green (I)], [Blue (I)] FROM [%s]", rastername))
  georef <- getGeoref(con, rastername)
  crswkt <- manifoldCRS(con, rastername)
  #print(crswkt)
  crs <- wktCRS2proj4(crswkt)
  #  print(crs)
  #crs <- NA_character_
  r0 <- rasterFromManifoldGeoref(georef, crs)
  setValues(brick(r0, r0, r0), cbind(zz[[1]], zz[[2]], zz[[3]]))
}
