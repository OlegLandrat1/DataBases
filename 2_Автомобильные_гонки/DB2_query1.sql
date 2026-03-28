/*
Определить, какие автомобили из каждого класса имеют наименьшую среднюю позицию в гонках, и вывести информацию о каждом таком автомобиле для данного класса, включая его класс, среднюю позицию и количество гонок, в которых он участвовал. Также отсортировать результаты по средней позиции.
*/

SELECT 
    c.class,
    c.name,
    AVG(r.position) AS avg_position,
    COUNT(r.race) AS num_races
FROM Cars c
INNER JOIN Results r ON c.name = r.car
GROUP BY c.class, c.name
HAVING AVG(r.position) = (
    SELECT MIN(avg_pos)
    FROM (
        SELECT AVG(r2.position) AS avg_pos
        FROM Cars c2
        INNER JOIN Results r2 ON c2.name = r2.car
        WHERE c2.class = c.class
        GROUP BY c2.name
    ) AS subquery
)
ORDER BY avg_position ASC;
