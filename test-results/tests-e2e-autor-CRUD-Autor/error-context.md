# Test info

- Name: CRUD Autor
- Location: C:\Users\yuri.200819\devops-unisatc-a3\tests\e2e\autor.spec.ts:5:5

# Error details

```
Error: locator.click: Test timeout of 30000ms exceeded.
Call log:
  - waiting for getByRole('button', { name: /Sign in/i })
    - waiting for" http://localhost:1337/admin/auth/login" navigation to finish...

    at login (C:\Users\yuri.200819\devops-unisatc-a3\tests\e2e\utils.ts:8:56)
    at C:\Users\yuri.200819\devops-unisatc-a3\tests\e2e\autor.spec.ts:6:3
```

# Test source

```ts
   1 | // tests/e2e/utils.ts
   2 | import { Page } from '@playwright/test';
   3 |
   4 | export async function login(page: Page) {
   5 |   await page.goto('http://localhost:1337/admin/auth/login');
   6 |   await page.getByLabel('Email').fill('admin@satc.edu.br');
   7 |   await page.getByLabel('Password').fill('welcomeToStrapi123');
>  8 |   await page.getByRole('button', { name: /Sign in/i }).click();
     |                                                        ^ Error: locator.click: Test timeout of 30000ms exceeded.
   9 |
  10 |   // Espera carregar o dashboard
  11 |   await page.waitForURL('http://localhost:1337/admin');
  12 | }
  13 |
```