#version 460

uniform ivec2 screenDimensions;
uniform mat4 cameraViewProj;

in vec4 positionAndProgress;
in ivec2 barDimensions;

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

    gl_Position = cameraViewProj * vec4(WS_pos, 1.0);
    gl_Position /= gl_Position.w;
    gl_Position.xy += barVert * (screenDimensions / barDimensions);
}
