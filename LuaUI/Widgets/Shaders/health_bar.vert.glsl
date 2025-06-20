#version 460

uniform vec3 backColor;
uniform vec3 frontColor;
uniform ivec2 screenDimensions;
uniform mat4 cameraViewProj;

in vec4 positionAndProgress;
in ivec2 barDimensions;

out vec4 vtxPos;
out vec4 positionAndProgress_out;
flat out ivec2 barDimensions_out;


// Lookup table for the indices of the bar quad
const vec2 BAR_VERT[6] = vec2[6](
    vec2(-0.5, 0.5), // UL
    vec2(0.5, 0.5), // UR
    vec2(0.5, -0.5), // LR
    vec2(-0.5, 0.5), // UL
    vec2(0.5, -0.5), // LR
    vec2(-0.5, -0.5) // LL
);

void main() {
    // Billboard shader, adjusting based on distance from camera
    vec3 WS_pos = positionAndProgress.xyz;
    vec2 barVert = BAR_VERT[gl_VertexID];

    vtxPos = cameraViewProj * vec4(WS_pos, 1.0);
    vtxPos /= gl_Position.w;
    vtxPos.xy += barVert * (vec2(screenDimensions) / vec2(barDimensions));

    positionAndProgress_out = positionAndProgress;
    barDimensions_out = barDimensions;
}
