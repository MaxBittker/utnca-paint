// courtesy to PavelDoGreat/WebGL-Fluid-Simulation.
let undo = document.getElementById("undo");
function setupHandlers(
  canvas,
  pixelRatio,
  pushState,
  popState,
  getColorAtPoint
) {
  undo.addEventListener("click", (e) => {
    e.preventDefault();
    e.stopPropagation();
    popState();
  });
  undo.addEventListener("mouseup", (e) => {
    e.stopPropagation();
  });
  undo.addEventListener("touchend", (e) => {
    e.stopPropagation();
  });

  function scaleByPixelRatio(input) {
    return Math.floor(input * pixelRatio);
  }

  function pointerPrototype() {
    this.id = -1;
    this.texcoordX = 0;
    this.texcoordY = 0;
    this.prevTexcoordX = 0;
    this.prevTexcoordY = 0;
    this.deltaX = 0;
    this.deltaY = 0;
    this.down = false;
    this.moved = false;
    this.color = [30, 0, 300];
    this.force = 0.5;
    this.value = 1;
    this.missed = 0;
  }
  let pointers = [];
  let eventQueue = [];
  pointers.push(new pointerPrototype());

  function updatePointerDownData(pointer, id, posX, posY, value, force = 0.5) {
    pointer.id = id;
    pointer.down = true;
    pointer.moved = false;
    pointer.texcoordX = posX / canvas.width;
    pointer.texcoordY = 1.0 - posY / canvas.height;
    pointer.prevTexcoordX = pointer.texcoordX;
    pointer.prevTexcoordY = pointer.texcoordY;
    pointer.deltaX = 0;
    pointer.deltaY = 0;
    pointer.force = force;
    pointer.value = value;
    //   pointer.color = generateColor();
  }

  function updatePointerUpData(pointer) {
    pointer.down = false;
  }
  function queuePointerMoveData(pointerId, posX, posY, force = 0.5) {
    eventQueue.push({ pointerId, posX, posY, force });
  }
  function processQueue() {
    if (eventQueue.length == 0) {
      return 0;
    }
    let data = eventQueue.shift();
    updatePointerMoveData(data);
    return eventQueue.length;
  }

  function updatePointerMoveData({ pointerId, posX, posY, force = 0.5 }) {
    let pointer = pointers.find((p) => p.id == pointerId);
    // pointer.prevTexcoordX = pointer.texcoordX;
    // pointer.prevTexcoordY = pointer.texcoordY;
    pointer.texcoordX = posX / canvas.width;
    pointer.texcoordY = 1.0 - posY / canvas.height;
    // pointer.deltaX = correctDeltaX(pointer.texcoordX - pointer.prevTexcoordX);
    // pointer.deltaY = correctDeltaY(pointer.texcoordY - pointer.prevTexcoordY);
    pointer.moved =
      Math.abs(pointer.deltaX) > 0 || Math.abs(pointer.deltaY) > 0;
    pointer.force = force;
  }

  function correctDeltaX(delta) {
    let aspectRatio = canvas.width / canvas.height;
    if (aspectRatio < 1) delta *= aspectRatio;
    return delta;
  }

  function correctDeltaY(delta) {
    let aspectRatio = canvas.width / canvas.height;
    if (aspectRatio > 1) delta /= aspectRatio;
    return delta;
  }
  canvas.addEventListener("mousedown", (e) => {
    let posX = scaleByPixelRatio(e.offsetX);
    let posY = scaleByPixelRatio(e.offsetY);
    let pointer = pointers.find((p) => p.id == -1);
    if (pointer == null) pointer = new pointerPrototype();

    let value = getColorAtPoint(posX, posY);

    updatePointerDownData(pointer, -1, posX, posY, value);
  });

  canvas.addEventListener("mousemove", (e) => {
    let pointer = pointers[0];
    if (!pointer.down) return;
    let posX = scaleByPixelRatio(e.offsetX);
    let posY = scaleByPixelRatio(e.offsetY);
    queuePointerMoveData(pointer.id, posX, posY);
  });

  window.addEventListener("mouseup", () => {
    updatePointerUpData(pointers[0]);
    pushState();
  });

  canvas.addEventListener("touchstart", (e) => {
    e.preventDefault();
    const touches = e.targetTouches;
    while (touches.length >= pointers.length)
      pointers.push(new pointerPrototype());
    for (let i = 0; i < touches.length; i++) {
      let posX = scaleByPixelRatio(touches[i].pageX);
      let posY = scaleByPixelRatio(touches[i].pageY);
      // console.log(touches[i].force);
      let value = getColorAtPoint(posX, posY);

      updatePointerDownData(
        pointers[i + 1],
        touches[i].identifier,
        posX,
        posY,
        value,
        touches[i].force || 0.01
      );
    }
  });

  canvas.addEventListener(
    "touchmove",
    (e) => {
      e.preventDefault();
      const touches = e.targetTouches;
      for (let i = 0; i < touches.length; i++) {
        let pointer = pointers[i + 1];
        if (!pointer.down) continue;
        let posX = scaleByPixelRatio(touches[i].pageX);
        let posY = scaleByPixelRatio(touches[i].pageY);
        // console.log(touches[i].force);
        // pointer.missed += 1;
        queuePointerMoveData(pointer.id, posX, posY, touches[i].force);
        // updatePointerMoveData(pointer.id, posX, posY, touches[i].force);
      }
    },
    false
  );

  window.addEventListener("touchend", (e) => {
    const touches = e.changedTouches;
    for (let i = 0; i < touches.length; i++) {
      let pointer = pointers.find((p) => p.id == touches[i].identifier);
      if (pointer == null) continue;
      updatePointerUpData(pointer);
    }
    let nDown = pointers.filter((p) => p.down).length;

    if (nDown == 0) {
      console.log("touchend");
      pushState();
    }
  });

  return {
    getPointers: () => {
      console.log(pointers);
      return pointers;
    },
    processQueue,
  };
}

module.exports = setupHandlers;
