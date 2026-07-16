import type { HealthStatus } from '@mn/shared';

export async function getHealth(baseUrl: string): Promise<HealthStatus> {
  const res = await fetch(`${baseUrl}/health`);
  return (await res.json()) as HealthStatus;
}
