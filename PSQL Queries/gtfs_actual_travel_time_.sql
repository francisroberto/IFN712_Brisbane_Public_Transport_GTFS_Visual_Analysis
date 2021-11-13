SELECT *
FROM (
	Select *,
	lag(departure_time) over (PARTITION BY trip_id order by stop_sequence) as previous_departure,
	arrival_time - lag(departure_time) over (PARTITION BY trip_id order by stop_sequence) as actual_travel_time,
	TO_TIMESTAMP(timestamp) as timestamp_dt,
	TO_TIMESTAMP(departure_time) as departure_time_dt,
	TO_TIMESTAMP(arrival_time) as arrival_time_dt,
	lag(TO_TIMESTAMP(departure_time)) over (PARTITION BY trip_id order by stop_sequence) as previous_departure_dt
	FROM(
		Select *
		FROM(
			select 
			*,
			ROW_NUMBER() OVER (PARTITION BY trip_id, stop_sequence order by timestamp desc ) as row_number
			from
			(
				select 
				DISTINCT 
				trip_id,
				stop_sequence::DECIMAL as stop_sequence,
				timestamp::DECIMAL,
				CASE WHEN coalesce(departure_time, '') = '' THEN NULL ELSE departure_time::DECIMAL END as departure_time,
				CASE WHEN coalesce(arrival_time, '') = '' THEN NULL ELSE arrival_time::DECIMAL END as arrival_time,
				start_time,
				start_date, 
				route_id, stop_id,  arrival_delay,  arrival_uncertainty, departure_delay, departure_uncertainty, 
				schedule_relationship, id, shape_id

				from public.filtered_rt_shape_id_3330071
			
			) filtered_routes_unique
		
		) filtered_routes_unique
		WHERE row_number = 1
	)filtered_routes
) fr
inner join stop_times st on fr.stop_sequence = st.stop_sequence::DECIMAL and fr.trip_id = st.trip_id and  fr.stop_id::DECIMAL = st.stop_id::DECIMAL
inner join stops s on fr.stop_id::DECIMAL = (CASE WHEN s.stop_id~E'^\\d+$' THEN s.stop_id::DECIMAL ELSE 0 END)
inner join shapes_links sl on fr.shape_id = sl.shape_id