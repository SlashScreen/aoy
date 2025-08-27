#version 460

uniform vec3 backColor;
uniform vec3 frontColor;
uniform ivec2 screenDimensions;

in DataVS {
    float progress;
    float factor;
};

out vec4 colorOut;

void main() {
    vec3 col = mix(backColor, frontColor, step(factor, progress));

    colorOut = vec4(col, 1.0);
}
