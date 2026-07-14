# Wildlife Spatial Tracking & Sentinel-2 NDVI Pipeline

An automated R-based workflow for processing wildlife GPS telemetry data, extracting **Sentinel-2 NDVI (Normalized Difference Vegetation Index)** values through **Google Earth Engine**, and generating a consolidated database for ecological analyses.

The pipeline was developed to process telemetry data from three monitored individuals:

- 🦊 Mashca
- 🦊 Diego
- 🦊 Sucre

---

# Features

- Process wildlife GPS tracking datasets.
- Download monthly Sentinel-2 NDVI composites from Google Earth Engine.
- Extract NDVI values at GPS locations.
- Match satellite acquisition dates with telemetry records.
- Generate a unified database ready for statistical analyses.

---

# System Requirements

- R (≥ 4.2 recommended)
- Python 3.9
- Anaconda / Miniconda
- Google Earth Engine account
- Google Drive (for exported imagery)

---

# Python & Google Earth Engine Setup

Before running the first script, create the required Conda environment.

```bash
conda create -n rgee_py python=3.9 -y
conda activate rgee_py
conda install -c conda-forge earthengine-api -y
pip install numpy
```

Inside R, authenticate Google Earth Engine using **rgee**:

```r
library(rgee)

ee_Authenticate()
ee_Initialize()
```

---

# Repository Structure

```
Rgee/
│
├── 01_rgee-setup-and-ndvi-export.R
├── 02_spatial-ndvi-extraction.R
├── 03_database-consolidation-and-matching.R
│
├── NDVI_Mashca/
├── NDVI_Diego/
├── NDVI_Sucre/
│
├── mashca_points.csv
├── diego_points.csv
├── sucre_points.csv
│
├── mashca_ndvi.csv
├── Diego_ndvi.csv
├── Sucre_ndvi.csv
│
└── Zorros_NDVI.csv
```

---

# Workflow

The pipeline consists of three sequential scripts.

## 1. Google Earth Engine Setup & NDVI Export

**Script**

```text
01_rgee-setup-and-ndvi-export.R
```

### Purpose

- Configure the Python environment with **reticulate**.
- Authenticate **Google Earth Engine**.
- Generate monthly Sentinel-2 Surface Reflectance NDVI composites.
- Apply cloud filtering.
- Export GeoTIFF files to Google Drive.

---

## 2. Spatial NDVI Extraction

**Script**

```text
02_spatial-ndvi-extraction.R
```

### Purpose

- Load wildlife GPS coordinates.
- Import Sentinel-2 NDVI rasters.
- Register spatial objects using the **terra** package.
- Extract NDVI values for every GPS location.

---

## 3. Database Consolidation

**Script**

```text
03_database-consolidation-and-matching.R
```

### Purpose

- Convert extracted data into tidy format.
- Match telemetry dates with Sentinel-2 acquisition months.
- Merge all individuals into a single dataset.
- Export the final database:

```text
Zorros_NDVI.csv
```

---

# Directory Layout

Before running the extraction scripts, your local directory should resemble the following structure:

```
📁 Rgee/
│
├── 📁 NDVI_Mashca/          # Contains downloaded Sentinel-2 NDVI .tif files for Mashca
├── 📁 NDVI_Diego/           # Contains downloaded Sentinel-2 NDVI .tif files for Diego
├── 📁 NDVI_Sucre/           # Contains downloaded Sentinel-2 NDVI .tif files for Sucre
│
├── 📄 mashca_points.csv     # Raw tracking coordinates
├── 📄 diego_points.csv      # Raw tracking coordinates
├── 📄 sucre_points.csv      # Raw tracking coordinates
│
├── 📄 mashca_ndvi.csv       # Output from Script 2
├── 📄 Diego_ndvi.csv        # Output from Script 2
└── 📄 Sucre_ndvi.csv        # Output from Script 2
```

> **Note**
>
> Update the absolute file paths inside each script to match your local directory (e.g., `C:/Users/<username>/...`).

---

# Output

The final product is a consolidated CSV containing:

- Individual ID
- GPS coordinates
- Tracking date
- Matched Sentinel-2 acquisition month
- Extracted NDVI value

This dataset is suitable for ecological, habitat selection, and movement analyses.

---

# Main Packages

- **rgee**
- **reticulate**
- **terra**
- **tidyverse**
- **lubridate**

---

# Data Source

- **Sentinel-2 Surface Reflectance**
- **Copernicus Programme**
- **Google Earth Engine**

---

# Acknowledgments

This workflow makes use of:

- Google Earth Engine (GEE)
- Sentinel-2 imagery provided by the Copernicus Programme

---

# AI Assistance

Portions of the code were developed with assistance from **ChatGPT (OpenAI)** as an AI coding copilot. The AI was used to help structure, optimize, and debug iterative workflows and data extraction routines while all scientific decisions, methodological design, validation, and interpretation remained the responsibility of the authors.

---

# License
 MIT
