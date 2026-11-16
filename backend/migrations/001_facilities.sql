CREATE TABLE IF NOT EXISTS facilities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL CHECK (char_length(name) BETWEEN 2 AND 200),
  address TEXT NOT NULL CHECK (char_length(address) BETWEEN 5 AND 500),
  district TEXT NOT NULL CHECK (char_length(district) BETWEEN 2 AND 80),
  facility_type TEXT NOT NULL CHECK (facility_type IN ('Recycler', 'Refurbisher', 'Dismantler')),
  source_url TEXT NOT NULL CHECK (
    source_url LIKE 'https://www.mpcb.gov.in/%' OR
    source_url LIKE 'https://mpcb.gov.in/%' OR
    source_url LIKE 'https://www.ecmpcb.in/%' OR
    source_url LIKE 'https://ecmpcb.in/%'
  ),
  source_document_date DATE NOT NULL,
  source_checked_on DATE NOT NULL,
  authorization_valid_until DATE,
  verified_on DATE,
  verified_by TEXT CHECK (verified_by IS NULL OR char_length(verified_by) <= 120),
  publication_status TEXT NOT NULL DEFAULT 'candidate'
    CHECK (publication_status IN ('candidate', 'approved', 'rejected')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (
    publication_status <> 'approved' OR
    (verified_on IS NOT NULL AND verified_by IS NOT NULL AND authorization_valid_until IS NOT NULL)
  )
);

CREATE INDEX IF NOT EXISTS facilities_public_search_idx
  ON facilities (district, facility_type, name)
  WHERE publication_status = 'approved';

CREATE INDEX IF NOT EXISTS facilities_public_validity_idx
  ON facilities (authorization_valid_until, verified_on)
  WHERE publication_status = 'approved';

-- A non-login capability role allows deployment to create a separate secret-managed login later.
DO $$ BEGIN
  CREATE ROLE facility_api_reader NOLOGIN;
EXCEPTION WHEN duplicate_object THEN
  NULL;
END $$;

REVOKE ALL ON TABLE facilities FROM PUBLIC, anon, authenticated, service_role;
GRANT USAGE ON SCHEMA public TO facility_api_reader;
GRANT SELECT ON TABLE facilities TO facility_api_reader;

ALTER TABLE facilities ENABLE ROW LEVEL SECURITY;
CREATE POLICY facility_api_reader_public_rows
  ON facilities FOR SELECT TO facility_api_reader
  USING (
    publication_status = 'approved'
    AND authorization_valid_until >= CURRENT_DATE
    AND verified_on >= CURRENT_DATE - INTERVAL '180 days'
  );

-- Private append-style audit trail for database-side facility record changes.
CREATE TABLE IF NOT EXISTS facility_review_audit (
  event_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  facility_id UUID NOT NULL,
  action TEXT NOT NULL CHECK (action IN ('created', 'updated')),
  previous_status TEXT,
  resulting_status TEXT NOT NULL,
  actor_role NAME NOT NULL DEFAULT current_user,
  happened_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

REVOKE ALL ON TABLE facility_review_audit FROM PUBLIC, anon, authenticated, service_role, facility_api_reader;

CREATE OR REPLACE FUNCTION public.audit_facility_record_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = pg_catalog, public
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO public.facility_review_audit (facility_id, action, previous_status, resulting_status)
    VALUES (NEW.id, 'created', NULL, NEW.publication_status);
    RETURN NEW;
  END IF;

  IF ROW(NEW.name, NEW.address, NEW.district, NEW.facility_type, NEW.source_url,
         NEW.source_document_date, NEW.source_checked_on, NEW.authorization_valid_until,
         NEW.verified_on, NEW.verified_by, NEW.publication_status)
     IS DISTINCT FROM
     ROW(OLD.name, OLD.address, OLD.district, OLD.facility_type, OLD.source_url,
         OLD.source_document_date, OLD.source_checked_on, OLD.authorization_valid_until,
         OLD.verified_on, OLD.verified_by, OLD.publication_status) THEN
    INSERT INTO public.facility_review_audit (facility_id, action, previous_status, resulting_status)
    VALUES (NEW.id, 'updated', OLD.publication_status, NEW.publication_status);
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER facilities_change_audit
  AFTER INSERT OR UPDATE ON facilities
  FOR EACH ROW EXECUTE FUNCTION public.audit_facility_record_change();
