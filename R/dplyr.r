#' Manifold source
#' 
#' @param dbname 
#'
#' @param host 
#' @param port 
#' @param user 
#' @param password 
#' @param ... 
#'
#' @export
#' @importFrom dplyr src_sql
#' @importFrom DBI dbConnect
#' @examples 
#' \dontrun{
#' mapfile <- system.file("extdata", "AreaDrawing.map", package = "manifoldr")
#' mfd <- src_manifold(mapfile)
#' tbl(mfd, "GEOMETRY_COLUMNS")
#' }
src_manifold <- function(dbname = NULL, host = NULL, port = NULL, user = NULL,
                         password = NULL, ...) {
  
  con <-    dbConnect(ManifoldODBC(), dbname, ...)
  
  src_sql("manifold", con)
}

#' @rdname src_manifold
#' @export
src_desc.src_manifold <- function(con) {
  info <- dbGetInfo(con$con)
  host <- if (info$host == "") "localhost" else info$host
  
  paste0("manifold ", info$serverVersion, " [", info$user, "@",
         host, ":", info$port, "/", info$dbname, "]")
}


#' Tibble method for Manifold
#'
#' @param src 
#' @param from 
#' @param ... 
#'
#' @return
#' @export
#'
#' @examples
#' @importFrom dplyr tbl tbl_sql
tbl.src_manifold <- function(src, from, ...) {
  tbl_sql("manifold", src = src, from = from, ...)
}


# 
# ## crucial part, since our ODBC source uses TOP instead of LIMIT
# #' @export
# sql_select.ManifoldODBCConnection <-
#   function (con, select, from, where = NULL, group_by = NULL, having = NULL,
#             order_by = NULL, limit = NULL, offset = NULL, ...)
#   {
#     out <- vector("list", 8)
#     names(out) <- c("select", "from", "where", "group_by", "having",
#                     "order_by", "limit", "offset")
#     assertthat::assert_that(is.character(select), length(select) > 0L)
#     
#     
#     if (!is.null(limit)) {
#       assertthat::assert_that(is.integer(limit), length(limit) == 1L)
#       ## TOP clause is part of SELECT
#       out$select <- build_sql("SELECT ", " TOP ", limit, " ",  escape(select, collapse = ", ",
#                                                                       con = con))
#     } else {
#       
#       out$select <- build_sql("SELECT ", escape(select, collapse = ", ",
#                                                 con = con))
#     }
#     
#     assertthat::assert_that(is.character(from), length(from) == 1L)
#     out$from <- build_sql("FROM ", from, con = con)
#     if (length(where) > 0L) {
#       assertthat::assert_that(is.character(where))
#       out$where <- build_sql("WHERE ", escape(where, collapse = " AND ",
#                                               con = con))
#     }
#     if (!is.null(group_by)) {
#       assertthat::assert_that(is.character(group_by), length(group_by) >
#                                 0L)
#       out$group_by <- build_sql("GROUP BY ", escape(group_by,
#                                                     collapse = ", ", con = con))
#     }
#     if (!is.null(having)) {
#       assertthat::assert_that(is.character(having), length(having) == 1L)
#       out$having <- build_sql("HAVING ", escape(having, collapse = ", ",
#                                                 con = con))
#     }
#     if (!is.null(order_by)) {
#       assertthat::assert_that(is.character(order_by), length(order_by) >
#                                 0L)
#       out$order_by <- build_sql("ORDER BY ", escape(order_by,
#                                                     collapse = ", ", con = con))
#     }
#     
#     if (!is.null(offset)) {
#       assertthat::assert_that(is.integer(offset), length(offset) == 1L)
#       out$offset <- build_sql("OFFSET ", offset, con = con)
#     }
#     escape(unname(dplyr:::compact(out)), collapse = "\n", parens = FALSE,
#            con = con)
#   }
# 
# 
# 
# sql_surroundquote <-
#   function (x, surround0, surround1 = surround0)
#   {
#     # y <- gsub(quote, paste0(quote, quote), x, fixed = TRUE)
#     y <- paste0(surround0, x, surround1)
#     y[is.na(x)] <- "NULL"
#     names(y) <- names(x)
#     y
#   }
# sql_escape_comma <- function(x) {
#   gsub(",", " + Chr(44) + ", x)
# }
# sql_escape_string.ManifoldODBCConnection <- function(con, x) {
#   ##x <- sql_escape_comma(x)
#   sql_surroundquote(x, "\"")
# }
# 
# 
# sql_escape_ident.ManifoldODBCConnection<- function(con, x) {
#   sql_surroundquote(x, "[", "]")
# }