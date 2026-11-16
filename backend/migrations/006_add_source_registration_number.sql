ALTER TABLE public.facilities
  ADD COLUMN IF NOT EXISTS source_registration_no TEXT;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'facilities_source_registration_no_length'
      AND conrelid = 'public.facilities'::regclass
  ) THEN
    ALTER TABLE public.facilities
      ADD CONSTRAINT facilities_source_registration_no_length
      CHECK (
        source_registration_no IS NULL OR
        char_length(source_registration_no) BETWEEN 6 AND 120
      );
  END IF;
END;
$$;

CREATE UNIQUE INDEX IF NOT EXISTS facilities_source_registration_no_uidx
  ON public.facilities (source_registration_no)
  WHERE source_registration_no IS NOT NULL;
