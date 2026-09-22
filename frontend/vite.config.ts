/// <reference types="vitest/config" />
import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [react()],
  server: {
    // La API corre en 8000; el frontend le pega por /api sin CORS en desarrollo.
    proxy: { '/api': { target: 'http://localhost:8000', rewrite: (p) => p.replace(/^\/api/, '') } },
  },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test/setup.ts'],
    // Un único worker evita timeouts al iniciar el pool de forks en Windows.
    pool: 'threads',
    maxWorkers: 1,
    fileParallelism: false,
  },
});
