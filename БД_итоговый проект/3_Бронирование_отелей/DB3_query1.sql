/*
Определить, какие клиенты сделали более двух бронирований в разных отелях, и вывести информацию о каждом таком клиенте, включая его имя, электронную почту, телефон, общее количество бронирований, а также список отелей, в которых они бронировали номера (объединенные в одно поле через запятую). Также подсчитать среднюю длительность их пребывания (в днях) по всем бронированиям. Отсортировать результаты по количеству бронирований в порядке убывания.
*/

SELECT 
    c.ID_customer,
    c.name,
    c.email,
    c.phone,
    COUNT(b.ID_booking) AS total_bookings,
    GROUP_CONCAT(DISTINCT h.name SEPARATOR ', ') AS hotels_list,
    AVG(DATEDIFF(b.check_out_date, b.check_in_date)) AS avg_stay_duration
FROM Customer c
INNER JOIN Booking b ON c.ID_customer = b.ID_customer
INNER JOIN Room r ON b.ID_room = r.ID_room
INNER JOIN Hotel h ON r.ID_hotel = h.ID_hotel
GROUP BY c.ID_customer, c.name, c.email, c.phone
HAVING COUNT(DISTINCT r.ID_hotel) > 2
ORDER BY total_bookings DESC;
