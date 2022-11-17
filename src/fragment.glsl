precision highp float;
uniform float t;
uniform vec2 resolution;
uniform sampler2D backBuffer;
uniform sampler2D paintTexture;
uniform vec2 point;
uniform vec2 prevPoint;
uniform float force;
uniform float value;

varying vec2 uv;

// clang-format off
// clang-format on

float Scale = 1.0;

void init(vec2 resolution) {
  float d = max(resolution.x, resolution.y);
  Scale = ceil(d / 1024.0);
}

vec4 rule0(vec4 s, vec4 p) {
  return 1e-3 * (vec4(24, 12, -8, -2) +
                 mat4(-101, 5, 9, -34, -45, -150, 1, -23, -26, 97, -33, 6, 21,
                      26, 33, -42) *
                     s +
                 mat4(-17, -75, -91, 15, 30, 82, 98, -9, -59, -58, -47, -13,
                      -31, -7, 2, -16) *
                     p +
                 mat4(5, 27, 15, -17, 37, 45, 80, -52, -19, -47, -72, 78, 61,
                      18, 24, -4) *
                     abs(s) +
                 mat4(33, 6, 13, 14, -40, -20, -30, -6, -21, 8, 17, -13, -31, 3,
                      10, -10) *
                     abs(p));
}
vec4 rule1(vec4 s, vec4 p) {
  return 1e-3 *
         (vec4(-15, -2, -9, 24) +
          mat4(-66, -52, -1, 16, 21, -88, 1, 58, -21, 36, -91, -42, 12, 15, 7,
               -42) *
              s +
          mat4(38, -75, -41, -62, 13, 22, 23, 35, 11, 15, 16, 34, 0, 0, 0, 0) *
              p +
          mat4(-57, 42, 5, -44, -3, -39, -76, -76, -4, -29, -36, -56, 87, -5,
               61, 37) *
              abs(s) +
          mat4(-25, -6, -18, -5, -8, 13, 10, 11, -4, 6, 4, -3, 0, -1, 1, -2) *
              abs(p));
}
vec4 rule2(vec4 s, vec4 p) {
  return 1e-3 *
         (vec4(4, -10, -27, 18) +
          mat4(-67, 1, 2, 44, -13, -59, 4, 30, -1, 16, -57, 9, -10, -4, -2,
               -41) *
              s +
          mat4(19, -18, -1, 8, -4, 35, 8, 0, -4, -4, -1, 0, 34, 31, 21, -25) *
              p +
          mat4(4, 13, 18, -57, -79, -22, -25, 71, -12, -11, 24, 27, -17, -8, -7,
               6) *
              abs(s) +
          mat4(11, 10, 4, 0, 4, 1, 2, 7, -26, -33, -15, -3, 22, 27, 20, -34) *
              abs(p));
}
vec4 rule3(vec4 s, vec4 p) {
  return 1e-03 *
         (vec4(-23, -7, -51, -24) +
          mat4(-85, 16, -29, -6, 50, -143, 38, -89, 9, 6, -55, 2, -3, 12, 11,
               -53) *
              s +
          mat4(-10, -25, -17, 7, 19, 32, 22, -15, 0, 0, 1, 0, -14, -14, -7,
               -32) *
              p +
          mat4(9, 24, 0, 42, -23, -21, -21, 47, -16, -3, 36, -4, 5, -13, -11,
               49) *
              abs(s) +
          mat4(13, 1, 7, 1, -17, 2, -5, -4, -10, 0, -2, 0, 14, 7, 8, 10) *
              abs(p));
}
// vec4 rule3(vec4 s, vec4 p) {
//   return 1e-3 * (vec4(-17, 17, 0, -3) +
//                  mat4(-102, 25, 28, -21, -15, -32, 62, -47, 37, 31, -68, -27,
//                       -3, 18, 13, -78) *
//                      s +
//                  mat4(62, 1, 34, 18, -70, 29, -10, -10, 1, 0, 1, 1, -29, -19,
//                       -26, -65) *
//                      p +
//                  mat4(-66, -1, -38, -26, 108, -17, 66, -62, 22, -21, 10, -51,
//                       -16, -16, -16, 13) *
//                      abs(s) +
//                  mat4(20, -17, 4, 40, 1, 46, 24, -14, 9, -6, 0, 23, -5, -36,
//                       -32, -13) *
//                      abs(p));
// }
vec4 rule4(vec4 s, vec4 p) {
  return 1e-3 *
         (vec4(-1, 1, -5, -19) +
          mat4(-42, -2, 14, -10, 6, -35, 6, -23, 16, 19, -37, -10, 17, 24, 16,
               -33) *
              s +
          mat4(19, 1, 6, 0, -18, 3, -2, 1, 1, 0, 1, -3, 25, 24, 26, 35) * p +
          mat4(7, -10, -7, 1, -2, 10, 2, 3, -11, -12, 3, -28, 1, 4, 1, -21) *
              abs(s) +
          mat4(1, 1, 2, 5, 1, 2, -1, 0, -13, -17, -15, -4, 20, 22, 26, 40) *
              abs(p));
}
vec4 rule5(vec4 s, vec4 p) {
  return 1e-3 *
         (vec4(9, 6, 23, -23) +
          mat4(-173, 36, -6, 8, 32, -111, 0, 65, 7, 26, -120, -61, 70, 26, 63,
               -34) *
              s +
          mat4(-57, -85, -63, -1, 53, 80, 57, 11, 16, 20, 17, 30, 0, 0, 0, -1) *
              p +
          mat4(84, -9, 69, 29, 16, -31, -44, -11, 21, 69, 0, -4, -80, -20, -58,
               0) *
              abs(s) +
          mat4(11, 19, 39, -2, -16, -13, -30, 0, 0, -8, -11, 20, 1, -2, -10,
               4) *
              abs(p));
}
vec4 rule6(vec4 s, vec4 p) {
  return 1e-3 *
         (vec4(19, -8, 5, 10) +
          mat4(-61, 25, 22, -19, 11, -35, 40, -16, 14, 9, -71, -18, 22, 18, 28,
               -60) *
              s +
          mat4(31, -10, 21, 14, -34, 16, -19, -20, -7, -17, -8, 8, -21, -9, -8,
               -50) *
              p +
          mat4(10, 50, 56, -47, -44, -38, -96, 29, -27, 27, 9, 3, 5, 22, 11,
               3) *
              abs(s) +
          mat4(0, 2, 6, -2, -8, -3, -11, -5, -6, 2, 4, -20, 0, -4, -8, 24) *
              abs(p));
}
vec4 rule7(vec4 s, vec4 p) {
  return 1e-3 *
         (vec4(-27, 2, 0, -4) +
          mat4(-40, 12, 2, 10, -9, -60, 32, 30, 13, -2, -85, 13, -26, -40, -29,
               -68) *
              s +
          mat4(43, 18, 38, 34, -11, 38, 1, 22, -8, -12, -9, -4, 27, 36, 30,
               68) *
              p +
          mat4(20, -19, -8, -9, 17, 2, 21, 138, 13, 51, 1, -41, -17, -24, -16,
               -33) *
              abs(s) +
          mat4(8, 8, 7, -21, 3, 21, 13, 5, 24, 29, 21, -27, 3, -1, 3, 12) *
              abs(p));
}
vec4 rule8(vec4 s, vec4 p) {
  return 1e-03 *
         (vec4(6, -6, -19, -5) +
          mat4(-68, 14, -51, -3, 37, -104, -37, 21, -5, 12, -43, 0, 27, 20, 35,
               -68) *
              s +
          mat4(-12, -33, -30, -19, 28, 34, 21, 19, -7, -46, -56, 2, 32, 13, 5,
               -24) *
              p +
          mat4(18, 29, 39, 58, -81, -19, -5, -24, 16, -8, 12, -39, -37, -22,
               -21, 21) *
              abs(s) +
          mat4(13, 8, -1, -12, -4, -1, -1, 9, -4, -18, -28, 8, -18, 5, 3, 45) *
              abs(p));
}
vec4 rule9(vec4 s, vec4 p) {
  return 1e-03 *
         (vec4(-12, 28, 7, 4) +
          mat4(-30, -21, -52, 31, 9, -32, 22, -30, 27, 29, -60, -8, 41, 15, -15,
               -60) *
              s +
          mat4(78, -105, -55, 3, -11, 57, 31, 22, 9, 8, 17, 28, 0, 0, 0, -1) *
              p +
          mat4(-46, -8, -22, 28, 61, -6, 141, -4, 21, -23, -42, 0, -103, -8, -4,
               -40) *
              abs(s) +
          mat4(9, -92, -51, 12, 30, 4, 0, 7, 1, 12, 6, -36, 7, 17, 9, 16) *
              abs(p));
}
vec4 rule10X(vec4 s, vec4 p) {
  return 1e-03 * (vec4(45, -17, 6, 20) +
                  mat4(-32, 26, 7, 15, 56, -88, 52, -31, -45, 61, -47, -2, -7,
                       4, -2, -85) *
                      s +
                  mat4(61, -2, -12, -19, -70, 9, 17, 27, 1, 8, -18, 17, 28, -33,
                       -2, -70) *
                      p +
                  mat4(-5, 50, 7, 59, -114, -62, -33, -49, 12, 78, 14, -10, 0,
                       9, 0, 31) *
                      abs(s) +
                  mat4(14, 4, -1, -8, -10, -5, 1, 21, -15, -2, -23, -2, -40,
                       -18, 10, -28) *
                      abs(p));
}
vec4 rule10(vec4 s, vec4 p) {
  return 1e-03 *
         (vec4(15, -30, -47, 61) +
          mat4(-69, 42, 46, -8, 45, -88, -14, -3, -13, -6, -64, 4, -7, -8, -6,
               -30) *
              s +
          mat4(24, 4, 18, 15, -12, -1, -12, -14, 6, -2, -2, 4, 0, -19, -15,
               34) *
              p +
          mat4(-5, 52, 25, -185, -122, -1, 49, -26, -2, -45, 26, -15, 4, -10,
               -25, 5) *
              abs(s) +
          mat4(13, -7, -3, 28, -4, 0, -1, -10, 11, 18, 8, 0, 4, 23, 17, -29) *
              abs(p));
}

