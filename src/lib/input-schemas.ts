import { z } from 'zod';

const safeText = /^[\p{L}\p{N}\s.,'’()\-]*$/u;

export const facilitySearchSchema = z.object({
  query: z.string().trim().max(80).regex(safeText),
  district: z.string().trim().max(60).regex(safeText).default(''),
  type: z.enum(['all', 'Recycler', 'Refurbisher', 'Dismantler']),
  page: z.coerce.number().int().min(1).max(40).default(1),
  pageSize: z.coerce.number().int().min(1).max(25).default(10),
}).strict();

export const dashboardFilterSchema = z.object({
  metric: z.enum(['generated', 'combined', 'recycled', 'processed']),
  year: z.enum(['2023-24', '2024-25']).default('2024-25'),
  state: z.string().trim().max(60).regex(safeText).default(''),
}).strict();
