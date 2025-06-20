#version 460

uniform vec3 backColor;
uniform vec3 frontColor;
uniform ivec2 screenDimensions;
uniform mat4 cameraViewProj;

in vec4 vtxPos;
in vec4 positionAndProgress_out;
flat in ivec2 barDimensions_out;

out vec4 colorOut;

void main() {
    float progress = positionAndProgress_out.a;
    vec2 uv = gl_FragCoord.xy / screenDimensions;

    float fac = step(progress, uv.x);
    vec3 col = mix(frontColor, backColor, fac);

    colorOut = vec4(col, 1.0);
}
