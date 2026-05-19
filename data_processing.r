library(dplyr)
library(readr)
library(lubridate)

# Load the raw datasets
print("Loading datasets...")
stations <- read_csv("stations.csv")
station_month <- read_csv("station_month.csv")

# Merging the monthly recordings with the station metadata using 'Station' as the primary key
merged_data <- inner_join(station_month, stations, by = "Station")

# Data Cleaning
# Remove rows with missing or invalid noise readings to ensure dashboard accuracy
print("Cleaning data...")
cleaned_data <- merged_data %>%
  filter(!is.na(Day) & !is.na(Night) & !is.na(DayLimit) & !is.na(NightLimit))

# 4. Feature Engineering
print("Engineering features...")
processed_data <- cleaned_data %>%
  # Create a proper Date column using Year and Month 
  mutate(
    Date = make_date(year = Year, month = Month, day = 1),
    
    # Categorize stations based on CPCB standard limits
    Day_Status = ifelse(Day > DayLimit, "Exceeded", "Within Limit"),
    Night_Status = ifelse(Night > NightLimit, "Exceeded", "Within Limit"),

    Day_Exceedance_Value = ifelse(Day > DayLimit, Day - DayLimit, 0),
    Night_Exceedance_Value = ifelse(Night > NightLimit, Night - NightLimit, 0)
  )

print("Exporting processed dataset for Power BI...")
write_csv(processed_data, "Noise_Data_PowerBI.csv")

print("Processing complete. File 'Noise_Data_PowerBI.csv' is ready.")