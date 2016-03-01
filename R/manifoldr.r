

#' @importFrom wkb readWKB
#' @importFrom sp CRS proj4string<- SpatialPolygonsDataFrame SpatialLinesDataFrame SpatialPointsDataFrame
readmfd <- function(dsn, table, WHERE = NULL, spatial = FALSE, topol = c("area", "line", "point")) {

  topol <- match.arg(topol)
  on.exit(.cleanup(con))
 # if (!checkAvailability()) {stop("Manifold is not installed, but is required for connection to project files.")}
  con <- odbcConnectManifold(dsn)
  atts <- "*"
  if (spatial) {
    
    #mc <- mapcontents(dsn)
    attributes <- columnames(con, table)
    #mc$columns$colnames[mc$columns$tableID == mc$tables$ID[which(mc$tables$TABLE_NAME == table)]]
   
    attributes <- 
      paste0("[", attributes[-grep(" \\(I\\)", attributes)], "]")
  #  print(attributes)
    randomstring <- paste(sample(c(letters, 1:9), 15, replace = TRUE), collapse = "")
    atts <- sprintf("%s, CGeomWKB(Geom(ID)) AS [%s]", paste(attributes, collapse = ","), randomstring)
    crswkt <- manifoldCRS(con, table)
    crs <- wktCRS2proj4(crswkt)
   # print(crswkt)
  #  print(crs)
  }
  #if (is.null(query)) {
  if (is.null(WHERE)) WHERE <- "" else WHERE <- sprintf("AND %s", WHERE)
  topolclausestring <- topolclause(topol)
    query <- sprintf("SELECT %s FROM [%s] WHERE %s %s", atts, table, topolclausestring, WHERE)
  #}
    
  #print(query)
  
  #return(query)
 x <-  RODBC::sqlQuery(con, query)
 if (spatial) {
   if (nrow(x) < 1L) stop("query returned no records, cannot create a Spatial object from this")
   geom <- wkb::readWKB(x[[randomstring]])
   proj4string(geom) <-  CRS(crs)
  # print(geom)
   x[[randomstring]] <- NULL
   ## reconstruct our original layer
   x <- switch(topol, 
                area = SpatialPolygonsDataFrame(geom, x, match.ID = FALSE), 
                line = SpatialLinesDataFrame(geom, x, match.ID = FALSE), 
                point = SpatialPointsDataFrame(geom, x, match.ID = FALSE))
   
 }
 x
}

rasterFromManifoldGeoref <- function(x, crs) {
  ex <- extent(x$xmin,  x$xmin + x$ncol * x$dx,
               x$ymax - (x$nrow - 1) * x$dy,
               x$ymax + x$dy)
  raster(ex, nrow = x$nrow, ncol = x$ncol, crs = crs)
}


getGeoref <- function(con, rastername) {
  sqlQuery(con, sprintf("SELECT TOP 1 [Easting (I)] AS [xmin],  [Northing (I)] AS [ymax], PixelsByX([%s]) AS [ncol], PixelsByY([%s]) AS [nrow], 
                        PixelWidth([%s]) AS [dx], PixelHeight([%s]) AS [dy] FROM [%s]", rastername, rastername, rastername, rastername, rastername))
}
columnames <- function(con, tablename) {
  names(sqlQuery(con, sprintf("SELECT * FROM [%s] WHERE 0 = 1", tablename)))
}
mapcontents <- function(mapfile) {
  on.exit(.cleanup(con))
  con <- odbcConnectManifold(mapfile)
  if (con < 0) stop(sprintf('cannot open %s\nRODBC warning messages:\n\n', mapfile))
  tabs <- RODBC::sqlTables(con)
  tabs$ID <- seq(nrow(tabs))
  cols <- vector("list", nrow(tabs))
  # print(names(tabs))
  for (itab in seq_along(tabs$TABLE_NAME)) {
    tab <- sqlQuery(con, sprintf("SELECT * FROM [%s] WHERE 0 = 1", tabs$TABLE_NAME[itab]), as.is = TRUE)
    # print(tab)
    # print(list(colnames = names(tab), table = tabs$TABLE_NAME[itab]))
    # 
    cols[[itab]] <- data.frame(colnames = names(tab), tableID = tabs$ID[itab], stringsAsFactors = FALSE)
  }
  list(columns = do.call(rbind, cols),tables = tabs)
}
