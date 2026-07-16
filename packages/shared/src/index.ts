// Общие типы и модели — единственный источник правды для web/mobile/api.
export interface HealthStatus {
  ok: boolean;
  version: string;
}

export const APP_NAME = 'MN' as const;
