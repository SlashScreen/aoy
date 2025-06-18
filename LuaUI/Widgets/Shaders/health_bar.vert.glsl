// Vertex shader for camera-facing billboard
// Attributes
attribute vec3 a_position; // Center of the billboard in world space
attribute vec2 a_offset;   // Offset for each vertex of the quad (-0.5 to 0.5)
attribute float a_vertexIndex; // Vertex index: 0, 1, 2, 3 for each quad

// Uniforms
uniform vec3 u_cameraPos;  // Camera position in world space
uniform float u_size;      // (Unused, kept for compatibility)
uniform mat4 u_viewProj;   // View-projection matrix
uniform float width;        // Billboard width in screen pixels
uniform float height;       // Billboard height in screen pixels
uniform mat4 u_proj;       // Projection matrix
uniform mat4 u_view;       // View matrix
uniform vec2 u_viewport;   // Viewport size in pixels (x=width, y=height)

void main() {
    // Determine quad corner from a_vertexIndex (0-3)
    float corner = mod(a_vertexIndex, 4.0);
    vec2 quadOffsets[4];
    quadOffsets[0] = vec2(-0.5, -0.5); // bottom-left
    quadOffsets[1] = vec2( 0.5, -0.5); // bottom-right
    quadOffsets[2] = vec2(-0.5,  0.5); // top-left
    quadOffsets[3] = vec2( 0.5,  0.5); // top-right
    vec2 offset = quadOffsets[int(corner)];

    // Convert pixel size to NDC size
    vec2 pixelSize = vec2(width, height);
    vec2 ndcSize = pixelSize / u_viewport * 2.0; // NDC is [-1,1]

    // Project center to clip space
    vec4 clipCenter = u_viewProj * vec4(a_position, 1.0);
    vec3 ndcCenter = clipCenter.xyz / clipCenter.w;

    // Offset in NDC
    vec2 ndcOffset = offset * ndcSize;
    vec3 ndcPos = ndcCenter + vec3(ndcOffset, 0.0);

    // Convert back to clip space
    vec4 clipPos = vec4(ndcPos * clipCenter.w, clipCenter.w);

    gl_Position = clipPos;
}
