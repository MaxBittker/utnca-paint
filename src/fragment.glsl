precision highp float;
uniform float t;
uniform vec2 resolution;
uniform sampler2D backBuffer;
uniform vec2 point;
uniform vec2 prevPoint;
uniform float force;
uniform float value;


varying vec2 uv;

// clang-format off
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
  vec3 base = clamp(texture2D(backBuffer, vUv).xyz,0.,1.0);

  float n = 0.8;
  float fill = seg;
  gl_FragColor = vec4(base + fill * value, 1.0);
 
}