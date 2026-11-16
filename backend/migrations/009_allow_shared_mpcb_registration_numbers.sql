-- MPCB's outward registry currently repeats one registration number for two
-- different facilities. Keep registrations traceable without dropping either
-- facility; facility name is included in the import identity.
DROP INDEX IF EXISTS public.facilities_source_registration_no_uidx;

CREATE UNIQUE INDEX IF NOT EXISTS facilities_source_registration_name_uidx
  ON public.facilities (source_registration_no, name)
  WHERE source_registration_no IS NOT NULL;
