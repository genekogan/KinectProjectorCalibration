#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER;

uniform vec2 resolution;
uniform vec2 boxTL;
uniform vec2 boxBR;
uniform vec3 maskColor;
uniform sampler2D texture;
uniform sampler2D maskTex;
uniform float thresh;

void main(void) {
    vec2 p = gl_FragCoord.xy / resolution.xy;
	vec2 m = vec2(boxTL.x + p.x*(boxBR.x-boxTL.x), boxBR.y - p.y*(boxBR.y-boxTL.y));
    vec3 mask = texture2D(maskTex, m).rgb;
	vec3 col = texture2D(texture, p).rgb;
	float d = pow(mask.r-maskColor.r, 2.0)+pow(mask.g-maskColor.g, 2.0)+pow(mask.b-maskColor.b, 2.0);
	gl_FragColor = vec4(col, 1.0-step(thresh, d));	
}
