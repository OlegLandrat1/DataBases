/*
Определить, какие классы автомобилей имеют наибольшее количество автомобилей с низкой средней позицией (больше 3.0) и вывести информацию о каждом автомобиле из этих классов, включая его имя, класс, среднюю позицию, количество гонок, в которых он участвовал, страну производства класса автомобиля, а также общее количество гонок для каждого класса. Отсортировать результаты по количеству автомобилей с низкой средней позицией.
*/

WITH car_avg AS (
    SELECT 
        c.name,
        c.class,
        AVG(r.position) AS avg_position,
        COUNT(r.race) AS num_races
    FROM Cars c
    INNER JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
),
class_stats AS (
    SELECT 
        class,
        COUNT(DISTINCT name) AS count_low_avg_position
    FROM car_avg
    WHERE avg_position > 3.0
    GROUP BY class
),
max_count AS (
    SELECT MAX(count_low_avg_position) AS max_cnt
    FROM class_stats
)
SELECT 
    ca.name,
    ca.class,
    cl.country,
    ca.avg_position,
    ca.num_races,
    (SELECT COUNT(DISTINCT r.race) 
     FROM Cars c 
     INNER JOIN Results r ON c.name = r.car 
     WHERE c.class = ca.class) AS total_races_in_class,
    cs.count_low_avg_position
FROM car_avg ca
INNER JOIN Classes cl ON ca.class = cl.class
INNER JOIN class_stats cs ON ca.class = cs.class
INNER JOIN max_count mc ON cs.count_low_avg_position = mc.max_cnt
WHERE ca.avg_position > 3.0
ORDER BY cs.count_low_avg_position DESC, ca.class ASC;
