select s.shape_id,
            shape_pt_lat,
            shape_pt_lon,
            s.shape_pt_sequence,
            (s.shape_pt_sequence::INTEGER/10000)::INTEGER as link,
            lead(shape_pt_lat) over (PARTITION BY s.shape_id order by s.shape_pt_sequence::DECIMAL) as destination_lat,
            lead(shape_pt_lon) over (PARTITION BY s.shape_id order by s.shape_pt_sequence::DECIMAL) as destination_lon
            from shapes s
            order by s.shape_id