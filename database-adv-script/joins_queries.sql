SELECT
    b.booking_id,
    b.user_id
FROM Booking AS b
    INNER JOIN  User
AS u
ON b.user_id = u.user_id;


SELECT
    p.property_id,
    p.name,
    r.review_id,
    r.rating,
    r.comment,
    r.created_at
FROM Property AS p
    LEFT JOIN Review AS r
    ON r.property_id = p.property_id
ORDER BY p.property_id, r.created_at;


SELECT
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS user_name,
    b.booking_id,
    b.property_id,
    b.created_at
FROM User AS u
    LEFT JOIN Booking AS b
    ON b.user_id = u.user_id;
