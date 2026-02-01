/// <reference path="../.astro/types.d.ts" />

interface ImportMeta {
  readonly glob: (pattern: string) => Record<string, () => Promise<any>>;
}