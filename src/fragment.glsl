precision highp float;
uniform float t;
uniform vec2 resolution;
uniform sampler2D backBuffer;
uniform vec2 point;
uniform vec2 prevPoint;
// uniform float aspectRatio;
uniform float force;
uniform float value;
// uniform float radius;

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

float sdSegment(in vec2 p, in vec2 a, in vec2 b, in float R) {
  float h = min(1.0, max(0.0, dot(p - a, b - a) / dot(b - a, b - a)));
  return length(p - a - (b - a) * h) - R;
}
void main() {
  float aspectRatio = resolution.x / resolution.y;
  vec2 pixel = vec2(1.0) / resolution;
  vec2 scale = vec2(aspectRatio, 1.0);
  vec2 vUv = uv * 0.5 + vec2(0.5);

  vec2 p = vUv - point.xy;

  p.x *= aspectRatio;


  float seg = sdSegment(vUv * scale, point.xy * scale, prevPoint.xy * scale,
                        0.05 * (0.2 + force * 0.5));

  seg = 1.0 - (200. * seg);
  seg = max(0., seg);
  vec3 splat = vec3(1.0) * seg;
  vec3 base = clamp(texture2D(backBuffer, vUv).xyz,0.,1.0);


  float n = 0.8 + noise(vec3(vUv * 500., t * 0.5)) * 0.3;


  float fill =  (1.0 - luma(base*value)) * luma(splat) * n * 0.9;
  gl_FragColor = vec4(base + fill * vec3(value), 1.0);
 
}