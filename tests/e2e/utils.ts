// tests/e2e/utils.ts
import { Page } from '@playwright/test';

export async function login(page: Page) {
  await page.goto('http://localhost:1337/admin/auth/login');
  await page.getByLabel('Email').fill('admin@satc.edu.br');
  await page.getByLabel('Password').fill('welcomeToStrapi123');
  await page.getByRole('button', { name: /Sign in/i }).click();

  // Espera carregar o dashboard
  await page.waitForURL('http://localhost:1337/admin');
}
