#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;

    // AAA Aurora Color Palette (Neon Green, Deep Purple, Ocean Blue)
    vec3 color1 = vec3(0.10, 0.80, 0.60);
    vec3 color2 = vec3(0.40, 0.15, 0.85);
    vec3 color3 = vec3(0.00, 0.45, 0.90);

    // Physics-based wave calculations
    float wave1 = sin(uv.x * 4.0 + uTime * 1.5) * 0.5 + 0.5;
    float wave2 = sin(uv.y * 3.0 - uTime * 1.0 + wave1) * 0.5 + 0.5;

    // Blend the colors smoothly
    vec3 finalColor = mix(mix(color1, color2, wave1), color3, wave2);

    // Add a vertical fade out so it looks like it's glowing from the bottom/top
    finalColor *= smoothstep(1.2, -0.2, uv.y);

    fragColor = vec4(finalColor, 1.0);
}