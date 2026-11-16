import { withSupabase } from '@supabase/server';
import { z } from 'zod';

const paramsSchema = z.object({
  q: z.string().trim().max(80).regex(/^[\p{L}\p{N}\s.,'’()\-]*$/u).default(''),
  district: z.string().trim().max(60).regex(/^[\p{L}\p{N}\s.,'’()\-]*$/u).default(''),
  type: z.enum(['all', 'Recycler', 'Refurbisher', 'Dismantler']).default('all'),
  page: z.coerce.number().int().min(1).max(40).default(1),
  pageSize: z.coerce.number().int().min(1).max(25).default(10),
}).strict();

const localOrigins = ['http://localhost:4321', 'http://127.0.0.1:4321'];
const allowedOrigins = new Set([
  ...localOrigins,
  ...(Deno.env.get('ALLOWED_ORIGINS') ?? '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean),
]);

type Bucket = { startedAt: number; count: number };
const buckets = new Map<string, Bucket>();
const WINDOW_MS = 60_000;
const MAX_REQUESTS_PER_WINDOW = 45;
const MAX_BUCKETS = 10_000;

function requestOrigin(request: Request): string | null {
  const origin = request.headers.get('origin');
  return origin && allowedOrigins.has(origin) ? origin : null;
}

function responseHeaders(origin: string | null): Headers {
  const headers = new Headers({
    'Content-Type': 'application/json; charset=utf-8',
    'Cache-Control': 'no-store',
    'X-Content-Type-Options': 'nosniff',
    'Vary': 'Origin',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Access-Control-Allow-Headers': 'apikey, content-type',
    'Access-Control-Max-Age': '600',
  });
  if (origin) headers.set('Access-Control-Allow-Origin', origin);
  return headers;
}

function jsonResponse(body: unknown, status: number, origin: string | null): Response {
  return new Response(JSON.stringify(body), { status, headers: responseHeaders(origin) });
}

function tooManyRequests(request: Request): boolean {
  const now = Date.now();
  // Supabase's edge gateway supplies cf-connecting-ip. Do not trust arbitrary
  // x-forwarded-for values sent by clients. A shared fallback bucket still
  // bounds work if a trusted platform address is unavailable.
  const platformIp = request.headers.get('cf-connecting-ip')?.trim();
  const key = platformIp && platformIp.length <= 64 ? platformIp : 'unattributed';

  if (buckets.size > MAX_BUCKETS) {
    for (const [bucketKey, bucket] of buckets) {
      if (now - bucket.startedAt >= WINDOW_MS) buckets.delete(bucketKey);
    }
    if (buckets.size > MAX_BUCKETS) return true;
  }

  const bucket = buckets.get(key);
  if (!bucket || now - bucket.startedAt >= WINDOW_MS) {
    buckets.set(key, { startedAt: now, count: 1 });
    return false;
  }
  bucket.count += 1;
  return bucket.count > MAX_REQUESTS_PER_WINDOW;
}

function parseQuery(url: URL) {
  const allowedKeys = new Set(['q', 'district', 'type', 'page', 'pageSize']);
  for (const key of url.searchParams.keys()) {
    if (!allowedKeys.has(key) || url.searchParams.getAll(key).length !== 1) return null;
  }

  const parsed = paramsSchema.safeParse({
    q: url.searchParams.get('q') ?? '',
    district: url.searchParams.get('district') ?? '',
    type: url.searchParams.get('type') ?? 'all',
    page: url.searchParams.get('page') ?? '1',
    pageSize: url.searchParams.get('pageSize') ?? '10',
  });
  return parsed.success ? parsed.data : null;
}

const authenticatedHandler = withSupabase({ auth: 'publishable' }, async (request, ctx) => {
  const origin = requestOrigin(request);
  if (request.headers.has('origin') && !origin) {
    return jsonResponse({ message: 'Unable to fetch facilities' }, 403, null);
  }
  if (request.method !== 'GET') {
    return jsonResponse({ message: 'Method not allowed' }, 405, origin);
  }

  if (request.url.length > 2048) {
    return jsonResponse({ message: 'Invalid search parameters' }, 400, origin);
  }

  const params = parseQuery(new URL(request.url));
  if (!params) return jsonResponse({ message: 'Invalid search parameters' }, 400, origin);
  if (tooManyRequests(request)) {
    return jsonResponse({ message: 'Too many searches. Please try again shortly.' }, 429, origin);
  }

  try {
    const { data, error } = await ctx.supabaseAdmin.rpc('search_public_facilities', {
      p_q: params.q,
      p_district: params.district,
      p_type: params.type,
      p_page: params.page,
      p_page_size: params.pageSize,
    });
    if (error || !Array.isArray(data)) {
      return jsonResponse({ message: 'Unable to fetch facilities' }, 503, origin);
    }

    const rows = data as Array<Record<string, unknown>>;
    const total = rows.length > 0 && typeof rows[0].total_count === 'number'
      ? rows[0].total_count
      : rows.length > 0 && typeof rows[0].total_count === 'string'
        ? Number(rows[0].total_count)
        : 0;
    const items = rows.map((row) => ({
      name: row.name,
      address: row.address,
      district: row.district,
      type: row.facility_type,
      sourceUrl: row.source_url,
      sourceCheckedOn: row.source_checked_on,
      validUntil: row.authorization_valid_until,
      verifiedOn: row.verified_on,
    }));

    return jsonResponse({ items, total, page: params.page, pageSize: params.pageSize }, 200, origin);
  } catch {
    return jsonResponse({ message: 'Unable to fetch facilities' }, 503, origin);
  }
});

export default {
  fetch: async (request: Request) => {
    if (request.method === 'OPTIONS') {
      const origin = requestOrigin(request);
      if (request.headers.has('origin') && !origin) {
        return new Response(null, { status: 403, headers: responseHeaders(null) });
      }
      return new Response(null, { status: 204, headers: responseHeaders(origin) });
    }
    return authenticatedHandler(request);
  },
};
