#version 460

uniform float progress;
uniform vec3 back_color;
uniform vec3 front_color;

uniform vec2 viewPortSize;

void main() {
    vec2 uv = gl_FragCoord.xy / viewPortSize;
    float fac = step(progress, uv.x);
    vec3 col = mix(front_color, back_color, fac);

    gl_FragColor = vec4(col, 1.0);
}
