context("File installation and availability of Manifold")

mapfile <- system.file("extdata", "AreaDrawing.map", package = "manifoldr")
fakefile <- "/home/some/time/BIFF.TREK"

test_that("real file exists", {
  expect_that(file.exists(mapfile), is_true())
})

test_that("fake file does not exist", {
  expect_that(file.exists(fakefile), is_false())
})

test_that("connection is successful", {
  if (manifoldr:::checkAvailability()) {
  expect_that(odbcConnectManifold(mapfile), is_a("RODBC"))
  } else {
    expectt_that(failconnect <- odbcConnectManifold(mapfile), testthat::gives_warning("ODBC connection failed"))
    expect_lt(failconnect, 0)
  }
})

test_that("failed connection is graceful", {
  expect_lt(odbcConnectManifold(fakefile), 0)
})

test_that("we can get out a table summary", {
  expect_that(manifoldr:::mfd(mapfile), is_a("list"))
})

test_that("we can read a drawing table", {
  expect_that(manifoldr:::readmfd(mapfile, "Drawing Table"), is_a("data.frame"))
})