export type FinancialYear = '2023-24' | '2024-25';

export const nationalIndicators: Record<FinancialYear, { generatedMt: number; combinedManagementPercent: number }> = {
  '2023-24': { generatedMt: 1_254_286.55, combinedManagementPercent: 61.94 },
  '2024-25': { generatedMt: 1_397_955.59, combinedManagementPercent: 70.71 },
};

export const eprSnapshot = {
  recycledMt: 287_500,
  eprCertificatesMt: 118_600,
  registeredRecyclers: 386,
  asOf: '2026-03-05',
};

export const processedByState: Array<{ state: string; fy2023_24: number | null; fy2024_25: number | null }> = [
  { state: 'Andhra Pradesh', fy2023_24: 768.715, fy2024_25: 148.969 },
  { state: 'Assam', fy2023_24: null, fy2024_25: null },
  { state: 'Bihar', fy2023_24: null, fy2024_25: 6.0 },
  { state: 'Chhattisgarh', fy2023_24: 7370.845, fy2024_25: 3500.917 },
  { state: 'Gujarat', fy2023_24: 95776.688, fy2024_25: 76879.919 },
  { state: 'Haryana', fy2023_24: 110061.696, fy2024_25: 149653.641 },
  { state: 'Himachal Pradesh', fy2023_24: 159.679, fy2024_25: 169.271 },
  { state: 'Jharkhand', fy2023_24: null, fy2024_25: 129.1435 },
  { state: 'Karnataka', fy2023_24: 20910.603, fy2024_25: 16151.766 },
  { state: 'Kerala', fy2023_24: 5242.860, fy2024_25: 10079.632 },
  { state: 'Madhya Pradesh', fy2023_24: 5914.660, fy2024_25: 13014.042 },
  { state: 'Maharashtra', fy2023_24: 40664.231, fy2024_25: 52597.803 },
  { state: 'Punjab', fy2023_24: 65.493, fy2024_25: 2972.086 },
  { state: 'Rajasthan', fy2023_24: 24279.505, fy2024_25: 21345.480 },
  { state: 'Tamil Nadu', fy2023_24: 23203.636, fy2024_25: 16360.815 },
  { state: 'Telangana', fy2023_24: 65226.787, fy2024_25: 119187.979 },
  { state: 'Uttar Pradesh', fy2023_24: 236727.041, fy2024_25: 388160.231 },
  { state: 'Uttarakhand', fy2023_24: 134255.106, fy2024_25: 113562.255 },
  { state: 'West Bengal', fy2023_24: 6302.319, fy2024_25: 4559.529 },
];

export const dataSources = {
  national: {
    label: 'Ministry of Environment, Forest and Climate Change — Rajya Sabha reply',
    url: 'https://www.pib.gov.in/PressReleaseIframePage.aspx?PRID=2147876&lang=2&reg=48',
    published: '2025-07-24',
  },
  epr: {
    label: 'Ministry of Environment, Forest and Climate Change — Lok Sabha reply',
    url: 'https://www.pib.gov.in/PressReleasePage.aspx?PRID=2244104&lang=1&reg=1',
    published: '2026-03-23',
  },
};