vec4 rule11(vec4 s, vec4 p) {
  return 1e-03 *
         (vec4(-2, -3, 0, 0) +
          mat4(-52, 28, 9, 13, -7, -53, 40, -56, 20, 5, -92, -6, 12, 9, 8,
               -20) *
              s +
          mat4(16, -20, 5, 22, -12, 25, -1, -24, 0, 0, 0, 0, -78, -34, -57,
               -65) *
              p +
          mat4(17, 3, -26, 46, -43, -11, -4, 26, 3, -29, -19, -68, -9, -12, -8,
               12) *
              abs(s) +
          mat4(-4, 3, -5, 1, -1, -5, 3, -5, 1, 1, -2, -1, 53, 76, 63, -2) *
              abs(p));
}

vec4 rule12(vec4 s, vec4 p) {
  return 1e-03 * (vec4(-41, -24, -11, 3) +
                  mat4(-62, -13, 2, -5, 21, -73, 0, 1, -14, 10, -92, -1, -7, 0,
                       -1, -51) *
                      s +
                  mat4(37, 19, 28, 22, -25, -7, -15, -18, 10, 9, 9, 7, -29, -27,
                       -24, -34) *
                      p +
                  mat4(55, 1, -22, 29, -14, -28, -41, 56, 4, 26, 36, -60, -3, 5,
                       8, 15) *
                      abs(s) +
                  mat4(-8, -42, -25, 13, 11, 33, 23, -13, -3, -2, -1, -2, 6, 24,
                       23, -24) *
                      abs(p));
}

