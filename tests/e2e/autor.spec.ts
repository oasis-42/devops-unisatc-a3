// tests/e2e/autor.spec.ts
import { test, expect } from '@playwright/test';
import { login } from './utils';

test('CRUD Autor', async ({ page }) => {
  await login(page);

  // Navegar até a collection Autor
  await page.getByText('Autor').click();

  // Criar novo autor
  await page.getByRole('button', { name: /Create new entry/i }).click();
  await page.getByLabel('Name').fill('Autor Teste');
  await page.getByRole('button', { name: /Save/i }).click();

  // Verifica se foi salvo
  await expect(page.getByText('Entry created')).toBeVisible();
  await expect(page.getByText('Autor Teste')).toBeVisible();

  // Editar autor
  await page.getByText('Autor Teste').click();
  await page.getByLabel('Name').fill('Autor Editado');
  await page.getByRole('button', { name: /Save/i }).click();
  await expect(page.getByText('Entry updated')).toBeVisible();

  // Deletar autor
  await page.getByRole('button', { name: /Delete this entry/i }).click();
  await page.getByRole('button', { name: /Confirm/i }).click();
  await expect(page.locator('text=Autor Editado')).not.toBeVisible();
});
