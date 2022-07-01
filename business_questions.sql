##################### Magist Business Questions ################

######## In relation to the products:

# What categories of tech products does Magist have? 

SELECT DISTINCT
    product_category_name_english
FROM
    products p
        JOIN
    product_category_name_translation t ON p.product_category_name = t.product_category_name
GROUP BY product_category_name_english
ORDER BY product_category_name_english;

-- Eniac ("Apple compatible accessories") tech categories: audio, computers, computers_accessories, electronics, signaling_and_security, tablets_printing_image, telephony, watches_gifts

# How many products of these tech categories have been sold (within the time window of the database snapshot)? --> 21979 products

/* Group by tech categories

SELECT 
    pt.product_category_name_english, COUNT(*)
FROM
    product_category_name_translation pt
        JOIN
    products p ON p.product_category_name = pt.product_category_name
        JOIN
    order_items oi ON oi.product_id = p.product_id
WHERE
    pt.product_category_name_english IN ('audio' , 'computers',
        'computers_accessories',
        'electronics',
        'signaling_and_security',
        'tablets_printing_image',
        'telephony',
        'watches_gifts')
GROUP BY pt.product_category_name_english
order by pt.product_category_name_english; */


SELECT 
    COUNT(*)
FROM
    product_category_name_translation pt
        JOIN
    products p ON p.product_category_name = pt.product_category_name
        JOIN
    order_items oi ON oi.product_id = p.product_id
WHERE
    pt.product_category_name_english IN ('audio' , 'computers',
        'computers_accessories',
        'electronics',
        'signaling_and_security',
        'tablets_printing_image',
        'telephony',
        'watches_gifts');


# What percentage does that represent from the overall number of products sold? 
SELECT 
    COUNT(*)
FROM
    product_category_name_translation pt
        JOIN
    products p ON p.product_category_name = pt.product_category_name
        JOIN
    order_items oi ON oi.product_id = p.product_id;

-- overall products sold: 112650
-- percentage of tech products sold: 21979/112650*100=19,51%

# What’s the average price of the products being sold? --> 120.65
SELECT 
    avg(price)
FROM
    order_items;
    
    
# What is the average price of tech products being sold? --> 132.11

SELECT 
    avg(oi.price)
FROM
    product_category_name_translation pt
        JOIN
    products p ON p.product_category_name = pt.product_category_name
        JOIN
    order_items oi ON oi.product_id = p.product_id
WHERE
    pt.product_category_name_english IN ('audio' , 'computers',
        'computers_accessories',
        'electronics',
        'signaling_and_security',
        'tablets_printing_image',
        'telephony',
        'watches_gifts');


# Are expensive tech products popular? (TIP: Look at the function CASE WHEN to accomplish this task.)

SELECT 
    CASE
        WHEN oi.price >= 540 THEN 'expensive'
        ELSE 'cheap'
    END AS price_category,
    COUNT(*)
FROM
    product_category_name_translation pt
        JOIN
    products p ON p.product_category_name = pt.product_category_name
        JOIN
    order_items oi ON oi.product_id = p.product_id
WHERE
    pt.product_category_name_english IN ('audio' , 'computers',
        'computers_accessories',
        'electronics',
        'signaling_and_security',
        'tablets_printing_image',
        'telephony',
        'watches_gifts')
GROUP BY price_category;

-- 20997 cheap tech products, 982 expensive tech products

######## In relation to the sellers:

# How many months of data are included in the magist database? --> 25 months
select month(order_purchase_timestamp) as month_, year(order_purchase_timestamp) as year_, count(*) over () as number_of_months
FROM
   orders
group by 1, 2
order by 2, 1;

# How many sellers are there? --> 3095 sellers
SELECT 
    COUNT(distinct seller_id)
FROM
    sellers;

# How many Tech sellers are there? --> 549 tech sellers
SELECT 
    count(distinct s.seller_id)
FROM
    product_category_name_translation pt
        JOIN
    products p ON p.product_category_name = pt.product_category_name
        JOIN
    order_items oi ON oi.product_id = p.product_id
    join 
    sellers s on oi.seller_id = s.seller_id
WHERE
    pt.product_category_name_english IN ('audio' , 'computers',
        'computers_accessories',
        'electronics',
        'signaling_and_security',
        'tablets_printing_image',
        'telephony',
        'watches_gifts');

# What percentage of overall sellers are Tech sellers?

-- 549/3095*100=17,73%

# What is the total amount earned by all sellers? --> 13.494.400,74 €

SELECT 
    ROUND(SUM(oi.price), 2)
FROM
    orders o
        JOIN
    order_items oi ON o.order_id = oi.order_id
