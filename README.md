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


## 4. Vizualizácia dát

Dashboard obsahuje **8 vizualizácií**, ktoré poskytujú komplexný pohľad na kľúčové metriky a trendy na realitnom trhu v Pensylvánii. Tieto vizualizácie odpovedajú na dôležité otázky investorov a umožňujú lepšie pochopiť vzťah medzi cenou, lokalitou a environmentálnymi rizikami.

### Graf 1: Najdrahšie nehnuteľnosti v bezpečných zónach (Nízke riziko)
Táto vizualizácia identifikuje prémiové nehnuteľnosti, ktoré sa nachádzajú v oblastiach s minimálnym rizikom povodní a požiarov (index < 2). Pomáha investorom nájsť vysoko hodnotné objekty, ktoré sú zároveň dlhodobo chránené pred klimatickými hrozbami.

```sql
SELECT 
    p.property_street_address,
    l.state_name,
    f.climate_flood_risk_value,
    f.climate_fire_risk_value,
    f.estimate_price
FROM FACT_ESTATE_METRICS f
JOIN DIM_LOCATION l ON f.location_key = l.location_key
JOIN DIM_PROPERTY_DETAILS p ON f.property_key = p.property_key
WHERE f.climate_flood_risk_value < 2 
  AND f.climate_fire_risk_value < 2 
  AND p.home_status = 'FOR_SALE'
ORDER BY f.estimate_price DESC;
```

### Graf 2: Dostupnosť rodinného bývania (Top 10 najlacnejších)
Graf zobrazuje 10 najdostupnejších nehnuteľností pre rodiny: minimálne 3 spálne a cena pod 300 000 USD. Táto analýza umožňuje sledovať možnosti pre strednú vrstvu obyvateľstva a identifikovať najvýhodnejšie ponuky na trhu.

```sql
SELECT 
    p.property_street_address, 
    l.city, 
    f.estimate_price, 
    p.bedrooms, 
    p.living_area_value
FROM FACT_ESTATE_METRICS f
JOIN DIM_LOCATION l ON f.location_key = l.location_key
JOIN DIM_PROPERTY_DETAILS p ON f.property_key = p.property_key
WHERE f.estimate_price <= 300000 AND f.estimate_price > 0
  AND p.bedrooms >= 3
  AND p.home_status = 'FOR_SALE'
ORDER BY f.estimate_price ASC
LIMIT 10;
```

### Graf 3: Moderné trendy: Novostavby s vybavením pre zvieratá
Tento prehľad sa zameriava na moderné budovy postavené po roku 2020, ktoré reflektujú trendy ako "pet-friendly" (parky pre psov). Vizualizácia ukazuje, že nová výstavba sa čoraz viac sústredi na doplnkovú infraštruktúru.

```sql
SELECT 
    b.building_name,
    p.year_built,
    b.has_pet_park,
    f.estimate_price
FROM FACT_ESTATE_METRICS f
JOIN DIM_BUILDING_INFO b ON f.building_key = b.building_key
JOIN DIM_PROPERTY_DETAILS p ON f.property_key = p.property_key
WHERE p.year_built >= 2020
  AND b.has_pet_park = TRUE
ORDER BY p.year_built DESC, f.estimate_price;
```

### Graf 4: Analýza trhového záujmu (Populárne ale nepredané)
Vizualizácia porovnáva počet zobrazení a uložení do obľúbených pri nehnuteľnostiach, ktoré sú stále na predaj. Identifikuje objekty, ktoré generujú vysoký organický záujem, ale zostávajú na trhu dlšie.

```sql
SELECT 
    p.property_zpid,
    p.property_street_address,
    f.estimate_price,
    f.favorite_count,
    f.page_view_count
FROM FACT_ESTATE_METRICS f
JOIN DIM_PROPERTY_DETAILS p ON f.property_key = p.property_key
WHERE p.home_status = 'FOR_SALE' 
  AND f.page_view_count IS NOT NULL
ORDER BY f.favorite_count DESC, f.page_view_count DESC
LIMIT 10;
```

### Graf 5: Porovnanie cien voči priemeru okresu (County)
Táto tabuľka využíva okenné funkcie na výpočet rozdielu medzi cenou konkrétneho domu a priemernou cenou v danom okrese. Umožňuje detegovať podhodnotené alebo naopak luxusné ponuky.

```sql
SELECT 
    p.property_key, 
    l.county, 
    f.estimate_price,
    AVG(f.estimate_price) OVER (PARTITION BY l.county) AS avg_county_price,
    f.estimate_price - AVG(f.estimate_price) OVER (PARTITION BY l.county) AS price_diff_from_avg
FROM FACT_ESTATE_METRICS f
JOIN DIM_LOCATION l ON f.location_key = l.location_key
JOIN DIM_PROPERTY_DETAILS p ON f.property_key = p.property_key;
```

### Graf 6: Identifikácia podhodnotených investičných príležitostí
Vizualizácia porovnáva ponukovú cenu s trhovým odhadom (Zestimate). Cieľom je nájsť nehnuteľnosti predávané pod hodnotou, čo pre investora predstavuje okamžitý potenciálny zisk.

```sql
SELECT 
    l.city,
    f.estimate_price AS current_price,
    f.zillow_zestimate AS market_value,
    (f.zillow_zestimate - f.estimate_price) AS potential_profit
FROM FACT_ESTATE_METRICS f
JOIN DIM_LOCATION l ON f.location_key = l.location_key
WHERE f.estimate_price < f.zillow_zestimate
  AND f.estimate_price > 0
ORDER BY potential_profit DESC
LIMIT 10;
```

### Graf 7: Kumulatívna pozornosť používateľov podľa agentov
Tento graf pomocou okenných funkcií (SUM OVER) sleduje kumulatívny počet zobrazení stránok pre jednotlivých agentov. Umožňuje identifikovať najúspešnejších brokerov, ktorí generujú najväčšiu pozornosť na trhu.

```sql
SELECT 
    s.seller_name, 
    s.agency_name, 
    f.page_view_count,
    SUM(f.page_view_count) OVER (PARTITION BY s.seller_key ORDER BY f.metric_key) as total_agent_views
FROM FACT_ESTATE_METRICS f
JOIN DIM_SELLER s ON f.seller_key = s.seller_key;
```

### Graf 8: Výkonnosť realitných kancelárií a kumulatívne predaje
Graf znázorňuje úspešnosť brokerov v roku 2025. Pomocou kumulatívnej sumy môžeme sledovať celkovú predajnú silu najväčších hráčov na trhu v Pensylvánii.

```sql
WITH CompanyStats AS (
    SELECT 
        s.agency_name AS company_name,
        COUNT(f.metric_key) AS sold_count,
        COUNT(CASE WHEN d.year = 2025 THEN 1 END) AS sold_last_year
    FROM FACT_ESTATE_METRICS f
    JOIN DIM_SELLER s ON f.seller_key = s.seller_key
    JOIN DIM_PROPERTY_DETAILS p ON f.property_key = p.property_key
    JOIN DIM_DATE d ON f.date_key = d.date_key
    WHERE p.home_status = 'SOLD'
    GROUP BY s.agency_name
)
SELECT 
    company_name,
    sold_count,
    SUM(sold_count) OVER (ORDER BY sold_count DESC) AS cumulative_total_sold
FROM CompanyStats
ORDER BY sold_last_year DESC;
```






