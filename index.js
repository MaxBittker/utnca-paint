// const { setupOverlay } = require("regl-shader-error-overlay");
// setupOverlay();
let {getContext, drawLine} = require("./src/paint.js");

let paintElement = document.getElementById("paint");



let pixelRatio =  Math.min(window.devicePixelRatio, 1.5);
const regl = require("regl")({
  pixelRatio,
  extensions: ["OES_texture_float"],
  optionalExtensions: [
    // "oes_texture_float_linear",
    // "WEBGL_color_buffer_float"
    // "WEBGL_debug_renderer_info",
    // "WEBGL_debug_shaders"
  ],
});
let _viewportWidth = 1;
let _viewportHeight = 1;
function getColorAtPoint(x, y) {
  var stored_pixels = undoStack[undoStack.length - 1];

  let index = (_viewportWidth * (_viewportHeight - y) + x) * 4;
  let r = stored_pixels[index];
  let g = stored_pixels[index + 1];
  let b = stored_pixels[index + 2];
  let a = stored_pixels[index + 3];
  let color = [r, g, b, a];
  let value = 1;
  if (color[0] > 10) {
    value = -1;
  }
  return value;
}
let offscreenPointer = {
  texcoordX: -9,
  texcoordY: -9,
  prevTexcoordX: -10,
  prevTexcoordY: -10,
};
let shaders = require("./src/pack.shader.js");
let postShaders = require("./src/post.shader.js");
let setupHandlers = require("./src/touch.js");

let vert = shaders.vertex;
let frag = shaders.fragment;

var typedArrayTexture;
var doPop = false;
var undoStack = [];

let paintTexture = regl.texture(paintElement);


function pushState() {
  var gl = regl._gl;
  var stored_pixels = new Uint8Array(
    gl.drawingBufferWidth * gl.drawingBufferHeight * 4
  );
  gl.bindFramebuffer(
    gl.FRAMEBUFFER,
    densityDoubleFBO.read._framebuffer.framebuffer
  );
  // read the pixels
  gl.readPixels(
    0,
    0,
    gl.drawingBufferWidth,
    gl.drawingBufferHeight,
    gl.RGBA,
    gl.UNSIGNED_BYTE,
    stored_pixels
  );
  // Unbind the framebuffer
  gl.bindFramebuffer(gl.FRAMEBUFFER, null);
  undoStack.push(stored_pixels);
  if (undoStack.length > 30) {
    undoStack.shift();
  }
  console.log("stored pixels " + undoStack.length); // Uint8Array
}
function popState() {
  var gl = regl._gl;
  undoStack.pop();

  var stored_pixels = undoStack[undoStack.length - 1];
  typedArrayTexture = regl.texture({
    width: gl.drawingBufferWidth,
    height: gl.drawingBufferHeight,
    data: stored_pixels,
    // format: 'rgba32f',
    colorType:'float'
  });
  doPop = true;
}
let { getPointers, processQueue } = setupHandlers(
  regl._gl.canvas,
  pixelRatio,
  pushState,
  popState,
  getColorAtPoint
);

pointers = getPointers();
shaders.on("change", () => {
  console.log("update");
  vert = shaders.vertex;
  frag = shaders.fragment;
  let overlay = document.getElementById("regl-overlay-error");
  overlay && overlay.parentNode.removeChild(overlay);
});

function createDoubleFBO() {
  let fbo1 = regl.framebuffer({  
    // format: 'rgba32f',
  colorType: 'float'
});
  let fbo2 = regl.framebuffer({
    // format: 'rgba32f',
    colorType: 'float'
  });

  return {
    resize(w, h) {
      fbo1.resize(w, h);
      fbo2.resize(w, h);
    },
    get read() {
      return fbo1;
    },
    get write() {
      return fbo2;
    },
    swap() {
      let temp = fbo1;
      fbo1 = fbo2;
      fbo2 = temp;
    },
  };
}

const densityDoubleFBO = createDoubleFBO();

const drawFboBlurred = regl({
  frag: () => postShaders.fragment,
  vert: () => postShaders.vertex,

  attributes: {
    position: [-4, -4, 4, -4, 0, 4],
  },
  uniforms: {
    t: ({ tick }) => tick,
    tex: () => densityDoubleFBO.read,
    resolution: ({ viewportWidth, viewportHeight }) => [
      viewportWidth,
      viewportHeight,
    ],
    wRcp: ({ viewportWidth }) => 1.0 / viewportWidth,
    hRcp: ({ viewportHeight }) => 1.0 / viewportHeight,
    pixelRatio,
  },
  depth: { enable: false },
  count: 3,
});

let drawTriangle = regl({
  framebuffer: () => densityDoubleFBO.write,

  uniforms: {
    t: ({ tick }) => tick,

    force: regl.prop("force"),
    value: regl.prop("value"),
    point: (context, props) => [
      props.pointer.x / context.viewportWidth,
      1. - (props.pointer.y / context.viewportHeight),
    ],
    prevPoint: (context, props) => [
      props.pointer.prevX / context.viewportWidth,
     1 -  (props.pointer.prevY /context.viewportHeight),
    ],
    resolution: ({ viewportWidth, viewportHeight }) => [
      viewportWidth,
      viewportHeight,
    ],
    paintTexture: paintTexture,
    backBuffer: (_, props) =>
      props.pop ? typedArrayTexture : densityDoubleFBO.read,
  },

  frag: () => shaders.fragment,
  vert: () => shaders.vertex,
  attributes: {
    position: [
      [-1, 4],
      [-1, -1],
      [4, -1],
    ],
  },
  depth: { enable: false },

  count: 3,
});

regl.frame(function ({ viewportWidth, viewportHeight }) {
  let w = viewportWidth;
  let h = viewportHeight;
  // w = 512;
  // h = 288;
  densityDoubleFBO.resize(w, h);
  _viewportWidth = w;
  _viewportHeight = h;
  do {
    pointers.forEach((pointer) => {
      if (!pointer.down) {
        return;
      }

      drawLine(pointer);

      pointer.moved = false;

      drawTriangle({
        pointer,
        force: .5,
        pop: false,
        value: 1,
      });
      pointer.prevTexcoordX = pointer.texcoordX;
      pointer.prevTexcoordY = pointer.texcoordY;
      densityDoubleFBO.swap();
    });
  } while (processQueue() > 0);

  drawTriangle({
    pointer: offscreenPointer,
    force: 0.0,
    pop: doPop,
    value: 0,
  });
  doPop = false;
  if (undoStack.length == 0) {
    pushState();
  }
  let ctx = getContext();
  paintTexture.subimage(ctx);


  densityDoubleFBO.swap();

  drawFboBlurred();
});
