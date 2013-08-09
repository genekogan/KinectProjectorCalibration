#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform vec2 resolution;
uniform sampler2D texture;
uniform sampler2D lutexture;

void main(void) {
    vec2 p = gl_FragCoord.xy / resolution.xy;
	vec2 uv = texture2D(lutexture, p).bg;
    vec3 col = texture2D(texture, uv).rgb;
    gl_FragColor = vec4(col, 1.0);
}
