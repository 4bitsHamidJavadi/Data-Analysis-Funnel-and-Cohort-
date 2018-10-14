SELECT
  reg_users.my_date,
  reg_users.device_type,
  reg_users.source,
  reg_users.funnel1,
  free_users.funnel2,
  super_users.funnel3,
  paid_users.funnel4
FROM
--REGISTRATIONS-NUMBER OF USERS(FUNNEL1)
  (SELECT 
    registrations.reg_date AS my_date,
    registrations.device_type,
    registrations.source,
    COUNT(*) AS funnel1
  FROM registrations
  GROUP BY my_date, device_type, source
  ORDER BY my_date) AS reg_users

LEFT JOIN
--NUMBER OF USERS - SENT A FREE_TREE(FUNNEL2)
  (SELECT 
    free_tree.sent_date AS my_date,
    registrations.device_type,
    registrations.source,
    COUNT(DISTINCT(free_tree.user_id)) AS funnel2
  FROM  free_tree
  JOIN  registrations
  ON  free_tree.user_id = registrations.user_id
  GROUP BY my_date, device_type, source
  ORDER BY my_date) AS free_users

ON reg_users.my_date = free_users.my_date
AND reg_users.device_type = free_users.device_type
AND reg_users.source = free_users.source

LEFT JOIN
--NUMBER OF USERS - SENT A SUPER_TREE(FUNNEL3)
  (SELECT 
    super_tree.sent_date AS my_date,
    registrations.device_type,
    registrations.source,
    COUNT(DISTINCT(super_tree.user_id)) AS funnel3
  FROM  super_tree
  JOIN  registrations
  ON  super_tree.user_id = registrations.user_id
  GROUP BY my_date, device_type, source
  ORDER BY my_date) AS super_users

ON reg_users.my_date = super_users.my_date
AND reg_users.device_type = super_users.device_type
AND reg_users.source = super_users.source 

LEFT JOIN

--NUMBER OF USERS - PAID SUPER_TREE(FUNNEL4)
  (SELECT 
    super_tree.sent_date AS my_date,
    registrations.device_type,
    registrations.source,
    COUNT(DISTINCT(super_tree.user_id)) AS funnel4
  FROM  super_tree
  JOIN  registrations
  ON  super_tree.user_id = registrations.user_id
  WHERE super_tree.user_id IN 
    (SELECT
      user_id
     FROM
      (SELECT 
        user_id,
        COUNT(*) AS total_sent_super
       FROM super_tree
       GROUP BY user_id
       HAVING COUNT(*) > 1) AS users_sent_more_than_one_super)
  GROUP BY my_date, device_type, source
  ORDER BY my_date) AS paid_users
  
ON reg_users.my_date = paid_users.my_date
AND reg_users.device_type = paid_users.device_type
AND reg_users.source = paid_users.source;
