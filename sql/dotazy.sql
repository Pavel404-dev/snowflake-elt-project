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