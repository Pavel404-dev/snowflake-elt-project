CREATE TABLE FACT_ESTATE_METRICS (
  metric_key int PRIMARY KEY AUTO_INCREMENT,
  property_key int,
  building_key int,
  location_key int,
  date_key int,
  seller_key int,
  estimate_price float,
  annual_tax_amount float ,
  page_view_count float ,
  rent_estimate float ,
  included_furniture bool
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
  is_new bool,
  description varchar(255),
  area float
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
  transit_score int
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
  longitude float
);

CREATE TABLE DIM_DATE (
  date_key int PRIMARY KEY,
  full_date date,
  year int,
  quarter int,
  month int,
  month_name varchar(255), 
  day_of_week int ,
  day_name varchar(255) ,
  week_of_year int ,
  is_weekend boolean ,
  is_holiday boolean ,
  fiscal_quarter int 
);

CREATE TABLE DIM_SELLER (
  seller_key int PRIMARY KEY,
  name varchar(255),
  surname varchar(255),
  phone_number varchar(255),
  agency_name varchar(255), 
  agent_license_number varchar(255),
  agent_email varchar(255) ,
  brokerage_name varchar(255) ,
  broker_phone_number varchar(255) ,
  is_premier_agent boolean
);

ALTER TABLE FACT_ESTATE_METRICS ADD FOREIGN KEY (property_key) REFERENCES DIM_PROPERTY_DETAILS (property_key);

ALTER TABLE FACT_ESTATE_METRICS ADD FOREIGN KEY (building_key) REFERENCES DIM_BUILDING_INFO (building_key);

ALTER TABLE FACT_ESTATE_METRICS ADD FOREIGN KEY (location_key) REFERENCES DIM_LOCATION (location_key);

ALTER TABLE FACT_ESTATE_METRICS ADD FOREIGN KEY (date_key) REFERENCES DIM_DATE (date_key);

ALTER TABLE FACT_ESTATE_METRICS ADD FOREIGN KEY (seller_key) REFERENCES DIM_SELLER (seller_key);