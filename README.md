# ELT proces datasetu US Real Estate (Pennsylvania)

Tento repozitár predstavuje implementáciu ELT procesu v Snowflake na analýzu realitného trhu v štáte Pensylvánia (USA). Projekt sa zameriava na transformáciu surových dát z marketplace do hviezdicovej schémy (Star Schema), čo umožňuje efektívnu multidimenzionálnu analýzu kľúčových metrík trhu nehnuteľností.

Výsledný model umožňuje investorom a analytikom preskúmať vzťahy medzi cenou, lokalitou, občianskou vybavenosťou a klimatickými rizikami.

---

## 1. Úvod a popis zdrojových dát

Cieľom projektu je analyzovať trh s nehnuteľnosťami v mestách ako **Philadelphia, Pittsburgh a Scranton**. Analýza sa zameriava na hodnotenie investičných príležitostí, vplyv infraštruktúry na cenu a posúdenie klimatických rizík.

Zdrojové dáta pochádzajú z datasetu **US Real Estate Properties** od poskytovateľa **Elementix**, dostupného cez Snowflake Marketplace. Dáta sú v staging vrstve uložené v dvoch rozsiahlych tabuľkách, ktoré obsahujú komplexné technické, finančné a geografické atribúty:

### 1.1 Detailný popis staging tabuliek

#### A. Tabuľka `buildings` (Metadata budov a infraštruktúra)
Táto tabuľka slúži ako číselník objektov a komplexov, v ktorých sa nehnuteľnosti nachádzajú. Obsahuje 115 stĺpcov zameraných na širší kontext budovy.
* **Identifikátory:** `building_key` (PK), `building_zpid` (identifikátor Zillow).
* **Lokalita a normalizácia adries:** Obsahuje surové aj normalizované adresné údaje (`normalized_city`, `normalized_state_name`, `normalized_zip_code`), čo zabezpečuje vysokú presnosť pri geografickom mapovaní.
* **Občianska vybavenosť (Amenities):** Detailné informácie o spoločných priestoroch a vybavení (bazén, posilňovňa, výťah, 24-hodinová údržba, park pre domáce zvieratá).
* **Indexy mobility:** `building_walk_score`, `building_transit_score` a `building_bike_score`, ktoré definujú kvalitu lokality z pohľadu dopravy a dostupnosti.
* **Pravidlá a poplatky:** Informácie o depozitoch, poplatkoch za prihlášku (`application_fee`) a podrobných pravidlách pre zvieratá (`pet_policy_description`).

#### B. Tabuľka `properties` (Detaily ponúk a finančné metriky)
Táto tabuľka predstavuje jadro analýzy, nakoľko obsahuje konkrétne ponuky nehnuteľností, ich fyzický stav a finančnú históriu. Obsahuje 73 stĺpcov.
* **Finančné ukazovatele:** Aktuálna cena (`price`), trhový odhad (`zillow_zestimate`), ročné dane (`reso_facts_tax_annual_amount`), mesačné poplatky.
* **Fyzické charakteristiky:** Počet spální (`bedrooms`), kúpeľní, rok výstavby (`year_built`), rozloha obytnej plochy (`living_area_value`) a architektonický štýl.
* **Environmentálne a klimatické riziká:** Indexy povodňového (`flood_risk_value`) a požiarneho rizika vrátane klasifikácie FEMA zón.
* **Marketingové dáta:** Popularita ponuky vyjadrená cez `zillow_page_view_count` a `zillow_favorite_count`.
* **Vzdelanie:** Dáta o priradených školských obvodoch (základné, stredné a vysoké školy).
* **Informácie o predajcoch:** Údaje o agentoch a brokerských spoločnostiach (`brokerage_name`, `attribution_agent_license_number`).

### 1.2 Dátová architektúra

#### ERD diagram
Surové dáta sú v staging vrstve prepojené prostredníctvom identifikátora **building_key**, kde jedna budova (`buildings`) môže obsahovať viacero konkrétnych nehnuteľností/jednotiek (`properties`).



![ERD Diagram](img/startSchemaFinal.png)

*Obrázok 1 Entitno-relačná schéma zdrojových dát (Staging layer)*

---

## 2. Dimenzionálny model

V projekte bola navrhnutá **schéma hviezdy (star schema)** podľa Kimballovej metodológie. Táto štruktúra obsahuje jednu tabuľku faktov **`fact_estate_metrics`**, ktorá je prepojená so patmi dimenziami:

* **`dim_property_details`**: Obsahuje podrobné fyzické informácie o nehnuteľnosti (typ stavby, počet izieb, rozloha, materiál).
* **`dim_building_info`**: Zahŕňa údaje o budove ako celku (počet jednotiek, vybavenie ako posilňovňa či bazén, bezpečnostné prvky).
* **`dim_location`**: Obsahuje geografické dáta vrátane informácií o školských obvodoch a indexoch dostupnosti (Walk Score).
* **`dim_seller`**: Údaje o agentoch, ich licenciách a pridružených brokerských spoločnostiach.
* **`dim_date`**: Podrobná časová dimenzia pre analýzu trendov (deň, mesiac, štvrťrok, víkendy).
  
Štruktúra hviezdicového modelu je znázornená na diagrame nižšie:

![Star Schema](img/FinalStarSchema.png)
*Obrázok 2 Schéma hviezdy pre US Real Estate Analytics*

---

## 3. ELT proces v Snowflake

ELT proces pozostáva z troch hlavných fáz: extrahovanie (Extract), načítanie (Load) a transformácia (Transform).

