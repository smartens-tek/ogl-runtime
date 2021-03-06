<Material name="aluminum_anisotropic" version="1.0">
    <MetaData >
        <Property formalName="Environment Map" name="uEnvironmentTexture" description="Environment texture for the material" type="Texture" filter="linear" minfilter="linearMipmapLinear" clamp="repeat" usage="environment" default="./maps/materials/spherical_checker.png" category="Material"/>
        <Property formalName="Enable Environment" name="uEnvironmentMappingEnabled" description="Enable environment mapping" type="Boolean" default="True" category="Material"/>
        <Property formalName="Baked Shadow Map" name="uBakedShadowTexture" description="Baked shadow texture for the material" type="Texture" filter="linear" minfilter="linearMipmapLinear" clamp="repeat" usage="shadow" default="./maps/materials/shadow.png" category="Material"/>
        <Property formalName="Shadow Mapping" name="uShadowMappingEnabled" description="Enable shadow mapping" type="Boolean" default="False" category="Material"/>
        <Property formalName="Index of Refraction" name="material_ior" description="Refractive index of the material" type="Float" default="8.000000" category="Material"/>
        <Property formalName="Diffuse Map" name="reflection_texture" description="Reflection texture for the material" type="Texture" filter="linear" minfilter="linearMipmapLinear" clamp="repeat" usage="specular" default="./maps/materials/concentric_milled_steel.png" category="Material"/>
        <Property formalName="Reflection Map Offset" name="reflection_map_offset" hidden="True" type="Float" default="1.000000" description="Reflection texture value offset" category="Material"/>
        <Property formalName="Reflection Map Scale" name="reflection_map_scale" hidden="True" type="Float" default="1.000000" description="Reflection texture value scale" category="Material"/>
        <Property formalName="Tiling" name="tiling" type="Float2" default="8 5" description="Texture Tiling size" category="Material"/>
        <Property formalName="Roughness Map Offset" name="roughness_map_offset" hidden="True" type="Float" default="0.000000" description="Roughness texture value offset" category="Material"/>
        <Property formalName="Roughness Map Scale" name="roughness_map_scale" hidden="True" type="Float" default="1.000000" description="Roughness texture value scale" category="Material"/>
        <Property formalName="Anisotropy" name="anisotropy" type="Float" default="0.800000" description="Anisotropy" category="Material"/>
        <Property formalName="Anisotropy Map" name="aniso_rot_texture" description="Anisotropy rot texture of the material" type="Texture" filter="linear" minfilter="linear" clamp="repeat" usage="anisotropy" default="./maps/materials/concentric_milled_steel_aniso.png" category="Material"/>
        <Property formalName="Roughness Map Offset" name="aniso_tex_color_offset" hidden="True" type="Float" default="0.000000" description="Roughness texture value offset" category="Material"/>
        <Property formalName="Roughness Map Scale" name="aniso_tex_color_scale" hidden="True" type="Float" default="1.000000" description="Roughness texture value scale" category="Material"/>
        <Property formalName="Base Weight" name="base_weight" description="Base weight" hidden="True" type="Float" default="1.000000" category="Material"/>
        <Property formalName="Bump Map" name="bump_texture" description="Bump texture of the material" type="Texture" filter="linear" minfilter="linearMipmapLinear" clamp="repeat" usage="bump" default="./maps/materials/concentric_milled_steel.png" category="Material"/>
        <Property formalName="Bump Amount" name="bump_amount" type="Float" min="0" max="2" default="0.000000" description="Scale value for bump amount" category="Material"/>
    </MetaData>
    <Shaders type="GLSL" version="330">
    <Shader>
    <Shared>    </Shared>
<VertexShader>
        </VertexShader>
        <FragmentShader>

// add enum defines
#define mono_alpha 0
#define mono_average 1
#define mono_luminance 2
#define mono_maximum 3
#define wrap_clamp 0
#define wrap_repeat 1
#define wrap_mirrored_repeat 2
#define gamma_default 0
#define gamma_linear 1
#define gamma_srgb 2
#define scatter_reflect 0
#define scatter_transmit 1
#define scatter_reflect_transmit 2

#define QT3DS_ENABLE_UV0 1
#define QT3DS_ENABLE_WORLD_POSITION 1
#define QT3DS_ENABLE_TEXTAN 1
#define QT3DS_ENABLE_BINORMAL 1

#include "vertexFragmentBase.glsllib"

// set shader output
out vec4 fragColor;

