import { test, expect } from '@playwright/test';

test('ge web scraper', async ({ page }) => {

    try {

        await page.goto('https://ge.globo.com/futebol/brasileirao-serie-a/',
            {
                waitUntil: 'domcontentloaded',
                timeout: 60000
            });

        const times = await page.locator('strong[itemprop="name"]');
        const quantidadeTimes = await times.count();
        const pontos = await page.locator('.classificacao__pontos--ponto');
        for (let i = 0; i < quantidadeTimes; i++) {
            const time = times.nth(i);
            const ponto = pontos.nth(i);
            console.log(await time.textContent() + ' - ' + await ponto.textContent());

        }

    } catch (err) {
        console.error('Erro:', err);
        throw err;
    }



})