const float ruleN = 13.0;

vec4 hash43(vec3 p) {
  vec4 p4 = fract(vec4(p.xyzx) * vec4(.1031, .1030, .0973, .1099));
  p4 += dot(p4, p4.wzxy + 33.33);
  return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}

vec4 R(float x, float y) { return texture2D(backBuffer, vec2(x, y)); }

float wrap(float x, float a, float b) {
  return x;
  return mod(x - a, b - a) + a;
}

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

  init(resolution);
  vec2 fragCoord = (uv * 0.5 + vec2(0.5)) * resolution;
  vec2 iResolution = resolution;
  vec2 dp = 1.0 / iResolution.xy;
  vec2 pos = (uv * 0.5 + vec2(0.5));
  vec4 paint = texture2D(paintTexture, vec2(vUv.x, 1.0 - vUv.y));

  // if (any(greaterThan(pos*Scale, vec2(1.0))))
  // discard;

  const float tileSize = 212.0;

  vec2 sz = 1.0 / vec2(Scale);
  float x = pos.x, y = pos.y;
  vec2 lo = dp * floor(fragCoord / tileSize) * tileSize;
  vec2 hi = min(lo + tileSize * dp, sz);
  float l = wrap(x - dp.x, lo.x, hi.x), r = wrap(x + dp.x, lo.x, hi.x);
  float u = wrap(y - dp.y, lo.y, hi.y), d = wrap(y + dp.y, lo.y, hi.y);
  vec4 s = R(x, y);
  // if (s == vec4(0, 0, 0, 0) || iMouse.z>0.0 &&
  // length(iMouse.xy/Scale-fragCoord)<20.0) {
  //   fragColor = hash43(vec3(fragCoord, iFrame))-0.5;
  //   return;
  // }
  vec4 p = R(l, u) * vec4(1, 1, -1, 1) + R(x, u) * vec4(2, 2, 0, 2) +
           R(r, u) * vec4(1, 1, 1, 1) + R(l, y) * vec4(2, 2, -2, 0) +
           s * vec4(-12, -12, 0, 0) + R(r, y) * vec4(2, 2, 2, 0) +
           R(l, d) * vec4(1, 1, -1, -1) + R(x, d) * vec4(2, 2, 0, -2) +
           R(r, d) * vec4(1, 1, 1, -1);

  vec4 ds;
  vec2 rulePos = floor((pos.xy / dp) / tileSize);
  // float ri = mod(rulePos.x + rulePos.y * 4., ruleN);

  float ri = (paint.r * 16.) - 0.1;
  if (ri < 0.0) {
    ds = vec4(-s * .01) + (hash43(vec3(fragCoord, t)) - 0.5) * 0.05;
  } else if (ri < 1.0) {
    ds = rule1(s, p);
  } else if (ri < 2.0) {
    ds = rule2(s, p);
  } else if (ri < 3.0) {
    ds = rule2(s, p);
  } else if (ri < 4.0) {
    ds = rule3(s, p);
  } else if (ri < 5.0) {
    ds = rule4(s, p);
  } else if (ri < 6.0) {
    ds = rule5(s, p);
  } else if (ri < 7.0) {
    ds = rule6(s, p);
  } else if (ri < 8.0) {
    ds = rule7(s, p);
  } else if (ri < 9.0) {
    ds = rule8(s, p);
  } else if (ri < 10.0) {
    ds = rule9(s, p);
  } else if (ri < 11.0) {
    ds = rule10(s, p);
  } else if (ri < 12.0) {
    ds = rule11(s, p);
  } else if (ri < 13.0) {
    ds = rule12(s, p);
  }

  vec4 ncao = clamp(s + ds, -1.5, 1.5);

  vec2 npos = vUv - point.xy;
  npos.x *= aspectRatio;
  float seg = sdSegment(vUv * scale, point.xy * scale, prevPoint.xy * scale,
                        0.05 * (.15));
  seg = 1.0 - (50. * seg);
  seg = max(0., seg);
  vec3 base = clamp(texture2D(backBuffer, vUv).xyz, 0., 1.0);
  float n = 0.8;
  float fill = seg;

  // gl_FragColor = vec4(base + fill * value, 1.0);
  if (value > 0.5) {
    if (t == 0. || (fill * value) > 0.15) {
      gl_FragColor = hash43(vec3(fragCoord, t)) - 0.5;
    } else {
      gl_FragColor = texture2D(backBuffer, vUv);
    }
  } else {
    gl_FragColor = ncao;
    if (s == vec4(0, 0, 0, 0)) {
      gl_FragColor = hash43(vec3(fragCoord, t)) - 0.5;
    }
  }
}