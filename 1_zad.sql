
	
	-- SCHEMA: Bazy_Danych

-- DROP SCHEMA IF EXISTS "Bazy_Danych" ;

CREATE SCHEMA IF NOT EXISTS "Bazy_Danych"
    AUTHORIZATION postgres;
	
	
--1 utworz tabele drogi
CREATE TABLE roads (id INT PRIMARY KEY NOT NULL, geometry GEOMETRY, name VARCHAR(50));


-- point(x y )
-- LINESTRING(x1 y1, x2 y2)wspolrzedne spacja 
-- POLYGON ((x1 y1, x2 y2, x3 y3, x4 y4))
-- 0 W INSERCIE BO LOKALNTY UKLAD WSPOLRZEDNYCH


INSERT INTO roads VALUES
	(1, ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)', 0), 'RoadX'),
	(2, ST_GeomFromText('LINESTRING(7.5 0, 7.5 10.5)', 0), 'RoadY');




CREATE TABLE buildings (id INT PRIMARY KEY NOT NULL, geometry GEOMETRY, name VARCHAR(50));

INSERT INTO buildings VALUES (1, ST_GeomFromText('POLYGON((8 1.5, 10.5 1.5, 10.5 4, 8 4, 8 1.5))', 0), 'BuildingA');
INSERT INTO buildings VALUES (2, ST_GeomFromText('POLYGON((4 5, 6 5, 6 7, 4 7, 4 5))', 0), 'BuildingB');
INSERT INTO	buildings VALUES (3, ST_GeomFromText('POLYGON((3 6, 5 6, 5 8, 3 8, 3 6))', 0), 'BuildingC');
INSERT INTO buildings VALUES (4, ST_GeomFromText('POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))', 0), 'BuildingD');
INSERT INTO  buildings VALUES (5, ST_GeomFromText('POLYGON((1 1, 2 1, 2 2, 1 2, 1 1))', 0), 'BuildingE');



CREATE TABLE points(id INT PRIMARY KEY NOT NULL, geometry GEOMETRY,name VARCHAR(50));
DROP TABLE points

INSERT INTO points VALUES   (1, ST_GeomFromText('POINT(1 3.5)', 0), 'G');
INSERT INTO points VALUES	(2, ST_GeomFromText('POINT(5.5 1.5)', 0), 'H');
INSERT INTO points VALUES  	(3, ST_GeomFromText('POINT(9.5 6)', 0), 'I');
INSERT INTO points VALUES  	(4, ST_GeomFromText('POINT(6.5 6)', 0), 'J');
INSERT INTO points VALUES  	(5, ST_GeomFromText('POINT(6 9.5)', 0), 'K');





SELECT *, ST_AsText(roads.geometry) AS WKT FROM roads;

-- 1 zadanie

-- a) Wyznacz całkowitą długość dróg w analizowanym mieście


SELECT SUM(ST_Length(geometry)) as sum_of_roads_length FROM roads;



-- b) Wypisz geometrię (WKT), pole powierzchni oraz obwód poligonu reprezentującego budynek o nazwie BuildingA.
SELECT ST_AsText(geometry) as WKT, ST_Area(geometry) as area, ST_Perimeter(geometry) as perimeter 
	FROM buildings
	WHERE name = 'BuildingA';

-- c) Wypisz nazwy i pola powierzchni wszystkich poligonów w warstwie budynki. Wyniki posortuj alfabetycznie.

SELECT name, ST_area(geometry) 
	FROM buildings
	ORDER BY name;
	
-- d) Wypisz nazwy i obwody 2 budynków o największej powierzchni.  

SELECT name, ST_perimeter(geometry) as perimeter
	FROM buildings
	ORDER BY perimeter DESC
	LIMIT 2
	
-- e) Wyznacz najkrótszą odległość między budynkiem BuildingC a punktem G.

SELECT ST_Distance(points.geometry, buildings.geometry) as shortest_distance 
	FROM points, buildings
	WHERE points.name = 'G' AND buildings.name = 'BuildingC'
	
-- f) Wypisz pole powierzchni tej części budynku BuildingC, 
--    która znajduje się w odległości większej niż 0.5 od budynku BuildingB. 

SELECT ST_Area(
	ST_Difference(
		(SELECT geometry FROM buildings WHERE name = 'BuildingC'), 
		ST_Buffer((SELECT geometry FROM buildings WHERE name = 'BuildingB'), 0.5)));
		
-- g) Wybierz te budynki, których centroid (ST_Centroid) znajduje się powyżej drogi o nazwie RoadX. 

SELECT buildings.name
	FROM buildings, roads
	WHERE roads.name = 'RoadX' AND ST_Y(ST_Centroid(buildings.geometry)) > ST_Y(ST_Centroid(roads.geometry));

-- h) Oblicz pole powierzchni tych części budynku BuildingC i poligonu o współrzędnych (4 7, 6 7, 6 8, 4 8, 4 7),
--	  które nie są wspólne dla tych dwóch obiektów.

SELECT ST_Area(ST_SymDifference(geometry, ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')))
	FROM buildings
	WHERE name = 'BuildingC'