// add structure defines
struct texture_coordinate_info
{
  vec3 position;
  vec3 tangent_u;
  vec3 tangent_v;
};


struct layer_result
{
  vec4 base;
  vec4 layer;
  mat3 tanFrame;
};


struct texture_return
{
  vec3 tint;
  float mono;
};


struct anisotropy_return
{
  float roughness_u;
  float roughness_v;
  vec3 tangent_u;
};


// temporary declarations
texture_coordinate_info tmp3;
texture_return tmp4;
anisotropy_return tmp5;
vec3 tmp6;
vec3 tmp8;
float ftmp0;
float ftmp1;
vec3 ftmp2;
 vec4 tmpShadowTerm;

layer_result layers[2];

#include "SSAOCustomMaterial.glsllib"
#include "sampleLight.glsllib"
#include "sampleProbe.glsllib"
#include "sampleArea.glsllib"
#include "luminance.glsllib"
#include "monoChannel.glsllib"
#include "fileBumpTexture.glsllib"
#include "transformCoordinate.glsllib"
#include "rotationTranslationScale.glsllib"
#include "textureCoordinateInfo.glsllib"
#include "fileTexture.glsllib"
#include "square.glsllib"
#include "calculateRoughness.glsllib"
#include "evalBakedShadowMap.glsllib"
#include "evalEnvironmentMap.glsllib"
#include "microfacetBSDF.glsllib"
#include "physGlossyBSDF.glsllib"
#include "simpleGlossyBSDF.glsllib"
#include "anisotropyConversion.glsllib"
#include "weightedLayer.glsllib"
#include "diffuseReflectionBSDF.glsllib"
#include "fresnelLayer.glsllib"

bool evalTwoSided()
{
  return( false );
}

vec3 computeFrontMaterialEmissive()
{
  return( vec3( 0, 0, 0 ) );
}

void computeFrontLayerColor( in vec3 normal, in vec3 lightDir, in vec3 viewDir, in vec3 lightDiffuse, in vec3 lightSpecular, in float materialIOR, float aoFactor )
{
#if QT3DS_ENABLE_CG_LIGHTING
  layers[0].layer += tmpShadowTerm * microfacetBSDF( layers[0].tanFrame, lightDir, viewDir, lightSpecular, materialIOR, ftmp0, ftmp1, scatter_reflect );

  layers[1].base += tmpShadowTerm * vec4( 0.0, 0.0, 0.0, 1.0 );
  layers[1].layer += tmpShadowTerm * diffuseReflectionBSDF( normal, lightDir, lightDiffuse );

#endif
}

void computeFrontAreaColor( in int lightIdx, in vec4 lightDiffuse, in vec4 lightSpecular )
{
#if QT3DS_ENABLE_CG_LIGHTING
  layers[0].layer += tmpShadowTerm * lightSpecular * sampleAreaGlossy( layers[0].tanFrame, varWorldPos, lightIdx, viewDir, ftmp0, ftmp1 );

  layers[1].base += tmpShadowTerm * vec4( 0.0, 0.0, 0.0, 1.0 );
  layers[1].layer += tmpShadowTerm * lightDiffuse * sampleAreaDiffuse( layers[1].tanFrame, varWorldPos, lightIdx );

#endif
}

void computeFrontLayerEnvironment( in vec3 normal, in vec3 viewDir, float aoFactor )
{
#if !QT3DS_ENABLE_LIGHT_PROBE
  layers[0].layer += tmpShadowTerm * microfacetSampledBSDF( layers[0].tanFrame, viewDir, ftmp0, ftmp1, scatter_reflect );

  layers[1].base += tmpShadowTerm * vec4( 0.0, 0.0, 0.0, 1.0 );
  layers[1].layer += tmpShadowTerm * diffuseReflectionBSDFEnvironment( normal, 0.000000 ) * aoFactor;

#else
  layers[0].layer += tmpShadowTerm * sampleGlossy( layers[0].tanFrame, viewDir, ftmp0 );

  layers[1].base += tmpShadowTerm * vec4( 0.0, 0.0, 0.0, 1.0 );
  layers[1].layer += tmpShadowTerm * sampleDiffuse( layers[1].tanFrame ) * aoFactor;

#endif
}

vec3 computeBackMaterialEmissive()
{
  return( vec3(0, 0, 0) );
}

