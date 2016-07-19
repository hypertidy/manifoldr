## ----eval=FALSE----------------------------------------------------------
#  f <- file.path(dp, "Data\\World\\Low Resolution\\Continents and Oceans lowres.map")
#  library(manifoldr)
#  library(rbenchmark)
#  benchmark(readmfd =  manifoldr:::readmfd(f, "Drawing"),
#            spatial = manifoldr:::readmfd(f, "Drawing"), replications = 4)
#  
#  a <- profr(manifoldr:::readmfd(f, "Drawing"))

## ----eval=FALSE----------------------------------------------------------
#  f <- file.path(dp, "Data\\World\\Medium Resolution\\World Provinces.map")
#  system.time(x <- manifoldr:::readmfd(f, "Provinces"))
#    #  user  system elapsed
#    # 23.02    0.66   24.24
#    #
#  system.time(x <- manifoldr:::readmfd(f, "Provinces", spatial = TRUE))
#   Error in if (byteOrder == as.raw(1L)) { : argument is of length zero
#  

## ----eval=FALSE----------------------------------------------------------
#  ## Built:                R 3.2.3; ; 2016-01-17 14:03:26 UTC; windows
#  f <- "..Data\\World\\High Resolution\\Countries hires.map"
#  system.time(x <- manifoldr:::readmfd(f, "Countries"))
#  #  user  system elapsed
#  # 100.39    1.70  103.21
#  format(object.size(x), unit = "Mb")
#  #[1] "75.5 Mb"
#  `

