
precision highp float;
varying vec2 uv;
uniform float t;

uniform sampler2D tex;
uniform float wRcp, hRcp;
uniform vec2 resolution;

// clang-format off
// clang-format on
float hue2rgb(float f1, float f2, float hue)
{
    if (hue < 0.0)
        hue += 1.0;
    else if (hue > 1.0)
        hue -= 1.0;
    float res;
    if ((6.0 * hue) < 1.0)
        res = f1 + (f2 - f1) * 6.0 * hue;
    else if ((2.0 * hue) < 1.0)
        res = f2;
    else if ((3.0 * hue) < 2.0)
        res = f1 + (f2 - f1) * ((2.0 / 3.0) - hue) * 6.0;
    else
        res = f1;
    return res;
}

vec3 hsl2rgb(vec3 hsl)
{
    vec3 rgb;

    if (hsl.y == 0.0) {
        rgb = vec3(hsl.z); // Luminance
    } else {
        float f2;

        if (hsl.z < 0.5)
            f2 = hsl.z * (1.0 + hsl.y);
        else
            f2 = hsl.z + hsl.y - hsl.y * hsl.z;

        float f1 = 2.0 * hsl.z - f2;

        rgb.r = hue2rgb(f1, f2, hsl.x + (1.0 / 3.0));
        rgb.g = hue2rgb(f1, f2, hsl.x);
        rgb.b = hue2rgb(f1, f2, hsl.x - (1.0 / 3.0));
    }
    return rgb;
}

vec3 hsl2rgb(float h, float s, float l)
{
    return hsl2rgb(vec3(h, s, l));
}

// out vec4 fragColor, in vec2 fragCoord
void main()
{

    vec2 uv2 = uv.xy;

    vec4 clr = texture2D(tex, uv);

    float r = clr.r;
    gl_FragColor = vec4(clr.rrr, 1.0) + .5;
    // gl_FragColor = vec4(hsl2rgb(.1, (r + .2) * .2, r + .5), 1.0);
}
