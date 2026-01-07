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
  zip_code varchar(50),
  county varchar(255),
  neighborhood varchar(255),
  home_number varchar(50),
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
  month_name varchar(20),
  day_of_week int,
  day_name varchar(20),
  week_of_year int,
  is_weekend boolean,
  is_holiday boolean,
  fiscal_quarter int
);

CREATE TABLE DIM_SELLER (
  seller_key int PRIMARY KEY,
  name varchar(255),
  surname varchar(255),
  phone_number varchar(50),
  agency_name varchar(255),
  agent_license_number varchar(100),
  agent_email varchar(255),
  brokerage_name varchar(255),
  broker_phone_number varchar(50),
  is_premier_agent boolean
);
  
  -- Foreign Keys (Snowflake не блокує вставку, але це корисно для документації)
  CONSTRAINT fk_property FOREIGN KEY (property_key) REFERENCES DIM_PROPERTY_DETAILS (property_key),
  CONSTRAINT fk_building FOREIGN KEY (building_key) REFERENCES DIM_BUILDING_INFO (building_key),
  CONSTRAINT fk_location FOREIGN KEY (location_key) REFERENCES DIM_LOCATION (location_key),
  CONSTRAINT fk_date FOREIGN KEY (date_key) REFERENCES DIM_DATE (date_key),
  CONSTRAINT fk_seller FOREIGN KEY (seller_key) REFERENCES DIM_SELLER (seller_key)
















-- Вказуємо створювати таблицю у ВАШІЙ базі даних
CREATE DATABASE IF NOT EXISTS LION_MY_LAST_PROJECT;

CREATE SCHEMA IF NOT EXISTS LION_MY_LAST_PROJECT.STAGING;


CREATE OR REPLACE TABLE LION_MY_LAST_PROJECT.STAGING.STAGING_REAL_ESTATE_FULL AS
SELECT DISTINCT
    -- ІДЕНТИФІКАТОРИ
    p.ZILLOW_ZPID AS property_zpid,
    p.ID AS property_internal_id,
    p.BUILDING_KEY,
    b.BUILDING_ZPID AS building_zpid,
    
    -- МЕТРИКИ
    p.PRICE AS estimate_price,
    p.RESO_FACTS_TAX_ANNUAL_AMOUNT AS annual_tax_amount,
    p.ZILLOW_PAGE_VIEW_COUNT AS page_view_count,
    p.ZILLOW_RENT_ZESTIMATE AS rent_estimate,
    b.BUILDING_IS_FURNISHED AS included_furniture,
    p.MONTHLY_HOA_FEE,
    p.RESO_FACTS_TAX_ASSESSED_VALUE AS tax_assessed_value,
    p.RESO_FACTS_PROPERTY_PRICE_PER_SQUARE_FOOT AS price_per_square_foot,
    b.BUILDING_DEPOSIT_FEE_MIN AS deposit_fee_min,
    p.climate_climate_flood_risk_value as climate_flood_risk_value,
    p.climate_CLIMATE_FIRE_RISK_VALUE as climate_fire_risk_value,
    p.ZILLOW_FAVORITE_COUNT AS favorite_count,

    -- ДЕТАЛІ КВАРТИРИ
    p.HOME_TYPE,
    p.HOME_STATUS,
    p.YEAR_BUILT,
    p.RESO_FACTS_STRUCTURE_STORIES_TOTAL AS total_stories_property,
    p.RESO_FACTS_AMENITY_ROOMS AS room_count_raw,
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

    -- БУДІВЛЯ
    b.BUILDING_NAME,
    b.BUILDING_TYPE,
    b.BUILDING_UNIT_COUNT AS unit_count,
    b.BUILDING_HAS_SWIMMING_POOL AS has_swimming_pool,
    b.BUILDING_HAS_ELEVATOR AS has_elevator,
    b.BUILDING_IS_SMOKE_FREE AS is_smoke_free,
    b.BUILDING_TRANSIT_SCORE AS transit_score,
    b.BUILDING_HAS_PET_PARK AS has_pet_park, 
    b.BUILDING_HAS_24HR_MAINTENANCE AS has_24hr_maintenance,
    b.BUILDING_IS_STUDENT_HOUSING AS is_student_housing,
    b.BUILDING_IS_SENIOR_HOUSING AS is_senior_housing,
    b.BUILDING_PET_POLICY_DESCRIPTION AS pet_policy_description,
    b.BUILDING_SECURITY_TYPES AS security_features,

    -- ЛОКАЦІЯ
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
    p.climate_CLIMATE_FEMA_ZONE as climate_fema_zone,
    p.climate_CLIMATE_FLOOD_RISK_LABEL AS climate_risk_label,

    -- ДАТА
    p.CREATED_TS, 
    p.DATE_POSTED_STRING,

    -- ПРОДАВЕЦЬ
    p.ATTRIBUTION_AGENT_NAME AS seller_name,
    p.ATTRIBUTION_AGENT_PHONE_NUMBER AS seller_phone,
    p.ATTRIBUTION_BROKER_NAME AS agency_name,
    p.ATTRIBUTION_AGENT_LICENSE_NUMBER AS agent_license,
    p.ATTRIBUTION_AGENT_EMAIL AS agent_email,
    p.BROKERAGE_NAME,
    p.ATTRIBUTION_BROKER_PHONE_NUMBER AS broker_phone,
    p.ZILLOW_IS_PREMIER_BUILDER AS is_premier_agent

