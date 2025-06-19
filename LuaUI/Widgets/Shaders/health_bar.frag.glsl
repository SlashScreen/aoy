#version 460

uniform vec3 backColor;
uniform vec3 frontColor;
uniform ivec2 screenDimensions;

in vec4 positionAndProgress;

void main() {
    float progress = positionAndProgress.a;
    vec2 uv = gl_FragCoord.xy / screenDimensions;

    float fac = step(progress, uv.x);
    vec3 col = mix(frontColor, backColor, fac);

    gl_FragColor = vec4(col, 1.0);
}
