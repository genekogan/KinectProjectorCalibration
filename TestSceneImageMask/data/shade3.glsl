#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_COLOR_SHADER;

#define M_PI 2.71828182845904523536028747135266249775724709369995
#define N 10.0

uniform vec2 resolution;
uniform vec2 center;
uniform vec3 color;
uniform vec3 rate;
uniform float time;

void main( void ) {

	// This is a reimplementation of this thing:
	// http://mainisusuallyafunction.blogspot.no/2011/10/quasicrystals-as-sums-of-waves-in-plane.html
	
	vec2 position = ( gl_FragCoord.xy-center.xy ) / 8.0;

	float col = 0.0;

	for (float i = 0.0; i < N; ++i) {
		float a = i * (5.0 * M_PI / N);
		col += cos( (position.x * cos(a) + position.y * sin(a)) + time ) / 2.0 + 0.5;
	}

	float m = mod(col, 2.0);
	if (m >= 1.0) col = 2.0 - m;
	else col = m;


	gl_FragColor = vec4( vec3( col*color.x, col*color.x, col*color.y ), 1.0 );

}
