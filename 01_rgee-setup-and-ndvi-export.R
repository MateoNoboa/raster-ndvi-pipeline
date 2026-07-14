# rgee_ndvi_pipeline.R
# -------------------------------------------------------------
# Description:
# Configure rgee (Google Earth Engine for R), authenticate user,
# and export monthly NDVI composites (Sentinel-2) for a defined ROI.
#
# Workflow:
# - Setup Python (Conda) environment
# - Authenticate Earth Engine
# - Generate monthly NDVI composites
# - Export results to Google Drive
#
# Notes:
# - Replace <username> and <your_email>
# - Run Conda commands in anaconda promt (Outside R)
#- after installing the Rtools, make sure to run this command line below inside RStudio:
# -writeLines('PATH="${RTOOLS44_HOME}\\usr\\bin;${PATH}"', con = "~/.Renviron")
# -------------------------------------------------------------

# ---- clean environment ----

rm(list = ls())
gc()

# ---- system setup (run anaconda, not R) ----
# conda create -n rgee_py python=3.9
# conda activate rgee_py
# conda install -c conda-forge earthengine-api
# pip install numpy

# ---- packages ----

install.packages("pacman")
library(pacman)

p_load(
  raster, rgdal, rgeos, gdalUtils,
  sp, sf, leaflet, mapview, caret,
  rgee, geojsonio, remotes, reticulate,
  devtools, googledrive
)

install_github("r-spatial/rgee")
library(rgee)

# ---- python environment ----

python_exe_path <- "C:/Users/<username>/miniconda3/envs/rgee_py"

Sys.setenv(RETICULATE_PYTHON = python_exe_path)
Sys.setenv(EARTHENGINE_PYTHON = python_exe_path)

reticulate::use_python(python_exe_path, required = TRUE) #(Restart Session if necessary)

# ---- authentication ----

rgee::ee_clean_user_credentials()
rgee::ee_Authenticate()

rgee::ee_Initialize(
  user = "<your_email>",
  drive = TRUE,
  project = "<your_proyect>"
)

ee_check_credentials()
ee_check()

# ---- initialize ee ----

ee_Initialize(drive = TRUE)

# ---- parameters ----

start_date <- "2023-03-24"
end_date   <- "2024-07-24"

# ---- region of interest ----

roi <- ee$Geometry$Polygon(
  coords = list(list(
    c(-78.76182660459017, -0.627800446223119),
    c(-78.76182660459017, -0.6996608422948992),
    c(-78.67199507617822, -0.6996608422948992),
    c(-78.67199507617822, -0.627800446223119),
    c(-78.76182660459017, -0.627800446223119)
  )),
  proj = "EPSG:4326",
  geodesic = FALSE
)

# ---- monthly sequence ----

date_sequence <- seq.Date(as.Date(start_date), as.Date(end_date), by = "month")
month_list <- format(date_sequence, "%Y-%m")

# ---- ndvi processing ----

for (month in month_list) {
  
  # Define monthly date range
  start_month <- paste0(month, "-01")
  end_month <- as.character(
    seq(as.Date(start_month), length = 2, by = "month")[2] - 1
  )
  
  cat("📦 Processing:", month, "\n")
  
  # Filter Sentinel-2 imagery
  collection_month <- ee$ImageCollection("COPERNICUS/S2_SR_HARMONIZED")$
    filterBounds(roi)$
    filterDate(start_month, end_month)$
    filter(ee$Filter$lt("CLOUDY_PIXEL_PERCENTAGE", 60))
  
  collection_size <- collection_month$size()$getInfo()
  
  # Skip if no images
  if (collection_size == 0) {
    cat("⚠️ No valid images for:", month, "\n")
    next
  }
  
  # Compute NDVI and monthly composite
  ndvi_month <- collection_month$
    map(function(img) {
      ndvi <- img$normalizedDifference(c("B8", "B4"))$rename("NDVI")
      ndvi$copyProperties(img, img$propertyNames())
    })$
    median()$
    clip(roi)
  
  # Export to Google Drive
  task <- ee_image_to_drive(
    image = ndvi_month$select("NDVI"),
    description = paste0("NDVI_", month),
    folder = "NDVI_Gabirel",
    fileNamePrefix = paste0("NDVI_", month),
    region = roi,
    scale = 20,
    fileFormat = "GeoTIFF",
    maxPixels = 1e13
  )
  
  task$start()
  cat("✅ Export started for:", month, "\n")
}

# ---- monitoring ----

rgee::ee_monitoring()

# https://code.earthengine.google.com/tasks