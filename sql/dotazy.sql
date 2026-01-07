CREATE TABLE FACT_ESTATE_METRICS (
  metric_key int PRIMARY KEY AUTO_INCREMENT,
  property_key int,
  building_key int,
  location_key int,
  date_key int,
  seller_key int,
  estimate_price float,
  annual_tax_amount float,
  page_view_count int,
  rent_estimate float,
  included_furniture boolean,
  monthly_hoa_fee float,
  tax_assessed_value float,
  price_per_square_foot float,
  deposit_fee_min float,
  climate_flood_risk_value float,
  climate_fire_risk_value float,
  favorite_count int
);

CREATE TABLE DIM_PROPERTY_DETAILS (
  property_key int PRIMARY KEY AUTO_INCREMENT,
  zillow_zpid bigint UNIQUE,
  home_type varchar(255),
  home_status varchar(255),
  year_built date,
  total_stories float,
  room_count int,
  structure_type varchar(255),
  roof_type varchar(255),
  heating_source varchar(255),
  is_new boolean,
  description text,
  area float,
  bedrooms float,
  bathrooms float,
  mls_id varchar(255),
  parcel_id varchar(255),
  lot_size_dimensions varchar(255),
  architectural_style varchar(255),
  has_attached_garage boolean
);

CREATE TABLE DIM_BUILDING_INFO (
  building_key int PRIMARY KEY AUTO_INCREMENT,
  building_zpid bigint,
  building_name varchar(255),
  building_type varchar(255),
  unit_count int,
  total_stories_in_building float,
  has_swimming_pool boolean,
  has_elevator boolean,
  is_smoke_free boolean,
  transit_score int,
  has_gym boolean,
  has_pet_park boolean,
  has_24hr_maintenance boolean,
  is_student_housing boolean,
  is_senior_housing boolean,
  pet_policy_description text,
  security_features varchar(255)
);

CREATE TABLE DIM_LOCATION (
  location_key int PRIMARY KEY AUTO_INCREMENT,
  city varchar(255),
  state_name varchar(255),
  zip_code varchar(255),
  county varchar(255),
  neighborhood varchar(255),
  home_number varchar(255),
  street_name varchar(255),
  latitude float,
  longitude float,
  elementary_school varchar(255),
  middle_school varchar(255),
  high_school varchar(255),
  walk_score int,
  walk_score_description varchar(255),
  climate_fema_zone varchar(255),
  climate_risk_label varchar(255)
);

CREATE TABLE DIM_DATE (
  date_key int PRIMARY KEY,
  full_date date,
  year int,
  quarter int,
  month int,
  month_name varchar(255),
  day_of_week int,
  day_name varchar(255),
  week_of_year int,
  is_weekend boolean,
  is_holiday boolean,
  fiscal_quarter int
);

CREATE TABLE DIM_SELLER (
  seller_key int PRIMARY KEY,
  name varchar(255),
  surname varchar(255),
  phone_number varchar(255),
  agency_name varchar(255),
  agent_license_number varchar(255),
  agent_email varchar(255),
  brokerage_name varchar(255),
  broker_phone_number varchar(255),
  is_premier_agent boolean
);

ALTER TABLE FACT_ESTATE_METRICS ADD FOREIGN KEY (property_key) REFERENCES DIM_PROPERTY_DETAILS (property_key);

ALTER TABLE FACT_ESTATE_METRICS ADD FOREIGN KEY (building_key) REFERENCES DIM_BUILDING_INFO (building_key);

ALTER TABLE FACT_ESTATE_METRICS ADD FOREIGN KEY (location_key) REFERENCES DIM_LOCATION (location_key);

ALTER TABLE FACT_ESTATE_METRICS ADD FOREIGN KEY (date_key) REFERENCES DIM_DATE (date_key);

ALTER TABLE FACT_ESTATE_METRICS ADD FOREIGN KEY (seller_key) REFERENCES DIM_SELLER (seller_key);














