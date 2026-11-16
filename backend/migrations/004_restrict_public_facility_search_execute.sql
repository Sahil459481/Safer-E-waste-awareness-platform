-- Ownership transfer can apply project default function privileges. Revoke
-- those defaults explicitly and leave only the Edge Function's server role.
REVOKE EXECUTE ON FUNCTION public.search_public_facilities(TEXT, TEXT, TEXT, INTEGER, INTEGER)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.search_public_facilities(TEXT, TEXT, TEXT, INTEGER, INTEGER)
  TO service_role;
