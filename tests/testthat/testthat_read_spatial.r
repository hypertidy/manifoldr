context("Read data in as spatial")

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