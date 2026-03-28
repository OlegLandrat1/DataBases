/*
Определить, какие автомобили имеют среднюю позицию лучше (меньше) средней позиции всех автомобилей в своем классе (то есть автомобилей в классе должно быть минимум два, чтобы выбрать один из них). Вывести информацию об этих автомобилях, включая их имя, класс, среднюю позицию, количество гонок, в которых они участвовали, и страну производства класса автомобиля. Также отсортировать результаты по классу и затем по средней позиции в порядке возрастания.
*/

SELECT 
    c.name,
    c.class,
    cl.country,
    AVG(r.position) AS avg_position,
    COUNT(r.race) AS num_races
FROM Cars c
INNER JOIN Results r ON c.name = r.car
INNER JOIN Classes cl ON c.class = cl.class
GROUP BY c.name, c.class, cl.country
HAVING AVG(r.position) < (
    SELECT AVG(r2.position)
    FROM Cars c2
    INNER JOIN Results r2 ON c2.name = r2.car
    WHERE c2.class = c.class
    GROUP BY c2.class
)
AND c.class IN (
    SELECT c3.class
    FROM Cars c3
    GROUP BY c3.class
    HAVING COUNT(c3.name) >= 2
)
ORDER BY c.class ASC, avg_position ASC;
