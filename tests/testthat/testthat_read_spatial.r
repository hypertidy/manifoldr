context("Read data in as spatial")
?testthat::skip_on_travis()
mapfile <- system.file("extdata", "AreaDrawing.map", package = "manifoldr")
montarafile <- system.file("extdata", "MONTARA_20m.map", package = "manifoldr")
test_that("we can read a drawing table", {
  expect_that(manifoldr::DrawingA(mapfile, "Drawing Table"), is_a("SpatialPolygonsDataFrame"))
  expect_that(manifoldr::DrawingA(mapfile, "Drawing Table"), is_a("SpatialPolygonsDataFrame"))
  expect_that(manifoldr::DrawingL(mapfile, "Drawing Table"), is_a("SpatialLinesDataFrame"))
  expect_that(manifoldr::DrawingP(mapfile, "Drawing Table"), is_a("SpatialPointsDataFrame"))
})

test_that("we can read a raster", {
  expect_that(manifoldr::Surface(montarafile, "Montara"), is_a("RasterLayer"))
})

test_that("we can issue simple queries", {
  expect_that(manifoldr:::readmfd(mapfile, "Drawing"), is_a("data.frame"))
 
  expect_that(manifoldr:::readmfd(mapfile, "Drawing", spatial = TRUE), is_a("SpatialPolygonsDataFrame")) 
  expect_that(manifoldr:::readmfd(mapfile, "Drawing", spatial = TRUE, topol = "point"), is_a("SpatialPointsDataFrame")) 
  
  expect_that(manifoldr:::readmfd(mapfile, "Drawing", spatial = TRUE, WHERE = "[Name] = \"E\""), is_a("SpatialPolygonsDataFrame")) 
  
})