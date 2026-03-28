/*
Необходимо провести анализ клиентов, которые сделали более двух бронирований в разных отелях и потратили более 500 долларов на свои бронирования. Для этого:

Определить клиентов, которые сделали более двух бронирований и забронировали номера в более чем одном отеле. Вывести для каждого такого клиента следующие данные: ID_customer, имя, общее количество бронирований, общее количество уникальных отелей, в которых они бронировали номера, и общую сумму, потраченную на бронирования.
Также определить клиентов, которые потратили более 500 долларов на бронирования, и вывести для них ID_customer, имя, общую сумму, потраченную на бронирования, и общее количество бронирований.
В результате объединить данные из первых двух пунктов, чтобы получить список клиентов, которые соответствуют условиям обоих запросов. Отобразить поля: ID_customer, имя, общее количество бронирований, общую сумму, потраченную на бронирования, и общее количество уникальных отелей.
Результаты отсортировать по общей сумме, потраченной клиентами, в порядке возрастания.
*/

SELECT 
    c.ID_customer,
    c.name,
    COUNT(b.ID_booking) AS total_bookings,
    SUM(r.price * DATEDIFF(b.check_out_date, b.check_in_date)) AS total_spent,
    COUNT(DISTINCT h.ID_hotel) AS unique_hotels
FROM Customer c
INNER JOIN Booking b ON c.ID_customer = b.ID_customer
INNER JOIN Room r ON b.ID_room = r.ID_room
INNER JOIN Hotel h ON r.ID_hotel = h.ID_hotel
GROUP BY c.ID_customer, c.name
HAVING COUNT(b.ID_booking) > 2
    AND COUNT(DISTINCT h.ID_hotel) > 1
    AND SUM(r.price * DATEDIFF(b.check_out_date, b.check_in_date)) > 500
ORDER BY total_spent ASC;
