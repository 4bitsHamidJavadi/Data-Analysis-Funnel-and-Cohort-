#!/usr/bin/env bash

#Creating table for paid users per day
i=1
while [ $i -le 273 ]
do
cohort="day_$i"

#finding the date base on the number of day
the_date=$(psql -X -A -U hamid -d postgres -t -c "SELECT 
						    DISTINCT(sent_date)
						  FROM  free_tree
						  WHERE day = '$cohort';")

psql -U hamid -d postgres -c "INSERT INTO paid_users_date
			    (SELECT
				 date_table.sent_date,
				 date_table.user_id,
				 data_table.total_sent_till_this_day
			     FROM
				(SELECT
				    sent_date, 
				    user_id 
				 FROM super_tree
				 WHERE sent_date = '$the_date'
				 GROUP BY sent_date, user_id) AS date_table
			     JOIN
			     (SELECT 
				 user_id,
				 COUNT(*) AS total_sent_till_this_day
			      FROM super_tree
			      WHERE user_id IN 
			      (SELECT DISTINCT(user_id) FROM super_tree
			      WHERE sent_date = '$the_date') AND 
			      sent_date <= '$the_date'
			      GROUP BY user_id
			      HAVING COUNT(*) > 1) AS data_table
			    ON date_table.user_id = data_table.user_id);"
i=$((i+1))
done

