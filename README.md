
функції:
кількість вільних квартир які є в будинкку та виставлені на продаж. Це зробити за допомогою коунт, мінус ще щось. Стовпчики: buildings.unit_count - properties.home_status where home_status ilike "%sold" 
join propperties p on p.building_key = b.building key

select (b.building_unit_count - count(p.home_status)) from buildings b 
join properties p on p.building_key = b.building_key
where p.home_status ='SOLD'
group by 