#!/usr/bin/env bash

# doing cohort analysis for 30 days
i=1
while [ $i -le 30 ]
do
#cohort base on the day
cohort="day_$i"

#finding the date base on the number of day
the_date=$(psql -X -A -U hamid -d postgres -t -c "SELECT 
						    DISTINCT(sent_date)
						  FROM  free_tree
						  WHERE day = '$cohort';")

#the day of sending the first free_tree
ARR[0]=$(psql -X -A -U hamid -d postgres -t -c "SELECT 
						    COUNT(DISTINCT(user_id)) 
						  FROM free_tree
						  WHERE sent_date = '$the_date' AND user_id NOT IN
						  ( SELECT 
						     user_id
						    FROM free_tree
						    WHERE sent_date < '$the_date');")

#One to Seven days after sending first free_tree
# j is the number of days after the first day free_tree sent. we need to initialize it base on i.
j=$((i+1))
# k is the index of array which we use to store the 7 days of each row
k=1
end=$((i+7))

while [ $j -le $end ]
do
ARR[$k]=$(psql -X -A -U hamid -d postgres -t -c "SELECT 
						    COUNT(DISTINCT(user_id))
						 FROM free_tree
						 WHERE day = 'day_$j' AND user_id IN
						 (SELECT
						     user_id 
						 FROM free_tree
						 WHERE sent_date = '$the_date' AND user_id NOT IN
						 (SELECT 
						    user_id
						  FROM free_tree
						  WHERE sent_date < '$the_date'));")

j=$((j+1))
k=$((k+1))
done

#Insert first row to the cohort_analysis_free_tree table
psql -U hamid -d postgres -c "INSERT INTO cohort_analysis_free_tree
			      VALUES ('$cohort', ${ARR[0]}, ${ARR[1]}, ${ARR[2]}, ${ARR[3]}, ${ARR[4]}, ${ARR[5]}, ${ARR[6]}, ${ARR[7]});"

i=$((i+1))
done