### 3.1 Extract (Extrahovanie dát)
Dáta zo zdrojového datasetu boli najprv sprístupnené v Snowflake prostredníctvom Marketplace. Pre import súborov tretích strán bolo vytvorené interné stage úložisko:
```sql
CREATE OR REPLACE STAGE my_stage;





функції:
кількість вільних квартир які є в будинкку та виставлені на продаж. Це зробити за допомогою коунт, мінус ще щось. Стовпчики: buildings.unit_count - properties.home_status where home_status ilike "%sold" 
join propperties p on p.building_key = b.building key

select (b.building_unit_count - count(p.home_status)) from buildings b 
join properties p on p.building_key = b.building_key
where p.home_status ='SOLD'
group by 


вкажи продажі двох кварталів за останніх 3 роки. Використати таблицю dim_date.


вирахувати скільки $ за м2


-----найменший ризик будівлі яку затопить------

SELECT 
    PROPERTY_STREET_ADDRESS,
    PROPERTY_STATE,
    CLIMATE_CLIMATE_FLOOD_RISK_VALUE,
    CLIMATE_CLIMATE_FIRE_RISK_VALUE,
    PRICE
FROM properties
join buildings on buildings.building_key = properties.building_key
WHERE 
    CLIMATE_CLIMATE_FLOOD_RISK_VALUE < 2 -- Низький ризик
    AND CLIMATE_CLIMATE_FIRE_RISK_VALUE < 2 -- Низький ризик
    AND HOME_STATUS = 'FOR_SALE'
ORDER BY PRICE DESC



-----знайти доступні будинки з мінімум 3 спальнями, ціною до 300,000, відсортовані від найдешевших-----

SELECT 
    PROPERTY_STREET_ADDRESS, 
    PROPERTY_CITY, 
    PRICE, 
    BEDROOMS, 
    BATHROOMS, 
    LIVING_AREA_VALUE
FROM properties
WHERE 
    PRICE <= 300000 and price > 0
    AND BEDROOMS >= 3
    AND HOME_STATUS = 'FOR_SALE' -- Припускаємо, що статус "на продаж"
ORDER BY PRICE ASC
LIMIT 10;





---------нові будинки (збудовані після 2020 року), де дозволені тварини та є парк для вигулу-----

SELECT 
    b.BUILDING_NAME,
    p.YEAR_BUILT,
    b.BUILDING_HAS_PET_PARK,
    b.BUILDING_PET_POLICY_DESCRIPTION,
    p.price
FROM buildings b
JOIN properties p on b.building_key = p.building_key
WHERE 
    YEAR_BUILT >= 2020
    AND (BUILDING_HAS_PET_PARK = TRUE OR RESO_FACTS_PROPERTY_HAS_PETS_ALLOWED = TRUE)
ORDER BY YEAR_BUILT DESC, price
LIMIT 10;




---------будинки, які користуються найбільшою увагою користувачів (багато переглядів та збережень в обране), але все ще не продані.-------

SELECT 
    zillow_zpid,
    PROPERTY_STREET_ADDRESS,
    PRICE,
        ZILLOW_FAVORITE_COUNT,
    ZILLOW_PAGE_VIEW_COUNT,
    DAYS_ON_ZILLOW
    FROM properties
WHERE 
    HOME_STATUS = 'FOR_SALE' and ZILLOW_PAGE_VIEW_COUNT is not null
ORDER BY ZILLOW_FAVORITE_COUNT DESC, ZILLOW_PAGE_VIEW_COUNT DESC
LIMIT 10;





Різниця між ціною обєкта та середньою ціною в окрузі (County)
Чи переплачує клієнт за цей конкретний будинок порівняно з середнім рівнем в окрузі?

SELECT 
    p.property_key, l.county, f.price,
    AVG(f.price) OVER (PARTITION BY l.county) as avg_county_price,
    f.price - AVG(f.price) OVER (PARTITION BY l.county) as price_diff_from_avg
FROM FACT_ESTATE_METRICS f
JOIN DIM_LOCATION l ON f.location_key = l.location_key;



Накопичувальна сума переглядів для Агента
Скільки всього уваги привертають обєкти конкретного брокера (Running Total).

SQL

SELECT 
    s.name, s.surname, f.page_view_count,
    SUM(f.page_view_count) OVER (PARTITION BY s.seller_key ORDER BY f.metric_key) as total_agent_views
FROM FACT_ESTATE_METRICS f
JOIN DIM_SELLER s ON f.seller_key = s.seller_key;




WITH CompanyStats AS (
    SELECT 
        s.brokerage_name AS company_name,
        COUNT(f.metric_key) AS sold_count,
        -- Рахуємо кількість продажів саме за 2025 рік для подальшого сортування
        COUNT(CASE WHEN d.year = 2025 THEN 1 END) AS sold_last_year
    FROM fact_estate_metrics f
    JOIN dim_seller s ON f.seller_key = s.seller_key
    JOIN dim_property_details p ON f.property_key = p.property_key
    JOIN dim_date d ON f.date_key = d.date_key
    WHERE p.home_status = 'SOLD'
    GROUP BY s.brokerage_name
)
SELECT 
    company_name,
    sold_count,
    -- Кумулятивна сума всіх проданих квартир по компаніях
    SUM(sold_count) OVER (ORDER BY sold_count DESC) AS cumulative_total_sold
FROM CompanyStats
ORDER BY sold_last_year DESC;






-----------------в стовпчик date.year ми записуватимемо перші 4 значення стовпчика 
