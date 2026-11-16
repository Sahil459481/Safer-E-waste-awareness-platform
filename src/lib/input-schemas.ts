import { z } from 'zod';

const safeText = /^[\p{L}\p{N}\s.,'’()\-]*$/u;

export const facilitySearchSchema = z.object({
  query: z.string().trim().max(80).regex(safeText),
  district: z.string().trim().max(60).regex(safeText).default(''),
  type: z.enum(['all', 'Recycler', 'Refurbisher', 'Dismantler']),
  page: z.coerce.number().int().min(1).max(40).default(1),
  pageSize: z.coerce.number().int().min(1).max(25).default(10),
}).strict();

const facilityRecordSchema = z.object({
  name: z.string().min(2).max(200),
  address: z.string().min(5).max(500),
  district: z.string().min(2).max(80),
  type: z.enum(['Recycler', 'Refurbisher', 'Dismantler']),
  sourceUrl: z.string().url().max(500),
  sourceCheckedOn: z.iso.date(),
  validUntil: z.iso.date(),
  verifiedOn: z.iso.date(),
}).strict();

export const facilitySearchResponseSchema = z.object({
  items: z.array(facilityRecordSchema).max(25),
  total: z.number().int().min(0).max(1_000_000),
  page: z.number().int().min(1).max(40),
  pageSize: z.number().int().min(1).max(25),
}).strict();

export const dashboardFilterSchema = z.object({
  metric: z.enum(['generated', 'combined', 'recycled', 'processed']),
  year: z.enum(['2023-24', '2024-25']).default('2024-25'),
  state: z.string().trim().max(60).regex(safeText).default(''),
}).strict();
