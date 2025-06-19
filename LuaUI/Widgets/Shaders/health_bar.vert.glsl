#version 460

uniform ivec2 screenDimensions;

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
    //vec3 camPos = gl_ModelViewMatrixInverse[3].xyz;
    vec3 WS_pos = positionAndProgress.xyz;
    vec2 barVert = BAR_VERT[gl_VertexID];

    vec3 WS_cameraRight = vec3(gl_ModelViewMatrix[0][0], gl_ModelViewMatrix[1][0], gl_ModelViewMatrix[2][0]);
    vec3 WS_cameraUp = vec3(gl_ModelViewMatrix[0][1], gl_ModelViewMatrix[1][1], gl_ModelViewMatrix[2][1]);

    vec2 billboardSize = vec2(1.0, 1.0); // TODO: Calculate via screen size pixels
    vec3 WS_vertexPos = WS_pos + (WS_cameraRight * barVert.x * billboardSize.x) + (WS_cameraUp * barVert.y * billboardSize.y);
}