-- Вказуємо повний шлях до джерел (Database.Schema.Table)
FROM LION_DB_PROJECT_F.PUBLIC.PROPERTIES p
LEFT JOIN LION_DB_PROJECT_F.PUBLIC.BUILDINGS b 
    ON p.BUILDING_KEY = b.BUILDING_KEY;










--adding to tables new values

--dim_date
    INSERT INTO DIM_DATE (date_key, full_date, year, quarter, month, month_name, day_of_week, day_name, week_of_year, is_weekend, is_holiday, fiscal_quarter)
SELECT 
    TO_NUMBER(TO_CHAR(TO_DATE(TO_TIMESTAMP(CREATED_TS / 1000000)), 'YYYYMMDD')) as date_key,
    TO_DATE(TO_TIMESTAMP(CREATED_TS / 1000000)) as full_date,
    YEAR(TO_DATE(TO_TIMESTAMP(CREATED_TS / 1000000))) as year,
    QUARTER(TO_DATE(TO_TIMESTAMP(CREATED_TS / 1000000))) as quarter,
    MONTH(TO_DATE(TO_TIMESTAMP(CREATED_TS / 1000000))) as month,
    MONTHNAME(TO_DATE(TO_TIMESTAMP(CREATED_TS / 1000000))) as month_name,
    DAYOFWEEKISO(TO_DATE(TO_TIMESTAMP(CREATED_TS / 1000000))) as day_of_week,
    DAYNAME(TO_DATE(TO_TIMESTAMP(CREATED_TS / 1000000))) as day_name,
    WEEKISO(TO_DATE(TO_TIMESTAMP(CREATED_TS / 1000000))) as week_of_year,
    IFF(DAYOFWEEKISO(TO_DATE(TO_TIMESTAMP(CREATED_TS / 1000000))) IN (6, 7), TRUE, FALSE) as is_weekend,
    FALSE as is_holiday,
    CASE 
        WHEN QUARTER(TO_DATE(TO_TIMESTAMP(CREATED_TS / 1000000))) = 1 THEN 1 
        ELSE QUARTER(TO_DATE(TO_TIMESTAMP(CREATED_TS / 1000000))) 
    END as fiscal_quarter
FROM LION_MY_LAST_PROJECT.STAGING.STAGING_REAL_ESTATE_FULL
WHERE CREATED_TS IS NOT NULL;



--dim_location 

INSERT INTO DIM_LOCATION (city, state_name, zip_code, county, neighborhood, home_number, street_name, latitude, longitude, elementary_school, middle_school, high_school, walk_score, walk_score_description, climate_fema_zone, climate_risk_label)
SELECT 
    city,
    state_name,
    zip_code,
    county,
    neighborhood,
    home_number,
    street_name,
    latitude,
    longitude,
    elementary_school,
    middle_school,
    high_school,
    walk_score,
    walk_score_description,
    climate_fema_zone,
    climate_risk_label
