#line 0 1

vec3 sky(vec3 direction) {
	vec3 colour = vec3(snoise(direction * 3.0) * 0.5 + 0.5) * 0.5;
	colour += vec3(1.0, 0.5, 0.5) * max(0.0, 1.0 - distance(direction, vec3(1.0, 0.0, 0.0)) / 0.25);
	colour += vec3(0.0, 0.5, 0.5) * max(0.0, 1.0 - distance(direction, vec3(-1.0, 0.0, 0.0)) / 0.25);
	colour += vec3(0.5, 1.0, 0.5) * max(0.0, 1.0 - distance(direction, vec3(0.0, 1.0, 0.0)) / 0.25);
	colour += vec3(0.5, 0.0, 0.5) * max(0.0, 1.0 - distance(direction, vec3(0.0, -1.0, 0.0)) / 0.25);
	colour += vec3(0.5, 0.5, 1.0) * max(0.0, 1.0 - distance(direction, vec3(0.0, 0.0, 1.0)) / 0.25);
	colour += vec3(0.5, 0.5, 0.0) * max(0.0, 1.0 - distance(direction, vec3(0.0, 0.0, -1.0)) / 0.25);
	return colour;
}
