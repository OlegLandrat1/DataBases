/*
Вам необходимо провести анализ данных о бронированиях в отелях и определить предпочтения клиентов по типу отелей. Для этого выполните следующие шаги:

Категоризация отелей.
Определите категорию каждого отеля на основе средней стоимости номера:

«Дешевый»: средняя стоимость менее 175 долларов.
«Средний»: средняя стоимость от 175 до 300 долларов.
«Дорогой»: средняя стоимость более 300 долларов.
Анализ предпочтений клиентов.
Для каждого клиента определите предпочитаемый тип отеля на основании условия ниже:

Если у клиента есть хотя бы один «дорогой» отель, присвойте ему категорию «дорогой».
Если у клиента нет «дорогих» отелей, но есть хотя бы один «средний», присвойте ему категорию «средний».
Если у клиента нет «дорогих» и «средних» отелей, но есть «дешевые», присвойте ему категорию предпочитаемых отелей «дешевый».
Вывод информации.
Выведите для каждого клиента следующую информацию:

ID_customer: уникальный идентификатор клиента.
name: имя клиента.
preferred_hotel_type: предпочитаемый тип отеля.
visited_hotels: список уникальных отелей, которые посетил клиент.
Сортировка результатов.
Отсортируйте клиентов так, чтобы сначала шли клиенты с «дешевыми» отелями, затем со «средними» и в конце — с «дорогими».
*/

WITH hotel_categories AS (
    SELECT 
        h.ID_hotel,
        h.name AS hotel_name,
        AVG(r.price) AS avg_price,
        CASE 
            WHEN AVG(r.price) < 175 THEN 'Дешевый'
            WHEN AVG(r.price) BETWEEN 175 AND 300 THEN 'Средний'
            ELSE 'Дорогой'
        END AS hotel_category
    FROM Hotel h
    LEFT JOIN Room r ON h.ID_hotel = r.ID_hotel
    GROUP BY h.ID_hotel, h.name
),
customer_hotel_bookings AS (
    SELECT 
        c.ID_customer,
        c.name,
        hc.hotel_category,
        hc.hotel_name
    FROM Customer c
    INNER JOIN Booking b ON c.ID_customer = b.ID_customer
    INNER JOIN Room r ON b.ID_room = r.ID_room
    INNER JOIN hotel_categories hc ON r.ID_hotel = hc.ID_hotel
),
customer_preferences AS (
    SELECT 
        ID_customer,
        name,
        CASE 
            WHEN MAX(CASE WHEN hotel_category = 'Дорогой' THEN 1 ELSE 0 END) = 1 THEN 'Дорогой'
            WHEN MAX(CASE WHEN hotel_category = 'Средний' THEN 1 ELSE 0 END) = 1 THEN 'Средний'
            WHEN MAX(CASE WHEN hotel_category = 'Дешевый' THEN 1 ELSE 0 END) = 1 THEN 'Дешевый'
        END AS preferred_hotel_type,
        GROUP_CONCAT(DISTINCT hotel_name SEPARATOR ', ') AS visited_hotels
    FROM customer_hotel_bookings
    GROUP BY ID_customer, name
)
SELECT 
    ID_customer,
    name,
    preferred_hotel_type,
    visited_hotels
FROM customer_preferences
ORDER BY 
    CASE 
        WHEN preferred_hotel_type = 'Дешевый' THEN 1
        WHEN preferred_hotel_type = 'Средний' THEN 2
        WHEN preferred_hotel_type = 'Дорогой' THEN 3
    END ASC,
    name ASC;
