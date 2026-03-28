/*
Определить классы автомобилей, которые имеют наименьшую среднюю позицию в гонках, и вывести информацию о каждом автомобиле из этих классов, включая его имя, среднюю позицию, количество гонок, в которых он участвовал, страну производства класса автомобиля, а также общее количество гонок, в которых участвовали автомобили этих классов. Если несколько классов имеют одинаковую среднюю позицию, выбрать все из них.
*/

SELECT 
    c.name,
    c.class,
    cl.country,
    AVG(r.position) AS avg_position,
    COUNT(r.race) AS num_races,
    (SELECT AVG(r2.position) 
     FROM Cars c2 
     INNER JOIN Results r2 ON c2.name = r2.car 
     WHERE c2.class = c.class) AS class_avg_position,
    (SELECT COUNT(DISTINCT r3.race) 
     FROM Cars c3 
     INNER JOIN Results r3 ON c3.name = r3.car 
     WHERE c3.class = c.class) AS total_races_in_class
FROM Cars c
INNER JOIN Results r ON c.name = r.car
INNER JOIN Classes cl ON c.class = cl.class
WHERE c.class IN (
    SELECT c2.class
    FROM Cars c2
    INNER JOIN Results r2 ON c2.name = r2.car
    GROUP BY c2.class
    HAVING AVG(r2.position) = (
        SELECT MIN(avg_pos)
        FROM (
            SELECT AVG(r3.position) AS avg_pos
            FROM Cars c3
            INNER JOIN Results r3 ON c3.name = r3.car
            GROUP BY c3.class
        ) AS subquery
    )
)
GROUP BY c.name, c.class, cl.country
ORDER BY c.class, c.name;
