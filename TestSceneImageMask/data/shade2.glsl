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
	vec3 rr = rate;
	vec2 position = (gl_FragCoord.xy-center.xy) / resolution.xy ;
	float col = 0.0;
	col += sin( position.x * cos( time / 15.0 ) * 80.0 ) + cos( position.y * cos( time / 15.0 ) * 10.0 );
	col += sin( position.y * sin( time / 10.0 ) * 60.0 ) + cos( position.x * sin( time / 25.0 ) * 40.0 );
	col += sin( position.x * sin( time / 5.0 ) * 10.0 ) + sin( position.y * sin( time / 35.0 ) * 80.0 );
	col *= sin( time / 10.0 ) * 0.5;
	gl_FragColor = vec4( vec3( col*color.x, col*color.y * 0.8, sin( col*color.z + time / 3.0 ) * 0.75 ), 1.0 );
}