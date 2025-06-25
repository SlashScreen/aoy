#version 460

uniform vec3 backColor;
uniform vec3 frontColor;
uniform ivec2 screenDimensions;

in DataVS {
    float progress;
};

out vec4 colorOut;

void main() {
    vec2 uv = gl_FragCoord.xy / screenDimensions;

    float fac = step(progress, uv.x);
    vec3 col = mix(frontColor, backColor, fac);

    colorOut = vec4(col, 1.0);
}