WHERE
    o.order_status NOT IN ('canceled' , 'unavailable');

# What is the total amount earned by all Tech sellers? --> 2.884.598,77 €

WITH tech_product_categories AS (
SELECT product_category_name, product_category_name_english
FROM product_category_name_translation
WHERE product_category_name_english IN ('audio' , 'computers',
        'computers_accessories',
        'electronics',
        'signaling_and_security',
        'tablets_printing_image',
        'telephony',
        'watches_gifts'))
SELECT round(sum(oi.price),2)
FROM orders o 
	JOIN order_items oi
		ON o.order_id = oi.order_id
	join products p on oi.product_id = p.product_id
    join tech_product_categories t on t.product_category_name = p.product_category_name
WHERE o.order_status not in ("canceled", "unavailable");

# Can you work out the average monthly income of all sellers? 
-- total amount / number of months / number of sellers = 13.494.400,74 € / 25 months / 3095 sellers = 174,40 € per month and seller


# Can you work out the average monthly income of Tech sellers?
-- total amount of tech sellers / number of months = 2.884.598,77 € / 25 months / 549 tech sellers = 210,17 € per month and tech seller


######## In relation to the delivery time:

# What’s the average time between the order being placed and the product being delivered? --> 12.5 days
SELECT 
    AVG(DATEDIFF(order_delivered_customer_date,
            order_purchase_timestamp))
FROM
    orders
WHERE
    order_status NOT IN ('canceled' , 'unavailable');

# How many orders are delivered on time vs orders delivered with a delay? --> 89805 on time, 6673 delayed
SELECT 
    COUNT(*) AS numbers,
    CASE
        WHEN
            DATEDIFF(order_delivered_customer_date,
                    order_estimated_delivery_date) <= 0
        THEN
            'on time'
        ELSE 'delayed'
    END AS delivery
FROM
    orders
WHERE
    order_status = "delivered"
GROUP BY delivery;

# Is there any pattern for delayed orders, e.g. big products being delayed more often?
SELECT AVG(datediff(o.order_delivered_customer_date, o.order_estimated_delivery_date)) AS avg_delayed_delivery,
		AVG(p.product_weight_g) , AVG(p.product_height_cm),
        AVG(p.product_length_cm), AVG(p.product_width_cm)
FROM orders o
	JOIN order_items oi
		ON o.order_id = oi.order_id
	JOIN products p
		ON oi.product_id = p.product_id 
WHERE datediff(o.order_delivered_customer_date , o.order_estimated_delivery_date) > 0 
		AND o.order_status = "delivered";

SELECT AVG(datediff(o.order_delivered_customer_date , o.order_estimated_delivery_date)) AS avg_early_deliverd, 
		AVG(p.product_weight_g) , AVG(p.product_height_cm) , 
        AVG(p.product_length_cm), AVG(p.product_width_cm)
FROM orders o
	JOIN order_items oi
		ON o.order_id = oi.order_id
	JOIN products p
		ON oi.product_id = p.product_id 
WHERE datediff(o.order_delivered_customer_date , o.order_estimated_delivery_date) <= 0 
		AND o.order_status = "delivered";

SELECT AVG(datediff(o.order_delivered_customer_date , o.order_estimated_delivery_date)) AS avg_all_delivered,
		AVG(p.product_weight_g) , AVG(p.product_height_cm) ,
		AVG(p.product_length_cm), AVG(p.product_width_cm)
FROM orders o
	JOIN order_items oi
		ON o.order_id = oi.order_id
	JOIN products p
		ON oi.product_id = p.product_id 
WHERE o.order_status = "delivered";

SELECT 
	CASE
		WHEN p.product_weight_g >= 2500 THEN 'very_high_weight'
        WHEN p.product_weight_g >= 2000 THEN 'high_weight'
        WHEN p.product_weight_g >= 1500 THEN 'medium_weight'
        WHEN p.product_weight_g >= 1000 THEN 'low_weight'
        WHEN p.product_weight_g >= 500 THEN 'very_low_weight'
        ELSE 'Light_weight'
	END AS weight_range,
		AVG(datediff(o.order_delivered_customer_date , o.order_estimated_delivery_date)) AS avg_delay_delivered
FROM orders o
	JOIN order_items oi
		ON o.order_id = oi.order_id
	JOIN products p
		ON oi.product_id = p.product_id 
WHERE datediff(o.order_delivered_customer_date , o.order_estimated_delivery_date) > 0
		AND o.order_status = "delivered"
GROUP BY weight_range;

######## MAIN QUESTIONS TO ANSWER ######## 

# Is Magist a good fit for high-end tech products? No
# Are orders delivered on time? No
