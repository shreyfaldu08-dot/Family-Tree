
const puppeteer = require('puppeteer');
(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.setViewport({width: 390, height: 844});
  await page.goto('http://localhost:8085');
  await page.waitForTimeout(3000);
  const info = await page.evaluate(() => ({
    scrollWidth: document.body.scrollWidth,
    clientWidth: document.body.clientWidth,
    windowWidth: window.innerWidth
  }));
  console.log(JSON.stringify(info));
  await browser.close();
})();
