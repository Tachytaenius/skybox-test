#line 0 1

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

uniform samplerCube skybox;

vec4 effect(vec4 colour, sampler2D image, vec2 textureCoords, vec2 windowCoords) {
	return Texel(skybox, normalize(directionPreNormalise) * vec3(1.0, -1.0, 1.0));
}

#endif