void computeBackLayerColor( in vec3 normal, in vec3 lightDir, in vec3 viewDir, in vec3 lightDiffuse, in vec3 lightSpecular, in float materialIOR, float aoFactor )
{
#if QT3DS_ENABLE_CG_LIGHTING
  layers[0].base += vec4( 0.0, 0.0, 0.0, 1.0 );
  layers[0].layer += vec4( 0.0, 0.0, 0.0, 1.0 );
#endif
}

void computeBackAreaColor( in int lightIdx, in vec4 lightDiffuse, in vec4 lightSpecular )
{
#if QT3DS_ENABLE_CG_LIGHTING
  layers[0].base += vec4( 0.0, 0.0, 0.0, 1.0 );
  layers[0].layer += vec4( 0.0, 0.0, 0.0, 1.0 );
#endif
}

void computeBackLayerEnvironment( in vec3 normal, in vec3 viewDir, float aoFactor )
{
#if !QT3DS_ENABLE_LIGHT_PROBE
  layers[0].base += vec4( 0.0, 0.0, 0.0, 1.0 );
  layers[0].layer += vec4( 0.0, 0.0, 0.0, 1.0 );
#else
  layers[0].base += vec4( 0.0, 0.0, 0.0, 1.0 );
  layers[0].layer += vec4( 0.0, 0.0, 0.0, 1.0 );
#endif
}

float computeIOR()
{
  return( false ? 1.0 : luminance( vec3( 1, 1, 1 ) ) );
}

float evalCutout()
{
  return( 1.000000 );
}

vec3 computeNormal()
{
  return( tmp8 );
}

void computeTemporaries()
{
     tmp3 = transformCoordinate( rotationTranslationScale( vec3( 0.000000, 0.000000, 0.000000 ), vec3( 0.000000, 0.000000, 0.000000 ), vec3( tiling[0], tiling[1], 1.000000 ) ), textureCoordinateInfo( texCoord0, tangent, binormal ) );
     tmp4 = fileTexture(reflection_texture, vec3( reflection_map_offset ), vec3( reflection_map_scale ), mono_luminance, tmp3, vec2( 0.000000, 1.000000 ), vec2( 0.000000, 1.000000 ), wrap_repeat, wrap_repeat, gamma_linear );
     tmp5 = anisotropyConversion( fileTexture(reflection_texture, vec3( roughness_map_offset ), vec3( roughness_map_scale ), mono_luminance, tmp3, vec2( 0.000000, 1.000000 ), vec2( 0.000000, 1.000000 ), wrap_repeat, wrap_repeat, gamma_linear ).mono, anisotropy, fileTexture(aniso_rot_texture, vec3( aniso_tex_color_offset ), vec3( aniso_tex_color_scale ), mono_luminance, tmp3, vec2( 0.000000, 1.000000 ), vec2( 0.000000, 1.000000 ), wrap_repeat, wrap_repeat, gamma_default ).mono, tangent, false );
     tmp6 = tmp4.tint;
     tmp8 = fileBumpTexture(bump_texture, bump_amount, mono_average, tmp3, vec2( 0.000000, 1.000000 ), vec2( 0.000000, 1.000000 ), wrap_repeat, wrap_repeat, normal );
     ftmp0 = tmp5.roughness_u;
     ftmp1 = tmp5.roughness_v;
     ftmp2 = tmp5.tangent_u;
     tmpShadowTerm = evalBakedShadowMap( texCoord0 );
}

vec4 computeLayerWeights( in float alpha )
{
  vec4 color;
  color = weightedLayer( base_weight, vec4( tmp6, 1.0).rgb, layers[1].layer, layers[1].base, alpha );
  color = fresnelLayer( tmp8, vec3( material_ior ), tmp4.mono, vec4( tmp6, 1.0).rgb, layers[0].layer, color, color.a );
  return color;
}


void initializeLayerVariables(void)
{
  // clear layers
  layers[0].base = vec4(0.0, 0.0, 0.0, 1.0);
  layers[0].layer = vec4(0.0, 0.0, 0.0, 1.0);
  layers[0].tanFrame = orthoNormalize( mat3( ftmp2, cross(tmp8, ftmp2), tmp8 ) );
  layers[1].base = vec4(0.0, 0.0, 0.0, 1.0);
  layers[1].layer = vec4(0.0, 0.0, 0.0, 1.0);
  layers[1].tanFrame = orthoNormalize( mat3( tangent, cross(normal, tangent), normal ) );
}

        </FragmentShader>
    </Shader>
    </Shaders>
<Passes >
        <ShaderKey value="5"/>
        <LayerKey count="2"/>
    <Pass >
    </Pass>
</Passes>
</Material>
