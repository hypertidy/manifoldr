## ----eval=FALSE----------------------------------------------------------
#  library(manifoldr)
#  mapfile <- system.file("extdata", "AreaDrawing.map", package = "manifoldr")
#  
#  dwg <- Drawing(mapfile, quiet = FALSE)
#  

## ----eval=FALSE----------------------------------------------------------
#  library(manifoldr)
#  library(RODBC)
#  mapfile <- system.file("extdata", "AreaDrawing.map", package = "manifoldr")
#  
#  geom2D <- DrawingA(mapfile, "Drawing")
#  geom2D
#  
#  geom1D <- DrawingL(mapfile, "Drawing")
#  geom1D
#  
#  geom0D <- DrawingP(mapfile, "Drawing")
#  geom0D
#  

## ----eval=FALSE----------------------------------------------------------
#  library(raster)
#  mapfile2 <- system.file("extdata", "Montara_20m.map", package= "manifoldr")
#  
#  gg <- Surface(mapfile2, "Montara")
#  
#  gg

## ----eval=FALSE----------------------------------------------------------
#  mapfile3 <- system.file("extdata", "V20160202016022.L3m_R3QL_NPP_CHL_chlor_a_9km.map", package= "manifoldr")
#  im <- Image(mapfile3, "V20160202016022.L3m_R3QL_NPP_CHL_chlor_a_9km")
#  plotRGB(im)
#  im

## ---- eval = FALSE, include =FALSE---------------------------------------
#  mapfile <- system.file("extdata", "AreaDrawing.map", package = "manifoldr")
#  
#  x <- manifoldr:::readmfd(mapfile, "Drawing",  query = "SELECT [Name], [Branches (I)], [X (I)] FROM [Drawing] WHERE isArea([ID]) ORDER BY [NAME]", spatial = FALSE)
#  
#  

## ---- eval = FALSE, include =FALSE---------------------------------------
#  library(manifoldr)
#  library(RODBC)
#  mapfile <- system.file("extdata", "AreaDrawing.map", package = "manifoldr")
#  con <- odbcConnectManifold(mapfile)
#  tab <- sqlQuery(con, "SELECT [ID], [Name], BranchCount([ID]) AS [nBranch] FROM [Drawing] ORDER BY [nBranch]")
#  close(con)
#  
#  print(tab)

## ----message=FALSE,warning=FALSE, eval=FALSE-----------------------------
#  ## extensions we need
#  library(wkb)    ## for parsing WKB blobs as Spatial R objects
#  library(sp)     ## Spatial R objects
#  library(RODBC)  ## ODBC in R
#  library(raster) ## just for nice print methods for sp objects
#  library(manifoldr)
#  ## open a connection to a map file
#  ## original  file has Local Scale 0.0001, so I use a modified copy "Provinces_"
#  con <- odbcConnectManifold("E:\\ManifoldDVD\\Data\\World\\Medium Resolution\\World Provinces.map")
#  ## list the available tables if needed
#  ##sqlTables(con)
#  
#  ## read in just the ID and the Geom (I) as WKB
#  ## (Manifold's Geom includes the CRS so we cast to OGC using CGeomWKB)
#  ## remember this is just a data.frame
#  ProvincesGeom <- sqlQuery(con, "SELECT [ID], [Country], [Province], CGeomWKB(Geom(ID)) AS [geom] FROM [Provinces_] WHERE [Longitude (I)] > 100 AND [Latitude (I)] < 0")
#  ## get the CRS (somehow)
#  ## . . .
#  close(con)
#  
#  ## construct an R spatial object from the raw geometry
#  ## this is just SpatialPolygons/Lines/Points (what happens to mixed geom layers?)
#  Rsp <- readWKB(ProvincesGeom$geom)
#  
#  ## reconstruct our original layer
#  Countries <- SpatialPolygonsDataFrame(Rsp, subset(ProvincesGeom, select = c("ID", "Country", "Province")))
#  Countries
#  
#  plot(Countries)
#  devtools::session_info()

