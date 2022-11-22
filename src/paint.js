let canvas = document.getElementById("paint");
let hudC = document.getElementById("hud");
let buttons = document.getElementById("buttons");
let pixelRatio = Math.min(window.devicePixelRatio, 1.5);

let activeColor = "#010000";
const ruleN = 19;
for (var i = 0; i <= ruleN; i++) {
  let nbtn = document.createElement("button");
  if(i == 1){
    nbtn.classList.add("active")
  }
  nbtn.addEventListener("click", (e) => {
    let ii = parseInt(e.target.innerText);
   
    activeColor = `#${ii.toString(16).padStart(2, "0")}1111`;
    console.log(activeColor);
    document.querySelectorAll("button").forEach((btn) => {
      btn.classList.remove("active");
    });
    nbtn.classList.add("active");
  });
  nbtn.innerText = i;
  buttons.appendChild(nbtn);
    
}
// let target = document.getElementById("target");
let canvasRatio = 0.5 / pixelRatio;
canvas.width = window.innerWidth / 2;
canvas.height = window.innerHeight / 2;

hudC.width = window.innerWidth;
hudC.height = window.innerHeight;

let ctx = canvas.getContext("2d", { alpha: false });
let hudCtx = hudC.getContext("2d");
hudCtx.clearRect(0, 0, hudC.width, hudC.height);

// ctx.translate(canvas.width, 0);
// ctx.scale(-1, 1);

for (var i = 0; i <= ruleN; i++) {
  ctx.beginPath();
  ctx.fillStyle = `#${i.toString(16).padStart(2, "0")}1111`;
  // ctx.fillRect(i*50,window.inner,50,50);
  // let w = Math.min(16.2, window.innerWidth / 4 / 12.0);
  let w =16.2;
  // ctx.fillRect(((i) * (w*2)),(window.innerHeight / 2 ) - (w*2),w*2,w*2);
  // ctx.fillRect(((i) * (w*2)),0,w*2,(window.innerHeight / 2 ) );
  ctx.arc(
    (i + 0.5) * (w * 2),
    window.innerHeight / 2 - (w + 0.62),
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
let scaleX = 1;
let scaleY = 1;
let r = 45;

document.addEventListener("wheel",(e)=>{
  e.preventDefault()
  console.log(e.deltaY);
  r += e.deltaY*.1;
  r = Math.max(5,r);
  r = Math.min(100,r);
  drawHover(lastP);
  console.log(r);
})
function drawLine(pointer) {
  // ctx.fillStyle = `#C5C`;
  // ctx.strokeStyle = `#C5C`;
  //    `rgb(${Math.random() * 250},${Math.random() * 250},${Math.random() * 250})`;
  ctx.lineWidth = r;

  //   console.log(Math.floor(distance(pointer)));
  //   if (distance(pointer) < 5) {
  //     return;
  //   }
  //   let [dx, dy] = delta(pointer);
  pointer.y = Math.min(
    pointer.y,
    (window.innerHeight - 40) * canvasRatio * scaleY * 4
  );
  // console.log(activeColor)
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
let lastP = null;
function drawHover(pointer) {
  lastP = pointer;
  hudCtx.clearRect(0, 0, hudC.width, hudC.height);
  hudCtx.strokeStyle = "#fff9";
  console.log(pointer.x);
  hudCtx.beginPath();
  hudCtx.arc(
    pointer.x * canvasRatio * scaleX * 2,
    pointer.y * canvasRatio * scaleY * 2,
    r,
    0,
    2 * Math.PI
  );
  hudCtx.stroke();
}

function getContext() {
  return ctx;
}
module.exports = { getContext, drawLine, drawHover };
