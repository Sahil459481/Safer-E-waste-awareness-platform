-- Read-only public facility search. The function is owned by a NOLOGIN role
-- with SELECT-only access to facilities and executes under that role's RLS.
CREATE OR REPLACE FUNCTION public.search_public_facilities(
  p_q TEXT,
  p_district TEXT,
  p_type TEXT,
  p_page INTEGER,
  p_page_size INTEGER
)
RETURNS TABLE (
  id UUID,
  name TEXT,
  address TEXT,
  district TEXT,
  facility_type TEXT,
  source_url TEXT,
  source_checked_on DATE,
  authorization_valid_until DATE,
  verified_on DATE,
  total_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
SET statement_timeout = '1500ms'
AS $$
DECLARE
  v_total BIGINT;
  v_q TEXT;
  v_district TEXT;
BEGIN
  IF p_q IS NULL OR char_length(p_q) > 80
     OR p_district IS NULL OR char_length(p_district) > 60
     OR p_type NOT IN ('all', 'Recycler', 'Refurbisher', 'Dismantler')
     OR p_page NOT BETWEEN 1 AND 40
     OR p_page_size NOT BETWEEN 1 AND 25 THEN
    RAISE EXCEPTION 'Invalid facility search parameters';
  END IF;

  -- Escape LIKE metacharacters so search input remains literal text.
  v_q := replace(replace(replace(p_q, '!', '!!'), '%', '!%'), '_', '!_');
  v_district := replace(replace(replace(p_district, '!', '!!'), '%', '!%'), '_', '!_');

  SELECT count(*)
    INTO v_total
    FROM public.facilities AS f
   WHERE f.publication_status = 'approved'
     AND f.authorization_valid_until >= CURRENT_DATE
     AND f.verified_on >= CURRENT_DATE - 180
     AND (p_type = 'all' OR f.facility_type = p_type)
     AND (p_district = '' OR f.district ILIKE '%' || v_district || '%' ESCAPE '!')
     AND (p_q = '' OR f.name ILIKE '%' || v_q || '%' ESCAPE '!'
                   OR f.address ILIKE '%' || v_q || '%' ESCAPE '!'
                   OR f.district ILIKE '%' || v_q || '%' ESCAPE '!');

  RETURN QUERY
  SELECT f.id, f.name, f.address, f.district, f.facility_type,
         f.source_url, f.source_checked_on, f.authorization_valid_until,
         f.verified_on, v_total
    FROM public.facilities AS f
   WHERE f.publication_status = 'approved'
     AND f.authorization_valid_until >= CURRENT_DATE
     AND f.verified_on >= CURRENT_DATE - 180
     AND (p_type = 'all' OR f.facility_type = p_type)
     AND (p_district = '' OR f.district ILIKE '%' || v_district || '%' ESCAPE '!')
     AND (p_q = '' OR f.name ILIKE '%' || v_q || '%' ESCAPE '!'
                   OR f.address ILIKE '%' || v_q || '%' ESCAPE '!'
                   OR f.district ILIKE '%' || v_q || '%' ESCAPE '!')
   ORDER BY f.district, f.name, f.id
   LIMIT p_page_size
  OFFSET ((p_page - 1) * p_page_size);
END;
$$;

-- The migration role needs SET ROLE only while transferring ownership. It is
-- revoked in this transaction immediately after the transfer.
GRANT facility_api_reader TO postgres WITH SET TRUE;
GRANT CREATE ON SCHEMA public TO facility_api_reader;
ALTER FUNCTION public.search_public_facilities(TEXT, TEXT, TEXT, INTEGER, INTEGER)
  OWNER TO facility_api_reader;
REVOKE CREATE ON SCHEMA public FROM facility_api_reader;
REVOKE facility_api_reader FROM postgres;
REVOKE ALL ON FUNCTION public.search_public_facilities(TEXT, TEXT, TEXT, INTEGER, INTEGER)
  FROM PUBLIC, anon, authenticated, facility_api_reader;
GRANT EXECUTE ON FUNCTION public.search_public_facilities(TEXT, TEXT, TEXT, INTEGER, INTEGER)
  TO service_role;
