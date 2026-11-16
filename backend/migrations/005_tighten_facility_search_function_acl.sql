-- Make the migration connection assume the dedicated function-owner role
-- while tightening the ACL. This ensures the REVOKE executes as the owner.
GRANT facility_api_reader TO postgres WITH SET TRUE;
SET ROLE facility_api_reader;
REVOKE EXECUTE ON FUNCTION public.search_public_facilities(TEXT, TEXT, TEXT, INTEGER, INTEGER)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.search_public_facilities(TEXT, TEXT, TEXT, INTEGER, INTEGER)
  TO service_role;
RESET ROLE;
REVOKE facility_api_reader FROM postgres;
