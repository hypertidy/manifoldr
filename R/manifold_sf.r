#' Read a Drawing from a Manifold project. 
#'
#' @param mapfile Manifold project file
#' @param dwgname Drawing name to read
#'
#' @return Drawing returns a `sf` object
#' @export
#' 
#' @examples
#' mapfile <- system.file("extdata", "AreaDrawing.map", package = "manifoldr")
#' dwg  <- Drawing(mapfile, "Drawing")
#' ## only lines
#' dwg_sub <- Drawing(mapfile, WHERE = "WHERE [Type (I)] = 2")
Drawing <- function(mapfile, dwgname, ...) {
  sfmfd(mapfile, dwgname, ...)
}

query_mfd <- function(dsn, query) {
  on.exit(.cleanup(con))
  # if (!checkAvailability()) {stop("Manifold is not installed, but is required for connection to project files.")}
  con <- odbcConnectManifold(dsn)
  RODBC::sqlQuery(con, query)
}

#' @export
#' @importFrom sf st_as_sfc st_as_sf
#' @importFrom RODBC sqlTables
#' @importFrom tibble as_tibble
sfmfd <- function(dsn, table, sf_geom_name = "geom", crs = NULL, WHERE = "", quiet = FALSE) {
   atts <- "*"
   verbose = !quiet
   on.exit(.cleanup(con))
    #mc <- mapcontents(dsn)
   con <- odbcConnectManifold(dsn)
   if (missing(table)) {
     available_tables <- RODBC::sqlTables(con)
     avt <- available_tables[available_tables[["TABLE_TYPE"]] == "TABLE", ]
     if (nrow(avt) > 0) {
       table <- avt$TABLE_NAME[1]
       if (verbose) print(sprintf("choosing table [%s] from: ", table))
       if (verbose) print(paste(avt$TABLE_NAME, collapse = ","))
     } else {
       stop("no tables available")
     }
   }
    attributes <- manifoldr:::columnames(con, table)
    #mc$columns$colnames[mc$columns$tableID == mc$tables$ID[which(mc$tables$TABLE_NAME == table)]]
    #close(con)
    attributes <- 
      paste0("[", attributes[-grep(" \\(I\\)", attributes)], "]")
    atts <- sprintf("%s, CGeomWKB(Geom(ID)) AS [%s]", paste(attributes, collapse = ","), sf_geom_name)
    crswkt <- manifoldr:::manifoldCRS(con, table)
    if (is.null(crs)) {
      crs <- manifoldr:::wktCRS2proj4(crswkt)
    }
    query <- sprintf("SELECT %s FROM [%s] %s", atts, table,  WHERE)
    if (verbose) print(query)
  x <-  manifoldr:::query_mfd(dsn, query)
  empty <- which(unlist(lapply(x[[sf_geom_name]], length)) < 1)
  if (length(empty) > 0) {
   # x[[sf_geom_name]][empty] <- replicate(length(empty), NULL)
    ## drop it
    if (verbose) print(sprintf("dropping %i empty features", length(empty)))
    x <- x[-empty, ]
    if (nrow(x) < 1L) stop("all geometries are empty")
  }
  x <- tibble::as_tibble(x)
  x[[sf_geom_name]] <- sf::st_as_sfc(structure(x[[sf_geom_name]], class = "WKB"), EWKB = FALSE)
  st_as_sf(x)
}