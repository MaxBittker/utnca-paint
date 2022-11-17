let canvas = document.getElementById("paint");
let buttons = document.getElementById("buttons");
let pixelRatio =  Math.min(window.devicePixelRatio, 1.5);

let activeColor = "#011"
const ruleN = 12;
for(var i=0; i<=ruleN; i++) {
    let nbtn = document.createElement("button");
    nbtn.addEventListener("click",(e)=>{
        activeColor = `#${parseInt(e.target.innerText).toString(16)}11`;
        console.log(activeColor)
        document.querySelectorAll("button").forEach((btn)=>{
            btn.classList.remove("active");
        })
        nbtn.classList.add("active");
    });
nbtn.innerText=i
    buttons.appendChild(nbtn);
}
// let target = document.getElementById("target");
let canvasRatio = 0.5 / pixelRatio;
canvas.width = window.innerWidth / 2;
canvas.height = window.innerHeight / 2;

let ctx = canvas.getContext("2d", { alpha: false });
// ctx.translate(canvas.width, 0);
// ctx.scale(-1, 1);

for(var i=0; i<=ruleN; i++) {

ctx.beginPath();
ctx.fillStyle = `#${i.toString(16)}11`;
console.log(ctx.fillStyle)
// ctx.fillRect(i*50,window.inner,50,50);
let w = Math.min(15, (window.innerWidth/4)/12.0);
ctx.arc(
  ((i+.5) * (w*2.15)),
  (window.innerHeight / 2 ) - (w+2.62),
  w,
  0,
  2 * Math.PI
);
ctx.fill();
}

function delta(pointer) {
  return [pointer.x - pointer.prevX, pointer.y - pointer.prevY];
}
function distance(pointer) {
  let [dx, dy] = delta(pointer);
  return Math.sqrt(dx * dx + dy * dy);
}
function drawLine(pointer) {
  let r = 25;

    // ctx.fillStyle = `#C5C`;
    // ctx.strokeStyle = `#C5C`;
  //    `rgb(${Math.random() * 250},${Math.random() * 250},${Math.random() * 250})`;
  ctx.lineWidth = r;

  let scaleX = 1;
  let scaleY = 1;
  //   console.log(Math.floor(distance(pointer)));
//   if (distance(pointer) < 5) {
//     return;
//   }
//   let [dx, dy] = delta(pointer);

    console.log(activeColor)
  ctx.strokeStyle = activeColor;

  ctx.fillStyle = ctx.strokeStyle;

  ctx.beginPath();
  ctx.moveTo(
    pointer.prevX * canvasRatio * scaleX,
    pointer.prevY * canvasRatio * scaleY
  );
  ctx.lineTo(
    pointer.x * canvasRatio * scaleX,
    pointer.y * canvasRatio * scaleY
  );
  ctx.stroke();
  ctx.beginPath();

  ctx.arc(
    pointer.x * canvasRatio * scaleX,
    pointer.y * canvasRatio * scaleY,
    r / 2,
    0,
    2 * Math.PI
  );
  ctx.fill();

  pointer.prevX = pointer.x;
  pointer.prevY = pointer.y;
}
function getContext() {
  return ctx;
}
module.exports = { getContext, drawLine };