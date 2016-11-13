context("Read data in as spatial")
readA <- function() {
  testthat::skip_on_travis()
  manifoldr::DrawingA(mapfile, "Drawing Table")
}
readL <- function() {
  testthat::skip_on_travis()
  manifoldr::DrawingL(mapfile, "Drawing Table")
}
readP <- function() {
  testthat::skip_on_travis()
  manifoldr::DrawingP(mapfile, "Drawing Table")
}
mapfile <- system.file("extdata", "AreaDrawing.map", package = "manifoldr")
montarafile <- system.file("extdata", "MONTARA_20m.map", package = "manifoldr")
test_that("we can read a drawing table", {
  expect_that(readA(), is_a("SpatialPolygonsDataFrame"))
  expect_that(readA(), is_a("SpatialPolygonsDataFrame"))
  expect_that(readL(), is_a("SpatialLinesDataFrame"))
  expect_that(readP(), is_a("SpatialPointsDataFrame"))
})

test_that("we can read a raster", {
 testthat::skip_on_travis()
  testthat::skip_on_cran()
  expect_that(manifoldr::Surface(montarafile, "Montara"), is_a("RasterLayer"))
})

test_that("we can issue simple queries", {
  testthat::skip_on_travis()
  expect_that(manifoldr:::readmfd(mapfile, "Drawing"), is_a("data.frame"))
 
  expect_that(manifoldr:::readmfd(mapfile, "Drawing", spatial = TRUE), is_a("SpatialPolygonsDataFrame")) 
  expect_that(manifoldr:::readmfd(mapfile, "Drawing", spatial = TRUE, topol = "point"), is_a("SpatialPointsDataFrame")) 
  
  expect_that(manifoldr:::readmfd(mapfile, "Drawing", spatial = TRUE, WHERE = "[Name] = \"E\""), is_a("SpatialPolygonsDataFrame")) 
  
})