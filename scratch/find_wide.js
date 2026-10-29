
const all = document.querySelectorAll('*');
let widest = [];
all.forEach(el => {
    if (el.scrollWidth > 390 || el.offsetWidth > 390) {
        widest.push({tag: el.tagName, class: el.className, w: el.offsetWidth, sw: el.scrollWidth});
    }
});
console.log(JSON.stringify(widest.slice(0, 10)));
