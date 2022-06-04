#include "ReShade.fxh"
#include "Common.fxh"

uniform float _Exposure <
    ui_min = 0.0f; ui_max = 10.0f;
    ui_label = "Exposure";
    ui_type = "drag";
    ui_tooltip = "Adjust camera exposure";
> = 1.0f;

uniform float _Temperature <
    ui_min = -1.0f; ui_max = 1.0f;
    ui_label = "Temperature";
    ui_type = "drag";
    ui_tooltip = "Adjust white balancing temperature";
> = 0.0f;

uniform float _Tint <
    ui_min = -1.0f; ui_max = 1.0f;
    ui_label = "Tint";
    ui_type = "drag";
    ui_tooltip = "Adjust white balance color tint";
> = 0.0f;

uniform float _Contrast <
    ui_min = 0.0f; ui_max = 5.0f;
    ui_label = "Contrast";
    ui_type = "drag";
    ui_tooltip = "Adjust contrast";
> = 1.0f;

uniform float3 _Brightness <
    ui_min = -5.0f; ui_max = 5.0f;
    ui_label = "Brightness";
    ui_type = "drag";
    ui_tooltip = "Adjust brightness of each color channel";
> = float3(0.0, 0.0, 0.0);

uniform float3 _ColorFilter <
    ui_min = 0.0f; ui_max = 1.0f;
    ui_label = "Color Filter";
    ui_type = "drag";
    ui_tooltip = "Set color filter (white for no change)";
> = float3(1.0, 1.0, 1.0);

uniform float _FilterIntensity <
    ui_min = 0.0f; ui_max = 10.0f;
    ui_label = "Color Filter Intensity (HDR)";
    ui_type = "drag";
    ui_tooltip = "Adjust the intensity of the color filter";
> = 1.0f;

uniform float _Saturation <
    ui_min = 0.0f; ui_max = 5.0f;
    ui_label = "Saturation";
    ui_type = "drag";
    ui_tooltip = "Adjust saturation";
> = 1.0f;

float4 PS_ColorCorrect(float4 position : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET {
    float4 col = tex2D(ReShade::BackBuffer, uv).rgba;
    float UIMask = 1.0f - col.a;

    float3 output = col.rgb;

    output *= _Exposure;

    output = Common::WhiteBalance(output.rgb, _Temperature, _Tint);
    output = max(0.0f, output);

    output = _Contrast * (output - 0.5f) + 0.5f + _Brightness;
    output = max(0.0f, output);

    output *= (_ColorFilter * _FilterIntensity);

    output = lerp(Common::Luminance(output), output, _Saturation);

    return float4(lerp(col.rgb, output, UIMask), col.a);
}

technique ColorCorrection {
    pass {
        VertexShader = PostProcessVS;
        PixelShader = PS_ColorCorrect;
    }
}