FROM LION_MY_LAST_PROJECT.STAGING.STAGING_REAL_ESTATE_FULL;




--dim_building_info
INSERT INTO DIM_BUILDING_INFO (building_zpid, building_name, building_type, unit_count, total_stories_in_building, has_swimming_pool, has_elevator, is_smoke_free, transit_score, has_gym, has_pet_park, has_24hr_maintenance, is_student_housing, is_senior_housing, pet_policy_description, security_features)
SELECT 
    building_zpid,
    building_name,
    building_type,
    unit_count,
    NULL as total_stories_in_building, 
    has_swimming_pool,
    has_elevator,
    is_smoke_free,
    transit_score,
    FALSE as has_gym,
    has_pet_park,
    has_24hr_maintenance,
    is_student_housing,
    is_senior_housing,
    pet_policy_description,
    security_features
FROM LION_MY_LAST_PROJECT.STAGING.STAGING_REAL_ESTATE_FULL


--dim_seller

INSERT INTO DIM_SELLER (name, surname, phone_number, agency_name, agent_license_number, agent_email, brokerage_name, broker_phone_number, is_premier_agent)
SELECT 
    seller_name,
    SPLIT_PART(seller_name, ' ', -1) as surname,
    seller_phone,
    agency_name,
    agent_license,
    agent_email,
    brokerage_name,
    broker_phone,
    is_premier_agent
FROM LION_MY_LAST_PROJECT.STAGING.STAGING_REAL_ESTATE_FULL;




--dim_property_details

INSERT INTO DIM_PROPERTY_DETAILS (zillow_zpid, home_type, home_status, year_built, total_stories, room_count, structure_type, roof_type, heating_source, is_new, description, area, bedrooms, bathrooms, mls_id, parcel_id, lot_size_dimensions, architectural_style, has_attached_garage)
SELECT 
    property_zpid,
    home_type,
    home_status,
    TO_DATE(TO_VARCHAR(year_built), 'YYYY') as year_built,
    total_stories_property,
    REGEXP_COUNT(room_count_raw, 'roomType') as room_count,
    structure_type,
    roof_type,
    heating_source,
    is_new,
    property_description,
    area,
    bedrooms,
    bathrooms,
    mls_id,
    parcel_id,
    lot_size_dimensions,
    architectural_style,
    has_attached_garage
FROM LION_MY_LAST_PROJECT.STAGING.STAGING_REAL_ESTATE_FULL;




--fact_estate_metrics
INSERT INTO FACT_ESTATE_METRICS (
    property_key, 
    building_key, 
    date_key, 
    estimate_price, 
    annual_tax_amount, 
    page_view_count, 
    rent_estimate,
    included_furniture, 
    monthly_hoa_fee, 
    tax_assessed_value,
    price_per_square_foot, 
    deposit_fee_min, 
    climate_flood_risk_value, 
    climate_fire_risk_value, 
    favorite_count
)
SELECT 
    dp.property_key,
    db.building_key,
    dd.date_key,

    stg.estimate_price,
    stg.annual_tax_amount,
    stg.page_view_count,
    stg.rent_estimate,
    stg.included_furniture,
    stg.monthly_hoa_fee,
    stg.tax_assessed_value,
    stg.price_per_square_foot,
    stg.deposit_fee_min,
    stg.climate_flood_risk_value,
    stg.climate_fire_risk_value,
    stg.favorite_count

FROM LION_MY_LAST_PROJECT.STAGING.STAGING_REAL_ESTATE_FULL stg

JOIN DIM_PROPERTY_DETAILS dp ON stg.property_zpid = dp.zillow_zpid

JOIN DIM_DATE dd ON dd.date_key = TO_NUMBER(TO_CHAR(TO_DATE(TO_TIMESTAMP(stg.CREATED_TS / 1000000)), 'YYYYMMDD'))

LEFT JOIN DIM_BUILDING_INFO db ON stg.building_zpid = db.building_zpid
