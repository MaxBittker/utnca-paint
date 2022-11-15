
precision highp float;
varying vec2 uv;
uniform float t;

uniform sampler2D tex;
uniform float wRcp, hRcp;
uniform vec2 resolution;

// clang-format off
// clang-format on

// out vec4 fragColor, in vec2 fragCoord
void main() {

  vec2 uv2 = uv.xy;

  vec4 clr = texture2D(tex, uv);


    gl_FragColor = vec4(clr.rgb, 1.0) +.5;

}
