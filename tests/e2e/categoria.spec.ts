// tests/e2e/categoria.spec.ts
import { test, expect } from '@playwright/test';
import { login } from './utils';

test('CRUD Categoria', async ({ page }) => {
  await login(page);

  // Navega até a collection Categoria
  await page.getByText('Categoria').click();

  // Criar novo item
  await page.getByRole('button', { name: /Create new entry/i }).click();
  await page.getByLabel('Name').fill('Categoria Teste');
  await page.getByRole('button', { name: /Save/i }).click();

  // Verifica se foi salvo
  await expect(page.getByText('Entry created')).toBeVisible();
  await expect(page.getByText('Categoria Teste')).toBeVisible();

  // Editar item
  await page.getByText('Categoria Teste').click();
  await page.getByLabel('Name').fill('Categoria Editada');
  await page.getByRole('button', { name: /Save/i }).click();
  await expect(page.getByText('Entry updated')).toBeVisible();

  // Deletar item
  await page.getByRole('button', { name: /Delete this entry/i }).click();
  await page.getByRole('button', { name: /Confirm/i }).click();
  await expect(page.locator('text=Categoria Editada')).not.toBeVisible();
});
