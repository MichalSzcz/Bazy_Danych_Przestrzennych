


--1 Zaimportuj następujące pliki shapefile do bazy, przyjmij wszędzie układ WGS84:
SELECT * FROM public.t2018_kar_buildings;
SELECT * FROM public.t2019_kar_buildings;

--1a. Znajdź budynki, które zostały wybudowane lub wyremontowane na przestrzeni roku (zmiana
--pomiędzy 2018 a 2019).

CREATE VIEW BUDYNKI_1 AS
SELECT t2019_kar_buildings.* FROM public.t2019_kar_buildings LEFT JOIN public.t2018_kar_buildings 
ON t2019_kar_buildings.polygon_id = t2018_kar_buildings.polygon_id 
WHERE ST_Equals(t2019_kar_buildings.geom, t2018_kar_buildings.geom) != true
OR t2018_kar_buildings.polygon_id IS NULL;
--2 
-- Znajdź ile nowych POI pojawi³o siê w promieniu 500 m od wyremontowanych lub wybudowanych budynków,
-- które znalezione zosta³y w zadaniu 1. Policz je wg ich kategorii .





-------
SELECT COUNT(DISTINCT(Poi19.poi_id)) 
FROM BUDYNKI_1 AS a,
	T2019_KAR_POI_TABLE AS b
WHERE
	b.gid NOT IN (
		SELECT DISTINCT(b.gid) 
		FROM
			T2019_KAR_POI_TABLE AS b,
			T2018_KAR_POI_TABLE AS c
		WHERE 
		ST_Equals(b.geom, c.geom)
	)
	AND
	ST_DWithin(b.geom, a.geom, 500);
	






--3Utwórz nową tabelę o nazwie ‘streets_reprojected’, która zawierać będzie dane z tabeli
--T2019_KAR_STREETS przetransformowane do układu współrzędnych DHDN.Berlin/Cassini.
CREATE TABLE streets_reprojected AS(
SELECT 
    gid, link_id, st_name, ref_in_id, nref_in_id, func_class, speed_cat, fr_speed_l, dir_travel, ST_Transform(geom, 3068)
    FROM t2019_kar_streets)
	
	
--4Stwórz tabelę o nazwie ‘input_points’ i dodaj do niej dwa rekordy o geometrii punktowej.

CREATE TABLE input_points (geom geometry, id integer);

INSERT INTO input_points VALUES( ST_GeomFromText('POINT(8.36093 49.03174)', 4326), 1);
INSERT INTO input_points VALUES( ST_GeomFromText('POINT(8.39876 49.00644)', 4326), 2)

SELECT * FROM input_points

--5 Zaktualizuj dane w tabeli ‘input_points’ tak, aby punkty te były w układzie współrzędnychDHDN.Berlin/Cassini. Wyświetl współrzędne za pomocą funkcji ST_AsText().
UPDATE input_points SET
geom = ST_Transform(geom,3068);
SELECT ST_AsText(geom) FROM input_points


--6 Znajdź wszystkie skrzyżowania, które znajdują się w odległości 200 m od linii zbudowanejz punktów w tabeli ‘input_points’. Wykorzystaj tabelę T2019_STREET_NODE.Dokonajreprojekcji geometrii, aby była zgodna z resztą tabel.

SELECT * FROM public.t2019_kar_street_node
WHERE ST_Within(ST_Transform(t2019_kar_street_node.geom, 3068), 
                ST_Buffer(ST_ShortestLine((SELECT geom FROM input_points WHERE id = 1),
                                          (SELECT geom FROM input_points WHERE id = 2)), 200));
										  
--7Policz jak wiele sklepów sportowych (‘Sporting Goods Store’ - tabela POIs) znajduje sięw odległości 300 m od parków (LAND_USE_A).
SELECT * FROM t2019_kar_poi_table
WHERE t2019_kar_poi_table.type='Sporting Goods Store'

SELECT distinct poi_id, t2019_kar_poi_table.* 
FROM t2019_kar_poi_table 
CROSS JOIN t2019_kar_land_use_a 
WHERE t2019_kar_poi_table.type='Sporting Goods Store' AND
ST_Distance(t2019_kar_poi_table.geom,  t2019_kar_land_use_a.geom) <= 300

SELECT distinct poi_id, t2019_kar_poi_table.* FROM t2019_kar_poi_table CROSS JOIN t2019_kar_land_use_a WHERE t2019_kar_poi_table.type='Sporting Goods Store' AND
St_Within( t2019_kar_poi_table.geom, ST_Buffer(ST_Union(ARRAY(SELECT t2019_kar_land_use_a.geom FROM t2019_kar_land_use_a)), 300 ))


--8 Znajdź punkty przecięcia torów kolejowych (RAILWAYS) z ciekami (WATER_LINES). Zapiszznalezioną geometrię do osobnej tabeli o nazwie ‘T2019_KAR_BRIDGES’.
SELECT distinct ST_Intersection(t2019_kar_railways.geom,t2019_kar_water_lines.geom) 
INTO T2019_KAR_BRIDGES
	FROM t2019_kar_railways,t2019_kar_water_lines
    
    
SELECT * FROM t2019_KAR_BRIDGES
