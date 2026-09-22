// Se ejecuta antes de cada archivo de test (vite.config.ts → test.setupFiles).
import '@testing-library/jest-dom/vitest';
import { expect } from 'vitest';
import * as axeMatchers from 'vitest-axe/matchers';

// vitest-axe no registra sus matchers solo: se agregan acá (los tipos, en vitest-axe.d.ts).
expect.extend(axeMatchers);
