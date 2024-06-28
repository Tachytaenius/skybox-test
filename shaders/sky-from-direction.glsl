#line 0 1
// Requires include/lib/simplex3d.glsl to be concatenated before
// Requires include/sky.glsl to be concatenated before

varying vec3 directionPreNormalise;

#ifdef VERTEX

uniform mat4 clipToSky;

vec4 position(mat4 loveTransform, vec4 homogenVertexPos) {
	directionPreNormalise = (
		clipToSky * vec4(
			VertexTexCoord.xy * 2.0 - 1.0,
			-1.0,
			1.0
		)
	).xyz;
	return loveTransform * homogenVertexPos;
}

#endif

#ifdef PIXEL

vec4 effect(vec4 colour, sampler2D image, vec2 textureCoords, vec2 windowCoords) {
	return vec4(sky(normalize(directionPreNormalise)), 1.0);
}

#endif
