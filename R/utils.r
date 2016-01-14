checkAvailability <- function() {
  fl <- sample(instmapfiles(), 1L)
  res <- try(odbcConnectManifold(fl))
  if (inherits(res, "try-error")) {
    message("Manifold does not seem to be installed, so functionality is limited.")
    return(FALSE)
  } else {
    close(res)
    return(TRUE)
  }
}
instmapfiles <- function() {
  list.files(pattern = ".map$", system.file("extdata", package = "manifoldr"), full.names = TRUE)
}
