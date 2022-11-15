precision highp float;
uniform float t;
uniform vec2 resolution;
uniform sampler2D tex;

uniform sampler2D backBuffer;

// uniform sampler2D webcam;
// uniform vec2 videoResolution;
// uniform vec2 eyes[2];

varying vec2 uv;

// clang-format off
#pragma glslify: squareFrame = require("glsl-square-frame")
#pragma glslify: worley2D = require(glsl-worley/worley2D.glsl)
#pragma glslify: hsv2rgb = require('glsl-hsv2rgb')
#pragma glslify: luma = require(glsl-luma)
#pragma glslify: smin = require(glsl-smooth-min)
#pragma glslify: fbm3d = require('glsl-fractal-brownian-noise/3d')
#pragma glslify: noise = require('glsl-noise/simplex/3d')

// clang-format on
#define PI 3.14159265359

float random(in vec2 _st) {
  return fract(sin(dot(_st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}
vec2 hash(vec2 p) {
  p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
  return fract(sin(p) * 18.5453);
}

vec2 pixel = vec2(1.0) / resolution;
vec3 voronoi(in vec2 x) {
  vec2 n = floor(x);
  vec2 f = fract(x);

  vec3 m = vec3(8.0);
  float f2 = 80.0;
  for (int j = -1; j <= 1; j++)
    for (int i = -1; i <= 1; i++) {
      vec2 g = vec2(float(i), float(j));
      vec2 o = hash(n + g);
      // vec2  r = g - f + o;
      vec2 r = g - f + (0.5 + 0.5 * sin(6.2831 * o));
      float d = dot(r, r);
      if (d < m.x) {
        f2 = m.x;
        m = vec3(d, o);
      } else if (d < f2) {
        f2 = d;
      }
    }

  return vec3(sqrt(m.x), sqrt(f2), m.y + m.z);
}

void main() {
  vec2 pos = squareFrame(resolution);
  vec3 color;
  vec4 input_color = texture2D(tex, uv);

  // vec2 webcamCoord = (uv * 0.5 + vec2(0.5)) * resolution / videoResolution;
  // vec2 flipwcord = vec2(1.) - webcamCoord;
  // vec2 eye1 = eyes[0] / videoResolution;
  // vec2 eye2 = eyes[1] / videoResolution;
  vec2 textCoord = uv * 0.5 + vec2(0.5);
  // vec2 closeEye =
  // distance(eye1, flipwcord) < distance(eye2, flipwcord) ? eye1 : eye2;
  // vec2 suck = -2.0 * pixel * normalize(flipwcord - closeEye) *
  // random(uv + t * vec2(1.0));
  // *(0.5 + noise(vec3(uv * 10., t * 5.)));

  // vec3 webcamColor = texture2D(webcam, flipwcord).rgb * 0.95;
  // float ed = smin(distance(eye1, flipwcord), distance(eye2, flipwcord),
  // 0.01);

  // float ifd = distance(eye1, eye2);

  // float s = 0.1 * ifd * 4.;
  // vec2 mid = (eye1 + eye2) * 0.5;

  color = vec3(0.09, 0.089, 0.087);

  vec3 red = vec3(0.9, 0.25, 0.);
  vec3 yellow = vec3(0.85, 0.7, 0.);
  vec3 brown = vec3(0.4, 0.2, 0.1);
  // vec3 hue = red;
  float m = 100.;
  // pos += noise(vec3(pos * 15., 0.5)) * 0.01;
  float scale = 30. + (noise(vec3(pos * 0.5, t * 0.005)) * 2.);
  vec3 c = voronoi(scale * pos);

  // colorize
  vec3 col = red;
  float h = 0.;
  if (c.z < 1.2) {
    h = 1.;
  }
  if (c.z < 0.7) {
    h = 2.;
  }
  // col += c.x * 0.5;
  // vec3 col = hsv2rgb(vec3(hue, 0.4, 0.6));
  // 0.5 + 0.5 * cos(c.y * 6.2831 + vec3(0.0, 1.0, 2.0));
  // col *= clamp(1.0 - 0.4 * c.x * c.x, 0.0, 1.0);
  // col -= (1.0 - smoothstep(0.08, 0.09, c.x));
  // col = hsv2rgb(vec3(0.0, 1.0, 0.9));
  // if (c.z < 1.2) {
  //   col = hsv2rgb(vec3(0.1, 0.9, 0.9));
  // }
  // if (c.z < 0.7) {
  //   col = hsv2rgb(vec3(0.05, 0.9, 0.35));
  // }
  vec2 spos = pos + noise(vec3(pos * 2., 0.5 + t * 0.003)) * 0.4;

  float dilation =
      (scale / 30.) *
          (noise(vec3((spos * vec2(1.0, 2.)) + vec2(h * 5., t * 0.004) +
                          (vec2(0.3) * h),
                      t * 0.000)) -
           0.3) *
          1.3

      + 0.6 + ((sin((t * 0.01) + c.z * 0.4) + 0.2) * 0.5);
  dilation = 2.5 - input_color.r * 3.5;
  // dilation = input_color.r * 2.5;

  // dilation *= 1.0 -length(pos);
  // dilation = 1.0 - abs(length(webcamColor - col));
  // dilation += 1.0;
  float dd = (c.y - c.x) * (1.0 - c.x * 1.0);
  dd *= dilation;
  dd *= 1.5;
  float a = 1.0;
  col = hsv2rgb(vec3(0.8, 0.9 - (dilation * 0.1) - c.x * 0.2, 0.7));
  if (c.z < 1.2) {
    col = hsv2rgb(vec3(0.0, 0.9 - dilation * 0.1, 0.6));
  }
  if (c.z < 0.7) {
    col = hsv2rgb(vec3(0.6, 0.9 - dilation * 0.1, 0.95));
  }
  // if
  if (dd > 0.4 || c.x < 0.05) {
    color = col * 2.;
  } else {
    // color += col * 0.03;
    color = vec3(0.8, 0.7, 0.9);
    a = dd * 3.;
  }
  // color = (c.y - c.x) * col;
  // vec3 cel = cellular(pos * 5.);
  // color = hsv2rgb(

  //     vec3(cel.z / 9., 0.5, 0.5));
  // if (cel.x < 0.05) {
  //   color = vec3(0.);
  // }
  // vec3 col = hsv2rgb(vec3(t + floor(c.y * 1.5) / 5., 0.5, 0.5));

  // if (pos.x < -1. + pixel.x * 5.) {
  //   if (mod(t, 20.) > 18.) {
  //     // color = vec3(1., 1., 1.);
  //   } else {
  //     // color = vec3(0.2, 0.3, 0.4);
  //   }
  // } else {
  //   float weight = luma(webcamColor);

  //   float edge = luma(texture2D(webcam, flipwcord - pixel.x).rgb) -
  //                luma(texture2D(webcam, flipwcord + pixel.x).rgb);

  //   edge *= 3.;

  //   if (distance(mid.x, flipwcord.x) < (ifd * 1.0) &&
  //       mid.y - flipwcord.y < ifd * 1.8 && mid.y - flipwcord.y > ifd *
  //       -2.5)
  //       {
  //   } else {
  //     weight *= 0.8;
  //   }
  //   vec2 fall = 2. * pixel * vec2(1., 0) * (0.5 + random(vec2(uv.y, t)) *
  //   0.5) *
  //               (1. - weight);

  //   color = texture2D(backBuffer, textCoord - fall).rgb * 1.0;
  //   if (uv.y < 0.0) {
  //     // color =weight * vec3(1.0);
  //   }
  // }

  // if (ed < s) {
  // distance(mid,flipwcord)<0.2
  // if (distance(mid.x, flipwcord.x) < (ifd * 1.0) &&
  //     mid.y - flipwcord.y < ifd * 1.8 && mid.y - flipwcord.y > ifd * -2.5)
  //     {
  //   float weight = luma(webcamColor);
  //   // color = weight * vec3(1.0);
  // }
  // if (luma(webcamColor) <
  //  0.4) {
  // 0.5 + 0.2 * noise(vec3(uv * 200., t * 0.1))) {
  // color = vec3(1.);
  // color *= 0.25;
  // }
  gl_FragColor = vec4(color, a);
  // gl_FragColor = vec4(0.0);
}