# ---- processing function -----
# Convert NDVI wide format to filtered long format

process_ndvi <- function(path, date_pattern = "\\d{4}[.-]\\d{2}") {
  
  data <- read.csv(path)
  
  # ---- reshape to long format ----
  data_long <- data %>%
    tidyr::pivot_longer(
      cols = dplyr::starts_with("NDVI_"),
      names_to = "ndvi_date",
      values_to = "ndvi_value"
    ) %>%
    dplyr::mutate(
      ndvi_date = stringr::str_extract(ndvi_date, date_pattern)
    ) %>%
    dplyr::select(
      individual.local.identifier,
      timestamp,
      event.id,
      location.long,
      location.lat,
      ndvi_date,
      ndvi_value
    )
  
  # ---- filter by matching month ----
  data_filtered <- data_long %>%
    dplyr::mutate(
      timestamp_date = as.Date(timestamp),
      year_month_timestamp = format(timestamp_date, "%Y.%m")
    ) %>%
    dplyr::filter(
      stringr::str_replace_all(ndvi_date, "-", ".") == year_month_timestamp
    ) %>%
    dplyr::select(
      individual.local.identifier,
      timestamp,
      event.id,
      location.long,
      location.lat,
      ndvi_date,
      ndvi_value
    )
  
  return(data_filtered)
}

# ---- process individuals ----

diego_filtered <- process_ndvi(
  "C:/Users/<username>/OneDrive/Escritorio/Rgee/Diego_ndvi.csv"
)

sucre_filtered <- process_ndvi(
  "C:/Users/<username>/OneDrive/Escritorio/Rgee/Sucre_ndvi.csv"
)

mashca_filtered <- process_ndvi(
  "C:/Users/<username>/OneDrive/Escritorio/Rgee/mashca_ndvi.csv"
)

# ---- merge datasets ----

foxes_ndvi <- dplyr::bind_rows(
  diego_filtered,
  sucre_filtered,
  mashca_filtered
)

# ---- inspect ----

str(foxes_ndvi)

# ---- export ----

write.csv(
  foxes_ndvi,
  "foxes_NDVI.csv",
  row.names = FALSE
)