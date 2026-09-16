import { render, screen } from '@testing-library/react';
import { axe } from 'vitest-axe';

import { App } from './App.tsx';

describe('App', () => {
  it('muestra el título del sistema', () => {
    render(<App />);
    expect(screen.getByRole('heading', { level: 1, name: 'Aulero UNViMe' })).toBeInTheDocument();
  });

  it('no tiene violaciones de accesibilidad detectables', async () => {
    const { container } = render(<App />);
    expect(await axe(container)).toHaveNoViolations();
  });
});
