
precision highp float;
varying vec2 uv;
uniform float t;

uniform sampler2D tex;
uniform float wRcp, hRcp;
uniform vec2 resolution;
#define R int(0)

// clang-format off
// clang-format on
const float PHI = 1.61803398874989484820459; // Φ = Golden Ratio 

float gold_noise(in vec2 xy, in float seed)
{
    return fract(tan(distance(xy*PHI, xy)*seed)*xy.x);
}

// checkerboard noise
vec2 stepnoise(vec2 p, float size) {
  p += 10.0;
  float x = floor(p.x / size) * size;
  float y = floor(p.y / size) * size;

  x = fract(x * 0.1) + 1.0 + x * 0.0002;
  y = fract(y * 0.1) + 1.0 + y * 0.0003;

  float a = fract(1.0 / (0.000001 * x * y + 0.00001));
  a = fract(1.0 / (0.000001234 * a + 0.00001));

  float b = fract(1.0 / (0.000002 * (x * y + x) + 0.00001));
  b = fract(1.0 / (0.0000235 * b + 0.00001));

  return vec2(a, b);
}
float tent(float f) { return 1.0 - abs(fract(f) - 0.5) * 2.0; }

#define SEED1 (1.705)
#define SEED2 (1.379)
#define DMUL 8.12235325

float poly(float a, float b, float c, float ta, float tb, float tc) {
  return (a * ta + b * tb + c * tc) / (ta + tb + tc);
}
float mask(vec2 p) {
  vec2 r = stepnoise(p, 5.5) - 0.5;
  p[0] += r[0] * DMUL;
  p[1] += r[1] * DMUL;

  float f = fract(p[0] * SEED1 + p[1] / (SEED1 + 0.15555)) * 1.03;
  return poly(pow(f, 150.0), f * f, f, 1.0, 0.0, 1.3);
}

float s(float x, float y, vec2 uv) {
  vec4 clr = texture2D(tex, (vec2(x, y) / resolution.xy) + uv);
  float f = clr[0] * 0.3 + clr[1] * 0.6 + clr[1] * 0.1;

  return f;
}

mat3 mynormalize(mat3 mat) {
  float sum = mat[0][0] + mat[0][1] + mat[0][2] + mat[1][0] + mat[1][1] +
              mat[1][2] + mat[2][0] + mat[2][1] + mat[2][2];
  return mat / sum;
}
// out vec4 fragColor, in vec2 fragCoord
void main() {

  vec2 uv2 = uv.xy;
  // / resolution.x;

  vec2 r = stepnoise(uv * resolution, 6.0);

  vec4 clr = texture2D(tex, uv);
  float slide = tent(-0.0 * t + uv2[0] * 0.5);

  float f = clr[0] * 0.3 + clr[1] * 0.6 + clr[1] * 0.1;
float f0 =f ;
  // sharpen input.  this is necassary for stochastic
  // ordered dither methods.
  vec2 uv3 = uv.xy;
  // / resolution.xy;
  float d = 0.5;
  mat3 mat = mat3(vec3(d, d, d), vec3(d, 2.0, d), vec3(d, d, d));

  float f1 = s(0.0, 0.0, uv3 * resolution);
  mat = mynormalize(mat) * 1.0;
  f = s(-1.0, -1.0, uv3) * mat[0][0] + s(-1.0, 0.0, uv3) * mat[0][1] +
      s(-1.0, 1.0, uv3) * mat[0][2] + s(0.0, -1.0, uv3) * mat[1][0] +
      s(0.0, 0.0, uv3) * mat[1][1] + s(0.0, 1.0, uv3) * mat[1][2] +
      s(1.0, -1.0, uv3) * mat[2][0] + s(1.0, 0.0, uv3) * mat[2][1] +
      s(1.0, 1.0, uv3) * mat[2][2];

  f = (f - s(0.0, 0.0, uv3));
  f *= 40.0;
  f = f1 - f;

  float c = mask(uv * resolution);

  if (uv2.y < 0.05) {
    c = float(slide >= c);
  } else {
    c = float(f >= c);
  }

  vec2 xy = (uv-vec2(1.0)) * resolution ;
  float time = t/ ((1. - f)*1000.);

vec3 noise = vec3(gold_noise(xy, fract(time * f0)+1.0), // r
                gold_noise(xy, fract(time * f0)+2.0), // g
                gold_noise(xy, fract(time * f0)+3.0));



  gl_FragColor = vec4(noise, 1.);

}
