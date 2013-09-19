#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform vec2 resolution;
uniform sampler2D texture;
uniform sampler2D bgTex;
uniform float depthThresh;

void main(void) {
    vec2 p = gl_FragCoord.xy / resolution.xy;  
	p.y = 1.0-p.y;
	float dep0 = texture2D(texture, p).r;	
	float floor = texture2D(bgTex, p).r;
	float dep = step(depthThresh, dep0 - floor);
	gl_FragColor = vec4(vec3(dep), 1.0);
}
