#version 460

uniform vec3 backColor;
uniform vec3 frontColor;
uniform ivec2 screenDimensions;

layout (location = 0) in vec4 positionAndProgress;
layout (location = 1) in ivec2 dimensions;

out DataVS {
    float progress;
};

// Engine provided UBOs
layout(std140, binding = 0) uniform UniformMatrixBuffer {
	mat4 screenView;
	mat4 screenProj;
	mat4 screenViewProj;

	mat4 cameraView;
	mat4 cameraProj;
	mat4 cameraViewProj;
	mat4 cameraBillboardView;

	mat4 cameraViewInv;
	mat4 cameraProjInv;
	mat4 cameraViewProjInv;

	mat4 shadowView;
	mat4 shadowProj;
	mat4 shadowViewProj;

	mat4 reflectionView;
	mat4 reflectionProj;
	mat4 reflectionViewProj;

	mat4 orthoProj01;

	// transforms for [0] := Draw, [1] := DrawInMiniMap, [2] := Lua DrawInMiniMap
	mat4 mmDrawView; //world to MM
	mat4 mmDrawProj; //world to MM
	mat4 mmDrawViewProj; //world to MM

	mat4 mmDrawIMMView; //heightmap to MM
	mat4 mmDrawIMMProj; //heightmap to MM
	mat4 mmDrawIMMViewProj; //heightmap to MM

	mat4 mmDrawDimView; //mm dims
	mat4 mmDrawDimProj; //mm dims
	mat4 mmDrawDimViewProj; //mm dims
};

layout(std140, binding = 1) uniform UniformParamsBuffer {
	vec3 rndVec3; //new every draw frame.
	uint renderCaps; //various render booleans

	vec4 timeInfo; //gameFrame, drawSeconds, interpolated(unsynced)GameSeconds(synced), frameTimeOffset
	vec4 viewGeometry; //vsx, vsy, vpx, vpy
	vec4 mapSize; //xz, xzPO2
	vec4 mapHeight; //height minCur, maxCur, minInit, maxInit

	vec4 fogColor; //fog color
	vec4 fogParams; //fog {start, end, 0.0, scale}

	vec4 sunDir; // (sky != nullptr) ? sky->GetLight()->GetLightDir() : float4(/*map default*/ 0.0f, 0.447214f, 0.894427f, 1.0f);

	vec4 sunAmbientModel;
	vec4 sunAmbientMap;
	vec4 sunDiffuseModel;
	vec4 sunDiffuseMap;
	vec4 sunSpecularModel; // float4{ sunLighting->modelSpecularColor.xyz, sunLighting->specularExponent };
	vec4 sunSpecularMap; //  float4{ sunLighting->groundSpecularColor.xyz, sunLighting->specularExponent };

	vec4 shadowDensity; //  float4{ sunLighting->groundShadowDensity, sunLighting->modelShadowDensity, 0.0, 0.0 };

	vec4 windInfo; // windx, windy, windz, windStrength
	vec2 mouseScreenPos; //x, y. Screen space.
	uint mouseStatus; // bits 0th to 32th: LMB, MMB, RMB, offscreen, mmbScroll, locked
	uint mouseUnused;
	vec4 mouseWorldPos; //x,y,z; w=0 -- offmap. Ignores water, doesn't ignore units/features under the mouse cursor

	vec4 teamColor[255]; //all team colors
};


// Lookup table for the indices of the bar quad
const vec2 BAR_VERT[6] = vec2[6](
    vec2(-0.5,  0.5), // UL
    vec2( 0.5,  0.5), // UR
    vec2( 0.5, -0.5), // LR
    vec2(-0.5,  0.5), // UL
    vec2( 0.5, -0.5), // LR
    vec2(-0.5, -0.5)  // LL
);

void main() {
    // Billboard shader, adjusting based on distance from camera
    vec4 WS_pos = vec4(positionAndProgress.xyz, 0.0);
    vec2 barVert = BAR_VERT[gl_VertexID % 6];

    gl_Position = cameraViewProj * WS_pos + vec4(0.0, 100.0, 0.0, 0.0);
    gl_Position /= gl_Position.w;
    gl_Position.xy += barVert * vec2(0.05, 0.01) ;//(vec2(dimensions) / vec2(screenDimensions));

    progress = positionAndProgress.w;
}
