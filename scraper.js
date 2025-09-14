const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  await page.goto('https://www.pizzint.watch/');

  const selector = "body > div.min-h-screen.bg-black.text-white.font-mono > div.py-3.sm\\:py-4.lg\\:py-6.border-b.border-gray-800 > div > div > div.w-full.lg\\:flex-1.lg\\:max-w-2xl > div.bg-blue-900\\/80.border-blue-500.border-2.rounded-xl.p-3.sm\\:p-4.lg\\:p-5 > div > div.text-center.sm\\:text-right.flex-shrink-0 > div.text-2xl.sm\\:text-3xl.lg\\:text-4xl.font-bold.text-blue-400.leading-none";

  const element = await page.waitForSelector(selector);
  const pizzaIndex = await element.textContent();

  console.log(`The pizza index is: ${pizzaIndex}`);

  await browser.close();
})();
