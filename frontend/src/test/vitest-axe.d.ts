import type { AxeMatchers } from 'vitest-axe/matchers';

declare module 'vitest' {
  // Vitest declara `Matchers<T>`; el aumento tiene que repetir el parámetro aunque no lo use.
  // eslint-disable-next-line @typescript-eslint/no-empty-object-type, @typescript-eslint/no-unused-vars
  interface Matchers<T = unknown> extends AxeMatchers {}
}
