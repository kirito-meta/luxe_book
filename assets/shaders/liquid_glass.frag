#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;

    // AAA Liquid Gradient Effect
    vec3 color1 = vec3(0.08, 0.08, 0.12); // Deep dark background
    vec3 color2 = vec3(0.40, 0.10, 0.80); // Luxe purple

    float wave1 = sin(uv.x * 5.0 + uTime) * 0.5 + 0.5;
    float wave2 = cos(uv.y * 3.0 - uTime * 0.8) * 0.5 + 0.5;

    vec3 finalColor = mix(color1, color2, wave1 * wave2);

    fragColor = vec4(finalColor, 1.0);
}