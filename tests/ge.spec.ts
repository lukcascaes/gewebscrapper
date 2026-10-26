import { test, expect } from '@playwright/test';

test('ge web scraper', async ({ page }) => {
    await page.goto('https://ge.globo.com/futebol/brasileirao-serie-a/',
        {
            waitUntil: 'domcontentloaded',
            timeout: 60000
        });

    // locator() não acessa a página, só descreve onde procurar. Por isso não leva await.
    const times = page.locator('strong[itemprop="name"]');
    const pontos = page.locator('.classificacao__pontos--ponto');
    const posicao = page.locator('.classificacao__equipes--posicao');
    const titulo = page.getByRole('link', { name: 'atalho editoria Brasileirão S' }).first();

    console.log(await titulo.textContent());

    // Espera (e tenta de novo) até a tabela ter os 20 times. Se não chegar a 20, o teste falha.
    await expect(times).toHaveCount(20);

    // allTextContents() lê todos os textos de uma vez e devolve um array de strings.
    const nomesTimes = await times.allTextContents();
    const pontosTimes = await pontos.allTextContents();
    const posicoesTimes = await posicao.allTextContents();

    const tabela: { posicao: number; time: string; pontos: number }[] = [];

    for (let i = 0; i < nomesTimes.length; i++) {
        tabela.push({
            posicao: Number(posicoesTimes[i]),
            time: nomesTimes[i].trim(),
            pontos: Number(pontosTimes[i])
        });
    }

    console.table(tabela);

    expect(tabela).toHaveLength(20);
    expect(tabela[0].posicao).toBe(1);
});
