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
#' dwg_sub
Drawing <- function(mapfile, dwgname, ...) {
  con <- odbcConnectManifold(mapfile)
  mfd_read_db(con, dwgname, ...)
}

query_mfd <- function(dsn, query) {
  on.exit(.cleanup(con))
  con <- odbcConnectManifold(dsn)
  RODBC::sqlQuery(con, query)
}

.choose_table <- function(con, verbose) {
  #geometry_columns <- RODBC::sqlQuery(con, "SELECT * FROM [geometry_columns]")
  #available_OGC_tables <- unique(geometry_columns$F_TABLE_NAME)
  available_tables <- sqlTables(con)
  avt <- available_tables[available_tables[["TABLE_TYPE"]] == "TABLE", ]
  if (nrow(avt) > 0) {
    ##table <- available_OGC_tables[1L] 
    table <- avt$TABLE_NAME[1]
    if (verbose) print(sprintf("choosing first table [%s] from: ", table))
    if (verbose) print(paste(avt$TABLE_NAME, collapse = ","))
    ## maybe list the actual tables as well ...
  } else {
    stop("no OGC-compliant tables available")
  }
  table
}
#' @export
#' @importFrom sf st_as_sfc st_as_sf
#' @importFrom RODBC sqlTables
#' @importFrom tibble as_tibble
mfd_read_db <- function(con = NULL, table, 
                        query = "", 
                        geom_column = NULL,
                        WHERE = "", ..., quiet = TRUE) {
   verbose = !quiet
   
   if (missing(table)) {
     table <- .choose_table(con, verbose)
   }
   available_colnames <- manifoldr:::columnames(con, table)
  crswkt <- manifoldr:::manifoldCRS(con, table)
  if (verbose) print(crswkt)
    crs <- manifoldr:::wktCRS2proj4(crswkt)
    if (verbose) print(crs)
   if (is.null(geom_column)) geom_column <- "geom"
    ## here we might use the OGC names, but it complicates things a bit trying to balance everything
    ## geometry_columns is pretty useless getting the CRS and the actual table names as they appear in Manifold
    ## so forget it
    available_colnames <- 
      paste0("[", available_colnames[-grep(" \\(I\\)", available_colnames)], "]")
    atts <- sprintf("%s, CGeomWKB(Geom(ID)) AS [%s]", paste(available_colnames, collapse = ","), geom_column)
    
    
    query <- sprintf("SELECT %s FROM [%s] %s", atts, table,  WHERE)
    #if (dropNULL) {
   query <- sprintf("SELECT * FROM (%s) WHERE [geom] IS NOT NULL", query)
  #  }
    if (verbose) print(query)
  x <-  RODBC::sqlQuery(con, query)

  x <- tibble::as_tibble(x)
  x[["geom"]] <- sf::st_as_sfc(structure(x[["geom"]], class = "WKB"), EWKB = FALSE)
  st_as_sf(x)
}