#version 460

uniform vec3 backColor;
uniform vec3 frontColor;
uniform ivec2 screenDimensions;

in DataVS {
    float progress;
};

out vec4 colorOut;

void main() {
    vec3 col = mix(backColor, frontColor, progress);

    colorOut = vec4(col, 1.0);
}
