var f = new Function("alert('I was able to evaluate a Function')");
document.documentElement.addEventListener('SVGLoad', f, false);
