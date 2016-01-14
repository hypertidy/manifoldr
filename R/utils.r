#' @importFrom RODBC odbcClose
checkAvailability <- function(fakefail = FALSE) {
  fl <- sample(instmapfiles(), 1L)
  if (fakefail) fl <- "nosuchfile.RARAmoopdobbBingBamBIFF"
  res <- suppressWarnings(odbcConnectManifold(fl))
  if (res < 0) {
    message("Manifold does not seem to be installed, so functionality is limited.")
    return(FALSE)
  } else {
    RODBC::odbcClose(res)
    return(TRUE)
  }
}
instmapfiles <- function() {
  list.files(pattern = ".map$", system.file("extdata", package = "manifoldr"), full.names = TRUE)
}
