ALTER TABLE public.facilities
  ADD COLUMN IF NOT EXISTS source_activity TEXT;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'facilities_source_activity_length'
      AND conrelid = 'public.facilities'::regclass
  ) THEN
    ALTER TABLE public.facilities
      ADD CONSTRAINT facilities_source_activity_length
      CHECK (
        source_activity IS NULL OR
        char_length(source_activity) BETWEEN 1 AND 500
      );
  END IF;
END;
$$;
