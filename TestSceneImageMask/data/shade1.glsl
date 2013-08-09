#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_COLOR_SHADER;

uniform vec2 resolution;
uniform vec2 center;
uniform vec3 color;
uniform vec3 rate;
uniform float time;

void main( void ) {
	vec3 light_color = vec3(1.2,0.8,0.6);
	vec3 rr = rate;
	float t = time*20.0;
	vec2 position = (gl_FragCoord.xy-center.xy) / resolution.xy;
	
	// 256 angle steps
	float angle = atan(position.y,position.x)/(2.*3.14159265359);
	angle -= floor(angle);
	float rad = length(position);
	
	float col = 0.0;
	for (int i = 0; i < 1; i++) {
		float angleFract = fract(angle*256.);
		float angleRnd = floor(angle*256.)+1.;
		float angleRnd1 = fract(angleRnd*fract(angleRnd*.7235)*45.1);
		float angleRnd2 = fract(angleRnd*fract(angleRnd*.82657)*13.724);
		float t = t+angleRnd1*10.;
		float radDist = sqrt(angleRnd2+float(i));
		
		float adist = radDist/rad*.1;
		float dist = (t*.1+adist);
		dist = abs(fract(dist)-.5);
		col +=  (1.0 / (dist))*cos(0.7*(sin(t)))*adist/radDist/30.0;

		angle = fract(angle+.61);
	}
	
	gl_FragColor = vec4( col*color.x, col*color.x, col*color.y, 1.0)*vec4(light_color,1.0);
}
