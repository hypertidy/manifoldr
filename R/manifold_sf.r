#' Read a Drawing from a Manifold project. 
#'
#' @param mapfile Manifold project file
#' @param dwgname Drawing name to read
#' @param ... passed on to \code{\link{mfd_read_db}}
#'
#' @return Drawing returns a `sf` object
#' @export
#' 
#' @examples
#' mapfile <- system.file("extdata", "AreaDrawing.map", package = "manifoldr")
#' dwg  <- Drawing(mapfile, "Drawing")
#' ## only lines
#' #dwg_sub <- Drawing(mapfile, WHERE = "WHERE [Type (I)] = 2")
#' #dwg_sub
Drawing <- function(mapfile, dwgname, ...) {
  con <- odbcConnectManifold(mapfile)
  on.exit(close(con), add = TRUE)
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

#' Read simple features from the Manifold driver
#' 
#' Read a drawing from a Manifold connection. 
#' 
#' By default the entire drawing is read with all non-intrinsic columns. The intrinsic column "Geom (I)" is
#' cast to WKB within Manifold and then interpreted using \code{\link[sf]{st_as_sfc}}.
#' @param con connection object
#' @param table table to read, can be a Drawing name or its child table
#' @param query query to run, optional
#' @param geom_column this is the name of the column as returned (not the name of the column natively)
#' @param WHERE optional WHERE clause, as in "WHERE ID = 1 AND size < 10"
#' @param ... other arguments passed along (none currently)
#' @param quiet keep quiet by default
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
  available_colnames <- columnames(con, table)
  crswkt <- manifoldCRS(con, table)
  if (verbose) print(crswkt)
    crs <- wktCRS2proj4(crswkt)
    if (verbose) print(crs)
   if (is.null(geom_column)) geom_column <- "geometry"
    ## here we might use the OGC names, but it complicates things a bit trying to balance everything
    ## geometry_columns is pretty useless getting the CRS and the actual table names as they appear in Manifold
    ## so forget it
    available_colnames <- 
      paste0("[", available_colnames[-grep(" \\(I\\)", available_colnames)], "]")
    atts <- sprintf("%s, CGeomWKB(Geom(ID)) AS [%s]", paste(available_colnames, collapse = ","), geom_column)
    
    
    query <- sprintf("SELECT %s FROM [%s] %s", atts, table,  WHERE)
    #if (dropNULL) {
     ## drop any empty ones in Manifold
   query <- sprintf("SELECT * FROM (%s) WHERE [%s] IS NOT NULL", query, geom_column)
  #  }
     ## or return the empty as valid empty geometries
   ## i.e st_multipolygon(list(), "XY")  
    if (verbose) print(query)
  x <-  RODBC::sqlQuery(con, query)

  #x <- tibble::as_tibble(x)
  x[[geom_column]] <- sf:::st_as_sfc.WKB(structure(x[[geom_column]], class = "WKB"), EWKB = FALSE)
  sf::st_as_sf(x)
}