CREATE OR REPLACE TABLE STAGING_REAL_ESTATE_FULL AS
SELECT DISTINCT
    -- === ІДЕНТИФІКАТОРИ ТА ЗВ'ЯЗКИ ===
    p.ZILLOW_ZPID AS property_zpid,
    p.ID AS property_internal_id,
    p.BUILDING_KEY,
    b.BUILDING_ZPID AS building_zpid,
    
    -- === ДЛЯ ТАБЛИЦІ ФАКТІВ (FACT_ESTATE_METRICS) ===
    p.PRICE AS estimate_price,
    p.RESO_FACTS_TAX_ANNUAL_AMOUNT AS annual_tax_amount,
    p.ZILLOW_PAGE_VIEW_COUNT AS page_view_count,
    p.ZILLOW_RENT_ZESTIMATE AS rent_estimate,
    b.BUILDING_IS_FURNISHED AS included_furniture, -- Меблі частіше відносяться до опису будинку/типу оренди
    p.MONTHLY_HOA_FEE,
    p.RESO_FACTS_TAX_ASSESSED_VALUE AS tax_assessed_value,
    p.RESO_FACTS_PROPERTY_PRICE_PER_SQUARE_FOOT AS price_per_square_foot,
    b.BUILDING_DEPOSIT_FEE_MIN AS deposit_fee_min,
    p.CLIMATE_FLOOD_RISK_VALUE,
    p.CLIMATE_FIRE_RISK_VALUE,
    p.ZILLOW_FAVORITE_COUNT AS favorite_count,

    -- === ДЛЯ DIM_PROPERTY_DETAILS (Деталі квартири) ===
    p.HOME_TYPE,
    p.HOME_STATUS,
    p.YEAR_BUILT, -- або p.RESO_FACTS_STRUCTURE_YEAR_BUILT
    p.RESO_FACTS_STRUCTURE_STORIES_TOTAL AS total_stories_property,
    p.RESO_FACTS_AMENITY_ROOMS AS room_count_raw, -- Тут може бути JSON або Text
    p.RESO_FACTS_STRUCTURE_TYPE AS structure_type,
    p.RESO_FACTS_STRUCTURE_ROOF_TYPE AS roof_type,
    p.RESO_FACTS_UTILITY_HEATING AS heating_source,
    p.IS_NEW_HOME AS is_new,
    p.DESCRIPTION AS property_description,
    p.LIVING_AREA_VALUE AS area,
    p.BEDROOMS,
    p.BATHROOMS,
    p.MLSID AS mls_id,
    p.PARCEL_ID,
    p.RESO_FACTS_PROPERTY_LOT_SIZE_DIMENSIONS AS lot_size_dimensions,
    p.RESO_FACTS_STRUCTURE_ARCHITECTURAL_STYLE AS architectural_style,
    p.RESO_FACTS_STRUCTURE_HAS_ATTACHED_GARAGE AS has_attached_garage,

    -- === ДЛЯ DIM_BUILDING_INFO (Інфо про ЖК/Будинок) ===
    b.BUILDING_NAME,
    b.BUILDING_TYPE,
    b.BUILDING_UNIT_COUNT AS unit_count,
    b.BUILDING_WALK_SCORE AS building_walk_score_raw, -- Можливо знадобиться тут
    -- Примітка: total_stories_in_building часто береться з RESO фактів будинку, якщо в B немає колонки
    b.BUILDING_HAS_SWIMMING_POOL AS has_swimming_pool,
    b.BUILDING_HAS_ELEVATOR AS has_elevator,
    b.BUILDING_IS_SMOKE_FREE AS is_smoke_free,
    b.BUILDING_TRANSIT_SCORE AS transit_score,
    -- gym та pet_park часто є в amenities JSON, але якщо є окремі колонки:
    b.BUILDING_HAS_PET_PARK AS has_pet_park, 
    b.BUILDING_HAS_24HR_MAINTENANCE AS has_24hr_maintenance,
    b.BUILDING_IS_STUDENT_HOUSING AS is_student_housing,
    b.BUILDING_IS_SENIOR_HOUSING AS is_senior_housing,
    b.BUILDING_PET_POLICY_DESCRIPTION AS pet_policy_description,
    b.BUILDING_SECURITY_TYPES AS security_features,
    -- Якщо є окрема колонка для спортзалу в B, додайте її, інакше вона в amenities

    -- === ДЛЯ DIM_LOCATION (Локація) ===
    p.PROPERTY_CITY AS city,
    p.PROPERTY_STATE AS state_name,
    p.PROPERTY_ZIPCODE AS zip_code,
    p.COUNTY,
    p.PROPERTY_NEIGHBORHOOD AS neighborhood,
    p.NORMALIZED_ADDRESS_NUMBER AS home_number,
    p.NORMALIZED_STREET_NAME AS street_name,
    p.LATITUDE,
    p.LONGITUDE,
    p.RESO_FACTS_PROPERTY_ELEMENTARY_SCHOOL AS elementary_school,
    p.RESO_FACTS_PROPERTY_MIDDLE_SCHOOL AS middle_school,
    p.RESO_FACTS_PROPERTY_HIGH_SCHOOL AS high_school,
    b.BUILDING_WALK_SCORE AS walk_score,
    b.BUILDING_WALK_SCORE_DESCRIPTION AS walk_score_description,
    p.CLIMATE_FEMA_ZONE,
    p.CLIMATE_FLOOD_RISK_LABEL AS climate_risk_label, -- Або fire_risk_label

    -- === ДЛЯ DIM_DATE (Час) ===
    -- Беремо дату створення або публікації як основну дату події
    p.CREATED_TS, 
    p.DATE_POSTED_STRING,

    -- === ДЛЯ DIM_SELLER (Продавець) ===
    p.ATTRIBUTION_AGENT_NAME AS seller_name,
    -- surname треба буде витягувати з name пізніше
    p.ATTRIBUTION_AGENT_PHONE_NUMBER AS seller_phone,
    p.ATTRIBUTION_BROKER_NAME AS agency_name,
    p.ATTRIBUTION_AGENT_LICENSE_NUMBER AS agent_license,
    p.ATTRIBUTION_AGENT_EMAIL AS agent_email,
    p.BROKERAGE_NAME,
    p.ATTRIBUTION_BROKER_PHONE_NUMBER AS broker_phone,
    p.ZILLOW_IS_PREMIER_BUILDER AS is_premier_agent

FROM PROPERTIES p
LEFT JOIN BUILDINGS b 
    ON p.BUILDING_KEY = b.BUILDING_KEY;
