﻿Shader "Sphere/Cloud" {
	Properties {
		_Color ("Color Tint", Color) = (1,1,1,1)
		_MainTex ("Main (RGB)", 2D) = "white" {}
		_DetailTex ("Detail (RGB)", 2D) = "white" {}
		_BumpMap ("Bumpmap", 2D) = "bump" {}
		_FalloffPow ("Falloff Power", Range(0,3)) = 2
		_FalloffScale ("Falloff Scale", Range(0,20)) = 3
		_DetailScale ("Detail Scale", Range(0,1000)) = 100
		_DetailOffset ("Detail Offset", Color) = (0,0,0,0)
		_BumpScale ("Bump Scale", Range(0,1000)) = 50
		_BumpOffset ("Bump offset", Color) = (0,0,0,0)
		_DetailDist ("Detail Distance", Range(0,1)) = 0.00875
		_MinLight ("Minimum Light", Range(0,1)) = .1
	}

SubShader {
		Tags {  "Queue"="Transparent"
	   			"RenderMode"="Transparent" }
		Lighting On
		Cull Back
	    ZWrite Off
		
		Blend SrcAlpha OneMinusSrcAlpha
		
			
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }
Program "vp" {
// Vertex combos: 6
//   opengl - ALU: 50 to 56
//   d3d9 - ALU: 51 to 56
//   d3d11 - ALU: 40 to 43, TEX: 0 to 0, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Bind "vertex" Vertex
Bind "tangent" ATTR14
Bind "normal" Normal
Vector 2 [_WorldSpaceCameraPos]
Vector 3 [_WorldSpaceLightPos0]
Matrix 5 [_Object2World]
Matrix 9 [_World2Object]
Vector 4 [unity_Scale]
Float 17 [_DetailDist]
"3.0-!!ARBvp1.0
# 50 ALU
PARAM c[18] = { { 1, 1.0005, 0 },
		state.lightmodel.ambient,
		program.local[2..12],
		state.matrix.mvp,
		program.local[17] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
MOV R0.xyz, vertex.attrib[14];
MUL R1.xyz, vertex.normal.zxyw, R0.yzxw;
MAD R0.xyz, vertex.normal.yzxw, R0.zxyw, -R1;
MOV R1.w, c[0].x;
MOV R1.xyz, c[2];
DP4 R2.z, R1, c[11];
DP4 R2.x, R1, c[9];
DP4 R2.y, R1, c[10];
MAD R3.xyz, R2, c[4].w, -vertex.position;
MUL R2.xyz, R0, vertex.attrib[14].w;
MOV R1, c[3];
DP4 R0.x, R1, c[9];
DP4 R0.y, R1, c[10];
DP4 R0.z, R1, c[11];
DP3 result.texcoord[3].y, R2, R0;
DP3 result.texcoord[0].y, R3, R2;
MOV R1.z, c[7].w;
MOV R1.x, c[5].w;
MOV R1.y, c[6].w;
ADD R4.xyz, -R1, c[2];
DP4 R2.z, vertex.position, c[7];
DP4 R2.x, vertex.position, c[5];
DP4 R2.y, vertex.position, c[6];
ADD R1.xyz, R2, -R1;
DP3 R0.w, R1, R1;
DP3 R1.w, R4, R4;
RSQ R1.x, R1.w;
RSQ R0.w, R0.w;
RCP R1.x, R1.x;
RCP R0.w, R0.w;
MAD R0.w, -R0, c[0].y, R1.x;
MIN R0.w, R0, c[0].x;
DP3 result.texcoord[3].z, vertex.normal, R0;
DP3 result.texcoord[3].x, vertex.attrib[14], R0;
DP3 R0.y, vertex.position, vertex.position;
RSQ R0.y, R0.y;
MAX result.texcoord[1].y, R0.w, c[0].z;
ADD R1.xyz, -R2, c[2];
DP3 R0.w, R1, R1;
RSQ R0.x, R0.w;
RCP R0.x, R0.x;
DP3 result.texcoord[0].z, vertex.normal, R3;
DP3 result.texcoord[0].x, R3, vertex.attrib[14];
MUL result.texcoord[1].x, R0, c[17];
MUL result.texcoord[2].xyz, R0.y, vertex.position;
MOV result.texcoord[4].xyz, c[1];
DP4 result.position.w, vertex.position, c[16];
DP4 result.position.z, vertex.position, c[15];
DP4 result.position.y, vertex.position, c[14];
DP4 result.position.x, vertex.position, c[13];
END
# 50 instructions, 5 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Vector 12 [glstate_lightmodel_ambient]
Matrix 0 [glstate_matrix_mvp]
Vector 13 [_WorldSpaceCameraPos]
Vector 14 [_WorldSpaceLightPos0]
Matrix 4 [_Object2World]
Matrix 8 [_World2Object]
Vector 15 [unity_Scale]
Float 16 [_DetailDist]
"vs_3_0
; 51 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
def c17, 1.00000000, 1.00049996, 0, 0
dcl_position0 v0
dcl_tangent0 v1
dcl_normal0 v2
mov r0.xyz, v1
mul r1.xyz, v2.zxyw, r0.yzxw
mov r0.xyz, v1
mad r0.xyz, v2.yzxw, r0.zxyw, -r1
mul r3.xyz, r0, v1.w
mov r0, c10
dp4 r4.z, c14, r0
mov r0, c9
dp4 r4.y, c14, r0
mov r1.w, c17.x
mov r1.xyz, c13
dp4 r2.z, r1, c10
dp4 r2.x, r1, c8
dp4 r2.y, r1, c9
mad r2.xyz, r2, c15.w, -v0
mov r1, c8
dp4 r4.x, c14, r1
mov r0.z, c6.w
mov r0.x, c4.w
mov r0.y, c5.w
dp4 r1.z, v0, c6
dp4 r1.x, v0, c4
dp4 r1.y, v0, c5
dp3 o1.y, r2, r3
dp3 o1.z, v2, r2
dp3 o1.x, r2, v1
add r2.xyz, -r0, c13
add r0.xyz, r1, -r0
dp3 r0.x, r0, r0
dp3 r0.w, r2, r2
rsq r0.y, r0.w
rsq r0.x, r0.x
rcp r0.y, r0.y
rcp r0.x, r0.x
mad_sat o2.y, -r0.x, c17, r0
add r0.xyz, -r1, c13
dp3 r0.x, r0, r0
rsq r0.x, r0.x
dp3 r0.y, v0, v0
rcp r0.x, r0.x
rsq r0.y, r0.y
dp3 o4.y, r3, r4
dp3 o4.z, v2, r4
dp3 o4.x, v1, r4
mul o2.x, r0, c16
mul o3.xyz, r0.y, v0
mov o5.xyz, c12
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
"
}

SubProgram "d3d11 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "color" Color
ConstBuffer "$Globals" 128 // 112 used size, 12 vars
Float 108 [_DetailDist]
ConstBuffer "UnityPerCamera" 128 // 76 used size, 8 vars
Vector 64 [_WorldSpaceCameraPos] 3
ConstBuffer "UnityLighting" 720 // 16 used size, 17 vars
Vector 0 [_WorldSpaceLightPos0] 4
ConstBuffer "UnityPerDraw" 336 // 336 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
Matrix 192 [_Object2World] 4
Matrix 256 [_World2Object] 4
Vector 320 [unity_Scale] 4
ConstBuffer "UnityPerFrame" 208 // 80 used size, 4 vars
Vector 64 [glstate_lightmodel_ambient] 4
BindCB "$Globals" 0
BindCB "UnityPerCamera" 1
BindCB "UnityLighting" 2
BindCB "UnityPerDraw" 3
BindCB "UnityPerFrame" 4
// 42 instructions, 3 temp regs, 0 temp arrays:
// ALU 40 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0
eefiecedhpglldndbddppbjkaapmdheidoclempaabaaaaaanmahaaaaadaaaaaa
cmaaaaaapeaaaaaakmabaaaaejfdeheomaaaaaaaagaaaaaaaiaaaaaajiaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaakbaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaakjaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
ahahaaaalaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaadaaaaaaapaaaaaalaaaaaaa
abaaaaaaaaaaaaaaadaaaaaaaeaaaaaaapaaaaaaljaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaafaaaaaaapaaaaaafaepfdejfeejepeoaafeebeoehefeofeaaeoepfc
enebemaafeeffiedepepfceeaaedepemepfcaaklepfdeheolaaaaaaaagaaaaaa
aiaaaaaajiaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaakeaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaabaaaaaaahaiaaaakeaaaaaaabaaaaaaaaaaaaaa
adaaaaaaacaaaaaaadamaaaakeaaaaaaacaaaaaaaaaaaaaaadaaaaaaadaaaaaa
ahaiaaaakeaaaaaaadaaaaaaaaaaaaaaadaaaaaaaeaaaaaaahaiaaaakeaaaaaa
aeaaaaaaaaaaaaaaadaaaaaaafaaaaaaahaiaaaafdfgfpfaepfdejfeejepeoaa
feeffiedepepfceeaaklklklfdeieefcciagaaaaeaaaabaaikabaaaafjaaaaae
egiocaaaaaaaaaaaahaaaaaafjaaaaaeegiocaaaabaaaaaaafaaaaaafjaaaaae
egiocaaaacaaaaaaabaaaaaafjaaaaaeegiocaaaadaaaaaabfaaaaaafjaaaaae
egiocaaaaeaaaaaaafaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaadpcbabaaa
abaaaaaafpaaaaadhcbabaaaacaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaa
gfaaaaadhccabaaaabaaaaaagfaaaaaddccabaaaacaaaaaagfaaaaadhccabaaa
adaaaaaagfaaaaadhccabaaaaeaaaaaagfaaaaadhccabaaaafaaaaaagiaaaaac
adaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiocaaaadaaaaaa
abaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaadaaaaaaaaaaaaaaagbabaaa
aaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaadaaaaaa
acaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpccabaaaaaaaaaaa
egiocaaaadaaaaaaadaaaaaapgbpbaaaaaaaaaaaegaobaaaaaaaaaaadiaaaaah
hcaabaaaaaaaaaaajgbebaaaabaaaaaacgbjbaaaacaaaaaadcaaaaakhcaabaaa
aaaaaaaajgbebaaaacaaaaaacgbjbaaaabaaaaaaegacbaiaebaaaaaaaaaaaaaa
diaaaaahhcaabaaaaaaaaaaaegacbaaaaaaaaaaapgbpbaaaabaaaaaadiaaaaaj
hcaabaaaabaaaaaafgifcaaaabaaaaaaaeaaaaaaegiccaaaadaaaaaabbaaaaaa
dcaaaaalhcaabaaaabaaaaaaegiccaaaadaaaaaabaaaaaaaagiacaaaabaaaaaa
aeaaaaaaegacbaaaabaaaaaadcaaaaalhcaabaaaabaaaaaaegiccaaaadaaaaaa
bcaaaaaakgikcaaaabaaaaaaaeaaaaaaegacbaaaabaaaaaaaaaaaaaihcaabaaa
abaaaaaaegacbaaaabaaaaaaegiccaaaadaaaaaabdaaaaaadcaaaaalhcaabaaa
abaaaaaaegacbaaaabaaaaaapgipcaaaadaaaaaabeaaaaaaegbcbaiaebaaaaaa
aaaaaaaabaaaaaahcccabaaaabaaaaaaegacbaaaaaaaaaaaegacbaaaabaaaaaa
baaaaaahbccabaaaabaaaaaaegbcbaaaabaaaaaaegacbaaaabaaaaaabaaaaaah
eccabaaaabaaaaaaegbcbaaaacaaaaaaegacbaaaabaaaaaaaaaaaaakhcaabaaa
abaaaaaaegiccaiaebaaaaaaabaaaaaaaeaaaaaaegiccaaaadaaaaaaapaaaaaa
baaaaaahicaabaaaaaaaaaaaegacbaaaabaaaaaaegacbaaaabaaaaaaelaaaaaf
icaabaaaaaaaaaaadkaabaaaaaaaaaaadiaaaaaihcaabaaaabaaaaaafgbfbaaa
aaaaaaaaegiccaaaadaaaaaaanaaaaaadcaaaaakhcaabaaaabaaaaaaegiccaaa
adaaaaaaamaaaaaaagbabaaaaaaaaaaaegacbaaaabaaaaaadcaaaaakhcaabaaa
abaaaaaaegiccaaaadaaaaaaaoaaaaaakgbkbaaaaaaaaaaaegacbaaaabaaaaaa
dcaaaaakhcaabaaaabaaaaaaegiccaaaadaaaaaaapaaaaaapgbpbaaaaaaaaaaa
egacbaaaabaaaaaaaaaaaaajhcaabaaaacaaaaaaegacbaiaebaaaaaaabaaaaaa
egiccaaaadaaaaaaapaaaaaaaaaaaaajhcaabaaaabaaaaaaegacbaaaabaaaaaa
egiccaiaebaaaaaaabaaaaaaaeaaaaaabaaaaaahbcaabaaaabaaaaaaegacbaaa
abaaaaaaegacbaaaabaaaaaaelaaaaafbcaabaaaabaaaaaaakaabaaaabaaaaaa
diaaaaaibccabaaaacaaaaaaakaabaaaabaaaaaadkiacaaaaaaaaaaaagaaaaaa
baaaaaahbcaabaaaabaaaaaaegacbaaaacaaaaaaegacbaaaacaaaaaaelaaaaaf
bcaabaaaabaaaaaaakaabaaaabaaaaaadccaaaakcccabaaaacaaaaaaakaabaia
ebaaaaaaabaaaaaaabeaaaaagcbaiadpdkaabaaaaaaaaaaabaaaaaahicaabaaa
aaaaaaaaegbcbaaaaaaaaaaaegbcbaaaaaaaaaaaeeaaaaaficaabaaaaaaaaaaa
dkaabaaaaaaaaaaadiaaaaahhccabaaaadaaaaaapgapbaaaaaaaaaaaegbcbaaa
aaaaaaaadiaaaaajhcaabaaaabaaaaaafgifcaaaacaaaaaaaaaaaaaaegiccaaa
adaaaaaabbaaaaaadcaaaaalhcaabaaaabaaaaaaegiccaaaadaaaaaabaaaaaaa
agiacaaaacaaaaaaaaaaaaaaegacbaaaabaaaaaadcaaaaalhcaabaaaabaaaaaa
egiccaaaadaaaaaabcaaaaaakgikcaaaacaaaaaaaaaaaaaaegacbaaaabaaaaaa
dcaaaaalhcaabaaaabaaaaaaegiccaaaadaaaaaabdaaaaaapgipcaaaacaaaaaa
aaaaaaaaegacbaaaabaaaaaabaaaaaahcccabaaaaeaaaaaaegacbaaaaaaaaaaa
egacbaaaabaaaaaabaaaaaahbccabaaaaeaaaaaaegbcbaaaabaaaaaaegacbaaa
abaaaaaabaaaaaaheccabaaaaeaaaaaaegbcbaaaacaaaaaaegacbaaaabaaaaaa
dgaaaaaghccabaaaafaaaaaaegiccaaaaeaaaaaaaeaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES


#ifdef VERTEX

varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _DetailDist;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;
uniform highp mat4 glstate_matrix_mvp;
uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  highp vec2 tmpvar_5;
  highp vec3 tmpvar_6;
  tmpvar_6 = (_Object2World * _glesVertex).xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (_Object2World * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
  highp vec3 p_8;
  p_8 = (tmpvar_6 - _WorldSpaceCameraPos);
  tmpvar_5.x = (_DetailDist * sqrt(dot (p_8, p_8)));
  highp vec3 p_9;
  p_9 = (tmpvar_7 - _WorldSpaceCameraPos);
  highp vec3 p_10;
  p_10 = (tmpvar_7 - tmpvar_6);
  tmpvar_5.y = clamp ((sqrt(dot (p_9, p_9)) - (1.0005 * sqrt(dot (p_10, p_10)))), 0.0, 1.0);
  highp vec3 tmpvar_11;
  highp vec3 tmpvar_12;
  tmpvar_11 = tmpvar_1.xyz;
  tmpvar_12 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_13;
  tmpvar_13[0].x = tmpvar_11.x;
  tmpvar_13[0].y = tmpvar_12.x;
  tmpvar_13[0].z = tmpvar_2.x;
  tmpvar_13[1].x = tmpvar_11.y;
  tmpvar_13[1].y = tmpvar_12.y;
  tmpvar_13[1].z = tmpvar_2.y;
  tmpvar_13[2].x = tmpvar_11.z;
  tmpvar_13[2].y = tmpvar_12.z;
  tmpvar_13[2].z = tmpvar_2.z;
  highp vec3 tmpvar_14;
  tmpvar_14 = (tmpvar_13 * (_World2Object * _WorldSpaceLightPos0).xyz);
  tmpvar_3 = tmpvar_14;
  highp vec4 tmpvar_15;
  tmpvar_15.w = 1.0;
  tmpvar_15.xyz = _WorldSpaceCameraPos;
  highp vec3 tmpvar_16;
  tmpvar_16 = glstate_lightmodel_ambient.xyz;
  tmpvar_4 = tmpvar_16;
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_TEXCOORD0 = (tmpvar_13 * (((_World2Object * tmpvar_15).xyz * unity_Scale.w) - _glesVertex.xyz));
  xlv_TEXCOORD1 = tmpvar_5;
  xlv_TEXCOORD2 = normalize(_glesVertex.xyz);
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
}



#endif
#ifdef FRAGMENT

varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _MinLight;
uniform highp float _BumpScale;
uniform highp float _DetailScale;
uniform highp float _FalloffScale;
uniform highp float _FalloffPow;
uniform lowp vec4 _BumpOffset;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _Color;
uniform sampler2D _BumpMap;
uniform sampler2D _DetailTex;
uniform sampler2D _MainTex;
uniform lowp vec4 _LightColor0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  lowp float tmpvar_5;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  tmpvar_4 = tmpvar_2;
  tmpvar_5 = 0.0;
  mediump float rim_6;
  mediump float detailLevel_7;
  mediump vec4 normal_8;
  mediump vec4 detail_9;
  mediump vec4 normalZ_10;
  mediump vec4 normalY_11;
  mediump vec4 normalX_12;
  mediump vec4 detailZ_13;
  mediump vec4 detailY_14;
  mediump vec4 detailX_15;
  mediump vec4 main_16;
  highp vec2 uv_17;
  highp float r_18;
  if ((abs(xlv_TEXCOORD2.x) > (1e-08 * abs(xlv_TEXCOORD2.z)))) {
    highp float y_over_x_19;
    y_over_x_19 = (xlv_TEXCOORD2.z / xlv_TEXCOORD2.x);
    highp float s_20;
    highp float x_21;
    x_21 = (y_over_x_19 * inversesqrt(((y_over_x_19 * y_over_x_19) + 1.0)));
    s_20 = (sign(x_21) * (1.5708 - (sqrt((1.0 - abs(x_21))) * (1.5708 + (abs(x_21) * (-0.214602 + (abs(x_21) * (0.0865667 + (abs(x_21) * -0.0310296)))))))));
    r_18 = s_20;
    if ((xlv_TEXCOORD2.x < 0.0)) {
      if ((xlv_TEXCOORD2.z >= 0.0)) {
        r_18 = (s_20 + 3.14159);
      } else {
        r_18 = (r_18 - 3.14159);
      };
    };
  } else {
    r_18 = (sign(xlv_TEXCOORD2.z) * 1.5708);
  };
  uv_17.x = (0.5 + (0.159155 * r_18));
  highp float x_22;
  x_22 = -(xlv_TEXCOORD2.y);
  uv_17.y = (0.31831 * (1.5708 - (sign(x_22) * (1.5708 - (sqrt((1.0 - abs(x_22))) * (1.5708 + (abs(x_22) * (-0.214602 + (abs(x_22) * (0.0865667 + (abs(x_22) * -0.0310296)))))))))));
  lowp vec4 tmpvar_23;
  tmpvar_23 = (texture2D (_MainTex, uv_17) * _Color);
  main_16 = tmpvar_23;
  lowp vec4 tmpvar_24;
  highp vec2 P_25;
  P_25 = ((xlv_TEXCOORD2.zy * _DetailScale) + _DetailOffset.xy);
  tmpvar_24 = texture2D (_DetailTex, P_25);
  detailX_15 = tmpvar_24;
  lowp vec4 tmpvar_26;
  highp vec2 P_27;
  P_27 = ((xlv_TEXCOORD2.zx * _DetailScale) + _DetailOffset.xy);
  tmpvar_26 = texture2D (_DetailTex, P_27);
  detailY_14 = tmpvar_26;
  lowp vec4 tmpvar_28;
  highp vec2 P_29;
  P_29 = ((xlv_TEXCOORD2.xy * _DetailScale) + _DetailOffset.xy);
  tmpvar_28 = texture2D (_DetailTex, P_29);
  detailZ_13 = tmpvar_28;
  lowp vec4 tmpvar_30;
  highp vec2 P_31;
  P_31 = ((xlv_TEXCOORD2.zy * _BumpScale) + _BumpOffset.xy);
  tmpvar_30 = texture2D (_BumpMap, P_31);
  normalX_12 = tmpvar_30;
  lowp vec4 tmpvar_32;
  highp vec2 P_33;
  P_33 = ((xlv_TEXCOORD2.zx * _BumpScale) + _BumpOffset.xy);
  tmpvar_32 = texture2D (_BumpMap, P_33);
  normalY_11 = tmpvar_32;
  lowp vec4 tmpvar_34;
  highp vec2 P_35;
  P_35 = ((xlv_TEXCOORD2.xy * _BumpScale) + _BumpOffset.xy);
  tmpvar_34 = texture2D (_BumpMap, P_35);
  normalZ_10 = tmpvar_34;
  highp vec3 tmpvar_36;
  tmpvar_36 = abs(xlv_TEXCOORD2);
  highp vec4 tmpvar_37;
  tmpvar_37 = mix (detailZ_13, detailX_15, tmpvar_36.xxxx);
  detail_9 = tmpvar_37;
  highp vec4 tmpvar_38;
  tmpvar_38 = mix (detail_9, detailY_14, tmpvar_36.yyyy);
  detail_9 = tmpvar_38;
  highp vec4 tmpvar_39;
  tmpvar_39 = mix (normalZ_10, normalX_12, tmpvar_36.xxxx);
  normal_8 = tmpvar_39;
  highp vec4 tmpvar_40;
  tmpvar_40 = mix (normal_8, normalY_11, tmpvar_36.yyyy);
  normal_8 = tmpvar_40;
  highp float tmpvar_41;
  tmpvar_41 = clamp ((2.0 * xlv_TEXCOORD1.x), 0.0, 1.0);
  detailLevel_7 = tmpvar_41;
  mediump vec3 tmpvar_42;
  tmpvar_42 = ((main_16.xyz * mix (detail_9.xyz, vec3(1.0, 1.0, 1.0), vec3(detailLevel_7))) * _Color.xyz);
  tmpvar_3 = tmpvar_42;
  mediump float tmpvar_43;
  tmpvar_43 = (main_16.w * mix (detail_9.w, 1.0, detailLevel_7));
  highp float tmpvar_44;
  tmpvar_44 = clamp (normalize(xlv_TEXCOORD0).z, 0.0, 1.0);
  rim_6 = tmpvar_44;
  highp float tmpvar_45;
  tmpvar_45 = ((tmpvar_43 * xlv_TEXCOORD1.y) * clamp (((1.0 - xlv_TEXCOORD1.y) + clamp (pow ((_FalloffScale * rim_6), _FalloffPow), 0.0, 1.0)), 0.0, 1.0));
  tmpvar_5 = tmpvar_45;
  lowp vec3 tmpvar_46;
  lowp vec4 packednormal_47;
  packednormal_47 = normal_8;
  tmpvar_46 = ((packednormal_47.xyz * 2.0) - 1.0);
  mediump vec3 tmpvar_48;
  tmpvar_48 = mix (tmpvar_46, vec3(0.0, 0.0, 1.0), vec3(detailLevel_7));
  tmpvar_4 = tmpvar_48;
  tmpvar_2 = tmpvar_4;
  mediump vec3 lightDir_49;
  lightDir_49 = xlv_TEXCOORD3;
  mediump vec4 c_50;
  mediump float tmpvar_51;
  tmpvar_51 = clamp (dot (tmpvar_4, lightDir_49), 0.0, 1.0);
  highp vec3 tmpvar_52;
  tmpvar_52 = clamp ((_MinLight + (_LightColor0.xyz * (tmpvar_51 * 2.0))), 0.0, 1.0);
  lowp vec3 tmpvar_53;
  tmpvar_53 = (tmpvar_3 * tmpvar_52);
  c_50.xyz = tmpvar_53;
  c_50.w = tmpvar_5;
  c_1 = c_50;
  c_1.xyz = (c_1.xyz + (tmpvar_3 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES


#ifdef VERTEX

varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _DetailDist;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;
uniform highp mat4 glstate_matrix_mvp;
uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  highp vec2 tmpvar_5;
  highp vec3 tmpvar_6;
  tmpvar_6 = (_Object2World * _glesVertex).xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (_Object2World * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
  highp vec3 p_8;
  p_8 = (tmpvar_6 - _WorldSpaceCameraPos);
  tmpvar_5.x = (_DetailDist * sqrt(dot (p_8, p_8)));
  highp vec3 p_9;
  p_9 = (tmpvar_7 - _WorldSpaceCameraPos);
  highp vec3 p_10;
  p_10 = (tmpvar_7 - tmpvar_6);
  tmpvar_5.y = clamp ((sqrt(dot (p_9, p_9)) - (1.0005 * sqrt(dot (p_10, p_10)))), 0.0, 1.0);
  highp vec3 tmpvar_11;
  highp vec3 tmpvar_12;
  tmpvar_11 = tmpvar_1.xyz;
  tmpvar_12 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_13;
  tmpvar_13[0].x = tmpvar_11.x;
  tmpvar_13[0].y = tmpvar_12.x;
  tmpvar_13[0].z = tmpvar_2.x;
  tmpvar_13[1].x = tmpvar_11.y;
  tmpvar_13[1].y = tmpvar_12.y;
  tmpvar_13[1].z = tmpvar_2.y;
  tmpvar_13[2].x = tmpvar_11.z;
  tmpvar_13[2].y = tmpvar_12.z;
  tmpvar_13[2].z = tmpvar_2.z;
  highp vec3 tmpvar_14;
  tmpvar_14 = (tmpvar_13 * (_World2Object * _WorldSpaceLightPos0).xyz);
  tmpvar_3 = tmpvar_14;
  highp vec4 tmpvar_15;
  tmpvar_15.w = 1.0;
  tmpvar_15.xyz = _WorldSpaceCameraPos;
  highp vec3 tmpvar_16;
  tmpvar_16 = glstate_lightmodel_ambient.xyz;
  tmpvar_4 = tmpvar_16;
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_TEXCOORD0 = (tmpvar_13 * (((_World2Object * tmpvar_15).xyz * unity_Scale.w) - _glesVertex.xyz));
  xlv_TEXCOORD1 = tmpvar_5;
  xlv_TEXCOORD2 = normalize(_glesVertex.xyz);
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
}



#endif
#ifdef FRAGMENT

varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _MinLight;
uniform highp float _BumpScale;
uniform highp float _DetailScale;
uniform highp float _FalloffScale;
uniform highp float _FalloffPow;
uniform lowp vec4 _BumpOffset;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _Color;
uniform sampler2D _BumpMap;
uniform sampler2D _DetailTex;
uniform sampler2D _MainTex;
uniform lowp vec4 _LightColor0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  lowp float tmpvar_5;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  tmpvar_4 = tmpvar_2;
  tmpvar_5 = 0.0;
  mediump float rim_6;
  mediump float detailLevel_7;
  mediump vec4 normal_8;
  mediump vec4 detail_9;
  mediump vec4 normalZ_10;
  mediump vec4 normalY_11;
  mediump vec4 normalX_12;
  mediump vec4 detailZ_13;
  mediump vec4 detailY_14;
  mediump vec4 detailX_15;
  mediump vec4 main_16;
  highp vec2 uv_17;
  highp float r_18;
  if ((abs(xlv_TEXCOORD2.x) > (1e-08 * abs(xlv_TEXCOORD2.z)))) {
    highp float y_over_x_19;
    y_over_x_19 = (xlv_TEXCOORD2.z / xlv_TEXCOORD2.x);
    highp float s_20;
    highp float x_21;
    x_21 = (y_over_x_19 * inversesqrt(((y_over_x_19 * y_over_x_19) + 1.0)));
    s_20 = (sign(x_21) * (1.5708 - (sqrt((1.0 - abs(x_21))) * (1.5708 + (abs(x_21) * (-0.214602 + (abs(x_21) * (0.0865667 + (abs(x_21) * -0.0310296)))))))));
    r_18 = s_20;
    if ((xlv_TEXCOORD2.x < 0.0)) {
      if ((xlv_TEXCOORD2.z >= 0.0)) {
        r_18 = (s_20 + 3.14159);
      } else {
        r_18 = (r_18 - 3.14159);
      };
    };
  } else {
    r_18 = (sign(xlv_TEXCOORD2.z) * 1.5708);
  };
  uv_17.x = (0.5 + (0.159155 * r_18));
  highp float x_22;
  x_22 = -(xlv_TEXCOORD2.y);
  uv_17.y = (0.31831 * (1.5708 - (sign(x_22) * (1.5708 - (sqrt((1.0 - abs(x_22))) * (1.5708 + (abs(x_22) * (-0.214602 + (abs(x_22) * (0.0865667 + (abs(x_22) * -0.0310296)))))))))));
  lowp vec4 tmpvar_23;
  tmpvar_23 = (texture2D (_MainTex, uv_17) * _Color);
  main_16 = tmpvar_23;
  lowp vec4 tmpvar_24;
  highp vec2 P_25;
  P_25 = ((xlv_TEXCOORD2.zy * _DetailScale) + _DetailOffset.xy);
  tmpvar_24 = texture2D (_DetailTex, P_25);
  detailX_15 = tmpvar_24;
  lowp vec4 tmpvar_26;
  highp vec2 P_27;
  P_27 = ((xlv_TEXCOORD2.zx * _DetailScale) + _DetailOffset.xy);
  tmpvar_26 = texture2D (_DetailTex, P_27);
  detailY_14 = tmpvar_26;
  lowp vec4 tmpvar_28;
  highp vec2 P_29;
  P_29 = ((xlv_TEXCOORD2.xy * _DetailScale) + _DetailOffset.xy);
  tmpvar_28 = texture2D (_DetailTex, P_29);
  detailZ_13 = tmpvar_28;
  lowp vec4 tmpvar_30;
  highp vec2 P_31;
  P_31 = ((xlv_TEXCOORD2.zy * _BumpScale) + _BumpOffset.xy);
  tmpvar_30 = texture2D (_BumpMap, P_31);
  normalX_12 = tmpvar_30;
  lowp vec4 tmpvar_32;
  highp vec2 P_33;
  P_33 = ((xlv_TEXCOORD2.zx * _BumpScale) + _BumpOffset.xy);
  tmpvar_32 = texture2D (_BumpMap, P_33);
  normalY_11 = tmpvar_32;
  lowp vec4 tmpvar_34;
  highp vec2 P_35;
  P_35 = ((xlv_TEXCOORD2.xy * _BumpScale) + _BumpOffset.xy);
  tmpvar_34 = texture2D (_BumpMap, P_35);
  normalZ_10 = tmpvar_34;
  highp vec3 tmpvar_36;
  tmpvar_36 = abs(xlv_TEXCOORD2);
  highp vec4 tmpvar_37;
  tmpvar_37 = mix (detailZ_13, detailX_15, tmpvar_36.xxxx);
  detail_9 = tmpvar_37;
  highp vec4 tmpvar_38;
  tmpvar_38 = mix (detail_9, detailY_14, tmpvar_36.yyyy);
  detail_9 = tmpvar_38;
  highp vec4 tmpvar_39;
  tmpvar_39 = mix (normalZ_10, normalX_12, tmpvar_36.xxxx);
  normal_8 = tmpvar_39;
  highp vec4 tmpvar_40;
  tmpvar_40 = mix (normal_8, normalY_11, tmpvar_36.yyyy);
  normal_8 = tmpvar_40;
  highp float tmpvar_41;
  tmpvar_41 = clamp ((2.0 * xlv_TEXCOORD1.x), 0.0, 1.0);
  detailLevel_7 = tmpvar_41;
  mediump vec3 tmpvar_42;
  tmpvar_42 = ((main_16.xyz * mix (detail_9.xyz, vec3(1.0, 1.0, 1.0), vec3(detailLevel_7))) * _Color.xyz);
  tmpvar_3 = tmpvar_42;
  mediump float tmpvar_43;
  tmpvar_43 = (main_16.w * mix (detail_9.w, 1.0, detailLevel_7));
  highp float tmpvar_44;
  tmpvar_44 = clamp (normalize(xlv_TEXCOORD0).z, 0.0, 1.0);
  rim_6 = tmpvar_44;
  highp float tmpvar_45;
  tmpvar_45 = ((tmpvar_43 * xlv_TEXCOORD1.y) * clamp (((1.0 - xlv_TEXCOORD1.y) + clamp (pow ((_FalloffScale * rim_6), _FalloffPow), 0.0, 1.0)), 0.0, 1.0));
  tmpvar_5 = tmpvar_45;
  lowp vec4 packednormal_46;
  packednormal_46 = normal_8;
  lowp vec3 normal_47;
  normal_47.xy = ((packednormal_46.wy * 2.0) - 1.0);
  normal_47.z = sqrt((1.0 - clamp (dot (normal_47.xy, normal_47.xy), 0.0, 1.0)));
  mediump vec3 tmpvar_48;
  tmpvar_48 = mix (normal_47, vec3(0.0, 0.0, 1.0), vec3(detailLevel_7));
  tmpvar_4 = tmpvar_48;
  tmpvar_2 = tmpvar_4;
  mediump vec3 lightDir_49;
  lightDir_49 = xlv_TEXCOORD3;
  mediump vec4 c_50;
  mediump float tmpvar_51;
  tmpvar_51 = clamp (dot (tmpvar_4, lightDir_49), 0.0, 1.0);
  highp vec3 tmpvar_52;
  tmpvar_52 = clamp ((_MinLight + (_LightColor0.xyz * (tmpvar_51 * 2.0))), 0.0, 1.0);
  lowp vec3 tmpvar_53;
  tmpvar_53 = (tmpvar_3 * tmpvar_52);
  c_50.xyz = tmpvar_53;
  c_50.w = tmpvar_5;
  c_1 = c_50;
  c_1.xyz = (c_1.xyz + (tmpvar_3 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "gles3 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES3#version 300 es


#ifdef VERTEX

#define gl_Vertex _glesVertex
in vec4 _glesVertex;
#define gl_Color _glesColor
in vec4 _glesColor;
#define gl_Normal (normalize(_glesNormal))
in vec3 _glesNormal;
#define gl_MultiTexCoord0 _glesMultiTexCoord0
in vec4 _glesMultiTexCoord0;
#define gl_MultiTexCoord1 _glesMultiTexCoord1
in vec4 _glesMultiTexCoord1;
#define TANGENT vec4(normalize(_glesTANGENT.xyz), _glesTANGENT.w)
in vec4 _glesTANGENT;
mat2 xll_transpose_mf2x2(mat2 m) {
  return mat2( m[0][0], m[1][0], m[0][1], m[1][1]);
}
mat3 xll_transpose_mf3x3(mat3 m) {
  return mat3( m[0][0], m[1][0], m[2][0],
               m[0][1], m[1][1], m[2][1],
               m[0][2], m[1][2], m[2][2]);
}
mat4 xll_transpose_mf4x4(mat4 m) {
  return mat4( m[0][0], m[1][0], m[2][0], m[3][0],
               m[0][1], m[1][1], m[2][1], m[3][1],
               m[0][2], m[1][2], m[2][2], m[3][2],
               m[0][3], m[1][3], m[2][3], m[3][3]);
}
float xll_saturate_f( float x) {
  return clamp( x, 0.0, 1.0);
}
vec2 xll_saturate_vf2( vec2 x) {
  return clamp( x, 0.0, 1.0);
}
vec3 xll_saturate_vf3( vec3 x) {
  return clamp( x, 0.0, 1.0);
}
vec4 xll_saturate_vf4( vec4 x) {
  return clamp( x, 0.0, 1.0);
}
mat2 xll_saturate_mf2x2(mat2 m) {
  return mat2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0));
}
mat3 xll_saturate_mf3x3(mat3 m) {
  return mat3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0));
}
mat4 xll_saturate_mf4x4(mat4 m) {
  return mat4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0));
}
#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 315
struct SurfaceOutput {
    lowp vec3 Albedo;
    lowp vec3 Normal;
    lowp vec3 Emission;
    mediump float Specular;
    lowp float Gloss;
    lowp float Alpha;
};
#line 67
struct appdata_full {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
    highp vec4 texcoord1;
    lowp vec4 color;
};
#line 411
struct Input {
    highp vec2 viewDist;
    highp vec3 viewDir;
    highp vec3 localPos;
};
#line 455
struct v2f_surf {
    highp vec4 pos;
    highp vec3 viewDir;
    highp vec2 cust_viewDist;
    highp vec3 cust_localPos;
    lowp vec3 lightDir;
    lowp vec3 vlight;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform lowp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 325
uniform lowp vec4 _LightColor0;
uniform lowp vec4 _SpecColor;
#line 338
#line 346
#line 360
uniform sampler2D _MainTex;
uniform sampler2D _DetailTex;
#line 393
uniform sampler2D _BumpMap;
uniform lowp vec4 _Color;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _BumpOffset;
#line 397
uniform highp float _FalloffPow;
uniform highp float _FalloffScale;
uniform highp float _DetailScale;
uniform highp float _DetailDist;
#line 401
uniform highp float _BumpScale;
uniform highp float _MinLight;
#line 418
#line 465
#line 82
highp vec3 ObjSpaceLightDir( in highp vec4 v ) {
    highp vec3 objSpaceLightPos = (_World2Object * _WorldSpaceLightPos0).xyz;
    return objSpaceLightPos.xyz;
}
#line 91
highp vec3 ObjSpaceViewDir( in highp vec4 v ) {
    highp vec3 objSpaceCameraPos = ((_World2Object * vec4( _WorldSpaceCameraPos.xyz, 1.0)).xyz * unity_Scale.w);
    return (objSpaceCameraPos - v.xyz);
}
#line 418
void vert( inout appdata_full v, out Input o ) {
    highp vec3 vertexPos = (_Object2World * v.vertex).xyz;
    #line 422
    highp vec3 origin = (_Object2World * vec4( 0.0, 0.0, 0.0, 1.0)).xyz;
    highp float diff = (_DetailDist * distance( vertexPos, _WorldSpaceCameraPos));
    o.viewDist.x = diff;
    o.viewDist.y = xll_saturate_f((distance( origin, _WorldSpaceCameraPos) - (1.0005 * distance( origin, vertexPos))));
    #line 426
    o.localPos = normalize(v.vertex.xyz);
}
#line 465
v2f_surf vert_surf( in appdata_full v ) {
    v2f_surf o;
    Input customInputData;
    #line 469
    vert( v, customInputData);
    o.cust_viewDist = customInputData.viewDist;
    o.cust_localPos = customInputData.localPos;
    o.pos = (glstate_matrix_mvp * v.vertex);
    #line 473
    highp vec3 worldN = (mat3( _Object2World) * (v.normal * unity_Scale.w));
    highp vec3 binormal = (cross( v.normal, v.tangent.xyz) * v.tangent.w);
    highp mat3 rotation = xll_transpose_mf3x3(mat3( v.tangent.xyz, binormal, v.normal));
    highp vec3 lightDir = (rotation * ObjSpaceLightDir( v.vertex));
    #line 477
    o.lightDir = lightDir;
    highp vec3 viewDirForLight = (rotation * ObjSpaceViewDir( v.vertex));
    o.viewDir = viewDirForLight;
    o.vlight = glstate_lightmodel_ambient.xyz;
    #line 482
    return o;
}

out highp vec3 xlv_TEXCOORD0;
out highp vec2 xlv_TEXCOORD1;
out highp vec3 xlv_TEXCOORD2;
out lowp vec3 xlv_TEXCOORD3;
out lowp vec3 xlv_TEXCOORD4;
void main() {
    v2f_surf xl_retval;
    appdata_full xlt_v;
    xlt_v.vertex = vec4(gl_Vertex);
    xlt_v.tangent = vec4(TANGENT);
    xlt_v.normal = vec3(gl_Normal);
    xlt_v.texcoord = vec4(gl_MultiTexCoord0);
    xlt_v.texcoord1 = vec4(gl_MultiTexCoord1);
    xlt_v.color = vec4(gl_Color);
    xl_retval = vert_surf( xlt_v);
    gl_Position = vec4(xl_retval.pos);
    xlv_TEXCOORD0 = vec3(xl_retval.viewDir);
    xlv_TEXCOORD1 = vec2(xl_retval.cust_viewDist);
    xlv_TEXCOORD2 = vec3(xl_retval.cust_localPos);
    xlv_TEXCOORD3 = vec3(xl_retval.lightDir);
    xlv_TEXCOORD4 = vec3(xl_retval.vlight);
}


#endif
#ifdef FRAGMENT

#define gl_FragData _glesFragData
layout(location = 0) out mediump vec4 _glesFragData[4];
float xll_saturate_f( float x) {
  return clamp( x, 0.0, 1.0);
}
vec2 xll_saturate_vf2( vec2 x) {
  return clamp( x, 0.0, 1.0);
}
vec3 xll_saturate_vf3( vec3 x) {
  return clamp( x, 0.0, 1.0);
}
vec4 xll_saturate_vf4( vec4 x) {
  return clamp( x, 0.0, 1.0);
}
mat2 xll_saturate_mf2x2(mat2 m) {
  return mat2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0));
}
mat3 xll_saturate_mf3x3(mat3 m) {
  return mat3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0));
}
mat4 xll_saturate_mf4x4(mat4 m) {
  return mat4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0));
}
#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 315
struct SurfaceOutput {
    lowp vec3 Albedo;
    lowp vec3 Normal;
    lowp vec3 Emission;
    mediump float Specular;
    lowp float Gloss;
    lowp float Alpha;
};
#line 67
struct appdata_full {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
    highp vec4 texcoord1;
    lowp vec4 color;
};
#line 411
struct Input {
    highp vec2 viewDist;
    highp vec3 viewDir;
    highp vec3 localPos;
};
#line 455
struct v2f_surf {
    highp vec4 pos;
    highp vec3 viewDir;
    highp vec2 cust_viewDist;
    highp vec3 cust_localPos;
    lowp vec3 lightDir;
    lowp vec3 vlight;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform lowp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 325
uniform lowp vec4 _LightColor0;
uniform lowp vec4 _SpecColor;
#line 338
#line 346
#line 360
uniform sampler2D _MainTex;
uniform sampler2D _DetailTex;
#line 393
uniform sampler2D _BumpMap;
uniform lowp vec4 _Color;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _BumpOffset;
#line 397
uniform highp float _FalloffPow;
uniform highp float _FalloffScale;
uniform highp float _DetailScale;
uniform highp float _DetailDist;
#line 401
uniform highp float _BumpScale;
uniform highp float _MinLight;
#line 418
#line 465
#line 403
mediump vec4 LightingSimpleLambert( in SurfaceOutput s, in mediump vec3 lightDir, in mediump float atten ) {
    #line 405
    mediump float NdotL = xll_saturate_f(dot( s.Normal, lightDir));
    mediump vec4 c;
    c.xyz = (s.Albedo * xll_saturate_vf3((_MinLight + (_LightColor0.xyz * ((NdotL * atten) * 2.0)))));
    c.w = s.Alpha;
    #line 409
    return c;
}
#line 272
lowp vec3 UnpackNormal( in lowp vec4 packednormal ) {
    #line 274
    return ((packednormal.xyz * 2.0) - 1.0);
}
#line 428
void surf( in Input IN, inout SurfaceOutput o ) {
    #line 430
    highp vec3 pos = IN.localPos;
    highp vec2 uv;
    uv.x = (0.5 + (0.159155 * atan( pos.z, pos.x)));
    uv.y = (0.31831 * acos((-pos.y)));
    #line 434
    mediump vec4 main = (texture( _MainTex, uv) * _Color);
    mediump vec4 detailX = texture( _DetailTex, ((pos.zy * _DetailScale) + _DetailOffset.xy));
    mediump vec4 detailY = texture( _DetailTex, ((pos.zx * _DetailScale) + _DetailOffset.xy));
    mediump vec4 detailZ = texture( _DetailTex, ((pos.xy * _DetailScale) + _DetailOffset.xy));
    #line 438
    mediump vec4 normalX = texture( _BumpMap, ((pos.zy * _BumpScale) + _BumpOffset.xy));
    mediump vec4 normalY = texture( _BumpMap, ((pos.zx * _BumpScale) + _BumpOffset.xy));
    mediump vec4 normalZ = texture( _BumpMap, ((pos.xy * _BumpScale) + _BumpOffset.xy));
    pos = abs(pos);
    #line 442
    mediump vec4 detail = mix( detailZ, detailX, vec4( pos.x));
    detail = mix( detail, detailY, vec4( pos.y));
    mediump vec4 normal = mix( normalZ, normalX, vec4( pos.x));
    normal = mix( normal, normalY, vec4( pos.y));
    #line 446
    mediump float detailLevel = xll_saturate_f((2.0 * IN.viewDist.x));
    mediump vec3 albedo = (main.xyz * mix( detail.xyz, vec3( 1.0), vec3( detailLevel)));
    o.Normal = vec3( 0.0, 0.0, 1.0);
    o.Albedo = (albedo * _Color.xyz);
    #line 450
    mediump float avg = (main.w * mix( detail.w, 1.0, detailLevel));
    mediump float rim = xll_saturate_f(dot( normalize(IN.viewDir), o.Normal));
    o.Alpha = ((avg * IN.viewDist.y) * xll_saturate_f(((1.0 - IN.viewDist.y) + xll_saturate_f(pow( (_FalloffScale * rim), _FalloffPow)))));
    o.Normal = mix( UnpackNormal( normal), vec3( 0.0, 0.0, 1.0), vec3( detailLevel));
}
#line 484
lowp vec4 frag_surf( in v2f_surf IN ) {
    #line 486
    Input surfIN;
    surfIN.viewDist = IN.cust_viewDist;
    surfIN.localPos = IN.cust_localPos;
    surfIN.viewDir = IN.viewDir;
    #line 490
    SurfaceOutput o;
    o.Albedo = vec3( 0.0);
    o.Emission = vec3( 0.0);
    o.Specular = 0.0;
    #line 494
    o.Alpha = 0.0;
    o.Gloss = 0.0;
    surf( surfIN, o);
    lowp float atten = 1.0;
    #line 498
    lowp vec4 c = vec4( 0.0);
    c = LightingSimpleLambert( o, IN.lightDir, atten);
    c.xyz += (o.Albedo * IN.vlight);
    return c;
}
in highp vec3 xlv_TEXCOORD0;
in highp vec2 xlv_TEXCOORD1;
in highp vec3 xlv_TEXCOORD2;
in lowp vec3 xlv_TEXCOORD3;
in lowp vec3 xlv_TEXCOORD4;
void main() {
    lowp vec4 xl_retval;
    v2f_surf xlt_IN;
    xlt_IN.pos = vec4(0.0);
    xlt_IN.viewDir = vec3(xlv_TEXCOORD0);
    xlt_IN.cust_viewDist = vec2(xlv_TEXCOORD1);
    xlt_IN.cust_localPos = vec3(xlv_TEXCOORD2);
    xlt_IN.lightDir = vec3(xlv_TEXCOORD3);
    xlt_IN.vlight = vec3(xlv_TEXCOORD4);
    xl_retval = frag_surf( xlt_IN);
    gl_FragData[0] = vec4(xl_retval);
}


#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Bind "vertex" Vertex
Bind "tangent" ATTR14
Bind "normal" Normal
Vector 2 [_WorldSpaceCameraPos]
Vector 3 [_ProjectionParams]
Vector 4 [_WorldSpaceLightPos0]
Matrix 5 [_Object2World]
Matrix 9 [_World2Object]
Vector 17 [unity_Scale]
Float 18 [_DetailDist]
"3.0-!!ARBvp1.0
# 56 ALU
PARAM c[19] = { { 1, 1.0005, 0, 0.5 },
		state.lightmodel.ambient,
		program.local[2..12],
		state.matrix.mvp,
		program.local[17..18] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
MOV R0.xyz, vertex.attrib[14];
MUL R1.xyz, vertex.normal.zxyw, R0.yzxw;
MAD R0.xyz, vertex.normal.yzxw, R0.zxyw, -R1;
MOV R1.w, c[0].x;
MOV R1.xyz, c[2];
DP4 R2.z, R1, c[11];
DP4 R2.x, R1, c[9];
DP4 R2.y, R1, c[10];
MAD R3.xyz, R2, c[17].w, -vertex.position;
MUL R2.xyz, R0, vertex.attrib[14].w;
MOV R1, c[4];
DP4 R0.z, R1, c[11];
DP4 R0.x, R1, c[9];
DP4 R0.y, R1, c[10];
DP3 result.texcoord[3].y, R2, R0;
DP3 result.texcoord[0].y, R3, R2;
DP3 result.texcoord[3].z, vertex.normal, R0;
DP3 result.texcoord[3].x, vertex.attrib[14], R0;
MOV R1.z, c[7].w;
MOV R1.x, c[5].w;
MOV R1.y, c[6].w;
ADD R4.xyz, -R1, c[2];
DP4 R2.z, vertex.position, c[7];
DP4 R2.x, vertex.position, c[5];
DP4 R2.y, vertex.position, c[6];
ADD R1.xyz, R2, -R1;
DP3 R0.w, R1, R1;
DP3 R1.w, R4, R4;
RSQ R1.x, R1.w;
RSQ R0.w, R0.w;
DP4 R1.w, vertex.position, c[16];
DP4 R1.z, vertex.position, c[15];
RCP R1.x, R1.x;
RCP R0.w, R0.w;
MAD R0.w, -R0, c[0].y, R1.x;
MIN R0.w, R0, c[0].x;
DP4 R1.x, vertex.position, c[13];
DP4 R1.y, vertex.position, c[14];
DP3 result.texcoord[0].z, vertex.normal, R3;
DP3 result.texcoord[0].x, R3, vertex.attrib[14];
MUL R3.xyz, R1.xyww, c[0].w;
MUL R0.y, R3, c[3].x;
MOV R0.x, R3;
ADD result.texcoord[5].xy, R0, R3.z;
ADD R0.xyz, -R2, c[2];
DP3 R0.x, R0, R0;
RSQ R0.x, R0.x;
DP3 R0.y, vertex.position, vertex.position;
RCP R0.x, R0.x;
RSQ R0.y, R0.y;
MAX result.texcoord[1].y, R0.w, c[0].z;
MOV result.position, R1;
MOV result.texcoord[5].zw, R1;
MUL result.texcoord[1].x, R0, c[18];
MUL result.texcoord[2].xyz, R0.y, vertex.position;
MOV result.texcoord[4].xyz, c[1];
END
# 56 instructions, 5 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Vector 12 [glstate_lightmodel_ambient]
Matrix 0 [glstate_matrix_mvp]
Vector 13 [_WorldSpaceCameraPos]
Vector 14 [_ProjectionParams]
Vector 15 [_ScreenParams]
Vector 16 [_WorldSpaceLightPos0]
Matrix 4 [_Object2World]
Matrix 8 [_World2Object]
Vector 17 [unity_Scale]
Float 18 [_DetailDist]
"vs_3_0
; 56 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_texcoord5 o6
def c19, 1.00000000, 1.00049996, 0.50000000, 0
dcl_position0 v0
dcl_tangent0 v1
dcl_normal0 v2
mov r0.xyz, v1
mul r1.xyz, v2.zxyw, r0.yzxw
mov r0.xyz, v1
mad r0.xyz, v2.yzxw, r0.zxyw, -r1
mul r3.xyz, r0, v1.w
mov r0, c10
dp4 r4.z, c16, r0
mov r0, c9
dp4 r4.y, c16, r0
mov r1.w, c19.x
mov r1.xyz, c13
dp4 r2.z, r1, c10
dp4 r2.x, r1, c8
dp4 r2.y, r1, c9
mad r2.xyz, r2, c17.w, -v0
mov r1, c8
dp4 r4.x, c16, r1
mov r0.z, c6.w
mov r0.x, c4.w
mov r0.y, c5.w
dp4 r1.z, v0, c6
dp4 r1.x, v0, c4
dp4 r1.y, v0, c5
dp3 o1.y, r2, r3
dp3 o1.z, v2, r2
dp3 o1.x, r2, v1
add r2.xyz, -r0, c13
add r0.xyz, r1, -r0
dp3 r0.x, r0, r0
dp3 r0.w, r2, r2
rsq r0.y, r0.w
rsq r0.x, r0.x
dp4 r0.w, v0, c3
dp4 r0.z, v0, c2
rcp r0.y, r0.y
rcp r0.x, r0.x
mad_sat o2.y, -r0.x, c19, r0
dp4 r0.x, v0, c0
dp4 r0.y, v0, c1
mul r2.xyz, r0.xyww, c19.z
mov o0, r0
mul r2.y, r2, c14.x
add r1.xyz, -r1, c13
dp3 r0.x, r1, r1
rsq r0.x, r0.x
dp3 r0.y, v0, v0
rcp r0.x, r0.x
rsq r0.y, r0.y
dp3 o4.y, r3, r4
dp3 o4.z, v2, r4
dp3 o4.x, v1, r4
mad o6.xy, r2.z, c15.zwzw, r2
mov o6.zw, r0
mul o2.x, r0, c18
mul o3.xyz, r0.y, v0
mov o5.xyz, c12
"
}

SubProgram "d3d11 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "color" Color
ConstBuffer "$Globals" 192 // 176 used size, 13 vars
Float 172 [_DetailDist]
ConstBuffer "UnityPerCamera" 128 // 96 used size, 8 vars
Vector 64 [_WorldSpaceCameraPos] 3
Vector 80 [_ProjectionParams] 4
ConstBuffer "UnityLighting" 720 // 16 used size, 17 vars
Vector 0 [_WorldSpaceLightPos0] 4
ConstBuffer "UnityPerDraw" 336 // 336 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
Matrix 192 [_Object2World] 4
Matrix 256 [_World2Object] 4
Vector 320 [unity_Scale] 4
ConstBuffer "UnityPerFrame" 208 // 80 used size, 4 vars
Vector 64 [glstate_lightmodel_ambient] 4
BindCB "$Globals" 0
BindCB "UnityPerCamera" 1
BindCB "UnityLighting" 2
BindCB "UnityPerDraw" 3
BindCB "UnityPerFrame" 4
// 47 instructions, 4 temp regs, 0 temp arrays:
// ALU 43 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0
eefiecedmhjbampoddpgbiepflodmedjbnifhnaiabaaaaaaimaiaaaaadaaaaaa
cmaaaaaapeaaaaaameabaaaaejfdeheomaaaaaaaagaaaaaaaiaaaaaajiaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaakbaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaakjaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
ahahaaaalaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaadaaaaaaapaaaaaalaaaaaaa
abaaaaaaaaaaaaaaadaaaaaaaeaaaaaaapaaaaaaljaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaafaaaaaaapaaaaaafaepfdejfeejepeoaafeebeoehefeofeaaeoepfc
enebemaafeeffiedepepfceeaaedepemepfcaaklepfdeheomiaaaaaaahaaaaaa
aiaaaaaalaaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaalmaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaabaaaaaaahaiaaaalmaaaaaaabaaaaaaaaaaaaaa
adaaaaaaacaaaaaaadamaaaalmaaaaaaacaaaaaaaaaaaaaaadaaaaaaadaaaaaa
ahaiaaaalmaaaaaaadaaaaaaaaaaaaaaadaaaaaaaeaaaaaaahaiaaaalmaaaaaa
aeaaaaaaaaaaaaaaadaaaaaaafaaaaaaahaiaaaalmaaaaaaafaaaaaaaaaaaaaa
adaaaaaaagaaaaaaapaaaaaafdfgfpfaepfdejfeejepeoaafeeffiedepepfcee
aaklklklfdeieefcmaagaaaaeaaaabaalaabaaaafjaaaaaeegiocaaaaaaaaaaa
alaaaaaafjaaaaaeegiocaaaabaaaaaaagaaaaaafjaaaaaeegiocaaaacaaaaaa
abaaaaaafjaaaaaeegiocaaaadaaaaaabfaaaaaafjaaaaaeegiocaaaaeaaaaaa
afaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaadpcbabaaaabaaaaaafpaaaaad
hcbabaaaacaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaadhccabaaa
abaaaaaagfaaaaaddccabaaaacaaaaaagfaaaaadhccabaaaadaaaaaagfaaaaad
hccabaaaaeaaaaaagfaaaaadhccabaaaafaaaaaagfaaaaadpccabaaaagaaaaaa
giaaaaacaeaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiocaaa
adaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaadaaaaaaaaaaaaaa
agbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaa
adaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaa
aaaaaaaaegiocaaaadaaaaaaadaaaaaapgbpbaaaaaaaaaaaegaobaaaaaaaaaaa
dgaaaaafpccabaaaaaaaaaaaegaobaaaaaaaaaaadiaaaaahhcaabaaaabaaaaaa
jgbebaaaabaaaaaacgbjbaaaacaaaaaadcaaaaakhcaabaaaabaaaaaajgbebaaa
acaaaaaacgbjbaaaabaaaaaaegacbaiaebaaaaaaabaaaaaadiaaaaahhcaabaaa
abaaaaaaegacbaaaabaaaaaapgbpbaaaabaaaaaadiaaaaajhcaabaaaacaaaaaa
fgifcaaaabaaaaaaaeaaaaaaegiccaaaadaaaaaabbaaaaaadcaaaaalhcaabaaa
acaaaaaaegiccaaaadaaaaaabaaaaaaaagiacaaaabaaaaaaaeaaaaaaegacbaaa
acaaaaaadcaaaaalhcaabaaaacaaaaaaegiccaaaadaaaaaabcaaaaaakgikcaaa
abaaaaaaaeaaaaaaegacbaaaacaaaaaaaaaaaaaihcaabaaaacaaaaaaegacbaaa
acaaaaaaegiccaaaadaaaaaabdaaaaaadcaaaaalhcaabaaaacaaaaaaegacbaaa
acaaaaaapgipcaaaadaaaaaabeaaaaaaegbcbaiaebaaaaaaaaaaaaaabaaaaaah
cccabaaaabaaaaaaegacbaaaabaaaaaaegacbaaaacaaaaaabaaaaaahbccabaaa
abaaaaaaegbcbaaaabaaaaaaegacbaaaacaaaaaabaaaaaaheccabaaaabaaaaaa
egbcbaaaacaaaaaaegacbaaaacaaaaaaaaaaaaakhcaabaaaacaaaaaaegiccaia
ebaaaaaaabaaaaaaaeaaaaaaegiccaaaadaaaaaaapaaaaaabaaaaaahicaabaaa
abaaaaaaegacbaaaacaaaaaaegacbaaaacaaaaaaelaaaaaficaabaaaabaaaaaa
dkaabaaaabaaaaaadiaaaaaihcaabaaaacaaaaaafgbfbaaaaaaaaaaaegiccaaa
adaaaaaaanaaaaaadcaaaaakhcaabaaaacaaaaaaegiccaaaadaaaaaaamaaaaaa
agbabaaaaaaaaaaaegacbaaaacaaaaaadcaaaaakhcaabaaaacaaaaaaegiccaaa
adaaaaaaaoaaaaaakgbkbaaaaaaaaaaaegacbaaaacaaaaaadcaaaaakhcaabaaa
acaaaaaaegiccaaaadaaaaaaapaaaaaapgbpbaaaaaaaaaaaegacbaaaacaaaaaa
aaaaaaajhcaabaaaadaaaaaaegacbaiaebaaaaaaacaaaaaaegiccaaaadaaaaaa
apaaaaaaaaaaaaajhcaabaaaacaaaaaaegacbaaaacaaaaaaegiccaiaebaaaaaa
abaaaaaaaeaaaaaabaaaaaahbcaabaaaacaaaaaaegacbaaaacaaaaaaegacbaaa
acaaaaaaelaaaaafbcaabaaaacaaaaaaakaabaaaacaaaaaadiaaaaaibccabaaa
acaaaaaaakaabaaaacaaaaaadkiacaaaaaaaaaaaakaaaaaabaaaaaahbcaabaaa
acaaaaaaegacbaaaadaaaaaaegacbaaaadaaaaaaelaaaaafbcaabaaaacaaaaaa
akaabaaaacaaaaaadccaaaakcccabaaaacaaaaaaakaabaiaebaaaaaaacaaaaaa
abeaaaaagcbaiadpdkaabaaaabaaaaaabaaaaaahicaabaaaabaaaaaaegbcbaaa
aaaaaaaaegbcbaaaaaaaaaaaeeaaaaaficaabaaaabaaaaaadkaabaaaabaaaaaa
diaaaaahhccabaaaadaaaaaapgapbaaaabaaaaaaegbcbaaaaaaaaaaadiaaaaaj
hcaabaaaacaaaaaafgifcaaaacaaaaaaaaaaaaaaegiccaaaadaaaaaabbaaaaaa
dcaaaaalhcaabaaaacaaaaaaegiccaaaadaaaaaabaaaaaaaagiacaaaacaaaaaa
aaaaaaaaegacbaaaacaaaaaadcaaaaalhcaabaaaacaaaaaaegiccaaaadaaaaaa
bcaaaaaakgikcaaaacaaaaaaaaaaaaaaegacbaaaacaaaaaadcaaaaalhcaabaaa
acaaaaaaegiccaaaadaaaaaabdaaaaaapgipcaaaacaaaaaaaaaaaaaaegacbaaa
acaaaaaabaaaaaahcccabaaaaeaaaaaaegacbaaaabaaaaaaegacbaaaacaaaaaa
baaaaaahbccabaaaaeaaaaaaegbcbaaaabaaaaaaegacbaaaacaaaaaabaaaaaah
eccabaaaaeaaaaaaegbcbaaaacaaaaaaegacbaaaacaaaaaadgaaaaaghccabaaa
afaaaaaaegiccaaaaeaaaaaaaeaaaaaadiaaaaaiccaabaaaaaaaaaaabkaabaaa
aaaaaaaaakiacaaaabaaaaaaafaaaaaadiaaaaakncaabaaaabaaaaaaagahbaaa
aaaaaaaaaceaaaaaaaaaaadpaaaaaaaaaaaaaadpaaaaaadpdgaaaaafmccabaaa
agaaaaaakgaobaaaaaaaaaaaaaaaaaahdccabaaaagaaaaaakgakbaaaabaaaaaa
mgaabaaaabaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES


#ifdef VERTEX

varying highp vec4 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _DetailDist;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 unity_World2Shadow[4];
uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  highp vec2 tmpvar_5;
  highp vec3 tmpvar_6;
  tmpvar_6 = (_Object2World * _glesVertex).xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (_Object2World * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
  highp vec3 p_8;
  p_8 = (tmpvar_6 - _WorldSpaceCameraPos);
  tmpvar_5.x = (_DetailDist * sqrt(dot (p_8, p_8)));
  highp vec3 p_9;
  p_9 = (tmpvar_7 - _WorldSpaceCameraPos);
  highp vec3 p_10;
  p_10 = (tmpvar_7 - tmpvar_6);
  tmpvar_5.y = clamp ((sqrt(dot (p_9, p_9)) - (1.0005 * sqrt(dot (p_10, p_10)))), 0.0, 1.0);
  highp vec3 tmpvar_11;
  highp vec3 tmpvar_12;
  tmpvar_11 = tmpvar_1.xyz;
  tmpvar_12 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_13;
  tmpvar_13[0].x = tmpvar_11.x;
  tmpvar_13[0].y = tmpvar_12.x;
  tmpvar_13[0].z = tmpvar_2.x;
  tmpvar_13[1].x = tmpvar_11.y;
  tmpvar_13[1].y = tmpvar_12.y;
  tmpvar_13[1].z = tmpvar_2.y;
  tmpvar_13[2].x = tmpvar_11.z;
  tmpvar_13[2].y = tmpvar_12.z;
  tmpvar_13[2].z = tmpvar_2.z;
  highp vec3 tmpvar_14;
  tmpvar_14 = (tmpvar_13 * (_World2Object * _WorldSpaceLightPos0).xyz);
  tmpvar_3 = tmpvar_14;
  highp vec4 tmpvar_15;
  tmpvar_15.w = 1.0;
  tmpvar_15.xyz = _WorldSpaceCameraPos;
  highp vec3 tmpvar_16;
  tmpvar_16 = glstate_lightmodel_ambient.xyz;
  tmpvar_4 = tmpvar_16;
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_TEXCOORD0 = (tmpvar_13 * (((_World2Object * tmpvar_15).xyz * unity_Scale.w) - _glesVertex.xyz));
  xlv_TEXCOORD1 = tmpvar_5;
  xlv_TEXCOORD2 = normalize(_glesVertex.xyz);
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
  xlv_TEXCOORD5 = (unity_World2Shadow[0] * (_Object2World * _glesVertex));
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _MinLight;
uniform highp float _BumpScale;
uniform highp float _DetailScale;
uniform highp float _FalloffScale;
uniform highp float _FalloffPow;
uniform lowp vec4 _BumpOffset;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _Color;
uniform sampler2D _BumpMap;
uniform sampler2D _DetailTex;
uniform sampler2D _MainTex;
uniform sampler2D _ShadowMapTexture;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _LightShadowData;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  lowp float tmpvar_5;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  tmpvar_4 = tmpvar_2;
  tmpvar_5 = 0.0;
  mediump float rim_6;
  mediump float detailLevel_7;
  mediump vec4 normal_8;
  mediump vec4 detail_9;
  mediump vec4 normalZ_10;
  mediump vec4 normalY_11;
  mediump vec4 normalX_12;
  mediump vec4 detailZ_13;
  mediump vec4 detailY_14;
  mediump vec4 detailX_15;
  mediump vec4 main_16;
  highp vec2 uv_17;
  highp float r_18;
  if ((abs(xlv_TEXCOORD2.x) > (1e-08 * abs(xlv_TEXCOORD2.z)))) {
    highp float y_over_x_19;
    y_over_x_19 = (xlv_TEXCOORD2.z / xlv_TEXCOORD2.x);
    highp float s_20;
    highp float x_21;
    x_21 = (y_over_x_19 * inversesqrt(((y_over_x_19 * y_over_x_19) + 1.0)));
    s_20 = (sign(x_21) * (1.5708 - (sqrt((1.0 - abs(x_21))) * (1.5708 + (abs(x_21) * (-0.214602 + (abs(x_21) * (0.0865667 + (abs(x_21) * -0.0310296)))))))));
    r_18 = s_20;
    if ((xlv_TEXCOORD2.x < 0.0)) {
      if ((xlv_TEXCOORD2.z >= 0.0)) {
        r_18 = (s_20 + 3.14159);
      } else {
        r_18 = (r_18 - 3.14159);
      };
    };
  } else {
    r_18 = (sign(xlv_TEXCOORD2.z) * 1.5708);
  };
  uv_17.x = (0.5 + (0.159155 * r_18));
  highp float x_22;
  x_22 = -(xlv_TEXCOORD2.y);
  uv_17.y = (0.31831 * (1.5708 - (sign(x_22) * (1.5708 - (sqrt((1.0 - abs(x_22))) * (1.5708 + (abs(x_22) * (-0.214602 + (abs(x_22) * (0.0865667 + (abs(x_22) * -0.0310296)))))))))));
  lowp vec4 tmpvar_23;
  tmpvar_23 = (texture2D (_MainTex, uv_17) * _Color);
  main_16 = tmpvar_23;
  lowp vec4 tmpvar_24;
  highp vec2 P_25;
  P_25 = ((xlv_TEXCOORD2.zy * _DetailScale) + _DetailOffset.xy);
  tmpvar_24 = texture2D (_DetailTex, P_25);
  detailX_15 = tmpvar_24;
  lowp vec4 tmpvar_26;
  highp vec2 P_27;
  P_27 = ((xlv_TEXCOORD2.zx * _DetailScale) + _DetailOffset.xy);
  tmpvar_26 = texture2D (_DetailTex, P_27);
  detailY_14 = tmpvar_26;
  lowp vec4 tmpvar_28;
  highp vec2 P_29;
  P_29 = ((xlv_TEXCOORD2.xy * _DetailScale) + _DetailOffset.xy);
  tmpvar_28 = texture2D (_DetailTex, P_29);
  detailZ_13 = tmpvar_28;
  lowp vec4 tmpvar_30;
  highp vec2 P_31;
  P_31 = ((xlv_TEXCOORD2.zy * _BumpScale) + _BumpOffset.xy);
  tmpvar_30 = texture2D (_BumpMap, P_31);
  normalX_12 = tmpvar_30;
  lowp vec4 tmpvar_32;
  highp vec2 P_33;
  P_33 = ((xlv_TEXCOORD2.zx * _BumpScale) + _BumpOffset.xy);
  tmpvar_32 = texture2D (_BumpMap, P_33);
  normalY_11 = tmpvar_32;
  lowp vec4 tmpvar_34;
  highp vec2 P_35;
  P_35 = ((xlv_TEXCOORD2.xy * _BumpScale) + _BumpOffset.xy);
  tmpvar_34 = texture2D (_BumpMap, P_35);
  normalZ_10 = tmpvar_34;
  highp vec3 tmpvar_36;
  tmpvar_36 = abs(xlv_TEXCOORD2);
  highp vec4 tmpvar_37;
  tmpvar_37 = mix (detailZ_13, detailX_15, tmpvar_36.xxxx);
  detail_9 = tmpvar_37;
  highp vec4 tmpvar_38;
  tmpvar_38 = mix (detail_9, detailY_14, tmpvar_36.yyyy);
  detail_9 = tmpvar_38;
  highp vec4 tmpvar_39;
  tmpvar_39 = mix (normalZ_10, normalX_12, tmpvar_36.xxxx);
  normal_8 = tmpvar_39;
  highp vec4 tmpvar_40;
  tmpvar_40 = mix (normal_8, normalY_11, tmpvar_36.yyyy);
  normal_8 = tmpvar_40;
  highp float tmpvar_41;
  tmpvar_41 = clamp ((2.0 * xlv_TEXCOORD1.x), 0.0, 1.0);
  detailLevel_7 = tmpvar_41;
  mediump vec3 tmpvar_42;
  tmpvar_42 = ((main_16.xyz * mix (detail_9.xyz, vec3(1.0, 1.0, 1.0), vec3(detailLevel_7))) * _Color.xyz);
  tmpvar_3 = tmpvar_42;
  mediump float tmpvar_43;
  tmpvar_43 = (main_16.w * mix (detail_9.w, 1.0, detailLevel_7));
  highp float tmpvar_44;
  tmpvar_44 = clamp (normalize(xlv_TEXCOORD0).z, 0.0, 1.0);
  rim_6 = tmpvar_44;
  highp float tmpvar_45;
  tmpvar_45 = ((tmpvar_43 * xlv_TEXCOORD1.y) * clamp (((1.0 - xlv_TEXCOORD1.y) + clamp (pow ((_FalloffScale * rim_6), _FalloffPow), 0.0, 1.0)), 0.0, 1.0));
  tmpvar_5 = tmpvar_45;
  lowp vec3 tmpvar_46;
  lowp vec4 packednormal_47;
  packednormal_47 = normal_8;
  tmpvar_46 = ((packednormal_47.xyz * 2.0) - 1.0);
  mediump vec3 tmpvar_48;
  tmpvar_48 = mix (tmpvar_46, vec3(0.0, 0.0, 1.0), vec3(detailLevel_7));
  tmpvar_4 = tmpvar_48;
  tmpvar_2 = tmpvar_4;
  lowp float tmpvar_49;
  mediump float lightShadowDataX_50;
  highp float dist_51;
  lowp float tmpvar_52;
  tmpvar_52 = texture2DProj (_ShadowMapTexture, xlv_TEXCOORD5).x;
  dist_51 = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = _LightShadowData.x;
  lightShadowDataX_50 = tmpvar_53;
  highp float tmpvar_54;
  tmpvar_54 = max (float((dist_51 > (xlv_TEXCOORD5.z / xlv_TEXCOORD5.w))), lightShadowDataX_50);
  tmpvar_49 = tmpvar_54;
  mediump vec3 lightDir_55;
  lightDir_55 = xlv_TEXCOORD3;
  mediump float atten_56;
  atten_56 = tmpvar_49;
  mediump vec4 c_57;
  mediump float tmpvar_58;
  tmpvar_58 = clamp (dot (tmpvar_4, lightDir_55), 0.0, 1.0);
  highp vec3 tmpvar_59;
  tmpvar_59 = clamp ((_MinLight + (_LightColor0.xyz * ((tmpvar_58 * atten_56) * 2.0))), 0.0, 1.0);
  lowp vec3 tmpvar_60;
  tmpvar_60 = (tmpvar_3 * tmpvar_59);
  c_57.xyz = tmpvar_60;
  c_57.w = tmpvar_5;
  c_1 = c_57;
  c_1.xyz = (c_1.xyz + (tmpvar_3 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES


#ifdef VERTEX

varying highp vec4 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _DetailDist;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;
uniform highp mat4 glstate_matrix_mvp;
uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp vec4 _ProjectionParams;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  highp vec2 tmpvar_5;
  highp vec3 tmpvar_6;
  tmpvar_6 = (_Object2World * _glesVertex).xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (_Object2World * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
  highp vec3 p_8;
  p_8 = (tmpvar_6 - _WorldSpaceCameraPos);
  tmpvar_5.x = (_DetailDist * sqrt(dot (p_8, p_8)));
  highp vec3 p_9;
  p_9 = (tmpvar_7 - _WorldSpaceCameraPos);
  highp vec3 p_10;
  p_10 = (tmpvar_7 - tmpvar_6);
  tmpvar_5.y = clamp ((sqrt(dot (p_9, p_9)) - (1.0005 * sqrt(dot (p_10, p_10)))), 0.0, 1.0);
  highp vec4 tmpvar_11;
  tmpvar_11 = (glstate_matrix_mvp * _glesVertex);
  highp vec3 tmpvar_12;
  highp vec3 tmpvar_13;
  tmpvar_12 = tmpvar_1.xyz;
  tmpvar_13 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_14;
  tmpvar_14[0].x = tmpvar_12.x;
  tmpvar_14[0].y = tmpvar_13.x;
  tmpvar_14[0].z = tmpvar_2.x;
  tmpvar_14[1].x = tmpvar_12.y;
  tmpvar_14[1].y = tmpvar_13.y;
  tmpvar_14[1].z = tmpvar_2.y;
  tmpvar_14[2].x = tmpvar_12.z;
  tmpvar_14[2].y = tmpvar_13.z;
  tmpvar_14[2].z = tmpvar_2.z;
  highp vec3 tmpvar_15;
  tmpvar_15 = (tmpvar_14 * (_World2Object * _WorldSpaceLightPos0).xyz);
  tmpvar_3 = tmpvar_15;
  highp vec4 tmpvar_16;
  tmpvar_16.w = 1.0;
  tmpvar_16.xyz = _WorldSpaceCameraPos;
  highp vec3 tmpvar_17;
  tmpvar_17 = glstate_lightmodel_ambient.xyz;
  tmpvar_4 = tmpvar_17;
  highp vec4 o_18;
  highp vec4 tmpvar_19;
  tmpvar_19 = (tmpvar_11 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = tmpvar_19.x;
  tmpvar_20.y = (tmpvar_19.y * _ProjectionParams.x);
  o_18.xy = (tmpvar_20 + tmpvar_19.w);
  o_18.zw = tmpvar_11.zw;
  gl_Position = tmpvar_11;
  xlv_TEXCOORD0 = (tmpvar_14 * (((_World2Object * tmpvar_16).xyz * unity_Scale.w) - _glesVertex.xyz));
  xlv_TEXCOORD1 = tmpvar_5;
  xlv_TEXCOORD2 = normalize(_glesVertex.xyz);
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
  xlv_TEXCOORD5 = o_18;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _MinLight;
uniform highp float _BumpScale;
uniform highp float _DetailScale;
uniform highp float _FalloffScale;
uniform highp float _FalloffPow;
uniform lowp vec4 _BumpOffset;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _Color;
uniform sampler2D _BumpMap;
uniform sampler2D _DetailTex;
uniform sampler2D _MainTex;
uniform sampler2D _ShadowMapTexture;
uniform lowp vec4 _LightColor0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  lowp float tmpvar_5;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  tmpvar_4 = tmpvar_2;
  tmpvar_5 = 0.0;
  mediump float rim_6;
  mediump float detailLevel_7;
  mediump vec4 normal_8;
  mediump vec4 detail_9;
  mediump vec4 normalZ_10;
  mediump vec4 normalY_11;
  mediump vec4 normalX_12;
  mediump vec4 detailZ_13;
  mediump vec4 detailY_14;
  mediump vec4 detailX_15;
  mediump vec4 main_16;
  highp vec2 uv_17;
  highp float r_18;
  if ((abs(xlv_TEXCOORD2.x) > (1e-08 * abs(xlv_TEXCOORD2.z)))) {
    highp float y_over_x_19;
    y_over_x_19 = (xlv_TEXCOORD2.z / xlv_TEXCOORD2.x);
    highp float s_20;
    highp float x_21;
    x_21 = (y_over_x_19 * inversesqrt(((y_over_x_19 * y_over_x_19) + 1.0)));
    s_20 = (sign(x_21) * (1.5708 - (sqrt((1.0 - abs(x_21))) * (1.5708 + (abs(x_21) * (-0.214602 + (abs(x_21) * (0.0865667 + (abs(x_21) * -0.0310296)))))))));
    r_18 = s_20;
    if ((xlv_TEXCOORD2.x < 0.0)) {
      if ((xlv_TEXCOORD2.z >= 0.0)) {
        r_18 = (s_20 + 3.14159);
      } else {
        r_18 = (r_18 - 3.14159);
      };
    };
  } else {
    r_18 = (sign(xlv_TEXCOORD2.z) * 1.5708);
  };
  uv_17.x = (0.5 + (0.159155 * r_18));
  highp float x_22;
  x_22 = -(xlv_TEXCOORD2.y);
  uv_17.y = (0.31831 * (1.5708 - (sign(x_22) * (1.5708 - (sqrt((1.0 - abs(x_22))) * (1.5708 + (abs(x_22) * (-0.214602 + (abs(x_22) * (0.0865667 + (abs(x_22) * -0.0310296)))))))))));
  lowp vec4 tmpvar_23;
  tmpvar_23 = (texture2D (_MainTex, uv_17) * _Color);
  main_16 = tmpvar_23;
  lowp vec4 tmpvar_24;
  highp vec2 P_25;
  P_25 = ((xlv_TEXCOORD2.zy * _DetailScale) + _DetailOffset.xy);
  tmpvar_24 = texture2D (_DetailTex, P_25);
  detailX_15 = tmpvar_24;
  lowp vec4 tmpvar_26;
  highp vec2 P_27;
  P_27 = ((xlv_TEXCOORD2.zx * _DetailScale) + _DetailOffset.xy);
  tmpvar_26 = texture2D (_DetailTex, P_27);
  detailY_14 = tmpvar_26;
  lowp vec4 tmpvar_28;
  highp vec2 P_29;
  P_29 = ((xlv_TEXCOORD2.xy * _DetailScale) + _DetailOffset.xy);
  tmpvar_28 = texture2D (_DetailTex, P_29);
  detailZ_13 = tmpvar_28;
  lowp vec4 tmpvar_30;
  highp vec2 P_31;
  P_31 = ((xlv_TEXCOORD2.zy * _BumpScale) + _BumpOffset.xy);
  tmpvar_30 = texture2D (_BumpMap, P_31);
  normalX_12 = tmpvar_30;
  lowp vec4 tmpvar_32;
  highp vec2 P_33;
  P_33 = ((xlv_TEXCOORD2.zx * _BumpScale) + _BumpOffset.xy);
  tmpvar_32 = texture2D (_BumpMap, P_33);
  normalY_11 = tmpvar_32;
  lowp vec4 tmpvar_34;
  highp vec2 P_35;
  P_35 = ((xlv_TEXCOORD2.xy * _BumpScale) + _BumpOffset.xy);
  tmpvar_34 = texture2D (_BumpMap, P_35);
  normalZ_10 = tmpvar_34;
  highp vec3 tmpvar_36;
  tmpvar_36 = abs(xlv_TEXCOORD2);
  highp vec4 tmpvar_37;
  tmpvar_37 = mix (detailZ_13, detailX_15, tmpvar_36.xxxx);
  detail_9 = tmpvar_37;
  highp vec4 tmpvar_38;
  tmpvar_38 = mix (detail_9, detailY_14, tmpvar_36.yyyy);
  detail_9 = tmpvar_38;
  highp vec4 tmpvar_39;
  tmpvar_39 = mix (normalZ_10, normalX_12, tmpvar_36.xxxx);
  normal_8 = tmpvar_39;
  highp vec4 tmpvar_40;
  tmpvar_40 = mix (normal_8, normalY_11, tmpvar_36.yyyy);
  normal_8 = tmpvar_40;
  highp float tmpvar_41;
  tmpvar_41 = clamp ((2.0 * xlv_TEXCOORD1.x), 0.0, 1.0);
  detailLevel_7 = tmpvar_41;
  mediump vec3 tmpvar_42;
  tmpvar_42 = ((main_16.xyz * mix (detail_9.xyz, vec3(1.0, 1.0, 1.0), vec3(detailLevel_7))) * _Color.xyz);
  tmpvar_3 = tmpvar_42;
  mediump float tmpvar_43;
  tmpvar_43 = (main_16.w * mix (detail_9.w, 1.0, detailLevel_7));
  highp float tmpvar_44;
  tmpvar_44 = clamp (normalize(xlv_TEXCOORD0).z, 0.0, 1.0);
  rim_6 = tmpvar_44;
  highp float tmpvar_45;
  tmpvar_45 = ((tmpvar_43 * xlv_TEXCOORD1.y) * clamp (((1.0 - xlv_TEXCOORD1.y) + clamp (pow ((_FalloffScale * rim_6), _FalloffPow), 0.0, 1.0)), 0.0, 1.0));
  tmpvar_5 = tmpvar_45;
  lowp vec4 packednormal_46;
  packednormal_46 = normal_8;
  lowp vec3 normal_47;
  normal_47.xy = ((packednormal_46.wy * 2.0) - 1.0);
  normal_47.z = sqrt((1.0 - clamp (dot (normal_47.xy, normal_47.xy), 0.0, 1.0)));
  mediump vec3 tmpvar_48;
  tmpvar_48 = mix (normal_47, vec3(0.0, 0.0, 1.0), vec3(detailLevel_7));
  tmpvar_4 = tmpvar_48;
  tmpvar_2 = tmpvar_4;
  lowp float tmpvar_49;
  tmpvar_49 = texture2DProj (_ShadowMapTexture, xlv_TEXCOORD5).x;
  mediump vec3 lightDir_50;
  lightDir_50 = xlv_TEXCOORD3;
  mediump float atten_51;
  atten_51 = tmpvar_49;
  mediump vec4 c_52;
  mediump float tmpvar_53;
  tmpvar_53 = clamp (dot (tmpvar_4, lightDir_50), 0.0, 1.0);
  highp vec3 tmpvar_54;
  tmpvar_54 = clamp ((_MinLight + (_LightColor0.xyz * ((tmpvar_53 * atten_51) * 2.0))), 0.0, 1.0);
  lowp vec3 tmpvar_55;
  tmpvar_55 = (tmpvar_3 * tmpvar_54);
  c_52.xyz = tmpvar_55;
  c_52.w = tmpvar_5;
  c_1 = c_52;
  c_1.xyz = (c_1.xyz + (tmpvar_3 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "gles3 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES3#version 300 es


#ifdef VERTEX

#define gl_Vertex _glesVertex
in vec4 _glesVertex;
#define gl_Color _glesColor
in vec4 _glesColor;
#define gl_Normal (normalize(_glesNormal))
in vec3 _glesNormal;
#define gl_MultiTexCoord0 _glesMultiTexCoord0
in vec4 _glesMultiTexCoord0;
#define gl_MultiTexCoord1 _glesMultiTexCoord1
in vec4 _glesMultiTexCoord1;
#define TANGENT vec4(normalize(_glesTANGENT.xyz), _glesTANGENT.w)
in vec4 _glesTANGENT;
mat2 xll_transpose_mf2x2(mat2 m) {
  return mat2( m[0][0], m[1][0], m[0][1], m[1][1]);
}
mat3 xll_transpose_mf3x3(mat3 m) {
  return mat3( m[0][0], m[1][0], m[2][0],
               m[0][1], m[1][1], m[2][1],
               m[0][2], m[1][2], m[2][2]);
}
mat4 xll_transpose_mf4x4(mat4 m) {
  return mat4( m[0][0], m[1][0], m[2][0], m[3][0],
               m[0][1], m[1][1], m[2][1], m[3][1],
               m[0][2], m[1][2], m[2][2], m[3][2],
               m[0][3], m[1][3], m[2][3], m[3][3]);
}
float xll_saturate_f( float x) {
  return clamp( x, 0.0, 1.0);
}
vec2 xll_saturate_vf2( vec2 x) {
  return clamp( x, 0.0, 1.0);
}
vec3 xll_saturate_vf3( vec3 x) {
  return clamp( x, 0.0, 1.0);
}
vec4 xll_saturate_vf4( vec4 x) {
  return clamp( x, 0.0, 1.0);
}
mat2 xll_saturate_mf2x2(mat2 m) {
  return mat2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0));
}
mat3 xll_saturate_mf3x3(mat3 m) {
  return mat3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0));
}
mat4 xll_saturate_mf4x4(mat4 m) {
  return mat4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0));
}
#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 315
struct SurfaceOutput {
    lowp vec3 Albedo;
    lowp vec3 Normal;
    lowp vec3 Emission;
    mediump float Specular;
    lowp float Gloss;
    lowp float Alpha;
};
#line 67
struct appdata_full {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
    highp vec4 texcoord1;
    lowp vec4 color;
};
#line 419
struct Input {
    highp vec2 viewDist;
    highp vec3 viewDir;
    highp vec3 localPos;
};
#line 463
struct v2f_surf {
    highp vec4 pos;
    highp vec3 viewDir;
    highp vec2 cust_viewDist;
    highp vec3 cust_localPos;
    lowp vec3 lightDir;
    lowp vec3 vlight;
    highp vec4 _ShadowCoord;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform lowp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 325
uniform lowp vec4 _LightColor0;
uniform lowp vec4 _SpecColor;
#line 338
#line 346
#line 360
uniform highp vec4 _ShadowOffsets[4];
uniform sampler2D _ShadowMapTexture;
#line 393
uniform sampler2D _MainTex;
uniform sampler2D _DetailTex;
#line 401
uniform sampler2D _BumpMap;
uniform lowp vec4 _Color;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _BumpOffset;
#line 405
uniform highp float _FalloffPow;
uniform highp float _FalloffScale;
uniform highp float _DetailScale;
uniform highp float _DetailDist;
#line 409
uniform highp float _BumpScale;
uniform highp float _MinLight;
#line 426
#line 474
#line 494
#line 82
highp vec3 ObjSpaceLightDir( in highp vec4 v ) {
    highp vec3 objSpaceLightPos = (_World2Object * _WorldSpaceLightPos0).xyz;
    return objSpaceLightPos.xyz;
}
#line 91
highp vec3 ObjSpaceViewDir( in highp vec4 v ) {
    highp vec3 objSpaceCameraPos = ((_World2Object * vec4( _WorldSpaceCameraPos.xyz, 1.0)).xyz * unity_Scale.w);
    return (objSpaceCameraPos - v.xyz);
}
#line 426
void vert( inout appdata_full v, out Input o ) {
    highp vec3 vertexPos = (_Object2World * v.vertex).xyz;
    #line 430
    highp vec3 origin = (_Object2World * vec4( 0.0, 0.0, 0.0, 1.0)).xyz;
    highp float diff = (_DetailDist * distance( vertexPos, _WorldSpaceCameraPos));
    o.viewDist.x = diff;
    o.viewDist.y = xll_saturate_f((distance( origin, _WorldSpaceCameraPos) - (1.0005 * distance( origin, vertexPos))));
    #line 434
    o.localPos = normalize(v.vertex.xyz);
}
#line 474
v2f_surf vert_surf( in appdata_full v ) {
    v2f_surf o;
    Input customInputData;
    #line 478
    vert( v, customInputData);
    o.cust_viewDist = customInputData.viewDist;
    o.cust_localPos = customInputData.localPos;
    o.pos = (glstate_matrix_mvp * v.vertex);
    #line 482
    highp vec3 worldN = (mat3( _Object2World) * (v.normal * unity_Scale.w));
    highp vec3 binormal = (cross( v.normal, v.tangent.xyz) * v.tangent.w);
    highp mat3 rotation = xll_transpose_mf3x3(mat3( v.tangent.xyz, binormal, v.normal));
    highp vec3 lightDir = (rotation * ObjSpaceLightDir( v.vertex));
    #line 486
    o.lightDir = lightDir;
    highp vec3 viewDirForLight = (rotation * ObjSpaceViewDir( v.vertex));
    o.viewDir = viewDirForLight;
    o.vlight = glstate_lightmodel_ambient.xyz;
    #line 490
    o._ShadowCoord = (unity_World2Shadow[0] * (_Object2World * v.vertex));
    return o;
}

out highp vec3 xlv_TEXCOORD0;
out highp vec2 xlv_TEXCOORD1;
out highp vec3 xlv_TEXCOORD2;
out lowp vec3 xlv_TEXCOORD3;
out lowp vec3 xlv_TEXCOORD4;
out highp vec4 xlv_TEXCOORD5;
void main() {
    v2f_surf xl_retval;
    appdata_full xlt_v;
    xlt_v.vertex = vec4(gl_Vertex);
    xlt_v.tangent = vec4(TANGENT);
    xlt_v.normal = vec3(gl_Normal);
    xlt_v.texcoord = vec4(gl_MultiTexCoord0);
    xlt_v.texcoord1 = vec4(gl_MultiTexCoord1);
    xlt_v.color = vec4(gl_Color);
    xl_retval = vert_surf( xlt_v);
    gl_Position = vec4(xl_retval.pos);
    xlv_TEXCOORD0 = vec3(xl_retval.viewDir);
    xlv_TEXCOORD1 = vec2(xl_retval.cust_viewDist);
    xlv_TEXCOORD2 = vec3(xl_retval.cust_localPos);
    xlv_TEXCOORD3 = vec3(xl_retval.lightDir);
    xlv_TEXCOORD4 = vec3(xl_retval.vlight);
    xlv_TEXCOORD5 = vec4(xl_retval._ShadowCoord);
}


#endif
#ifdef FRAGMENT

#define gl_FragData _glesFragData
layout(location = 0) out mediump vec4 _glesFragData[4];
float xll_saturate_f( float x) {
  return clamp( x, 0.0, 1.0);
}
vec2 xll_saturate_vf2( vec2 x) {
  return clamp( x, 0.0, 1.0);
}
vec3 xll_saturate_vf3( vec3 x) {
  return clamp( x, 0.0, 1.0);
}
vec4 xll_saturate_vf4( vec4 x) {
  return clamp( x, 0.0, 1.0);
}
mat2 xll_saturate_mf2x2(mat2 m) {
  return mat2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0));
}
mat3 xll_saturate_mf3x3(mat3 m) {
  return mat3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0));
}
mat4 xll_saturate_mf4x4(mat4 m) {
  return mat4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0));
}
#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 315
struct SurfaceOutput {
    lowp vec3 Albedo;
    lowp vec3 Normal;
    lowp vec3 Emission;
    mediump float Specular;
    lowp float Gloss;
    lowp float Alpha;
};
#line 67
struct appdata_full {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
    highp vec4 texcoord1;
    lowp vec4 color;
};
#line 419
struct Input {
    highp vec2 viewDist;
    highp vec3 viewDir;
    highp vec3 localPos;
};
#line 463
struct v2f_surf {
    highp vec4 pos;
    highp vec3 viewDir;
    highp vec2 cust_viewDist;
    highp vec3 cust_localPos;
    lowp vec3 lightDir;
    lowp vec3 vlight;
    highp vec4 _ShadowCoord;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform lowp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 325
uniform lowp vec4 _LightColor0;
uniform lowp vec4 _SpecColor;
#line 338
#line 346
#line 360
uniform highp vec4 _ShadowOffsets[4];
uniform sampler2D _ShadowMapTexture;
#line 393
uniform sampler2D _MainTex;
uniform sampler2D _DetailTex;
#line 401
uniform sampler2D _BumpMap;
uniform lowp vec4 _Color;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _BumpOffset;
#line 405
uniform highp float _FalloffPow;
uniform highp float _FalloffScale;
uniform highp float _DetailScale;
uniform highp float _DetailDist;
#line 409
uniform highp float _BumpScale;
uniform highp float _MinLight;
#line 426
#line 474
#line 494
#line 411
mediump vec4 LightingSimpleLambert( in SurfaceOutput s, in mediump vec3 lightDir, in mediump float atten ) {
    #line 413
    mediump float NdotL = xll_saturate_f(dot( s.Normal, lightDir));
    mediump vec4 c;
    c.xyz = (s.Albedo * xll_saturate_vf3((_MinLight + (_LightColor0.xyz * ((NdotL * atten) * 2.0)))));
    c.w = s.Alpha;
    #line 417
    return c;
}
#line 272
lowp vec3 UnpackNormal( in lowp vec4 packednormal ) {
    #line 274
    return ((packednormal.xyz * 2.0) - 1.0);
}
#line 436
void surf( in Input IN, inout SurfaceOutput o ) {
    #line 438
    highp vec3 pos = IN.localPos;
    highp vec2 uv;
    uv.x = (0.5 + (0.159155 * atan( pos.z, pos.x)));
    uv.y = (0.31831 * acos((-pos.y)));
    #line 442
    mediump vec4 main = (texture( _MainTex, uv) * _Color);
    mediump vec4 detailX = texture( _DetailTex, ((pos.zy * _DetailScale) + _DetailOffset.xy));
    mediump vec4 detailY = texture( _DetailTex, ((pos.zx * _DetailScale) + _DetailOffset.xy));
    mediump vec4 detailZ = texture( _DetailTex, ((pos.xy * _DetailScale) + _DetailOffset.xy));
    #line 446
    mediump vec4 normalX = texture( _BumpMap, ((pos.zy * _BumpScale) + _BumpOffset.xy));
    mediump vec4 normalY = texture( _BumpMap, ((pos.zx * _BumpScale) + _BumpOffset.xy));
    mediump vec4 normalZ = texture( _BumpMap, ((pos.xy * _BumpScale) + _BumpOffset.xy));
    pos = abs(pos);
    #line 450
    mediump vec4 detail = mix( detailZ, detailX, vec4( pos.x));
    detail = mix( detail, detailY, vec4( pos.y));
    mediump vec4 normal = mix( normalZ, normalX, vec4( pos.x));
    normal = mix( normal, normalY, vec4( pos.y));
    #line 454
    mediump float detailLevel = xll_saturate_f((2.0 * IN.viewDist.x));
    mediump vec3 albedo = (main.xyz * mix( detail.xyz, vec3( 1.0), vec3( detailLevel)));
    o.Normal = vec3( 0.0, 0.0, 1.0);
    o.Albedo = (albedo * _Color.xyz);
    #line 458
    mediump float avg = (main.w * mix( detail.w, 1.0, detailLevel));
    mediump float rim = xll_saturate_f(dot( normalize(IN.viewDir), o.Normal));
    o.Alpha = ((avg * IN.viewDist.y) * xll_saturate_f(((1.0 - IN.viewDist.y) + xll_saturate_f(pow( (_FalloffScale * rim), _FalloffPow)))));
    o.Normal = mix( UnpackNormal( normal), vec3( 0.0, 0.0, 1.0), vec3( detailLevel));
}
#line 393
lowp float unitySampleShadow( in highp vec4 shadowCoord ) {
    highp float dist = textureProj( _ShadowMapTexture, shadowCoord).x;
    mediump float lightShadowDataX = _LightShadowData.x;
    #line 397
    return max( float((dist > (shadowCoord.z / shadowCoord.w))), lightShadowDataX);
}
#line 494
lowp vec4 frag_surf( in v2f_surf IN ) {
    Input surfIN;
    surfIN.viewDist = IN.cust_viewDist;
    #line 498
    surfIN.localPos = IN.cust_localPos;
    surfIN.viewDir = IN.viewDir;
    SurfaceOutput o;
    o.Albedo = vec3( 0.0);
    #line 502
    o.Emission = vec3( 0.0);
    o.Specular = 0.0;
    o.Alpha = 0.0;
    o.Gloss = 0.0;
    #line 506
    surf( surfIN, o);
    lowp float atten = unitySampleShadow( IN._ShadowCoord);
    lowp vec4 c = vec4( 0.0);
    c = LightingSimpleLambert( o, IN.lightDir, atten);
    #line 510
    c.xyz += (o.Albedo * IN.vlight);
    return c;
}
in highp vec3 xlv_TEXCOORD0;
in highp vec2 xlv_TEXCOORD1;
in highp vec3 xlv_TEXCOORD2;
in lowp vec3 xlv_TEXCOORD3;
in lowp vec3 xlv_TEXCOORD4;
in highp vec4 xlv_TEXCOORD5;
void main() {
    lowp vec4 xl_retval;
    v2f_surf xlt_IN;
    xlt_IN.pos = vec4(0.0);
    xlt_IN.viewDir = vec3(xlv_TEXCOORD0);
    xlt_IN.cust_viewDist = vec2(xlv_TEXCOORD1);
    xlt_IN.cust_localPos = vec3(xlv_TEXCOORD2);
    xlt_IN.lightDir = vec3(xlv_TEXCOORD3);
    xlt_IN.vlight = vec3(xlv_TEXCOORD4);
    xlt_IN._ShadowCoord = vec4(xlv_TEXCOORD5);
    xl_retval = frag_surf( xlt_IN);
    gl_FragData[0] = vec4(xl_retval);
}


#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" "VERTEXLIGHT_ON" }
Bind "vertex" Vertex
Bind "tangent" ATTR14
Bind "normal" Normal
Vector 2 [_WorldSpaceCameraPos]
Vector 3 [_WorldSpaceLightPos0]
Matrix 5 [_Object2World]
Matrix 9 [_World2Object]
Vector 4 [unity_Scale]
Float 17 [_DetailDist]
"3.0-!!ARBvp1.0
# 50 ALU
PARAM c[18] = { { 1, 1.0005, 0 },
		state.lightmodel.ambient,
		program.local[2..12],
		state.matrix.mvp,
		program.local[17] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
MOV R0.xyz, vertex.attrib[14];
MUL R1.xyz, vertex.normal.zxyw, R0.yzxw;
MAD R0.xyz, vertex.normal.yzxw, R0.zxyw, -R1;
MOV R1.w, c[0].x;
MOV R1.xyz, c[2];
DP4 R2.z, R1, c[11];
DP4 R2.x, R1, c[9];
DP4 R2.y, R1, c[10];
MAD R3.xyz, R2, c[4].w, -vertex.position;
MUL R2.xyz, R0, vertex.attrib[14].w;
MOV R1, c[3];
DP4 R0.x, R1, c[9];
DP4 R0.y, R1, c[10];
DP4 R0.z, R1, c[11];
DP3 result.texcoord[3].y, R2, R0;
DP3 result.texcoord[0].y, R3, R2;
MOV R1.z, c[7].w;
MOV R1.x, c[5].w;
MOV R1.y, c[6].w;
ADD R4.xyz, -R1, c[2];
DP4 R2.z, vertex.position, c[7];
DP4 R2.x, vertex.position, c[5];
DP4 R2.y, vertex.position, c[6];
ADD R1.xyz, R2, -R1;
DP3 R0.w, R1, R1;
DP3 R1.w, R4, R4;
RSQ R1.x, R1.w;
RSQ R0.w, R0.w;
RCP R1.x, R1.x;
RCP R0.w, R0.w;
MAD R0.w, -R0, c[0].y, R1.x;
MIN R0.w, R0, c[0].x;
DP3 result.texcoord[3].z, vertex.normal, R0;
DP3 result.texcoord[3].x, vertex.attrib[14], R0;
DP3 R0.y, vertex.position, vertex.position;
RSQ R0.y, R0.y;
MAX result.texcoord[1].y, R0.w, c[0].z;
ADD R1.xyz, -R2, c[2];
DP3 R0.w, R1, R1;
RSQ R0.x, R0.w;
RCP R0.x, R0.x;
DP3 result.texcoord[0].z, vertex.normal, R3;
DP3 result.texcoord[0].x, R3, vertex.attrib[14];
MUL result.texcoord[1].x, R0, c[17];
MUL result.texcoord[2].xyz, R0.y, vertex.position;
MOV result.texcoord[4].xyz, c[1];
DP4 result.position.w, vertex.position, c[16];
DP4 result.position.z, vertex.position, c[15];
DP4 result.position.y, vertex.position, c[14];
DP4 result.position.x, vertex.position, c[13];
END
# 50 instructions, 5 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" "VERTEXLIGHT_ON" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Vector 12 [glstate_lightmodel_ambient]
Matrix 0 [glstate_matrix_mvp]
Vector 13 [_WorldSpaceCameraPos]
Vector 14 [_WorldSpaceLightPos0]
Matrix 4 [_Object2World]
Matrix 8 [_World2Object]
Vector 15 [unity_Scale]
Float 16 [_DetailDist]
"vs_3_0
; 51 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
def c17, 1.00000000, 1.00049996, 0, 0
dcl_position0 v0
dcl_tangent0 v1
dcl_normal0 v2
mov r0.xyz, v1
mul r1.xyz, v2.zxyw, r0.yzxw
mov r0.xyz, v1
mad r0.xyz, v2.yzxw, r0.zxyw, -r1
mul r3.xyz, r0, v1.w
mov r0, c10
dp4 r4.z, c14, r0
mov r0, c9
dp4 r4.y, c14, r0
mov r1.w, c17.x
mov r1.xyz, c13
dp4 r2.z, r1, c10
dp4 r2.x, r1, c8
dp4 r2.y, r1, c9
mad r2.xyz, r2, c15.w, -v0
mov r1, c8
dp4 r4.x, c14, r1
mov r0.z, c6.w
mov r0.x, c4.w
mov r0.y, c5.w
dp4 r1.z, v0, c6
dp4 r1.x, v0, c4
dp4 r1.y, v0, c5
dp3 o1.y, r2, r3
dp3 o1.z, v2, r2
dp3 o1.x, r2, v1
add r2.xyz, -r0, c13
add r0.xyz, r1, -r0
dp3 r0.x, r0, r0
dp3 r0.w, r2, r2
rsq r0.y, r0.w
rsq r0.x, r0.x
rcp r0.y, r0.y
rcp r0.x, r0.x
mad_sat o2.y, -r0.x, c17, r0
add r0.xyz, -r1, c13
dp3 r0.x, r0, r0
rsq r0.x, r0.x
dp3 r0.y, v0, v0
rcp r0.x, r0.x
rsq r0.y, r0.y
dp3 o4.y, r3, r4
dp3 o4.z, v2, r4
dp3 o4.x, v1, r4
mul o2.x, r0, c16
mul o3.xyz, r0.y, v0
mov o5.xyz, c12
dp4 o0.w, v0, c3
dp4 o0.z, v0, c2
dp4 o0.y, v0, c1
dp4 o0.x, v0, c0
"
}

SubProgram "d3d11 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" "VERTEXLIGHT_ON" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "color" Color
ConstBuffer "$Globals" 128 // 112 used size, 12 vars
Float 108 [_DetailDist]
ConstBuffer "UnityPerCamera" 128 // 76 used size, 8 vars
Vector 64 [_WorldSpaceCameraPos] 3
ConstBuffer "UnityLighting" 720 // 16 used size, 17 vars
Vector 0 [_WorldSpaceLightPos0] 4
ConstBuffer "UnityPerDraw" 336 // 336 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
Matrix 192 [_Object2World] 4
Matrix 256 [_World2Object] 4
Vector 320 [unity_Scale] 4
ConstBuffer "UnityPerFrame" 208 // 80 used size, 4 vars
Vector 64 [glstate_lightmodel_ambient] 4
BindCB "$Globals" 0
BindCB "UnityPerCamera" 1
BindCB "UnityLighting" 2
BindCB "UnityPerDraw" 3
BindCB "UnityPerFrame" 4
// 42 instructions, 3 temp regs, 0 temp arrays:
// ALU 40 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0
eefiecedhpglldndbddppbjkaapmdheidoclempaabaaaaaanmahaaaaadaaaaaa
cmaaaaaapeaaaaaakmabaaaaejfdeheomaaaaaaaagaaaaaaaiaaaaaajiaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaakbaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaakjaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
ahahaaaalaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaadaaaaaaapaaaaaalaaaaaaa
abaaaaaaaaaaaaaaadaaaaaaaeaaaaaaapaaaaaaljaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaafaaaaaaapaaaaaafaepfdejfeejepeoaafeebeoehefeofeaaeoepfc
enebemaafeeffiedepepfceeaaedepemepfcaaklepfdeheolaaaaaaaagaaaaaa
aiaaaaaajiaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaakeaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaabaaaaaaahaiaaaakeaaaaaaabaaaaaaaaaaaaaa
adaaaaaaacaaaaaaadamaaaakeaaaaaaacaaaaaaaaaaaaaaadaaaaaaadaaaaaa
ahaiaaaakeaaaaaaadaaaaaaaaaaaaaaadaaaaaaaeaaaaaaahaiaaaakeaaaaaa
aeaaaaaaaaaaaaaaadaaaaaaafaaaaaaahaiaaaafdfgfpfaepfdejfeejepeoaa
feeffiedepepfceeaaklklklfdeieefcciagaaaaeaaaabaaikabaaaafjaaaaae
egiocaaaaaaaaaaaahaaaaaafjaaaaaeegiocaaaabaaaaaaafaaaaaafjaaaaae
egiocaaaacaaaaaaabaaaaaafjaaaaaeegiocaaaadaaaaaabfaaaaaafjaaaaae
egiocaaaaeaaaaaaafaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaadpcbabaaa
abaaaaaafpaaaaadhcbabaaaacaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaa
gfaaaaadhccabaaaabaaaaaagfaaaaaddccabaaaacaaaaaagfaaaaadhccabaaa
adaaaaaagfaaaaadhccabaaaaeaaaaaagfaaaaadhccabaaaafaaaaaagiaaaaac
adaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiocaaaadaaaaaa
abaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaadaaaaaaaaaaaaaaagbabaaa
aaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaadaaaaaa
acaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpccabaaaaaaaaaaa
egiocaaaadaaaaaaadaaaaaapgbpbaaaaaaaaaaaegaobaaaaaaaaaaadiaaaaah
hcaabaaaaaaaaaaajgbebaaaabaaaaaacgbjbaaaacaaaaaadcaaaaakhcaabaaa
aaaaaaaajgbebaaaacaaaaaacgbjbaaaabaaaaaaegacbaiaebaaaaaaaaaaaaaa
diaaaaahhcaabaaaaaaaaaaaegacbaaaaaaaaaaapgbpbaaaabaaaaaadiaaaaaj
hcaabaaaabaaaaaafgifcaaaabaaaaaaaeaaaaaaegiccaaaadaaaaaabbaaaaaa
dcaaaaalhcaabaaaabaaaaaaegiccaaaadaaaaaabaaaaaaaagiacaaaabaaaaaa
aeaaaaaaegacbaaaabaaaaaadcaaaaalhcaabaaaabaaaaaaegiccaaaadaaaaaa
bcaaaaaakgikcaaaabaaaaaaaeaaaaaaegacbaaaabaaaaaaaaaaaaaihcaabaaa
abaaaaaaegacbaaaabaaaaaaegiccaaaadaaaaaabdaaaaaadcaaaaalhcaabaaa
abaaaaaaegacbaaaabaaaaaapgipcaaaadaaaaaabeaaaaaaegbcbaiaebaaaaaa
aaaaaaaabaaaaaahcccabaaaabaaaaaaegacbaaaaaaaaaaaegacbaaaabaaaaaa
baaaaaahbccabaaaabaaaaaaegbcbaaaabaaaaaaegacbaaaabaaaaaabaaaaaah
eccabaaaabaaaaaaegbcbaaaacaaaaaaegacbaaaabaaaaaaaaaaaaakhcaabaaa
abaaaaaaegiccaiaebaaaaaaabaaaaaaaeaaaaaaegiccaaaadaaaaaaapaaaaaa
baaaaaahicaabaaaaaaaaaaaegacbaaaabaaaaaaegacbaaaabaaaaaaelaaaaaf
icaabaaaaaaaaaaadkaabaaaaaaaaaaadiaaaaaihcaabaaaabaaaaaafgbfbaaa
aaaaaaaaegiccaaaadaaaaaaanaaaaaadcaaaaakhcaabaaaabaaaaaaegiccaaa
adaaaaaaamaaaaaaagbabaaaaaaaaaaaegacbaaaabaaaaaadcaaaaakhcaabaaa
abaaaaaaegiccaaaadaaaaaaaoaaaaaakgbkbaaaaaaaaaaaegacbaaaabaaaaaa
dcaaaaakhcaabaaaabaaaaaaegiccaaaadaaaaaaapaaaaaapgbpbaaaaaaaaaaa
egacbaaaabaaaaaaaaaaaaajhcaabaaaacaaaaaaegacbaiaebaaaaaaabaaaaaa
egiccaaaadaaaaaaapaaaaaaaaaaaaajhcaabaaaabaaaaaaegacbaaaabaaaaaa
egiccaiaebaaaaaaabaaaaaaaeaaaaaabaaaaaahbcaabaaaabaaaaaaegacbaaa
abaaaaaaegacbaaaabaaaaaaelaaaaafbcaabaaaabaaaaaaakaabaaaabaaaaaa
diaaaaaibccabaaaacaaaaaaakaabaaaabaaaaaadkiacaaaaaaaaaaaagaaaaaa
baaaaaahbcaabaaaabaaaaaaegacbaaaacaaaaaaegacbaaaacaaaaaaelaaaaaf
bcaabaaaabaaaaaaakaabaaaabaaaaaadccaaaakcccabaaaacaaaaaaakaabaia
ebaaaaaaabaaaaaaabeaaaaagcbaiadpdkaabaaaaaaaaaaabaaaaaahicaabaaa
aaaaaaaaegbcbaaaaaaaaaaaegbcbaaaaaaaaaaaeeaaaaaficaabaaaaaaaaaaa
dkaabaaaaaaaaaaadiaaaaahhccabaaaadaaaaaapgapbaaaaaaaaaaaegbcbaaa
aaaaaaaadiaaaaajhcaabaaaabaaaaaafgifcaaaacaaaaaaaaaaaaaaegiccaaa
adaaaaaabbaaaaaadcaaaaalhcaabaaaabaaaaaaegiccaaaadaaaaaabaaaaaaa
agiacaaaacaaaaaaaaaaaaaaegacbaaaabaaaaaadcaaaaalhcaabaaaabaaaaaa
egiccaaaadaaaaaabcaaaaaakgikcaaaacaaaaaaaaaaaaaaegacbaaaabaaaaaa
dcaaaaalhcaabaaaabaaaaaaegiccaaaadaaaaaabdaaaaaapgipcaaaacaaaaaa
aaaaaaaaegacbaaaabaaaaaabaaaaaahcccabaaaaeaaaaaaegacbaaaaaaaaaaa
egacbaaaabaaaaaabaaaaaahbccabaaaaeaaaaaaegbcbaaaabaaaaaaegacbaaa
abaaaaaabaaaaaaheccabaaaaeaaaaaaegbcbaaaacaaaaaaegacbaaaabaaaaaa
dgaaaaaghccabaaaafaaaaaaegiccaaaaeaaaaaaaeaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" "VERTEXLIGHT_ON" }
"!!GLES


#ifdef VERTEX

varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _DetailDist;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;
uniform highp mat4 glstate_matrix_mvp;
uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  highp vec2 tmpvar_5;
  highp vec3 tmpvar_6;
  tmpvar_6 = (_Object2World * _glesVertex).xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (_Object2World * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
  highp vec3 p_8;
  p_8 = (tmpvar_6 - _WorldSpaceCameraPos);
  tmpvar_5.x = (_DetailDist * sqrt(dot (p_8, p_8)));
  highp vec3 p_9;
  p_9 = (tmpvar_7 - _WorldSpaceCameraPos);
  highp vec3 p_10;
  p_10 = (tmpvar_7 - tmpvar_6);
  tmpvar_5.y = clamp ((sqrt(dot (p_9, p_9)) - (1.0005 * sqrt(dot (p_10, p_10)))), 0.0, 1.0);
  highp vec3 tmpvar_11;
  highp vec3 tmpvar_12;
  tmpvar_11 = tmpvar_1.xyz;
  tmpvar_12 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_13;
  tmpvar_13[0].x = tmpvar_11.x;
  tmpvar_13[0].y = tmpvar_12.x;
  tmpvar_13[0].z = tmpvar_2.x;
  tmpvar_13[1].x = tmpvar_11.y;
  tmpvar_13[1].y = tmpvar_12.y;
  tmpvar_13[1].z = tmpvar_2.y;
  tmpvar_13[2].x = tmpvar_11.z;
  tmpvar_13[2].y = tmpvar_12.z;
  tmpvar_13[2].z = tmpvar_2.z;
  highp vec3 tmpvar_14;
  tmpvar_14 = (tmpvar_13 * (_World2Object * _WorldSpaceLightPos0).xyz);
  tmpvar_3 = tmpvar_14;
  highp vec4 tmpvar_15;
  tmpvar_15.w = 1.0;
  tmpvar_15.xyz = _WorldSpaceCameraPos;
  highp vec3 tmpvar_16;
  tmpvar_16 = glstate_lightmodel_ambient.xyz;
  tmpvar_4 = tmpvar_16;
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_TEXCOORD0 = (tmpvar_13 * (((_World2Object * tmpvar_15).xyz * unity_Scale.w) - _glesVertex.xyz));
  xlv_TEXCOORD1 = tmpvar_5;
  xlv_TEXCOORD2 = normalize(_glesVertex.xyz);
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
}



#endif
#ifdef FRAGMENT

varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _MinLight;
uniform highp float _BumpScale;
uniform highp float _DetailScale;
uniform highp float _FalloffScale;
uniform highp float _FalloffPow;
uniform lowp vec4 _BumpOffset;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _Color;
uniform sampler2D _BumpMap;
uniform sampler2D _DetailTex;
uniform sampler2D _MainTex;
uniform lowp vec4 _LightColor0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  lowp float tmpvar_5;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  tmpvar_4 = tmpvar_2;
  tmpvar_5 = 0.0;
  mediump float rim_6;
  mediump float detailLevel_7;
  mediump vec4 normal_8;
  mediump vec4 detail_9;
  mediump vec4 normalZ_10;
  mediump vec4 normalY_11;
  mediump vec4 normalX_12;
  mediump vec4 detailZ_13;
  mediump vec4 detailY_14;
  mediump vec4 detailX_15;
  mediump vec4 main_16;
  highp vec2 uv_17;
  highp float r_18;
  if ((abs(xlv_TEXCOORD2.x) > (1e-08 * abs(xlv_TEXCOORD2.z)))) {
    highp float y_over_x_19;
    y_over_x_19 = (xlv_TEXCOORD2.z / xlv_TEXCOORD2.x);
    highp float s_20;
    highp float x_21;
    x_21 = (y_over_x_19 * inversesqrt(((y_over_x_19 * y_over_x_19) + 1.0)));
    s_20 = (sign(x_21) * (1.5708 - (sqrt((1.0 - abs(x_21))) * (1.5708 + (abs(x_21) * (-0.214602 + (abs(x_21) * (0.0865667 + (abs(x_21) * -0.0310296)))))))));
    r_18 = s_20;
    if ((xlv_TEXCOORD2.x < 0.0)) {
      if ((xlv_TEXCOORD2.z >= 0.0)) {
        r_18 = (s_20 + 3.14159);
      } else {
        r_18 = (r_18 - 3.14159);
      };
    };
  } else {
    r_18 = (sign(xlv_TEXCOORD2.z) * 1.5708);
  };
  uv_17.x = (0.5 + (0.159155 * r_18));
  highp float x_22;
  x_22 = -(xlv_TEXCOORD2.y);
  uv_17.y = (0.31831 * (1.5708 - (sign(x_22) * (1.5708 - (sqrt((1.0 - abs(x_22))) * (1.5708 + (abs(x_22) * (-0.214602 + (abs(x_22) * (0.0865667 + (abs(x_22) * -0.0310296)))))))))));
  lowp vec4 tmpvar_23;
  tmpvar_23 = (texture2D (_MainTex, uv_17) * _Color);
  main_16 = tmpvar_23;
  lowp vec4 tmpvar_24;
  highp vec2 P_25;
  P_25 = ((xlv_TEXCOORD2.zy * _DetailScale) + _DetailOffset.xy);
  tmpvar_24 = texture2D (_DetailTex, P_25);
  detailX_15 = tmpvar_24;
  lowp vec4 tmpvar_26;
  highp vec2 P_27;
  P_27 = ((xlv_TEXCOORD2.zx * _DetailScale) + _DetailOffset.xy);
  tmpvar_26 = texture2D (_DetailTex, P_27);
  detailY_14 = tmpvar_26;
  lowp vec4 tmpvar_28;
  highp vec2 P_29;
  P_29 = ((xlv_TEXCOORD2.xy * _DetailScale) + _DetailOffset.xy);
  tmpvar_28 = texture2D (_DetailTex, P_29);
  detailZ_13 = tmpvar_28;
  lowp vec4 tmpvar_30;
  highp vec2 P_31;
  P_31 = ((xlv_TEXCOORD2.zy * _BumpScale) + _BumpOffset.xy);
  tmpvar_30 = texture2D (_BumpMap, P_31);
  normalX_12 = tmpvar_30;
  lowp vec4 tmpvar_32;
  highp vec2 P_33;
  P_33 = ((xlv_TEXCOORD2.zx * _BumpScale) + _BumpOffset.xy);
  tmpvar_32 = texture2D (_BumpMap, P_33);
  normalY_11 = tmpvar_32;
  lowp vec4 tmpvar_34;
  highp vec2 P_35;
  P_35 = ((xlv_TEXCOORD2.xy * _BumpScale) + _BumpOffset.xy);
  tmpvar_34 = texture2D (_BumpMap, P_35);
  normalZ_10 = tmpvar_34;
  highp vec3 tmpvar_36;
  tmpvar_36 = abs(xlv_TEXCOORD2);
  highp vec4 tmpvar_37;
  tmpvar_37 = mix (detailZ_13, detailX_15, tmpvar_36.xxxx);
  detail_9 = tmpvar_37;
  highp vec4 tmpvar_38;
  tmpvar_38 = mix (detail_9, detailY_14, tmpvar_36.yyyy);
  detail_9 = tmpvar_38;
  highp vec4 tmpvar_39;
  tmpvar_39 = mix (normalZ_10, normalX_12, tmpvar_36.xxxx);
  normal_8 = tmpvar_39;
  highp vec4 tmpvar_40;
  tmpvar_40 = mix (normal_8, normalY_11, tmpvar_36.yyyy);
  normal_8 = tmpvar_40;
  highp float tmpvar_41;
  tmpvar_41 = clamp ((2.0 * xlv_TEXCOORD1.x), 0.0, 1.0);
  detailLevel_7 = tmpvar_41;
  mediump vec3 tmpvar_42;
  tmpvar_42 = ((main_16.xyz * mix (detail_9.xyz, vec3(1.0, 1.0, 1.0), vec3(detailLevel_7))) * _Color.xyz);
  tmpvar_3 = tmpvar_42;
  mediump float tmpvar_43;
  tmpvar_43 = (main_16.w * mix (detail_9.w, 1.0, detailLevel_7));
  highp float tmpvar_44;
  tmpvar_44 = clamp (normalize(xlv_TEXCOORD0).z, 0.0, 1.0);
  rim_6 = tmpvar_44;
  highp float tmpvar_45;
  tmpvar_45 = ((tmpvar_43 * xlv_TEXCOORD1.y) * clamp (((1.0 - xlv_TEXCOORD1.y) + clamp (pow ((_FalloffScale * rim_6), _FalloffPow), 0.0, 1.0)), 0.0, 1.0));
  tmpvar_5 = tmpvar_45;
  lowp vec3 tmpvar_46;
  lowp vec4 packednormal_47;
  packednormal_47 = normal_8;
  tmpvar_46 = ((packednormal_47.xyz * 2.0) - 1.0);
  mediump vec3 tmpvar_48;
  tmpvar_48 = mix (tmpvar_46, vec3(0.0, 0.0, 1.0), vec3(detailLevel_7));
  tmpvar_4 = tmpvar_48;
  tmpvar_2 = tmpvar_4;
  mediump vec3 lightDir_49;
  lightDir_49 = xlv_TEXCOORD3;
  mediump vec4 c_50;
  mediump float tmpvar_51;
  tmpvar_51 = clamp (dot (tmpvar_4, lightDir_49), 0.0, 1.0);
  highp vec3 tmpvar_52;
  tmpvar_52 = clamp ((_MinLight + (_LightColor0.xyz * (tmpvar_51 * 2.0))), 0.0, 1.0);
  lowp vec3 tmpvar_53;
  tmpvar_53 = (tmpvar_3 * tmpvar_52);
  c_50.xyz = tmpvar_53;
  c_50.w = tmpvar_5;
  c_1 = c_50;
  c_1.xyz = (c_1.xyz + (tmpvar_3 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" "VERTEXLIGHT_ON" }
"!!GLES


#ifdef VERTEX

varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _DetailDist;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;
uniform highp mat4 glstate_matrix_mvp;
uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  highp vec2 tmpvar_5;
  highp vec3 tmpvar_6;
  tmpvar_6 = (_Object2World * _glesVertex).xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (_Object2World * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
  highp vec3 p_8;
  p_8 = (tmpvar_6 - _WorldSpaceCameraPos);
  tmpvar_5.x = (_DetailDist * sqrt(dot (p_8, p_8)));
  highp vec3 p_9;
  p_9 = (tmpvar_7 - _WorldSpaceCameraPos);
  highp vec3 p_10;
  p_10 = (tmpvar_7 - tmpvar_6);
  tmpvar_5.y = clamp ((sqrt(dot (p_9, p_9)) - (1.0005 * sqrt(dot (p_10, p_10)))), 0.0, 1.0);
  highp vec3 tmpvar_11;
  highp vec3 tmpvar_12;
  tmpvar_11 = tmpvar_1.xyz;
  tmpvar_12 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_13;
  tmpvar_13[0].x = tmpvar_11.x;
  tmpvar_13[0].y = tmpvar_12.x;
  tmpvar_13[0].z = tmpvar_2.x;
  tmpvar_13[1].x = tmpvar_11.y;
  tmpvar_13[1].y = tmpvar_12.y;
  tmpvar_13[1].z = tmpvar_2.y;
  tmpvar_13[2].x = tmpvar_11.z;
  tmpvar_13[2].y = tmpvar_12.z;
  tmpvar_13[2].z = tmpvar_2.z;
  highp vec3 tmpvar_14;
  tmpvar_14 = (tmpvar_13 * (_World2Object * _WorldSpaceLightPos0).xyz);
  tmpvar_3 = tmpvar_14;
  highp vec4 tmpvar_15;
  tmpvar_15.w = 1.0;
  tmpvar_15.xyz = _WorldSpaceCameraPos;
  highp vec3 tmpvar_16;
  tmpvar_16 = glstate_lightmodel_ambient.xyz;
  tmpvar_4 = tmpvar_16;
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_TEXCOORD0 = (tmpvar_13 * (((_World2Object * tmpvar_15).xyz * unity_Scale.w) - _glesVertex.xyz));
  xlv_TEXCOORD1 = tmpvar_5;
  xlv_TEXCOORD2 = normalize(_glesVertex.xyz);
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
}



#endif
#ifdef FRAGMENT

varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _MinLight;
uniform highp float _BumpScale;
uniform highp float _DetailScale;
uniform highp float _FalloffScale;
uniform highp float _FalloffPow;
uniform lowp vec4 _BumpOffset;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _Color;
uniform sampler2D _BumpMap;
uniform sampler2D _DetailTex;
uniform sampler2D _MainTex;
uniform lowp vec4 _LightColor0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  lowp float tmpvar_5;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  tmpvar_4 = tmpvar_2;
  tmpvar_5 = 0.0;
  mediump float rim_6;
  mediump float detailLevel_7;
  mediump vec4 normal_8;
  mediump vec4 detail_9;
  mediump vec4 normalZ_10;
  mediump vec4 normalY_11;
  mediump vec4 normalX_12;
  mediump vec4 detailZ_13;
  mediump vec4 detailY_14;
  mediump vec4 detailX_15;
  mediump vec4 main_16;
  highp vec2 uv_17;
  highp float r_18;
  if ((abs(xlv_TEXCOORD2.x) > (1e-08 * abs(xlv_TEXCOORD2.z)))) {
    highp float y_over_x_19;
    y_over_x_19 = (xlv_TEXCOORD2.z / xlv_TEXCOORD2.x);
    highp float s_20;
    highp float x_21;
    x_21 = (y_over_x_19 * inversesqrt(((y_over_x_19 * y_over_x_19) + 1.0)));
    s_20 = (sign(x_21) * (1.5708 - (sqrt((1.0 - abs(x_21))) * (1.5708 + (abs(x_21) * (-0.214602 + (abs(x_21) * (0.0865667 + (abs(x_21) * -0.0310296)))))))));
    r_18 = s_20;
    if ((xlv_TEXCOORD2.x < 0.0)) {
      if ((xlv_TEXCOORD2.z >= 0.0)) {
        r_18 = (s_20 + 3.14159);
      } else {
        r_18 = (r_18 - 3.14159);
      };
    };
  } else {
    r_18 = (sign(xlv_TEXCOORD2.z) * 1.5708);
  };
  uv_17.x = (0.5 + (0.159155 * r_18));
  highp float x_22;
  x_22 = -(xlv_TEXCOORD2.y);
  uv_17.y = (0.31831 * (1.5708 - (sign(x_22) * (1.5708 - (sqrt((1.0 - abs(x_22))) * (1.5708 + (abs(x_22) * (-0.214602 + (abs(x_22) * (0.0865667 + (abs(x_22) * -0.0310296)))))))))));
  lowp vec4 tmpvar_23;
  tmpvar_23 = (texture2D (_MainTex, uv_17) * _Color);
  main_16 = tmpvar_23;
  lowp vec4 tmpvar_24;
  highp vec2 P_25;
  P_25 = ((xlv_TEXCOORD2.zy * _DetailScale) + _DetailOffset.xy);
  tmpvar_24 = texture2D (_DetailTex, P_25);
  detailX_15 = tmpvar_24;
  lowp vec4 tmpvar_26;
  highp vec2 P_27;
  P_27 = ((xlv_TEXCOORD2.zx * _DetailScale) + _DetailOffset.xy);
  tmpvar_26 = texture2D (_DetailTex, P_27);
  detailY_14 = tmpvar_26;
  lowp vec4 tmpvar_28;
  highp vec2 P_29;
  P_29 = ((xlv_TEXCOORD2.xy * _DetailScale) + _DetailOffset.xy);
  tmpvar_28 = texture2D (_DetailTex, P_29);
  detailZ_13 = tmpvar_28;
  lowp vec4 tmpvar_30;
  highp vec2 P_31;
  P_31 = ((xlv_TEXCOORD2.zy * _BumpScale) + _BumpOffset.xy);
  tmpvar_30 = texture2D (_BumpMap, P_31);
  normalX_12 = tmpvar_30;
  lowp vec4 tmpvar_32;
  highp vec2 P_33;
  P_33 = ((xlv_TEXCOORD2.zx * _BumpScale) + _BumpOffset.xy);
  tmpvar_32 = texture2D (_BumpMap, P_33);
  normalY_11 = tmpvar_32;
  lowp vec4 tmpvar_34;
  highp vec2 P_35;
  P_35 = ((xlv_TEXCOORD2.xy * _BumpScale) + _BumpOffset.xy);
  tmpvar_34 = texture2D (_BumpMap, P_35);
  normalZ_10 = tmpvar_34;
  highp vec3 tmpvar_36;
  tmpvar_36 = abs(xlv_TEXCOORD2);
  highp vec4 tmpvar_37;
  tmpvar_37 = mix (detailZ_13, detailX_15, tmpvar_36.xxxx);
  detail_9 = tmpvar_37;
  highp vec4 tmpvar_38;
  tmpvar_38 = mix (detail_9, detailY_14, tmpvar_36.yyyy);
  detail_9 = tmpvar_38;
  highp vec4 tmpvar_39;
  tmpvar_39 = mix (normalZ_10, normalX_12, tmpvar_36.xxxx);
  normal_8 = tmpvar_39;
  highp vec4 tmpvar_40;
  tmpvar_40 = mix (normal_8, normalY_11, tmpvar_36.yyyy);
  normal_8 = tmpvar_40;
  highp float tmpvar_41;
  tmpvar_41 = clamp ((2.0 * xlv_TEXCOORD1.x), 0.0, 1.0);
  detailLevel_7 = tmpvar_41;
  mediump vec3 tmpvar_42;
  tmpvar_42 = ((main_16.xyz * mix (detail_9.xyz, vec3(1.0, 1.0, 1.0), vec3(detailLevel_7))) * _Color.xyz);
  tmpvar_3 = tmpvar_42;
  mediump float tmpvar_43;
  tmpvar_43 = (main_16.w * mix (detail_9.w, 1.0, detailLevel_7));
  highp float tmpvar_44;
  tmpvar_44 = clamp (normalize(xlv_TEXCOORD0).z, 0.0, 1.0);
  rim_6 = tmpvar_44;
  highp float tmpvar_45;
  tmpvar_45 = ((tmpvar_43 * xlv_TEXCOORD1.y) * clamp (((1.0 - xlv_TEXCOORD1.y) + clamp (pow ((_FalloffScale * rim_6), _FalloffPow), 0.0, 1.0)), 0.0, 1.0));
  tmpvar_5 = tmpvar_45;
  lowp vec4 packednormal_46;
  packednormal_46 = normal_8;
  lowp vec3 normal_47;
  normal_47.xy = ((packednormal_46.wy * 2.0) - 1.0);
  normal_47.z = sqrt((1.0 - clamp (dot (normal_47.xy, normal_47.xy), 0.0, 1.0)));
  mediump vec3 tmpvar_48;
  tmpvar_48 = mix (normal_47, vec3(0.0, 0.0, 1.0), vec3(detailLevel_7));
  tmpvar_4 = tmpvar_48;
  tmpvar_2 = tmpvar_4;
  mediump vec3 lightDir_49;
  lightDir_49 = xlv_TEXCOORD3;
  mediump vec4 c_50;
  mediump float tmpvar_51;
  tmpvar_51 = clamp (dot (tmpvar_4, lightDir_49), 0.0, 1.0);
  highp vec3 tmpvar_52;
  tmpvar_52 = clamp ((_MinLight + (_LightColor0.xyz * (tmpvar_51 * 2.0))), 0.0, 1.0);
  lowp vec3 tmpvar_53;
  tmpvar_53 = (tmpvar_3 * tmpvar_52);
  c_50.xyz = tmpvar_53;
  c_50.w = tmpvar_5;
  c_1 = c_50;
  c_1.xyz = (c_1.xyz + (tmpvar_3 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "gles3 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" "VERTEXLIGHT_ON" }
"!!GLES3#version 300 es


#ifdef VERTEX

#define gl_Vertex _glesVertex
in vec4 _glesVertex;
#define gl_Color _glesColor
in vec4 _glesColor;
#define gl_Normal (normalize(_glesNormal))
in vec3 _glesNormal;
#define gl_MultiTexCoord0 _glesMultiTexCoord0
in vec4 _glesMultiTexCoord0;
#define gl_MultiTexCoord1 _glesMultiTexCoord1
in vec4 _glesMultiTexCoord1;
#define TANGENT vec4(normalize(_glesTANGENT.xyz), _glesTANGENT.w)
in vec4 _glesTANGENT;
mat2 xll_transpose_mf2x2(mat2 m) {
  return mat2( m[0][0], m[1][0], m[0][1], m[1][1]);
}
mat3 xll_transpose_mf3x3(mat3 m) {
  return mat3( m[0][0], m[1][0], m[2][0],
               m[0][1], m[1][1], m[2][1],
               m[0][2], m[1][2], m[2][2]);
}
mat4 xll_transpose_mf4x4(mat4 m) {
  return mat4( m[0][0], m[1][0], m[2][0], m[3][0],
               m[0][1], m[1][1], m[2][1], m[3][1],
               m[0][2], m[1][2], m[2][2], m[3][2],
               m[0][3], m[1][3], m[2][3], m[3][3]);
}
float xll_saturate_f( float x) {
  return clamp( x, 0.0, 1.0);
}
vec2 xll_saturate_vf2( vec2 x) {
  return clamp( x, 0.0, 1.0);
}
vec3 xll_saturate_vf3( vec3 x) {
  return clamp( x, 0.0, 1.0);
}
vec4 xll_saturate_vf4( vec4 x) {
  return clamp( x, 0.0, 1.0);
}
mat2 xll_saturate_mf2x2(mat2 m) {
  return mat2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0));
}
mat3 xll_saturate_mf3x3(mat3 m) {
  return mat3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0));
}
mat4 xll_saturate_mf4x4(mat4 m) {
  return mat4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0));
}
#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 315
struct SurfaceOutput {
    lowp vec3 Albedo;
    lowp vec3 Normal;
    lowp vec3 Emission;
    mediump float Specular;
    lowp float Gloss;
    lowp float Alpha;
};
#line 67
struct appdata_full {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
    highp vec4 texcoord1;
    lowp vec4 color;
};
#line 411
struct Input {
    highp vec2 viewDist;
    highp vec3 viewDir;
    highp vec3 localPos;
};
#line 455
struct v2f_surf {
    highp vec4 pos;
    highp vec3 viewDir;
    highp vec2 cust_viewDist;
    highp vec3 cust_localPos;
    lowp vec3 lightDir;
    lowp vec3 vlight;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform lowp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 325
uniform lowp vec4 _LightColor0;
uniform lowp vec4 _SpecColor;
#line 338
#line 346
#line 360
uniform sampler2D _MainTex;
uniform sampler2D _DetailTex;
#line 393
uniform sampler2D _BumpMap;
uniform lowp vec4 _Color;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _BumpOffset;
#line 397
uniform highp float _FalloffPow;
uniform highp float _FalloffScale;
uniform highp float _DetailScale;
uniform highp float _DetailDist;
#line 401
uniform highp float _BumpScale;
uniform highp float _MinLight;
#line 418
#line 465
#line 82
highp vec3 ObjSpaceLightDir( in highp vec4 v ) {
    highp vec3 objSpaceLightPos = (_World2Object * _WorldSpaceLightPos0).xyz;
    return objSpaceLightPos.xyz;
}
#line 91
highp vec3 ObjSpaceViewDir( in highp vec4 v ) {
    highp vec3 objSpaceCameraPos = ((_World2Object * vec4( _WorldSpaceCameraPos.xyz, 1.0)).xyz * unity_Scale.w);
    return (objSpaceCameraPos - v.xyz);
}
#line 418
void vert( inout appdata_full v, out Input o ) {
    highp vec3 vertexPos = (_Object2World * v.vertex).xyz;
    #line 422
    highp vec3 origin = (_Object2World * vec4( 0.0, 0.0, 0.0, 1.0)).xyz;
    highp float diff = (_DetailDist * distance( vertexPos, _WorldSpaceCameraPos));
    o.viewDist.x = diff;
    o.viewDist.y = xll_saturate_f((distance( origin, _WorldSpaceCameraPos) - (1.0005 * distance( origin, vertexPos))));
    #line 426
    o.localPos = normalize(v.vertex.xyz);
}
#line 465
v2f_surf vert_surf( in appdata_full v ) {
    v2f_surf o;
    Input customInputData;
    #line 469
    vert( v, customInputData);
    o.cust_viewDist = customInputData.viewDist;
    o.cust_localPos = customInputData.localPos;
    o.pos = (glstate_matrix_mvp * v.vertex);
    #line 473
    highp vec3 worldN = (mat3( _Object2World) * (v.normal * unity_Scale.w));
    highp vec3 binormal = (cross( v.normal, v.tangent.xyz) * v.tangent.w);
    highp mat3 rotation = xll_transpose_mf3x3(mat3( v.tangent.xyz, binormal, v.normal));
    highp vec3 lightDir = (rotation * ObjSpaceLightDir( v.vertex));
    #line 477
    o.lightDir = lightDir;
    highp vec3 viewDirForLight = (rotation * ObjSpaceViewDir( v.vertex));
    o.viewDir = viewDirForLight;
    o.vlight = glstate_lightmodel_ambient.xyz;
    #line 482
    return o;
}

out highp vec3 xlv_TEXCOORD0;
out highp vec2 xlv_TEXCOORD1;
out highp vec3 xlv_TEXCOORD2;
out lowp vec3 xlv_TEXCOORD3;
out lowp vec3 xlv_TEXCOORD4;
void main() {
    v2f_surf xl_retval;
    appdata_full xlt_v;
    xlt_v.vertex = vec4(gl_Vertex);
    xlt_v.tangent = vec4(TANGENT);
    xlt_v.normal = vec3(gl_Normal);
    xlt_v.texcoord = vec4(gl_MultiTexCoord0);
    xlt_v.texcoord1 = vec4(gl_MultiTexCoord1);
    xlt_v.color = vec4(gl_Color);
    xl_retval = vert_surf( xlt_v);
    gl_Position = vec4(xl_retval.pos);
    xlv_TEXCOORD0 = vec3(xl_retval.viewDir);
    xlv_TEXCOORD1 = vec2(xl_retval.cust_viewDist);
    xlv_TEXCOORD2 = vec3(xl_retval.cust_localPos);
    xlv_TEXCOORD3 = vec3(xl_retval.lightDir);
    xlv_TEXCOORD4 = vec3(xl_retval.vlight);
}


#endif
#ifdef FRAGMENT

#define gl_FragData _glesFragData
layout(location = 0) out mediump vec4 _glesFragData[4];
float xll_saturate_f( float x) {
  return clamp( x, 0.0, 1.0);
}
vec2 xll_saturate_vf2( vec2 x) {
  return clamp( x, 0.0, 1.0);
}
vec3 xll_saturate_vf3( vec3 x) {
  return clamp( x, 0.0, 1.0);
}
vec4 xll_saturate_vf4( vec4 x) {
  return clamp( x, 0.0, 1.0);
}
mat2 xll_saturate_mf2x2(mat2 m) {
  return mat2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0));
}
mat3 xll_saturate_mf3x3(mat3 m) {
  return mat3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0));
}
mat4 xll_saturate_mf4x4(mat4 m) {
  return mat4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0));
}
#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 315
struct SurfaceOutput {
    lowp vec3 Albedo;
    lowp vec3 Normal;
    lowp vec3 Emission;
    mediump float Specular;
    lowp float Gloss;
    lowp float Alpha;
};
#line 67
struct appdata_full {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
    highp vec4 texcoord1;
    lowp vec4 color;
};
#line 411
struct Input {
    highp vec2 viewDist;
    highp vec3 viewDir;
    highp vec3 localPos;
};
#line 455
struct v2f_surf {
    highp vec4 pos;
    highp vec3 viewDir;
    highp vec2 cust_viewDist;
    highp vec3 cust_localPos;
    lowp vec3 lightDir;
    lowp vec3 vlight;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform lowp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 325
uniform lowp vec4 _LightColor0;
uniform lowp vec4 _SpecColor;
#line 338
#line 346
#line 360
uniform sampler2D _MainTex;
uniform sampler2D _DetailTex;
#line 393
uniform sampler2D _BumpMap;
uniform lowp vec4 _Color;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _BumpOffset;
#line 397
uniform highp float _FalloffPow;
uniform highp float _FalloffScale;
uniform highp float _DetailScale;
uniform highp float _DetailDist;
#line 401
uniform highp float _BumpScale;
uniform highp float _MinLight;
#line 418
#line 465
#line 403
mediump vec4 LightingSimpleLambert( in SurfaceOutput s, in mediump vec3 lightDir, in mediump float atten ) {
    #line 405
    mediump float NdotL = xll_saturate_f(dot( s.Normal, lightDir));
    mediump vec4 c;
    c.xyz = (s.Albedo * xll_saturate_vf3((_MinLight + (_LightColor0.xyz * ((NdotL * atten) * 2.0)))));
    c.w = s.Alpha;
    #line 409
    return c;
}
#line 272
lowp vec3 UnpackNormal( in lowp vec4 packednormal ) {
    #line 274
    return ((packednormal.xyz * 2.0) - 1.0);
}
#line 428
void surf( in Input IN, inout SurfaceOutput o ) {
    #line 430
    highp vec3 pos = IN.localPos;
    highp vec2 uv;
    uv.x = (0.5 + (0.159155 * atan( pos.z, pos.x)));
    uv.y = (0.31831 * acos((-pos.y)));
    #line 434
    mediump vec4 main = (texture( _MainTex, uv) * _Color);
    mediump vec4 detailX = texture( _DetailTex, ((pos.zy * _DetailScale) + _DetailOffset.xy));
    mediump vec4 detailY = texture( _DetailTex, ((pos.zx * _DetailScale) + _DetailOffset.xy));
    mediump vec4 detailZ = texture( _DetailTex, ((pos.xy * _DetailScale) + _DetailOffset.xy));
    #line 438
    mediump vec4 normalX = texture( _BumpMap, ((pos.zy * _BumpScale) + _BumpOffset.xy));
    mediump vec4 normalY = texture( _BumpMap, ((pos.zx * _BumpScale) + _BumpOffset.xy));
    mediump vec4 normalZ = texture( _BumpMap, ((pos.xy * _BumpScale) + _BumpOffset.xy));
    pos = abs(pos);
    #line 442
    mediump vec4 detail = mix( detailZ, detailX, vec4( pos.x));
    detail = mix( detail, detailY, vec4( pos.y));
    mediump vec4 normal = mix( normalZ, normalX, vec4( pos.x));
    normal = mix( normal, normalY, vec4( pos.y));
    #line 446
    mediump float detailLevel = xll_saturate_f((2.0 * IN.viewDist.x));
    mediump vec3 albedo = (main.xyz * mix( detail.xyz, vec3( 1.0), vec3( detailLevel)));
    o.Normal = vec3( 0.0, 0.0, 1.0);
    o.Albedo = (albedo * _Color.xyz);
    #line 450
    mediump float avg = (main.w * mix( detail.w, 1.0, detailLevel));
    mediump float rim = xll_saturate_f(dot( normalize(IN.viewDir), o.Normal));
    o.Alpha = ((avg * IN.viewDist.y) * xll_saturate_f(((1.0 - IN.viewDist.y) + xll_saturate_f(pow( (_FalloffScale * rim), _FalloffPow)))));
    o.Normal = mix( UnpackNormal( normal), vec3( 0.0, 0.0, 1.0), vec3( detailLevel));
}
#line 484
lowp vec4 frag_surf( in v2f_surf IN ) {
    #line 486
    Input surfIN;
    surfIN.viewDist = IN.cust_viewDist;
    surfIN.localPos = IN.cust_localPos;
    surfIN.viewDir = IN.viewDir;
    #line 490
    SurfaceOutput o;
    o.Albedo = vec3( 0.0);
    o.Emission = vec3( 0.0);
    o.Specular = 0.0;
    #line 494
    o.Alpha = 0.0;
    o.Gloss = 0.0;
    surf( surfIN, o);
    lowp float atten = 1.0;
    #line 498
    lowp vec4 c = vec4( 0.0);
    c = LightingSimpleLambert( o, IN.lightDir, atten);
    c.xyz += (o.Albedo * IN.vlight);
    return c;
}
in highp vec3 xlv_TEXCOORD0;
in highp vec2 xlv_TEXCOORD1;
in highp vec3 xlv_TEXCOORD2;
in lowp vec3 xlv_TEXCOORD3;
in lowp vec3 xlv_TEXCOORD4;
void main() {
    lowp vec4 xl_retval;
    v2f_surf xlt_IN;
    xlt_IN.pos = vec4(0.0);
    xlt_IN.viewDir = vec3(xlv_TEXCOORD0);
    xlt_IN.cust_viewDist = vec2(xlv_TEXCOORD1);
    xlt_IN.cust_localPos = vec3(xlv_TEXCOORD2);
    xlt_IN.lightDir = vec3(xlv_TEXCOORD3);
    xlt_IN.vlight = vec3(xlv_TEXCOORD4);
    xl_retval = frag_surf( xlt_IN);
    gl_FragData[0] = vec4(xl_retval);
}


#endif"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "VERTEXLIGHT_ON" }
Bind "vertex" Vertex
Bind "tangent" ATTR14
Bind "normal" Normal
Vector 2 [_WorldSpaceCameraPos]
Vector 3 [_ProjectionParams]
Vector 4 [_WorldSpaceLightPos0]
Matrix 5 [_Object2World]
Matrix 9 [_World2Object]
Vector 17 [unity_Scale]
Float 18 [_DetailDist]
"3.0-!!ARBvp1.0
# 56 ALU
PARAM c[19] = { { 1, 1.0005, 0, 0.5 },
		state.lightmodel.ambient,
		program.local[2..12],
		state.matrix.mvp,
		program.local[17..18] };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
MOV R0.xyz, vertex.attrib[14];
MUL R1.xyz, vertex.normal.zxyw, R0.yzxw;
MAD R0.xyz, vertex.normal.yzxw, R0.zxyw, -R1;
MOV R1.w, c[0].x;
MOV R1.xyz, c[2];
DP4 R2.z, R1, c[11];
DP4 R2.x, R1, c[9];
DP4 R2.y, R1, c[10];
MAD R3.xyz, R2, c[17].w, -vertex.position;
MUL R2.xyz, R0, vertex.attrib[14].w;
MOV R1, c[4];
DP4 R0.z, R1, c[11];
DP4 R0.x, R1, c[9];
DP4 R0.y, R1, c[10];
DP3 result.texcoord[3].y, R2, R0;
DP3 result.texcoord[0].y, R3, R2;
DP3 result.texcoord[3].z, vertex.normal, R0;
DP3 result.texcoord[3].x, vertex.attrib[14], R0;
MOV R1.z, c[7].w;
MOV R1.x, c[5].w;
MOV R1.y, c[6].w;
ADD R4.xyz, -R1, c[2];
DP4 R2.z, vertex.position, c[7];
DP4 R2.x, vertex.position, c[5];
DP4 R2.y, vertex.position, c[6];
ADD R1.xyz, R2, -R1;
DP3 R0.w, R1, R1;
DP3 R1.w, R4, R4;
RSQ R1.x, R1.w;
RSQ R0.w, R0.w;
DP4 R1.w, vertex.position, c[16];
DP4 R1.z, vertex.position, c[15];
RCP R1.x, R1.x;
RCP R0.w, R0.w;
MAD R0.w, -R0, c[0].y, R1.x;
MIN R0.w, R0, c[0].x;
DP4 R1.x, vertex.position, c[13];
DP4 R1.y, vertex.position, c[14];
DP3 result.texcoord[0].z, vertex.normal, R3;
DP3 result.texcoord[0].x, R3, vertex.attrib[14];
MUL R3.xyz, R1.xyww, c[0].w;
MUL R0.y, R3, c[3].x;
MOV R0.x, R3;
ADD result.texcoord[5].xy, R0, R3.z;
ADD R0.xyz, -R2, c[2];
DP3 R0.x, R0, R0;
RSQ R0.x, R0.x;
DP3 R0.y, vertex.position, vertex.position;
RCP R0.x, R0.x;
RSQ R0.y, R0.y;
MAX result.texcoord[1].y, R0.w, c[0].z;
MOV result.position, R1;
MOV result.texcoord[5].zw, R1;
MUL result.texcoord[1].x, R0, c[18];
MUL result.texcoord[2].xyz, R0.y, vertex.position;
MOV result.texcoord[4].xyz, c[1];
END
# 56 instructions, 5 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "VERTEXLIGHT_ON" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Vector 12 [glstate_lightmodel_ambient]
Matrix 0 [glstate_matrix_mvp]
Vector 13 [_WorldSpaceCameraPos]
Vector 14 [_ProjectionParams]
Vector 15 [_ScreenParams]
Vector 16 [_WorldSpaceLightPos0]
Matrix 4 [_Object2World]
Matrix 8 [_World2Object]
Vector 17 [unity_Scale]
Float 18 [_DetailDist]
"vs_3_0
; 56 ALU
dcl_position o0
dcl_texcoord0 o1
dcl_texcoord1 o2
dcl_texcoord2 o3
dcl_texcoord3 o4
dcl_texcoord4 o5
dcl_texcoord5 o6
def c19, 1.00000000, 1.00049996, 0.50000000, 0
dcl_position0 v0
dcl_tangent0 v1
dcl_normal0 v2
mov r0.xyz, v1
mul r1.xyz, v2.zxyw, r0.yzxw
mov r0.xyz, v1
mad r0.xyz, v2.yzxw, r0.zxyw, -r1
mul r3.xyz, r0, v1.w
mov r0, c10
dp4 r4.z, c16, r0
mov r0, c9
dp4 r4.y, c16, r0
mov r1.w, c19.x
mov r1.xyz, c13
dp4 r2.z, r1, c10
dp4 r2.x, r1, c8
dp4 r2.y, r1, c9
mad r2.xyz, r2, c17.w, -v0
mov r1, c8
dp4 r4.x, c16, r1
mov r0.z, c6.w
mov r0.x, c4.w
mov r0.y, c5.w
dp4 r1.z, v0, c6
dp4 r1.x, v0, c4
dp4 r1.y, v0, c5
dp3 o1.y, r2, r3
dp3 o1.z, v2, r2
dp3 o1.x, r2, v1
add r2.xyz, -r0, c13
add r0.xyz, r1, -r0
dp3 r0.x, r0, r0
dp3 r0.w, r2, r2
rsq r0.y, r0.w
rsq r0.x, r0.x
dp4 r0.w, v0, c3
dp4 r0.z, v0, c2
rcp r0.y, r0.y
rcp r0.x, r0.x
mad_sat o2.y, -r0.x, c19, r0
dp4 r0.x, v0, c0
dp4 r0.y, v0, c1
mul r2.xyz, r0.xyww, c19.z
mov o0, r0
mul r2.y, r2, c14.x
add r1.xyz, -r1, c13
dp3 r0.x, r1, r1
rsq r0.x, r0.x
dp3 r0.y, v0, v0
rcp r0.x, r0.x
rsq r0.y, r0.y
dp3 o4.y, r3, r4
dp3 o4.z, v2, r4
dp3 o4.x, v1, r4
mad o6.xy, r2.z, c15.zwzw, r2
mov o6.zw, r0
mul o2.x, r0, c18
mul o3.xyz, r0.y, v0
mov o5.xyz, c12
"
}

SubProgram "d3d11 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "VERTEXLIGHT_ON" }
Bind "vertex" Vertex
Bind "tangent" TexCoord2
Bind "normal" Normal
Bind "color" Color
ConstBuffer "$Globals" 192 // 176 used size, 13 vars
Float 172 [_DetailDist]
ConstBuffer "UnityPerCamera" 128 // 96 used size, 8 vars
Vector 64 [_WorldSpaceCameraPos] 3
Vector 80 [_ProjectionParams] 4
ConstBuffer "UnityLighting" 720 // 16 used size, 17 vars
Vector 0 [_WorldSpaceLightPos0] 4
ConstBuffer "UnityPerDraw" 336 // 336 used size, 6 vars
Matrix 0 [glstate_matrix_mvp] 4
Matrix 192 [_Object2World] 4
Matrix 256 [_World2Object] 4
Vector 320 [unity_Scale] 4
ConstBuffer "UnityPerFrame" 208 // 80 used size, 4 vars
Vector 64 [glstate_lightmodel_ambient] 4
BindCB "$Globals" 0
BindCB "UnityPerCamera" 1
BindCB "UnityLighting" 2
BindCB "UnityPerDraw" 3
BindCB "UnityPerFrame" 4
// 47 instructions, 4 temp regs, 0 temp arrays:
// ALU 43 float, 0 int, 0 uint
// TEX 0 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"vs_4_0
eefiecedmhjbampoddpgbiepflodmedjbnifhnaiabaaaaaaimaiaaaaadaaaaaa
cmaaaaaapeaaaaaameabaaaaejfdeheomaaaaaaaagaaaaaaaiaaaaaajiaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaakbaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaakjaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
ahahaaaalaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaadaaaaaaapaaaaaalaaaaaaa
abaaaaaaaaaaaaaaadaaaaaaaeaaaaaaapaaaaaaljaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaafaaaaaaapaaaaaafaepfdejfeejepeoaafeebeoehefeofeaaeoepfc
enebemaafeeffiedepepfceeaaedepemepfcaaklepfdeheomiaaaaaaahaaaaaa
aiaaaaaalaaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaalmaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaabaaaaaaahaiaaaalmaaaaaaabaaaaaaaaaaaaaa
adaaaaaaacaaaaaaadamaaaalmaaaaaaacaaaaaaaaaaaaaaadaaaaaaadaaaaaa
ahaiaaaalmaaaaaaadaaaaaaaaaaaaaaadaaaaaaaeaaaaaaahaiaaaalmaaaaaa
aeaaaaaaaaaaaaaaadaaaaaaafaaaaaaahaiaaaalmaaaaaaafaaaaaaaaaaaaaa
adaaaaaaagaaaaaaapaaaaaafdfgfpfaepfdejfeejepeoaafeeffiedepepfcee
aaklklklfdeieefcmaagaaaaeaaaabaalaabaaaafjaaaaaeegiocaaaaaaaaaaa
alaaaaaafjaaaaaeegiocaaaabaaaaaaagaaaaaafjaaaaaeegiocaaaacaaaaaa
abaaaaaafjaaaaaeegiocaaaadaaaaaabfaaaaaafjaaaaaeegiocaaaaeaaaaaa
afaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaadpcbabaaaabaaaaaafpaaaaad
hcbabaaaacaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaadhccabaaa
abaaaaaagfaaaaaddccabaaaacaaaaaagfaaaaadhccabaaaadaaaaaagfaaaaad
hccabaaaaeaaaaaagfaaaaadhccabaaaafaaaaaagfaaaaadpccabaaaagaaaaaa
giaaaaacaeaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiocaaa
adaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaadaaaaaaaaaaaaaa
agbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaa
adaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaa
aaaaaaaaegiocaaaadaaaaaaadaaaaaapgbpbaaaaaaaaaaaegaobaaaaaaaaaaa
dgaaaaafpccabaaaaaaaaaaaegaobaaaaaaaaaaadiaaaaahhcaabaaaabaaaaaa
jgbebaaaabaaaaaacgbjbaaaacaaaaaadcaaaaakhcaabaaaabaaaaaajgbebaaa
acaaaaaacgbjbaaaabaaaaaaegacbaiaebaaaaaaabaaaaaadiaaaaahhcaabaaa
abaaaaaaegacbaaaabaaaaaapgbpbaaaabaaaaaadiaaaaajhcaabaaaacaaaaaa
fgifcaaaabaaaaaaaeaaaaaaegiccaaaadaaaaaabbaaaaaadcaaaaalhcaabaaa
acaaaaaaegiccaaaadaaaaaabaaaaaaaagiacaaaabaaaaaaaeaaaaaaegacbaaa
acaaaaaadcaaaaalhcaabaaaacaaaaaaegiccaaaadaaaaaabcaaaaaakgikcaaa
abaaaaaaaeaaaaaaegacbaaaacaaaaaaaaaaaaaihcaabaaaacaaaaaaegacbaaa
acaaaaaaegiccaaaadaaaaaabdaaaaaadcaaaaalhcaabaaaacaaaaaaegacbaaa
acaaaaaapgipcaaaadaaaaaabeaaaaaaegbcbaiaebaaaaaaaaaaaaaabaaaaaah
cccabaaaabaaaaaaegacbaaaabaaaaaaegacbaaaacaaaaaabaaaaaahbccabaaa
abaaaaaaegbcbaaaabaaaaaaegacbaaaacaaaaaabaaaaaaheccabaaaabaaaaaa
egbcbaaaacaaaaaaegacbaaaacaaaaaaaaaaaaakhcaabaaaacaaaaaaegiccaia
ebaaaaaaabaaaaaaaeaaaaaaegiccaaaadaaaaaaapaaaaaabaaaaaahicaabaaa
abaaaaaaegacbaaaacaaaaaaegacbaaaacaaaaaaelaaaaaficaabaaaabaaaaaa
dkaabaaaabaaaaaadiaaaaaihcaabaaaacaaaaaafgbfbaaaaaaaaaaaegiccaaa
adaaaaaaanaaaaaadcaaaaakhcaabaaaacaaaaaaegiccaaaadaaaaaaamaaaaaa
agbabaaaaaaaaaaaegacbaaaacaaaaaadcaaaaakhcaabaaaacaaaaaaegiccaaa
adaaaaaaaoaaaaaakgbkbaaaaaaaaaaaegacbaaaacaaaaaadcaaaaakhcaabaaa
acaaaaaaegiccaaaadaaaaaaapaaaaaapgbpbaaaaaaaaaaaegacbaaaacaaaaaa
aaaaaaajhcaabaaaadaaaaaaegacbaiaebaaaaaaacaaaaaaegiccaaaadaaaaaa
apaaaaaaaaaaaaajhcaabaaaacaaaaaaegacbaaaacaaaaaaegiccaiaebaaaaaa
abaaaaaaaeaaaaaabaaaaaahbcaabaaaacaaaaaaegacbaaaacaaaaaaegacbaaa
acaaaaaaelaaaaafbcaabaaaacaaaaaaakaabaaaacaaaaaadiaaaaaibccabaaa
acaaaaaaakaabaaaacaaaaaadkiacaaaaaaaaaaaakaaaaaabaaaaaahbcaabaaa
acaaaaaaegacbaaaadaaaaaaegacbaaaadaaaaaaelaaaaafbcaabaaaacaaaaaa
akaabaaaacaaaaaadccaaaakcccabaaaacaaaaaaakaabaiaebaaaaaaacaaaaaa
abeaaaaagcbaiadpdkaabaaaabaaaaaabaaaaaahicaabaaaabaaaaaaegbcbaaa
aaaaaaaaegbcbaaaaaaaaaaaeeaaaaaficaabaaaabaaaaaadkaabaaaabaaaaaa
diaaaaahhccabaaaadaaaaaapgapbaaaabaaaaaaegbcbaaaaaaaaaaadiaaaaaj
hcaabaaaacaaaaaafgifcaaaacaaaaaaaaaaaaaaegiccaaaadaaaaaabbaaaaaa
dcaaaaalhcaabaaaacaaaaaaegiccaaaadaaaaaabaaaaaaaagiacaaaacaaaaaa
aaaaaaaaegacbaaaacaaaaaadcaaaaalhcaabaaaacaaaaaaegiccaaaadaaaaaa
bcaaaaaakgikcaaaacaaaaaaaaaaaaaaegacbaaaacaaaaaadcaaaaalhcaabaaa
acaaaaaaegiccaaaadaaaaaabdaaaaaapgipcaaaacaaaaaaaaaaaaaaegacbaaa
acaaaaaabaaaaaahcccabaaaaeaaaaaaegacbaaaabaaaaaaegacbaaaacaaaaaa
baaaaaahbccabaaaaeaaaaaaegbcbaaaabaaaaaaegacbaaaacaaaaaabaaaaaah
eccabaaaaeaaaaaaegbcbaaaacaaaaaaegacbaaaacaaaaaadgaaaaaghccabaaa
afaaaaaaegiccaaaaeaaaaaaaeaaaaaadiaaaaaiccaabaaaaaaaaaaabkaabaaa
aaaaaaaaakiacaaaabaaaaaaafaaaaaadiaaaaakncaabaaaabaaaaaaagahbaaa
aaaaaaaaaceaaaaaaaaaaadpaaaaaaaaaaaaaadpaaaaaadpdgaaaaafmccabaaa
agaaaaaakgaobaaaaaaaaaaaaaaaaaahdccabaaaagaaaaaakgakbaaaabaaaaaa
mgaabaaaabaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "VERTEXLIGHT_ON" }
"!!GLES


#ifdef VERTEX

varying highp vec4 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _DetailDist;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 unity_World2Shadow[4];
uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  highp vec2 tmpvar_5;
  highp vec3 tmpvar_6;
  tmpvar_6 = (_Object2World * _glesVertex).xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (_Object2World * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
  highp vec3 p_8;
  p_8 = (tmpvar_6 - _WorldSpaceCameraPos);
  tmpvar_5.x = (_DetailDist * sqrt(dot (p_8, p_8)));
  highp vec3 p_9;
  p_9 = (tmpvar_7 - _WorldSpaceCameraPos);
  highp vec3 p_10;
  p_10 = (tmpvar_7 - tmpvar_6);
  tmpvar_5.y = clamp ((sqrt(dot (p_9, p_9)) - (1.0005 * sqrt(dot (p_10, p_10)))), 0.0, 1.0);
  highp vec3 tmpvar_11;
  highp vec3 tmpvar_12;
  tmpvar_11 = tmpvar_1.xyz;
  tmpvar_12 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_13;
  tmpvar_13[0].x = tmpvar_11.x;
  tmpvar_13[0].y = tmpvar_12.x;
  tmpvar_13[0].z = tmpvar_2.x;
  tmpvar_13[1].x = tmpvar_11.y;
  tmpvar_13[1].y = tmpvar_12.y;
  tmpvar_13[1].z = tmpvar_2.y;
  tmpvar_13[2].x = tmpvar_11.z;
  tmpvar_13[2].y = tmpvar_12.z;
  tmpvar_13[2].z = tmpvar_2.z;
  highp vec3 tmpvar_14;
  tmpvar_14 = (tmpvar_13 * (_World2Object * _WorldSpaceLightPos0).xyz);
  tmpvar_3 = tmpvar_14;
  highp vec4 tmpvar_15;
  tmpvar_15.w = 1.0;
  tmpvar_15.xyz = _WorldSpaceCameraPos;
  highp vec3 tmpvar_16;
  tmpvar_16 = glstate_lightmodel_ambient.xyz;
  tmpvar_4 = tmpvar_16;
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_TEXCOORD0 = (tmpvar_13 * (((_World2Object * tmpvar_15).xyz * unity_Scale.w) - _glesVertex.xyz));
  xlv_TEXCOORD1 = tmpvar_5;
  xlv_TEXCOORD2 = normalize(_glesVertex.xyz);
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
  xlv_TEXCOORD5 = (unity_World2Shadow[0] * (_Object2World * _glesVertex));
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _MinLight;
uniform highp float _BumpScale;
uniform highp float _DetailScale;
uniform highp float _FalloffScale;
uniform highp float _FalloffPow;
uniform lowp vec4 _BumpOffset;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _Color;
uniform sampler2D _BumpMap;
uniform sampler2D _DetailTex;
uniform sampler2D _MainTex;
uniform sampler2D _ShadowMapTexture;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _LightShadowData;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  lowp float tmpvar_5;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  tmpvar_4 = tmpvar_2;
  tmpvar_5 = 0.0;
  mediump float rim_6;
  mediump float detailLevel_7;
  mediump vec4 normal_8;
  mediump vec4 detail_9;
  mediump vec4 normalZ_10;
  mediump vec4 normalY_11;
  mediump vec4 normalX_12;
  mediump vec4 detailZ_13;
  mediump vec4 detailY_14;
  mediump vec4 detailX_15;
  mediump vec4 main_16;
  highp vec2 uv_17;
  highp float r_18;
  if ((abs(xlv_TEXCOORD2.x) > (1e-08 * abs(xlv_TEXCOORD2.z)))) {
    highp float y_over_x_19;
    y_over_x_19 = (xlv_TEXCOORD2.z / xlv_TEXCOORD2.x);
    highp float s_20;
    highp float x_21;
    x_21 = (y_over_x_19 * inversesqrt(((y_over_x_19 * y_over_x_19) + 1.0)));
    s_20 = (sign(x_21) * (1.5708 - (sqrt((1.0 - abs(x_21))) * (1.5708 + (abs(x_21) * (-0.214602 + (abs(x_21) * (0.0865667 + (abs(x_21) * -0.0310296)))))))));
    r_18 = s_20;
    if ((xlv_TEXCOORD2.x < 0.0)) {
      if ((xlv_TEXCOORD2.z >= 0.0)) {
        r_18 = (s_20 + 3.14159);
      } else {
        r_18 = (r_18 - 3.14159);
      };
    };
  } else {
    r_18 = (sign(xlv_TEXCOORD2.z) * 1.5708);
  };
  uv_17.x = (0.5 + (0.159155 * r_18));
  highp float x_22;
  x_22 = -(xlv_TEXCOORD2.y);
  uv_17.y = (0.31831 * (1.5708 - (sign(x_22) * (1.5708 - (sqrt((1.0 - abs(x_22))) * (1.5708 + (abs(x_22) * (-0.214602 + (abs(x_22) * (0.0865667 + (abs(x_22) * -0.0310296)))))))))));
  lowp vec4 tmpvar_23;
  tmpvar_23 = (texture2D (_MainTex, uv_17) * _Color);
  main_16 = tmpvar_23;
  lowp vec4 tmpvar_24;
  highp vec2 P_25;
  P_25 = ((xlv_TEXCOORD2.zy * _DetailScale) + _DetailOffset.xy);
  tmpvar_24 = texture2D (_DetailTex, P_25);
  detailX_15 = tmpvar_24;
  lowp vec4 tmpvar_26;
  highp vec2 P_27;
  P_27 = ((xlv_TEXCOORD2.zx * _DetailScale) + _DetailOffset.xy);
  tmpvar_26 = texture2D (_DetailTex, P_27);
  detailY_14 = tmpvar_26;
  lowp vec4 tmpvar_28;
  highp vec2 P_29;
  P_29 = ((xlv_TEXCOORD2.xy * _DetailScale) + _DetailOffset.xy);
  tmpvar_28 = texture2D (_DetailTex, P_29);
  detailZ_13 = tmpvar_28;
  lowp vec4 tmpvar_30;
  highp vec2 P_31;
  P_31 = ((xlv_TEXCOORD2.zy * _BumpScale) + _BumpOffset.xy);
  tmpvar_30 = texture2D (_BumpMap, P_31);
  normalX_12 = tmpvar_30;
  lowp vec4 tmpvar_32;
  highp vec2 P_33;
  P_33 = ((xlv_TEXCOORD2.zx * _BumpScale) + _BumpOffset.xy);
  tmpvar_32 = texture2D (_BumpMap, P_33);
  normalY_11 = tmpvar_32;
  lowp vec4 tmpvar_34;
  highp vec2 P_35;
  P_35 = ((xlv_TEXCOORD2.xy * _BumpScale) + _BumpOffset.xy);
  tmpvar_34 = texture2D (_BumpMap, P_35);
  normalZ_10 = tmpvar_34;
  highp vec3 tmpvar_36;
  tmpvar_36 = abs(xlv_TEXCOORD2);
  highp vec4 tmpvar_37;
  tmpvar_37 = mix (detailZ_13, detailX_15, tmpvar_36.xxxx);
  detail_9 = tmpvar_37;
  highp vec4 tmpvar_38;
  tmpvar_38 = mix (detail_9, detailY_14, tmpvar_36.yyyy);
  detail_9 = tmpvar_38;
  highp vec4 tmpvar_39;
  tmpvar_39 = mix (normalZ_10, normalX_12, tmpvar_36.xxxx);
  normal_8 = tmpvar_39;
  highp vec4 tmpvar_40;
  tmpvar_40 = mix (normal_8, normalY_11, tmpvar_36.yyyy);
  normal_8 = tmpvar_40;
  highp float tmpvar_41;
  tmpvar_41 = clamp ((2.0 * xlv_TEXCOORD1.x), 0.0, 1.0);
  detailLevel_7 = tmpvar_41;
  mediump vec3 tmpvar_42;
  tmpvar_42 = ((main_16.xyz * mix (detail_9.xyz, vec3(1.0, 1.0, 1.0), vec3(detailLevel_7))) * _Color.xyz);
  tmpvar_3 = tmpvar_42;
  mediump float tmpvar_43;
  tmpvar_43 = (main_16.w * mix (detail_9.w, 1.0, detailLevel_7));
  highp float tmpvar_44;
  tmpvar_44 = clamp (normalize(xlv_TEXCOORD0).z, 0.0, 1.0);
  rim_6 = tmpvar_44;
  highp float tmpvar_45;
  tmpvar_45 = ((tmpvar_43 * xlv_TEXCOORD1.y) * clamp (((1.0 - xlv_TEXCOORD1.y) + clamp (pow ((_FalloffScale * rim_6), _FalloffPow), 0.0, 1.0)), 0.0, 1.0));
  tmpvar_5 = tmpvar_45;
  lowp vec3 tmpvar_46;
  lowp vec4 packednormal_47;
  packednormal_47 = normal_8;
  tmpvar_46 = ((packednormal_47.xyz * 2.0) - 1.0);
  mediump vec3 tmpvar_48;
  tmpvar_48 = mix (tmpvar_46, vec3(0.0, 0.0, 1.0), vec3(detailLevel_7));
  tmpvar_4 = tmpvar_48;
  tmpvar_2 = tmpvar_4;
  lowp float tmpvar_49;
  mediump float lightShadowDataX_50;
  highp float dist_51;
  lowp float tmpvar_52;
  tmpvar_52 = texture2DProj (_ShadowMapTexture, xlv_TEXCOORD5).x;
  dist_51 = tmpvar_52;
  highp float tmpvar_53;
  tmpvar_53 = _LightShadowData.x;
  lightShadowDataX_50 = tmpvar_53;
  highp float tmpvar_54;
  tmpvar_54 = max (float((dist_51 > (xlv_TEXCOORD5.z / xlv_TEXCOORD5.w))), lightShadowDataX_50);
  tmpvar_49 = tmpvar_54;
  mediump vec3 lightDir_55;
  lightDir_55 = xlv_TEXCOORD3;
  mediump float atten_56;
  atten_56 = tmpvar_49;
  mediump vec4 c_57;
  mediump float tmpvar_58;
  tmpvar_58 = clamp (dot (tmpvar_4, lightDir_55), 0.0, 1.0);
  highp vec3 tmpvar_59;
  tmpvar_59 = clamp ((_MinLight + (_LightColor0.xyz * ((tmpvar_58 * atten_56) * 2.0))), 0.0, 1.0);
  lowp vec3 tmpvar_60;
  tmpvar_60 = (tmpvar_3 * tmpvar_59);
  c_57.xyz = tmpvar_60;
  c_57.w = tmpvar_5;
  c_1 = c_57;
  c_1.xyz = (c_1.xyz + (tmpvar_3 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "VERTEXLIGHT_ON" }
"!!GLES


#ifdef VERTEX

varying highp vec4 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _DetailDist;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;
uniform highp mat4 glstate_matrix_mvp;
uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp vec4 _ProjectionParams;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  highp vec2 tmpvar_5;
  highp vec3 tmpvar_6;
  tmpvar_6 = (_Object2World * _glesVertex).xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (_Object2World * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
  highp vec3 p_8;
  p_8 = (tmpvar_6 - _WorldSpaceCameraPos);
  tmpvar_5.x = (_DetailDist * sqrt(dot (p_8, p_8)));
  highp vec3 p_9;
  p_9 = (tmpvar_7 - _WorldSpaceCameraPos);
  highp vec3 p_10;
  p_10 = (tmpvar_7 - tmpvar_6);
  tmpvar_5.y = clamp ((sqrt(dot (p_9, p_9)) - (1.0005 * sqrt(dot (p_10, p_10)))), 0.0, 1.0);
  highp vec4 tmpvar_11;
  tmpvar_11 = (glstate_matrix_mvp * _glesVertex);
  highp vec3 tmpvar_12;
  highp vec3 tmpvar_13;
  tmpvar_12 = tmpvar_1.xyz;
  tmpvar_13 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_14;
  tmpvar_14[0].x = tmpvar_12.x;
  tmpvar_14[0].y = tmpvar_13.x;
  tmpvar_14[0].z = tmpvar_2.x;
  tmpvar_14[1].x = tmpvar_12.y;
  tmpvar_14[1].y = tmpvar_13.y;
  tmpvar_14[1].z = tmpvar_2.y;
  tmpvar_14[2].x = tmpvar_12.z;
  tmpvar_14[2].y = tmpvar_13.z;
  tmpvar_14[2].z = tmpvar_2.z;
  highp vec3 tmpvar_15;
  tmpvar_15 = (tmpvar_14 * (_World2Object * _WorldSpaceLightPos0).xyz);
  tmpvar_3 = tmpvar_15;
  highp vec4 tmpvar_16;
  tmpvar_16.w = 1.0;
  tmpvar_16.xyz = _WorldSpaceCameraPos;
  highp vec3 tmpvar_17;
  tmpvar_17 = glstate_lightmodel_ambient.xyz;
  tmpvar_4 = tmpvar_17;
  highp vec4 o_18;
  highp vec4 tmpvar_19;
  tmpvar_19 = (tmpvar_11 * 0.5);
  highp vec2 tmpvar_20;
  tmpvar_20.x = tmpvar_19.x;
  tmpvar_20.y = (tmpvar_19.y * _ProjectionParams.x);
  o_18.xy = (tmpvar_20 + tmpvar_19.w);
  o_18.zw = tmpvar_11.zw;
  gl_Position = tmpvar_11;
  xlv_TEXCOORD0 = (tmpvar_14 * (((_World2Object * tmpvar_16).xyz * unity_Scale.w) - _glesVertex.xyz));
  xlv_TEXCOORD1 = tmpvar_5;
  xlv_TEXCOORD2 = normalize(_glesVertex.xyz);
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
  xlv_TEXCOORD5 = o_18;
}



#endif
#ifdef FRAGMENT

varying highp vec4 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _MinLight;
uniform highp float _BumpScale;
uniform highp float _DetailScale;
uniform highp float _FalloffScale;
uniform highp float _FalloffPow;
uniform lowp vec4 _BumpOffset;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _Color;
uniform sampler2D _BumpMap;
uniform sampler2D _DetailTex;
uniform sampler2D _MainTex;
uniform sampler2D _ShadowMapTexture;
uniform lowp vec4 _LightColor0;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  lowp float tmpvar_5;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  tmpvar_4 = tmpvar_2;
  tmpvar_5 = 0.0;
  mediump float rim_6;
  mediump float detailLevel_7;
  mediump vec4 normal_8;
  mediump vec4 detail_9;
  mediump vec4 normalZ_10;
  mediump vec4 normalY_11;
  mediump vec4 normalX_12;
  mediump vec4 detailZ_13;
  mediump vec4 detailY_14;
  mediump vec4 detailX_15;
  mediump vec4 main_16;
  highp vec2 uv_17;
  highp float r_18;
  if ((abs(xlv_TEXCOORD2.x) > (1e-08 * abs(xlv_TEXCOORD2.z)))) {
    highp float y_over_x_19;
    y_over_x_19 = (xlv_TEXCOORD2.z / xlv_TEXCOORD2.x);
    highp float s_20;
    highp float x_21;
    x_21 = (y_over_x_19 * inversesqrt(((y_over_x_19 * y_over_x_19) + 1.0)));
    s_20 = (sign(x_21) * (1.5708 - (sqrt((1.0 - abs(x_21))) * (1.5708 + (abs(x_21) * (-0.214602 + (abs(x_21) * (0.0865667 + (abs(x_21) * -0.0310296)))))))));
    r_18 = s_20;
    if ((xlv_TEXCOORD2.x < 0.0)) {
      if ((xlv_TEXCOORD2.z >= 0.0)) {
        r_18 = (s_20 + 3.14159);
      } else {
        r_18 = (r_18 - 3.14159);
      };
    };
  } else {
    r_18 = (sign(xlv_TEXCOORD2.z) * 1.5708);
  };
  uv_17.x = (0.5 + (0.159155 * r_18));
  highp float x_22;
  x_22 = -(xlv_TEXCOORD2.y);
  uv_17.y = (0.31831 * (1.5708 - (sign(x_22) * (1.5708 - (sqrt((1.0 - abs(x_22))) * (1.5708 + (abs(x_22) * (-0.214602 + (abs(x_22) * (0.0865667 + (abs(x_22) * -0.0310296)))))))))));
  lowp vec4 tmpvar_23;
  tmpvar_23 = (texture2D (_MainTex, uv_17) * _Color);
  main_16 = tmpvar_23;
  lowp vec4 tmpvar_24;
  highp vec2 P_25;
  P_25 = ((xlv_TEXCOORD2.zy * _DetailScale) + _DetailOffset.xy);
  tmpvar_24 = texture2D (_DetailTex, P_25);
  detailX_15 = tmpvar_24;
  lowp vec4 tmpvar_26;
  highp vec2 P_27;
  P_27 = ((xlv_TEXCOORD2.zx * _DetailScale) + _DetailOffset.xy);
  tmpvar_26 = texture2D (_DetailTex, P_27);
  detailY_14 = tmpvar_26;
  lowp vec4 tmpvar_28;
  highp vec2 P_29;
  P_29 = ((xlv_TEXCOORD2.xy * _DetailScale) + _DetailOffset.xy);
  tmpvar_28 = texture2D (_DetailTex, P_29);
  detailZ_13 = tmpvar_28;
  lowp vec4 tmpvar_30;
  highp vec2 P_31;
  P_31 = ((xlv_TEXCOORD2.zy * _BumpScale) + _BumpOffset.xy);
  tmpvar_30 = texture2D (_BumpMap, P_31);
  normalX_12 = tmpvar_30;
  lowp vec4 tmpvar_32;
  highp vec2 P_33;
  P_33 = ((xlv_TEXCOORD2.zx * _BumpScale) + _BumpOffset.xy);
  tmpvar_32 = texture2D (_BumpMap, P_33);
  normalY_11 = tmpvar_32;
  lowp vec4 tmpvar_34;
  highp vec2 P_35;
  P_35 = ((xlv_TEXCOORD2.xy * _BumpScale) + _BumpOffset.xy);
  tmpvar_34 = texture2D (_BumpMap, P_35);
  normalZ_10 = tmpvar_34;
  highp vec3 tmpvar_36;
  tmpvar_36 = abs(xlv_TEXCOORD2);
  highp vec4 tmpvar_37;
  tmpvar_37 = mix (detailZ_13, detailX_15, tmpvar_36.xxxx);
  detail_9 = tmpvar_37;
  highp vec4 tmpvar_38;
  tmpvar_38 = mix (detail_9, detailY_14, tmpvar_36.yyyy);
  detail_9 = tmpvar_38;
  highp vec4 tmpvar_39;
  tmpvar_39 = mix (normalZ_10, normalX_12, tmpvar_36.xxxx);
  normal_8 = tmpvar_39;
  highp vec4 tmpvar_40;
  tmpvar_40 = mix (normal_8, normalY_11, tmpvar_36.yyyy);
  normal_8 = tmpvar_40;
  highp float tmpvar_41;
  tmpvar_41 = clamp ((2.0 * xlv_TEXCOORD1.x), 0.0, 1.0);
  detailLevel_7 = tmpvar_41;
  mediump vec3 tmpvar_42;
  tmpvar_42 = ((main_16.xyz * mix (detail_9.xyz, vec3(1.0, 1.0, 1.0), vec3(detailLevel_7))) * _Color.xyz);
  tmpvar_3 = tmpvar_42;
  mediump float tmpvar_43;
  tmpvar_43 = (main_16.w * mix (detail_9.w, 1.0, detailLevel_7));
  highp float tmpvar_44;
  tmpvar_44 = clamp (normalize(xlv_TEXCOORD0).z, 0.0, 1.0);
  rim_6 = tmpvar_44;
  highp float tmpvar_45;
  tmpvar_45 = ((tmpvar_43 * xlv_TEXCOORD1.y) * clamp (((1.0 - xlv_TEXCOORD1.y) + clamp (pow ((_FalloffScale * rim_6), _FalloffPow), 0.0, 1.0)), 0.0, 1.0));
  tmpvar_5 = tmpvar_45;
  lowp vec4 packednormal_46;
  packednormal_46 = normal_8;
  lowp vec3 normal_47;
  normal_47.xy = ((packednormal_46.wy * 2.0) - 1.0);
  normal_47.z = sqrt((1.0 - clamp (dot (normal_47.xy, normal_47.xy), 0.0, 1.0)));
  mediump vec3 tmpvar_48;
  tmpvar_48 = mix (normal_47, vec3(0.0, 0.0, 1.0), vec3(detailLevel_7));
  tmpvar_4 = tmpvar_48;
  tmpvar_2 = tmpvar_4;
  lowp float tmpvar_49;
  tmpvar_49 = texture2DProj (_ShadowMapTexture, xlv_TEXCOORD5).x;
  mediump vec3 lightDir_50;
  lightDir_50 = xlv_TEXCOORD3;
  mediump float atten_51;
  atten_51 = tmpvar_49;
  mediump vec4 c_52;
  mediump float tmpvar_53;
  tmpvar_53 = clamp (dot (tmpvar_4, lightDir_50), 0.0, 1.0);
  highp vec3 tmpvar_54;
  tmpvar_54 = clamp ((_MinLight + (_LightColor0.xyz * ((tmpvar_53 * atten_51) * 2.0))), 0.0, 1.0);
  lowp vec3 tmpvar_55;
  tmpvar_55 = (tmpvar_3 * tmpvar_54);
  c_52.xyz = tmpvar_55;
  c_52.w = tmpvar_5;
  c_1 = c_52;
  c_1.xyz = (c_1.xyz + (tmpvar_3 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "gles3 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "VERTEXLIGHT_ON" }
"!!GLES3#version 300 es


#ifdef VERTEX

#define gl_Vertex _glesVertex
in vec4 _glesVertex;
#define gl_Color _glesColor
in vec4 _glesColor;
#define gl_Normal (normalize(_glesNormal))
in vec3 _glesNormal;
#define gl_MultiTexCoord0 _glesMultiTexCoord0
in vec4 _glesMultiTexCoord0;
#define gl_MultiTexCoord1 _glesMultiTexCoord1
in vec4 _glesMultiTexCoord1;
#define TANGENT vec4(normalize(_glesTANGENT.xyz), _glesTANGENT.w)
in vec4 _glesTANGENT;
mat2 xll_transpose_mf2x2(mat2 m) {
  return mat2( m[0][0], m[1][0], m[0][1], m[1][1]);
}
mat3 xll_transpose_mf3x3(mat3 m) {
  return mat3( m[0][0], m[1][0], m[2][0],
               m[0][1], m[1][1], m[2][1],
               m[0][2], m[1][2], m[2][2]);
}
mat4 xll_transpose_mf4x4(mat4 m) {
  return mat4( m[0][0], m[1][0], m[2][0], m[3][0],
               m[0][1], m[1][1], m[2][1], m[3][1],
               m[0][2], m[1][2], m[2][2], m[3][2],
               m[0][3], m[1][3], m[2][3], m[3][3]);
}
float xll_saturate_f( float x) {
  return clamp( x, 0.0, 1.0);
}
vec2 xll_saturate_vf2( vec2 x) {
  return clamp( x, 0.0, 1.0);
}
vec3 xll_saturate_vf3( vec3 x) {
  return clamp( x, 0.0, 1.0);
}
vec4 xll_saturate_vf4( vec4 x) {
  return clamp( x, 0.0, 1.0);
}
mat2 xll_saturate_mf2x2(mat2 m) {
  return mat2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0));
}
mat3 xll_saturate_mf3x3(mat3 m) {
  return mat3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0));
}
mat4 xll_saturate_mf4x4(mat4 m) {
  return mat4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0));
}
#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 315
struct SurfaceOutput {
    lowp vec3 Albedo;
    lowp vec3 Normal;
    lowp vec3 Emission;
    mediump float Specular;
    lowp float Gloss;
    lowp float Alpha;
};
#line 67
struct appdata_full {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
    highp vec4 texcoord1;
    lowp vec4 color;
};
#line 419
struct Input {
    highp vec2 viewDist;
    highp vec3 viewDir;
    highp vec3 localPos;
};
#line 463
struct v2f_surf {
    highp vec4 pos;
    highp vec3 viewDir;
    highp vec2 cust_viewDist;
    highp vec3 cust_localPos;
    lowp vec3 lightDir;
    lowp vec3 vlight;
    highp vec4 _ShadowCoord;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform lowp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 325
uniform lowp vec4 _LightColor0;
uniform lowp vec4 _SpecColor;
#line 338
#line 346
#line 360
uniform highp vec4 _ShadowOffsets[4];
uniform sampler2D _ShadowMapTexture;
#line 393
uniform sampler2D _MainTex;
uniform sampler2D _DetailTex;
#line 401
uniform sampler2D _BumpMap;
uniform lowp vec4 _Color;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _BumpOffset;
#line 405
uniform highp float _FalloffPow;
uniform highp float _FalloffScale;
uniform highp float _DetailScale;
uniform highp float _DetailDist;
#line 409
uniform highp float _BumpScale;
uniform highp float _MinLight;
#line 426
#line 474
#line 494
#line 82
highp vec3 ObjSpaceLightDir( in highp vec4 v ) {
    highp vec3 objSpaceLightPos = (_World2Object * _WorldSpaceLightPos0).xyz;
    return objSpaceLightPos.xyz;
}
#line 91
highp vec3 ObjSpaceViewDir( in highp vec4 v ) {
    highp vec3 objSpaceCameraPos = ((_World2Object * vec4( _WorldSpaceCameraPos.xyz, 1.0)).xyz * unity_Scale.w);
    return (objSpaceCameraPos - v.xyz);
}
#line 426
void vert( inout appdata_full v, out Input o ) {
    highp vec3 vertexPos = (_Object2World * v.vertex).xyz;
    #line 430
    highp vec3 origin = (_Object2World * vec4( 0.0, 0.0, 0.0, 1.0)).xyz;
    highp float diff = (_DetailDist * distance( vertexPos, _WorldSpaceCameraPos));
    o.viewDist.x = diff;
    o.viewDist.y = xll_saturate_f((distance( origin, _WorldSpaceCameraPos) - (1.0005 * distance( origin, vertexPos))));
    #line 434
    o.localPos = normalize(v.vertex.xyz);
}
#line 474
v2f_surf vert_surf( in appdata_full v ) {
    v2f_surf o;
    Input customInputData;
    #line 478
    vert( v, customInputData);
    o.cust_viewDist = customInputData.viewDist;
    o.cust_localPos = customInputData.localPos;
    o.pos = (glstate_matrix_mvp * v.vertex);
    #line 482
    highp vec3 worldN = (mat3( _Object2World) * (v.normal * unity_Scale.w));
    highp vec3 binormal = (cross( v.normal, v.tangent.xyz) * v.tangent.w);
    highp mat3 rotation = xll_transpose_mf3x3(mat3( v.tangent.xyz, binormal, v.normal));
    highp vec3 lightDir = (rotation * ObjSpaceLightDir( v.vertex));
    #line 486
    o.lightDir = lightDir;
    highp vec3 viewDirForLight = (rotation * ObjSpaceViewDir( v.vertex));
    o.viewDir = viewDirForLight;
    o.vlight = glstate_lightmodel_ambient.xyz;
    #line 490
    o._ShadowCoord = (unity_World2Shadow[0] * (_Object2World * v.vertex));
    return o;
}

out highp vec3 xlv_TEXCOORD0;
out highp vec2 xlv_TEXCOORD1;
out highp vec3 xlv_TEXCOORD2;
out lowp vec3 xlv_TEXCOORD3;
out lowp vec3 xlv_TEXCOORD4;
out highp vec4 xlv_TEXCOORD5;
void main() {
    v2f_surf xl_retval;
    appdata_full xlt_v;
    xlt_v.vertex = vec4(gl_Vertex);
    xlt_v.tangent = vec4(TANGENT);
    xlt_v.normal = vec3(gl_Normal);
    xlt_v.texcoord = vec4(gl_MultiTexCoord0);
    xlt_v.texcoord1 = vec4(gl_MultiTexCoord1);
    xlt_v.color = vec4(gl_Color);
    xl_retval = vert_surf( xlt_v);
    gl_Position = vec4(xl_retval.pos);
    xlv_TEXCOORD0 = vec3(xl_retval.viewDir);
    xlv_TEXCOORD1 = vec2(xl_retval.cust_viewDist);
    xlv_TEXCOORD2 = vec3(xl_retval.cust_localPos);
    xlv_TEXCOORD3 = vec3(xl_retval.lightDir);
    xlv_TEXCOORD4 = vec3(xl_retval.vlight);
    xlv_TEXCOORD5 = vec4(xl_retval._ShadowCoord);
}


#endif
#ifdef FRAGMENT

#define gl_FragData _glesFragData
layout(location = 0) out mediump vec4 _glesFragData[4];
float xll_saturate_f( float x) {
  return clamp( x, 0.0, 1.0);
}
vec2 xll_saturate_vf2( vec2 x) {
  return clamp( x, 0.0, 1.0);
}
vec3 xll_saturate_vf3( vec3 x) {
  return clamp( x, 0.0, 1.0);
}
vec4 xll_saturate_vf4( vec4 x) {
  return clamp( x, 0.0, 1.0);
}
mat2 xll_saturate_mf2x2(mat2 m) {
  return mat2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0));
}
mat3 xll_saturate_mf3x3(mat3 m) {
  return mat3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0));
}
mat4 xll_saturate_mf4x4(mat4 m) {
  return mat4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0));
}
#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 315
struct SurfaceOutput {
    lowp vec3 Albedo;
    lowp vec3 Normal;
    lowp vec3 Emission;
    mediump float Specular;
    lowp float Gloss;
    lowp float Alpha;
};
#line 67
struct appdata_full {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
    highp vec4 texcoord1;
    lowp vec4 color;
};
#line 419
struct Input {
    highp vec2 viewDist;
    highp vec3 viewDir;
    highp vec3 localPos;
};
#line 463
struct v2f_surf {
    highp vec4 pos;
    highp vec3 viewDir;
    highp vec2 cust_viewDist;
    highp vec3 cust_localPos;
    lowp vec3 lightDir;
    lowp vec3 vlight;
    highp vec4 _ShadowCoord;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform lowp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 325
uniform lowp vec4 _LightColor0;
uniform lowp vec4 _SpecColor;
#line 338
#line 346
#line 360
uniform highp vec4 _ShadowOffsets[4];
uniform sampler2D _ShadowMapTexture;
#line 393
uniform sampler2D _MainTex;
uniform sampler2D _DetailTex;
#line 401
uniform sampler2D _BumpMap;
uniform lowp vec4 _Color;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _BumpOffset;
#line 405
uniform highp float _FalloffPow;
uniform highp float _FalloffScale;
uniform highp float _DetailScale;
uniform highp float _DetailDist;
#line 409
uniform highp float _BumpScale;
uniform highp float _MinLight;
#line 426
#line 474
#line 494
#line 411
mediump vec4 LightingSimpleLambert( in SurfaceOutput s, in mediump vec3 lightDir, in mediump float atten ) {
    #line 413
    mediump float NdotL = xll_saturate_f(dot( s.Normal, lightDir));
    mediump vec4 c;
    c.xyz = (s.Albedo * xll_saturate_vf3((_MinLight + (_LightColor0.xyz * ((NdotL * atten) * 2.0)))));
    c.w = s.Alpha;
    #line 417
    return c;
}
#line 272
lowp vec3 UnpackNormal( in lowp vec4 packednormal ) {
    #line 274
    return ((packednormal.xyz * 2.0) - 1.0);
}
#line 436
void surf( in Input IN, inout SurfaceOutput o ) {
    #line 438
    highp vec3 pos = IN.localPos;
    highp vec2 uv;
    uv.x = (0.5 + (0.159155 * atan( pos.z, pos.x)));
    uv.y = (0.31831 * acos((-pos.y)));
    #line 442
    mediump vec4 main = (texture( _MainTex, uv) * _Color);
    mediump vec4 detailX = texture( _DetailTex, ((pos.zy * _DetailScale) + _DetailOffset.xy));
    mediump vec4 detailY = texture( _DetailTex, ((pos.zx * _DetailScale) + _DetailOffset.xy));
    mediump vec4 detailZ = texture( _DetailTex, ((pos.xy * _DetailScale) + _DetailOffset.xy));
    #line 446
    mediump vec4 normalX = texture( _BumpMap, ((pos.zy * _BumpScale) + _BumpOffset.xy));
    mediump vec4 normalY = texture( _BumpMap, ((pos.zx * _BumpScale) + _BumpOffset.xy));
    mediump vec4 normalZ = texture( _BumpMap, ((pos.xy * _BumpScale) + _BumpOffset.xy));
    pos = abs(pos);
    #line 450
    mediump vec4 detail = mix( detailZ, detailX, vec4( pos.x));
    detail = mix( detail, detailY, vec4( pos.y));
    mediump vec4 normal = mix( normalZ, normalX, vec4( pos.x));
    normal = mix( normal, normalY, vec4( pos.y));
    #line 454
    mediump float detailLevel = xll_saturate_f((2.0 * IN.viewDist.x));
    mediump vec3 albedo = (main.xyz * mix( detail.xyz, vec3( 1.0), vec3( detailLevel)));
    o.Normal = vec3( 0.0, 0.0, 1.0);
    o.Albedo = (albedo * _Color.xyz);
    #line 458
    mediump float avg = (main.w * mix( detail.w, 1.0, detailLevel));
    mediump float rim = xll_saturate_f(dot( normalize(IN.viewDir), o.Normal));
    o.Alpha = ((avg * IN.viewDist.y) * xll_saturate_f(((1.0 - IN.viewDist.y) + xll_saturate_f(pow( (_FalloffScale * rim), _FalloffPow)))));
    o.Normal = mix( UnpackNormal( normal), vec3( 0.0, 0.0, 1.0), vec3( detailLevel));
}
#line 393
lowp float unitySampleShadow( in highp vec4 shadowCoord ) {
    highp float dist = textureProj( _ShadowMapTexture, shadowCoord).x;
    mediump float lightShadowDataX = _LightShadowData.x;
    #line 397
    return max( float((dist > (shadowCoord.z / shadowCoord.w))), lightShadowDataX);
}
#line 494
lowp vec4 frag_surf( in v2f_surf IN ) {
    Input surfIN;
    surfIN.viewDist = IN.cust_viewDist;
    #line 498
    surfIN.localPos = IN.cust_localPos;
    surfIN.viewDir = IN.viewDir;
    SurfaceOutput o;
    o.Albedo = vec3( 0.0);
    #line 502
    o.Emission = vec3( 0.0);
    o.Specular = 0.0;
    o.Alpha = 0.0;
    o.Gloss = 0.0;
    #line 506
    surf( surfIN, o);
    lowp float atten = unitySampleShadow( IN._ShadowCoord);
    lowp vec4 c = vec4( 0.0);
    c = LightingSimpleLambert( o, IN.lightDir, atten);
    #line 510
    c.xyz += (o.Albedo * IN.vlight);
    return c;
}
in highp vec3 xlv_TEXCOORD0;
in highp vec2 xlv_TEXCOORD1;
in highp vec3 xlv_TEXCOORD2;
in lowp vec3 xlv_TEXCOORD3;
in lowp vec3 xlv_TEXCOORD4;
in highp vec4 xlv_TEXCOORD5;
void main() {
    lowp vec4 xl_retval;
    v2f_surf xlt_IN;
    xlt_IN.pos = vec4(0.0);
    xlt_IN.viewDir = vec3(xlv_TEXCOORD0);
    xlt_IN.cust_viewDist = vec2(xlv_TEXCOORD1);
    xlt_IN.cust_localPos = vec3(xlv_TEXCOORD2);
    xlt_IN.lightDir = vec3(xlv_TEXCOORD3);
    xlt_IN.vlight = vec3(xlv_TEXCOORD4);
    xlt_IN._ShadowCoord = vec4(xlv_TEXCOORD5);
    xl_retval = frag_surf( xlt_IN);
    gl_FragData[0] = vec4(xl_retval);
}


#endif"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "SHADOWS_NATIVE" }
"!!GLES


#ifdef VERTEX

#extension GL_EXT_shadow_samplers : enable
varying highp vec4 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _DetailDist;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 unity_World2Shadow[4];
uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  highp vec2 tmpvar_5;
  highp vec3 tmpvar_6;
  tmpvar_6 = (_Object2World * _glesVertex).xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (_Object2World * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
  highp vec3 p_8;
  p_8 = (tmpvar_6 - _WorldSpaceCameraPos);
  tmpvar_5.x = (_DetailDist * sqrt(dot (p_8, p_8)));
  highp vec3 p_9;
  p_9 = (tmpvar_7 - _WorldSpaceCameraPos);
  highp vec3 p_10;
  p_10 = (tmpvar_7 - tmpvar_6);
  tmpvar_5.y = clamp ((sqrt(dot (p_9, p_9)) - (1.0005 * sqrt(dot (p_10, p_10)))), 0.0, 1.0);
  highp vec3 tmpvar_11;
  highp vec3 tmpvar_12;
  tmpvar_11 = tmpvar_1.xyz;
  tmpvar_12 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_13;
  tmpvar_13[0].x = tmpvar_11.x;
  tmpvar_13[0].y = tmpvar_12.x;
  tmpvar_13[0].z = tmpvar_2.x;
  tmpvar_13[1].x = tmpvar_11.y;
  tmpvar_13[1].y = tmpvar_12.y;
  tmpvar_13[1].z = tmpvar_2.y;
  tmpvar_13[2].x = tmpvar_11.z;
  tmpvar_13[2].y = tmpvar_12.z;
  tmpvar_13[2].z = tmpvar_2.z;
  highp vec3 tmpvar_14;
  tmpvar_14 = (tmpvar_13 * (_World2Object * _WorldSpaceLightPos0).xyz);
  tmpvar_3 = tmpvar_14;
  highp vec4 tmpvar_15;
  tmpvar_15.w = 1.0;
  tmpvar_15.xyz = _WorldSpaceCameraPos;
  highp vec3 tmpvar_16;
  tmpvar_16 = glstate_lightmodel_ambient.xyz;
  tmpvar_4 = tmpvar_16;
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_TEXCOORD0 = (tmpvar_13 * (((_World2Object * tmpvar_15).xyz * unity_Scale.w) - _glesVertex.xyz));
  xlv_TEXCOORD1 = tmpvar_5;
  xlv_TEXCOORD2 = normalize(_glesVertex.xyz);
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
  xlv_TEXCOORD5 = (unity_World2Shadow[0] * (_Object2World * _glesVertex));
}



#endif
#ifdef FRAGMENT

#extension GL_EXT_shadow_samplers : enable
varying highp vec4 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _MinLight;
uniform highp float _BumpScale;
uniform highp float _DetailScale;
uniform highp float _FalloffScale;
uniform highp float _FalloffPow;
uniform lowp vec4 _BumpOffset;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _Color;
uniform sampler2D _BumpMap;
uniform sampler2D _DetailTex;
uniform sampler2D _MainTex;
uniform lowp sampler2DShadow _ShadowMapTexture;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _LightShadowData;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  lowp float tmpvar_5;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  tmpvar_4 = tmpvar_2;
  tmpvar_5 = 0.0;
  mediump float rim_6;
  mediump float detailLevel_7;
  mediump vec4 normal_8;
  mediump vec4 detail_9;
  mediump vec4 normalZ_10;
  mediump vec4 normalY_11;
  mediump vec4 normalX_12;
  mediump vec4 detailZ_13;
  mediump vec4 detailY_14;
  mediump vec4 detailX_15;
  mediump vec4 main_16;
  highp vec2 uv_17;
  highp float r_18;
  if ((abs(xlv_TEXCOORD2.x) > (1e-08 * abs(xlv_TEXCOORD2.z)))) {
    highp float y_over_x_19;
    y_over_x_19 = (xlv_TEXCOORD2.z / xlv_TEXCOORD2.x);
    highp float s_20;
    highp float x_21;
    x_21 = (y_over_x_19 * inversesqrt(((y_over_x_19 * y_over_x_19) + 1.0)));
    s_20 = (sign(x_21) * (1.5708 - (sqrt((1.0 - abs(x_21))) * (1.5708 + (abs(x_21) * (-0.214602 + (abs(x_21) * (0.0865667 + (abs(x_21) * -0.0310296)))))))));
    r_18 = s_20;
    if ((xlv_TEXCOORD2.x < 0.0)) {
      if ((xlv_TEXCOORD2.z >= 0.0)) {
        r_18 = (s_20 + 3.14159);
      } else {
        r_18 = (r_18 - 3.14159);
      };
    };
  } else {
    r_18 = (sign(xlv_TEXCOORD2.z) * 1.5708);
  };
  uv_17.x = (0.5 + (0.159155 * r_18));
  highp float x_22;
  x_22 = -(xlv_TEXCOORD2.y);
  uv_17.y = (0.31831 * (1.5708 - (sign(x_22) * (1.5708 - (sqrt((1.0 - abs(x_22))) * (1.5708 + (abs(x_22) * (-0.214602 + (abs(x_22) * (0.0865667 + (abs(x_22) * -0.0310296)))))))))));
  lowp vec4 tmpvar_23;
  tmpvar_23 = (texture2D (_MainTex, uv_17) * _Color);
  main_16 = tmpvar_23;
  lowp vec4 tmpvar_24;
  highp vec2 P_25;
  P_25 = ((xlv_TEXCOORD2.zy * _DetailScale) + _DetailOffset.xy);
  tmpvar_24 = texture2D (_DetailTex, P_25);
  detailX_15 = tmpvar_24;
  lowp vec4 tmpvar_26;
  highp vec2 P_27;
  P_27 = ((xlv_TEXCOORD2.zx * _DetailScale) + _DetailOffset.xy);
  tmpvar_26 = texture2D (_DetailTex, P_27);
  detailY_14 = tmpvar_26;
  lowp vec4 tmpvar_28;
  highp vec2 P_29;
  P_29 = ((xlv_TEXCOORD2.xy * _DetailScale) + _DetailOffset.xy);
  tmpvar_28 = texture2D (_DetailTex, P_29);
  detailZ_13 = tmpvar_28;
  lowp vec4 tmpvar_30;
  highp vec2 P_31;
  P_31 = ((xlv_TEXCOORD2.zy * _BumpScale) + _BumpOffset.xy);
  tmpvar_30 = texture2D (_BumpMap, P_31);
  normalX_12 = tmpvar_30;
  lowp vec4 tmpvar_32;
  highp vec2 P_33;
  P_33 = ((xlv_TEXCOORD2.zx * _BumpScale) + _BumpOffset.xy);
  tmpvar_32 = texture2D (_BumpMap, P_33);
  normalY_11 = tmpvar_32;
  lowp vec4 tmpvar_34;
  highp vec2 P_35;
  P_35 = ((xlv_TEXCOORD2.xy * _BumpScale) + _BumpOffset.xy);
  tmpvar_34 = texture2D (_BumpMap, P_35);
  normalZ_10 = tmpvar_34;
  highp vec3 tmpvar_36;
  tmpvar_36 = abs(xlv_TEXCOORD2);
  highp vec4 tmpvar_37;
  tmpvar_37 = mix (detailZ_13, detailX_15, tmpvar_36.xxxx);
  detail_9 = tmpvar_37;
  highp vec4 tmpvar_38;
  tmpvar_38 = mix (detail_9, detailY_14, tmpvar_36.yyyy);
  detail_9 = tmpvar_38;
  highp vec4 tmpvar_39;
  tmpvar_39 = mix (normalZ_10, normalX_12, tmpvar_36.xxxx);
  normal_8 = tmpvar_39;
  highp vec4 tmpvar_40;
  tmpvar_40 = mix (normal_8, normalY_11, tmpvar_36.yyyy);
  normal_8 = tmpvar_40;
  highp float tmpvar_41;
  tmpvar_41 = clamp ((2.0 * xlv_TEXCOORD1.x), 0.0, 1.0);
  detailLevel_7 = tmpvar_41;
  mediump vec3 tmpvar_42;
  tmpvar_42 = ((main_16.xyz * mix (detail_9.xyz, vec3(1.0, 1.0, 1.0), vec3(detailLevel_7))) * _Color.xyz);
  tmpvar_3 = tmpvar_42;
  mediump float tmpvar_43;
  tmpvar_43 = (main_16.w * mix (detail_9.w, 1.0, detailLevel_7));
  highp float tmpvar_44;
  tmpvar_44 = clamp (normalize(xlv_TEXCOORD0).z, 0.0, 1.0);
  rim_6 = tmpvar_44;
  highp float tmpvar_45;
  tmpvar_45 = ((tmpvar_43 * xlv_TEXCOORD1.y) * clamp (((1.0 - xlv_TEXCOORD1.y) + clamp (pow ((_FalloffScale * rim_6), _FalloffPow), 0.0, 1.0)), 0.0, 1.0));
  tmpvar_5 = tmpvar_45;
  lowp vec3 tmpvar_46;
  lowp vec4 packednormal_47;
  packednormal_47 = normal_8;
  tmpvar_46 = ((packednormal_47.xyz * 2.0) - 1.0);
  mediump vec3 tmpvar_48;
  tmpvar_48 = mix (tmpvar_46, vec3(0.0, 0.0, 1.0), vec3(detailLevel_7));
  tmpvar_4 = tmpvar_48;
  tmpvar_2 = tmpvar_4;
  lowp float shadow_49;
  lowp float tmpvar_50;
  tmpvar_50 = shadow2DEXT (_ShadowMapTexture, xlv_TEXCOORD5.xyz);
  highp float tmpvar_51;
  tmpvar_51 = (_LightShadowData.x + (tmpvar_50 * (1.0 - _LightShadowData.x)));
  shadow_49 = tmpvar_51;
  mediump vec3 lightDir_52;
  lightDir_52 = xlv_TEXCOORD3;
  mediump float atten_53;
  atten_53 = shadow_49;
  mediump vec4 c_54;
  mediump float tmpvar_55;
  tmpvar_55 = clamp (dot (tmpvar_4, lightDir_52), 0.0, 1.0);
  highp vec3 tmpvar_56;
  tmpvar_56 = clamp ((_MinLight + (_LightColor0.xyz * ((tmpvar_55 * atten_53) * 2.0))), 0.0, 1.0);
  lowp vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_3 * tmpvar_56);
  c_54.xyz = tmpvar_57;
  c_54.w = tmpvar_5;
  c_1 = c_54;
  c_1.xyz = (c_1.xyz + (tmpvar_3 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "gles3 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "SHADOWS_NATIVE" }
"!!GLES3#version 300 es


#ifdef VERTEX

#define gl_Vertex _glesVertex
in vec4 _glesVertex;
#define gl_Color _glesColor
in vec4 _glesColor;
#define gl_Normal (normalize(_glesNormal))
in vec3 _glesNormal;
#define gl_MultiTexCoord0 _glesMultiTexCoord0
in vec4 _glesMultiTexCoord0;
#define gl_MultiTexCoord1 _glesMultiTexCoord1
in vec4 _glesMultiTexCoord1;
#define TANGENT vec4(normalize(_glesTANGENT.xyz), _glesTANGENT.w)
in vec4 _glesTANGENT;
mat2 xll_transpose_mf2x2(mat2 m) {
  return mat2( m[0][0], m[1][0], m[0][1], m[1][1]);
}
mat3 xll_transpose_mf3x3(mat3 m) {
  return mat3( m[0][0], m[1][0], m[2][0],
               m[0][1], m[1][1], m[2][1],
               m[0][2], m[1][2], m[2][2]);
}
mat4 xll_transpose_mf4x4(mat4 m) {
  return mat4( m[0][0], m[1][0], m[2][0], m[3][0],
               m[0][1], m[1][1], m[2][1], m[3][1],
               m[0][2], m[1][2], m[2][2], m[3][2],
               m[0][3], m[1][3], m[2][3], m[3][3]);
}
float xll_saturate_f( float x) {
  return clamp( x, 0.0, 1.0);
}
vec2 xll_saturate_vf2( vec2 x) {
  return clamp( x, 0.0, 1.0);
}
vec3 xll_saturate_vf3( vec3 x) {
  return clamp( x, 0.0, 1.0);
}
vec4 xll_saturate_vf4( vec4 x) {
  return clamp( x, 0.0, 1.0);
}
mat2 xll_saturate_mf2x2(mat2 m) {
  return mat2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0));
}
mat3 xll_saturate_mf3x3(mat3 m) {
  return mat3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0));
}
mat4 xll_saturate_mf4x4(mat4 m) {
  return mat4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0));
}
#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 315
struct SurfaceOutput {
    lowp vec3 Albedo;
    lowp vec3 Normal;
    lowp vec3 Emission;
    mediump float Specular;
    lowp float Gloss;
    lowp float Alpha;
};
#line 67
struct appdata_full {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
    highp vec4 texcoord1;
    lowp vec4 color;
};
#line 419
struct Input {
    highp vec2 viewDist;
    highp vec3 viewDir;
    highp vec3 localPos;
};
#line 463
struct v2f_surf {
    highp vec4 pos;
    highp vec3 viewDir;
    highp vec2 cust_viewDist;
    highp vec3 cust_localPos;
    lowp vec3 lightDir;
    lowp vec3 vlight;
    highp vec4 _ShadowCoord;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform lowp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 325
uniform lowp vec4 _LightColor0;
uniform lowp vec4 _SpecColor;
#line 338
#line 346
#line 360
uniform highp vec4 _ShadowOffsets[4];
uniform lowp sampler2DShadow _ShadowMapTexture;
#line 393
uniform sampler2D _MainTex;
uniform sampler2D _DetailTex;
#line 401
uniform sampler2D _BumpMap;
uniform lowp vec4 _Color;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _BumpOffset;
#line 405
uniform highp float _FalloffPow;
uniform highp float _FalloffScale;
uniform highp float _DetailScale;
uniform highp float _DetailDist;
#line 409
uniform highp float _BumpScale;
uniform highp float _MinLight;
#line 426
#line 474
#line 494
#line 82
highp vec3 ObjSpaceLightDir( in highp vec4 v ) {
    highp vec3 objSpaceLightPos = (_World2Object * _WorldSpaceLightPos0).xyz;
    return objSpaceLightPos.xyz;
}
#line 91
highp vec3 ObjSpaceViewDir( in highp vec4 v ) {
    highp vec3 objSpaceCameraPos = ((_World2Object * vec4( _WorldSpaceCameraPos.xyz, 1.0)).xyz * unity_Scale.w);
    return (objSpaceCameraPos - v.xyz);
}
#line 426
void vert( inout appdata_full v, out Input o ) {
    highp vec3 vertexPos = (_Object2World * v.vertex).xyz;
    #line 430
    highp vec3 origin = (_Object2World * vec4( 0.0, 0.0, 0.0, 1.0)).xyz;
    highp float diff = (_DetailDist * distance( vertexPos, _WorldSpaceCameraPos));
    o.viewDist.x = diff;
    o.viewDist.y = xll_saturate_f((distance( origin, _WorldSpaceCameraPos) - (1.0005 * distance( origin, vertexPos))));
    #line 434
    o.localPos = normalize(v.vertex.xyz);
}
#line 474
v2f_surf vert_surf( in appdata_full v ) {
    v2f_surf o;
    Input customInputData;
    #line 478
    vert( v, customInputData);
    o.cust_viewDist = customInputData.viewDist;
    o.cust_localPos = customInputData.localPos;
    o.pos = (glstate_matrix_mvp * v.vertex);
    #line 482
    highp vec3 worldN = (mat3( _Object2World) * (v.normal * unity_Scale.w));
    highp vec3 binormal = (cross( v.normal, v.tangent.xyz) * v.tangent.w);
    highp mat3 rotation = xll_transpose_mf3x3(mat3( v.tangent.xyz, binormal, v.normal));
    highp vec3 lightDir = (rotation * ObjSpaceLightDir( v.vertex));
    #line 486
    o.lightDir = lightDir;
    highp vec3 viewDirForLight = (rotation * ObjSpaceViewDir( v.vertex));
    o.viewDir = viewDirForLight;
    o.vlight = glstate_lightmodel_ambient.xyz;
    #line 490
    o._ShadowCoord = (unity_World2Shadow[0] * (_Object2World * v.vertex));
    return o;
}

out highp vec3 xlv_TEXCOORD0;
out highp vec2 xlv_TEXCOORD1;
out highp vec3 xlv_TEXCOORD2;
out lowp vec3 xlv_TEXCOORD3;
out lowp vec3 xlv_TEXCOORD4;
out highp vec4 xlv_TEXCOORD5;
void main() {
    v2f_surf xl_retval;
    appdata_full xlt_v;
    xlt_v.vertex = vec4(gl_Vertex);
    xlt_v.tangent = vec4(TANGENT);
    xlt_v.normal = vec3(gl_Normal);
    xlt_v.texcoord = vec4(gl_MultiTexCoord0);
    xlt_v.texcoord1 = vec4(gl_MultiTexCoord1);
    xlt_v.color = vec4(gl_Color);
    xl_retval = vert_surf( xlt_v);
    gl_Position = vec4(xl_retval.pos);
    xlv_TEXCOORD0 = vec3(xl_retval.viewDir);
    xlv_TEXCOORD1 = vec2(xl_retval.cust_viewDist);
    xlv_TEXCOORD2 = vec3(xl_retval.cust_localPos);
    xlv_TEXCOORD3 = vec3(xl_retval.lightDir);
    xlv_TEXCOORD4 = vec3(xl_retval.vlight);
    xlv_TEXCOORD5 = vec4(xl_retval._ShadowCoord);
}


#endif
#ifdef FRAGMENT

#define gl_FragData _glesFragData
layout(location = 0) out mediump vec4 _glesFragData[4];
float xll_shadow2D(mediump sampler2DShadow s, vec3 coord) { return texture (s, coord); }
float xll_saturate_f( float x) {
  return clamp( x, 0.0, 1.0);
}
vec2 xll_saturate_vf2( vec2 x) {
  return clamp( x, 0.0, 1.0);
}
vec3 xll_saturate_vf3( vec3 x) {
  return clamp( x, 0.0, 1.0);
}
vec4 xll_saturate_vf4( vec4 x) {
  return clamp( x, 0.0, 1.0);
}
mat2 xll_saturate_mf2x2(mat2 m) {
  return mat2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0));
}
mat3 xll_saturate_mf3x3(mat3 m) {
  return mat3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0));
}
mat4 xll_saturate_mf4x4(mat4 m) {
  return mat4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0));
}
#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 315
struct SurfaceOutput {
    lowp vec3 Albedo;
    lowp vec3 Normal;
    lowp vec3 Emission;
    mediump float Specular;
    lowp float Gloss;
    lowp float Alpha;
};
#line 67
struct appdata_full {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
    highp vec4 texcoord1;
    lowp vec4 color;
};
#line 419
struct Input {
    highp vec2 viewDist;
    highp vec3 viewDir;
    highp vec3 localPos;
};
#line 463
struct v2f_surf {
    highp vec4 pos;
    highp vec3 viewDir;
    highp vec2 cust_viewDist;
    highp vec3 cust_localPos;
    lowp vec3 lightDir;
    lowp vec3 vlight;
    highp vec4 _ShadowCoord;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform lowp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 325
uniform lowp vec4 _LightColor0;
uniform lowp vec4 _SpecColor;
#line 338
#line 346
#line 360
uniform highp vec4 _ShadowOffsets[4];
uniform lowp sampler2DShadow _ShadowMapTexture;
#line 393
uniform sampler2D _MainTex;
uniform sampler2D _DetailTex;
#line 401
uniform sampler2D _BumpMap;
uniform lowp vec4 _Color;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _BumpOffset;
#line 405
uniform highp float _FalloffPow;
uniform highp float _FalloffScale;
uniform highp float _DetailScale;
uniform highp float _DetailDist;
#line 409
uniform highp float _BumpScale;
uniform highp float _MinLight;
#line 426
#line 474
#line 494
#line 411
mediump vec4 LightingSimpleLambert( in SurfaceOutput s, in mediump vec3 lightDir, in mediump float atten ) {
    #line 413
    mediump float NdotL = xll_saturate_f(dot( s.Normal, lightDir));
    mediump vec4 c;
    c.xyz = (s.Albedo * xll_saturate_vf3((_MinLight + (_LightColor0.xyz * ((NdotL * atten) * 2.0)))));
    c.w = s.Alpha;
    #line 417
    return c;
}
#line 272
lowp vec3 UnpackNormal( in lowp vec4 packednormal ) {
    #line 274
    return ((packednormal.xyz * 2.0) - 1.0);
}
#line 436
void surf( in Input IN, inout SurfaceOutput o ) {
    #line 438
    highp vec3 pos = IN.localPos;
    highp vec2 uv;
    uv.x = (0.5 + (0.159155 * atan( pos.z, pos.x)));
    uv.y = (0.31831 * acos((-pos.y)));
    #line 442
    mediump vec4 main = (texture( _MainTex, uv) * _Color);
    mediump vec4 detailX = texture( _DetailTex, ((pos.zy * _DetailScale) + _DetailOffset.xy));
    mediump vec4 detailY = texture( _DetailTex, ((pos.zx * _DetailScale) + _DetailOffset.xy));
    mediump vec4 detailZ = texture( _DetailTex, ((pos.xy * _DetailScale) + _DetailOffset.xy));
    #line 446
    mediump vec4 normalX = texture( _BumpMap, ((pos.zy * _BumpScale) + _BumpOffset.xy));
    mediump vec4 normalY = texture( _BumpMap, ((pos.zx * _BumpScale) + _BumpOffset.xy));
    mediump vec4 normalZ = texture( _BumpMap, ((pos.xy * _BumpScale) + _BumpOffset.xy));
    pos = abs(pos);
    #line 450
    mediump vec4 detail = mix( detailZ, detailX, vec4( pos.x));
    detail = mix( detail, detailY, vec4( pos.y));
    mediump vec4 normal = mix( normalZ, normalX, vec4( pos.x));
    normal = mix( normal, normalY, vec4( pos.y));
    #line 454
    mediump float detailLevel = xll_saturate_f((2.0 * IN.viewDist.x));
    mediump vec3 albedo = (main.xyz * mix( detail.xyz, vec3( 1.0), vec3( detailLevel)));
    o.Normal = vec3( 0.0, 0.0, 1.0);
    o.Albedo = (albedo * _Color.xyz);
    #line 458
    mediump float avg = (main.w * mix( detail.w, 1.0, detailLevel));
    mediump float rim = xll_saturate_f(dot( normalize(IN.viewDir), o.Normal));
    o.Alpha = ((avg * IN.viewDist.y) * xll_saturate_f(((1.0 - IN.viewDist.y) + xll_saturate_f(pow( (_FalloffScale * rim), _FalloffPow)))));
    o.Normal = mix( UnpackNormal( normal), vec3( 0.0, 0.0, 1.0), vec3( detailLevel));
}
#line 393
lowp float unitySampleShadow( in highp vec4 shadowCoord ) {
    lowp float shadow = xll_shadow2D( _ShadowMapTexture, shadowCoord.xyz.xyz);
    shadow = (_LightShadowData.x + (shadow * (1.0 - _LightShadowData.x)));
    #line 397
    return shadow;
}
#line 494
lowp vec4 frag_surf( in v2f_surf IN ) {
    Input surfIN;
    surfIN.viewDist = IN.cust_viewDist;
    #line 498
    surfIN.localPos = IN.cust_localPos;
    surfIN.viewDir = IN.viewDir;
    SurfaceOutput o;
    o.Albedo = vec3( 0.0);
    #line 502
    o.Emission = vec3( 0.0);
    o.Specular = 0.0;
    o.Alpha = 0.0;
    o.Gloss = 0.0;
    #line 506
    surf( surfIN, o);
    lowp float atten = unitySampleShadow( IN._ShadowCoord);
    lowp vec4 c = vec4( 0.0);
    c = LightingSimpleLambert( o, IN.lightDir, atten);
    #line 510
    c.xyz += (o.Albedo * IN.vlight);
    return c;
}
in highp vec3 xlv_TEXCOORD0;
in highp vec2 xlv_TEXCOORD1;
in highp vec3 xlv_TEXCOORD2;
in lowp vec3 xlv_TEXCOORD3;
in lowp vec3 xlv_TEXCOORD4;
in highp vec4 xlv_TEXCOORD5;
void main() {
    lowp vec4 xl_retval;
    v2f_surf xlt_IN;
    xlt_IN.pos = vec4(0.0);
    xlt_IN.viewDir = vec3(xlv_TEXCOORD0);
    xlt_IN.cust_viewDist = vec2(xlv_TEXCOORD1);
    xlt_IN.cust_localPos = vec3(xlv_TEXCOORD2);
    xlt_IN.lightDir = vec3(xlv_TEXCOORD3);
    xlt_IN.vlight = vec3(xlv_TEXCOORD4);
    xlt_IN._ShadowCoord = vec4(xlv_TEXCOORD5);
    xl_retval = frag_surf( xlt_IN);
    gl_FragData[0] = vec4(xl_retval);
}


#endif"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "SHADOWS_NATIVE" "VERTEXLIGHT_ON" }
"!!GLES


#ifdef VERTEX

#extension GL_EXT_shadow_samplers : enable
varying highp vec4 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _DetailDist;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp vec4 unity_Scale;
uniform highp mat4 _World2Object;
uniform highp mat4 _Object2World;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 unity_World2Shadow[4];
uniform lowp vec4 _WorldSpaceLightPos0;
uniform highp vec3 _WorldSpaceCameraPos;
attribute vec4 _glesTANGENT;
attribute vec3 _glesNormal;
attribute vec4 _glesVertex;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = normalize(_glesTANGENT.xyz);
  tmpvar_1.w = _glesTANGENT.w;
  vec3 tmpvar_2;
  tmpvar_2 = normalize(_glesNormal);
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  highp vec2 tmpvar_5;
  highp vec3 tmpvar_6;
  tmpvar_6 = (_Object2World * _glesVertex).xyz;
  highp vec3 tmpvar_7;
  tmpvar_7 = (_Object2World * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
  highp vec3 p_8;
  p_8 = (tmpvar_6 - _WorldSpaceCameraPos);
  tmpvar_5.x = (_DetailDist * sqrt(dot (p_8, p_8)));
  highp vec3 p_9;
  p_9 = (tmpvar_7 - _WorldSpaceCameraPos);
  highp vec3 p_10;
  p_10 = (tmpvar_7 - tmpvar_6);
  tmpvar_5.y = clamp ((sqrt(dot (p_9, p_9)) - (1.0005 * sqrt(dot (p_10, p_10)))), 0.0, 1.0);
  highp vec3 tmpvar_11;
  highp vec3 tmpvar_12;
  tmpvar_11 = tmpvar_1.xyz;
  tmpvar_12 = (((tmpvar_2.yzx * tmpvar_1.zxy) - (tmpvar_2.zxy * tmpvar_1.yzx)) * _glesTANGENT.w);
  highp mat3 tmpvar_13;
  tmpvar_13[0].x = tmpvar_11.x;
  tmpvar_13[0].y = tmpvar_12.x;
  tmpvar_13[0].z = tmpvar_2.x;
  tmpvar_13[1].x = tmpvar_11.y;
  tmpvar_13[1].y = tmpvar_12.y;
  tmpvar_13[1].z = tmpvar_2.y;
  tmpvar_13[2].x = tmpvar_11.z;
  tmpvar_13[2].y = tmpvar_12.z;
  tmpvar_13[2].z = tmpvar_2.z;
  highp vec3 tmpvar_14;
  tmpvar_14 = (tmpvar_13 * (_World2Object * _WorldSpaceLightPos0).xyz);
  tmpvar_3 = tmpvar_14;
  highp vec4 tmpvar_15;
  tmpvar_15.w = 1.0;
  tmpvar_15.xyz = _WorldSpaceCameraPos;
  highp vec3 tmpvar_16;
  tmpvar_16 = glstate_lightmodel_ambient.xyz;
  tmpvar_4 = tmpvar_16;
  gl_Position = (glstate_matrix_mvp * _glesVertex);
  xlv_TEXCOORD0 = (tmpvar_13 * (((_World2Object * tmpvar_15).xyz * unity_Scale.w) - _glesVertex.xyz));
  xlv_TEXCOORD1 = tmpvar_5;
  xlv_TEXCOORD2 = normalize(_glesVertex.xyz);
  xlv_TEXCOORD3 = tmpvar_3;
  xlv_TEXCOORD4 = tmpvar_4;
  xlv_TEXCOORD5 = (unity_World2Shadow[0] * (_Object2World * _glesVertex));
}



#endif
#ifdef FRAGMENT

#extension GL_EXT_shadow_samplers : enable
varying highp vec4 xlv_TEXCOORD5;
varying lowp vec3 xlv_TEXCOORD4;
varying lowp vec3 xlv_TEXCOORD3;
varying highp vec3 xlv_TEXCOORD2;
varying highp vec2 xlv_TEXCOORD1;
varying highp vec3 xlv_TEXCOORD0;
uniform highp float _MinLight;
uniform highp float _BumpScale;
uniform highp float _DetailScale;
uniform highp float _FalloffScale;
uniform highp float _FalloffPow;
uniform lowp vec4 _BumpOffset;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _Color;
uniform sampler2D _BumpMap;
uniform sampler2D _DetailTex;
uniform sampler2D _MainTex;
uniform lowp sampler2DShadow _ShadowMapTexture;
uniform lowp vec4 _LightColor0;
uniform highp vec4 _LightShadowData;
void main ()
{
  lowp vec4 c_1;
  lowp vec3 tmpvar_2;
  lowp vec3 tmpvar_3;
  lowp vec3 tmpvar_4;
  lowp float tmpvar_5;
  tmpvar_3 = vec3(0.0, 0.0, 0.0);
  tmpvar_4 = tmpvar_2;
  tmpvar_5 = 0.0;
  mediump float rim_6;
  mediump float detailLevel_7;
  mediump vec4 normal_8;
  mediump vec4 detail_9;
  mediump vec4 normalZ_10;
  mediump vec4 normalY_11;
  mediump vec4 normalX_12;
  mediump vec4 detailZ_13;
  mediump vec4 detailY_14;
  mediump vec4 detailX_15;
  mediump vec4 main_16;
  highp vec2 uv_17;
  highp float r_18;
  if ((abs(xlv_TEXCOORD2.x) > (1e-08 * abs(xlv_TEXCOORD2.z)))) {
    highp float y_over_x_19;
    y_over_x_19 = (xlv_TEXCOORD2.z / xlv_TEXCOORD2.x);
    highp float s_20;
    highp float x_21;
    x_21 = (y_over_x_19 * inversesqrt(((y_over_x_19 * y_over_x_19) + 1.0)));
    s_20 = (sign(x_21) * (1.5708 - (sqrt((1.0 - abs(x_21))) * (1.5708 + (abs(x_21) * (-0.214602 + (abs(x_21) * (0.0865667 + (abs(x_21) * -0.0310296)))))))));
    r_18 = s_20;
    if ((xlv_TEXCOORD2.x < 0.0)) {
      if ((xlv_TEXCOORD2.z >= 0.0)) {
        r_18 = (s_20 + 3.14159);
      } else {
        r_18 = (r_18 - 3.14159);
      };
    };
  } else {
    r_18 = (sign(xlv_TEXCOORD2.z) * 1.5708);
  };
  uv_17.x = (0.5 + (0.159155 * r_18));
  highp float x_22;
  x_22 = -(xlv_TEXCOORD2.y);
  uv_17.y = (0.31831 * (1.5708 - (sign(x_22) * (1.5708 - (sqrt((1.0 - abs(x_22))) * (1.5708 + (abs(x_22) * (-0.214602 + (abs(x_22) * (0.0865667 + (abs(x_22) * -0.0310296)))))))))));
  lowp vec4 tmpvar_23;
  tmpvar_23 = (texture2D (_MainTex, uv_17) * _Color);
  main_16 = tmpvar_23;
  lowp vec4 tmpvar_24;
  highp vec2 P_25;
  P_25 = ((xlv_TEXCOORD2.zy * _DetailScale) + _DetailOffset.xy);
  tmpvar_24 = texture2D (_DetailTex, P_25);
  detailX_15 = tmpvar_24;
  lowp vec4 tmpvar_26;
  highp vec2 P_27;
  P_27 = ((xlv_TEXCOORD2.zx * _DetailScale) + _DetailOffset.xy);
  tmpvar_26 = texture2D (_DetailTex, P_27);
  detailY_14 = tmpvar_26;
  lowp vec4 tmpvar_28;
  highp vec2 P_29;
  P_29 = ((xlv_TEXCOORD2.xy * _DetailScale) + _DetailOffset.xy);
  tmpvar_28 = texture2D (_DetailTex, P_29);
  detailZ_13 = tmpvar_28;
  lowp vec4 tmpvar_30;
  highp vec2 P_31;
  P_31 = ((xlv_TEXCOORD2.zy * _BumpScale) + _BumpOffset.xy);
  tmpvar_30 = texture2D (_BumpMap, P_31);
  normalX_12 = tmpvar_30;
  lowp vec4 tmpvar_32;
  highp vec2 P_33;
  P_33 = ((xlv_TEXCOORD2.zx * _BumpScale) + _BumpOffset.xy);
  tmpvar_32 = texture2D (_BumpMap, P_33);
  normalY_11 = tmpvar_32;
  lowp vec4 tmpvar_34;
  highp vec2 P_35;
  P_35 = ((xlv_TEXCOORD2.xy * _BumpScale) + _BumpOffset.xy);
  tmpvar_34 = texture2D (_BumpMap, P_35);
  normalZ_10 = tmpvar_34;
  highp vec3 tmpvar_36;
  tmpvar_36 = abs(xlv_TEXCOORD2);
  highp vec4 tmpvar_37;
  tmpvar_37 = mix (detailZ_13, detailX_15, tmpvar_36.xxxx);
  detail_9 = tmpvar_37;
  highp vec4 tmpvar_38;
  tmpvar_38 = mix (detail_9, detailY_14, tmpvar_36.yyyy);
  detail_9 = tmpvar_38;
  highp vec4 tmpvar_39;
  tmpvar_39 = mix (normalZ_10, normalX_12, tmpvar_36.xxxx);
  normal_8 = tmpvar_39;
  highp vec4 tmpvar_40;
  tmpvar_40 = mix (normal_8, normalY_11, tmpvar_36.yyyy);
  normal_8 = tmpvar_40;
  highp float tmpvar_41;
  tmpvar_41 = clamp ((2.0 * xlv_TEXCOORD1.x), 0.0, 1.0);
  detailLevel_7 = tmpvar_41;
  mediump vec3 tmpvar_42;
  tmpvar_42 = ((main_16.xyz * mix (detail_9.xyz, vec3(1.0, 1.0, 1.0), vec3(detailLevel_7))) * _Color.xyz);
  tmpvar_3 = tmpvar_42;
  mediump float tmpvar_43;
  tmpvar_43 = (main_16.w * mix (detail_9.w, 1.0, detailLevel_7));
  highp float tmpvar_44;
  tmpvar_44 = clamp (normalize(xlv_TEXCOORD0).z, 0.0, 1.0);
  rim_6 = tmpvar_44;
  highp float tmpvar_45;
  tmpvar_45 = ((tmpvar_43 * xlv_TEXCOORD1.y) * clamp (((1.0 - xlv_TEXCOORD1.y) + clamp (pow ((_FalloffScale * rim_6), _FalloffPow), 0.0, 1.0)), 0.0, 1.0));
  tmpvar_5 = tmpvar_45;
  lowp vec3 tmpvar_46;
  lowp vec4 packednormal_47;
  packednormal_47 = normal_8;
  tmpvar_46 = ((packednormal_47.xyz * 2.0) - 1.0);
  mediump vec3 tmpvar_48;
  tmpvar_48 = mix (tmpvar_46, vec3(0.0, 0.0, 1.0), vec3(detailLevel_7));
  tmpvar_4 = tmpvar_48;
  tmpvar_2 = tmpvar_4;
  lowp float shadow_49;
  lowp float tmpvar_50;
  tmpvar_50 = shadow2DEXT (_ShadowMapTexture, xlv_TEXCOORD5.xyz);
  highp float tmpvar_51;
  tmpvar_51 = (_LightShadowData.x + (tmpvar_50 * (1.0 - _LightShadowData.x)));
  shadow_49 = tmpvar_51;
  mediump vec3 lightDir_52;
  lightDir_52 = xlv_TEXCOORD3;
  mediump float atten_53;
  atten_53 = shadow_49;
  mediump vec4 c_54;
  mediump float tmpvar_55;
  tmpvar_55 = clamp (dot (tmpvar_4, lightDir_52), 0.0, 1.0);
  highp vec3 tmpvar_56;
  tmpvar_56 = clamp ((_MinLight + (_LightColor0.xyz * ((tmpvar_55 * atten_53) * 2.0))), 0.0, 1.0);
  lowp vec3 tmpvar_57;
  tmpvar_57 = (tmpvar_3 * tmpvar_56);
  c_54.xyz = tmpvar_57;
  c_54.w = tmpvar_5;
  c_1 = c_54;
  c_1.xyz = (c_1.xyz + (tmpvar_3 * xlv_TEXCOORD4));
  gl_FragData[0] = c_1;
}



#endif"
}

SubProgram "gles3 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" "SHADOWS_NATIVE" "VERTEXLIGHT_ON" }
"!!GLES3#version 300 es


#ifdef VERTEX

#define gl_Vertex _glesVertex
in vec4 _glesVertex;
#define gl_Color _glesColor
in vec4 _glesColor;
#define gl_Normal (normalize(_glesNormal))
in vec3 _glesNormal;
#define gl_MultiTexCoord0 _glesMultiTexCoord0
in vec4 _glesMultiTexCoord0;
#define gl_MultiTexCoord1 _glesMultiTexCoord1
in vec4 _glesMultiTexCoord1;
#define TANGENT vec4(normalize(_glesTANGENT.xyz), _glesTANGENT.w)
in vec4 _glesTANGENT;
mat2 xll_transpose_mf2x2(mat2 m) {
  return mat2( m[0][0], m[1][0], m[0][1], m[1][1]);
}
mat3 xll_transpose_mf3x3(mat3 m) {
  return mat3( m[0][0], m[1][0], m[2][0],
               m[0][1], m[1][1], m[2][1],
               m[0][2], m[1][2], m[2][2]);
}
mat4 xll_transpose_mf4x4(mat4 m) {
  return mat4( m[0][0], m[1][0], m[2][0], m[3][0],
               m[0][1], m[1][1], m[2][1], m[3][1],
               m[0][2], m[1][2], m[2][2], m[3][2],
               m[0][3], m[1][3], m[2][3], m[3][3]);
}
float xll_saturate_f( float x) {
  return clamp( x, 0.0, 1.0);
}
vec2 xll_saturate_vf2( vec2 x) {
  return clamp( x, 0.0, 1.0);
}
vec3 xll_saturate_vf3( vec3 x) {
  return clamp( x, 0.0, 1.0);
}
vec4 xll_saturate_vf4( vec4 x) {
  return clamp( x, 0.0, 1.0);
}
mat2 xll_saturate_mf2x2(mat2 m) {
  return mat2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0));
}
mat3 xll_saturate_mf3x3(mat3 m) {
  return mat3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0));
}
mat4 xll_saturate_mf4x4(mat4 m) {
  return mat4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0));
}
#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 315
struct SurfaceOutput {
    lowp vec3 Albedo;
    lowp vec3 Normal;
    lowp vec3 Emission;
    mediump float Specular;
    lowp float Gloss;
    lowp float Alpha;
};
#line 67
struct appdata_full {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
    highp vec4 texcoord1;
    lowp vec4 color;
};
#line 419
struct Input {
    highp vec2 viewDist;
    highp vec3 viewDir;
    highp vec3 localPos;
};
#line 463
struct v2f_surf {
    highp vec4 pos;
    highp vec3 viewDir;
    highp vec2 cust_viewDist;
    highp vec3 cust_localPos;
    lowp vec3 lightDir;
    lowp vec3 vlight;
    highp vec4 _ShadowCoord;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform lowp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 325
uniform lowp vec4 _LightColor0;
uniform lowp vec4 _SpecColor;
#line 338
#line 346
#line 360
uniform highp vec4 _ShadowOffsets[4];
uniform lowp sampler2DShadow _ShadowMapTexture;
#line 393
uniform sampler2D _MainTex;
uniform sampler2D _DetailTex;
#line 401
uniform sampler2D _BumpMap;
uniform lowp vec4 _Color;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _BumpOffset;
#line 405
uniform highp float _FalloffPow;
uniform highp float _FalloffScale;
uniform highp float _DetailScale;
uniform highp float _DetailDist;
#line 409
uniform highp float _BumpScale;
uniform highp float _MinLight;
#line 426
#line 474
#line 494
#line 82
highp vec3 ObjSpaceLightDir( in highp vec4 v ) {
    highp vec3 objSpaceLightPos = (_World2Object * _WorldSpaceLightPos0).xyz;
    return objSpaceLightPos.xyz;
}
#line 91
highp vec3 ObjSpaceViewDir( in highp vec4 v ) {
    highp vec3 objSpaceCameraPos = ((_World2Object * vec4( _WorldSpaceCameraPos.xyz, 1.0)).xyz * unity_Scale.w);
    return (objSpaceCameraPos - v.xyz);
}
#line 426
void vert( inout appdata_full v, out Input o ) {
    highp vec3 vertexPos = (_Object2World * v.vertex).xyz;
    #line 430
    highp vec3 origin = (_Object2World * vec4( 0.0, 0.0, 0.0, 1.0)).xyz;
    highp float diff = (_DetailDist * distance( vertexPos, _WorldSpaceCameraPos));
    o.viewDist.x = diff;
    o.viewDist.y = xll_saturate_f((distance( origin, _WorldSpaceCameraPos) - (1.0005 * distance( origin, vertexPos))));
    #line 434
    o.localPos = normalize(v.vertex.xyz);
}
#line 474
v2f_surf vert_surf( in appdata_full v ) {
    v2f_surf o;
    Input customInputData;
    #line 478
    vert( v, customInputData);
    o.cust_viewDist = customInputData.viewDist;
    o.cust_localPos = customInputData.localPos;
    o.pos = (glstate_matrix_mvp * v.vertex);
    #line 482
    highp vec3 worldN = (mat3( _Object2World) * (v.normal * unity_Scale.w));
    highp vec3 binormal = (cross( v.normal, v.tangent.xyz) * v.tangent.w);
    highp mat3 rotation = xll_transpose_mf3x3(mat3( v.tangent.xyz, binormal, v.normal));
    highp vec3 lightDir = (rotation * ObjSpaceLightDir( v.vertex));
    #line 486
    o.lightDir = lightDir;
    highp vec3 viewDirForLight = (rotation * ObjSpaceViewDir( v.vertex));
    o.viewDir = viewDirForLight;
    o.vlight = glstate_lightmodel_ambient.xyz;
    #line 490
    o._ShadowCoord = (unity_World2Shadow[0] * (_Object2World * v.vertex));
    return o;
}

out highp vec3 xlv_TEXCOORD0;
out highp vec2 xlv_TEXCOORD1;
out highp vec3 xlv_TEXCOORD2;
out lowp vec3 xlv_TEXCOORD3;
out lowp vec3 xlv_TEXCOORD4;
out highp vec4 xlv_TEXCOORD5;
void main() {
    v2f_surf xl_retval;
    appdata_full xlt_v;
    xlt_v.vertex = vec4(gl_Vertex);
    xlt_v.tangent = vec4(TANGENT);
    xlt_v.normal = vec3(gl_Normal);
    xlt_v.texcoord = vec4(gl_MultiTexCoord0);
    xlt_v.texcoord1 = vec4(gl_MultiTexCoord1);
    xlt_v.color = vec4(gl_Color);
    xl_retval = vert_surf( xlt_v);
    gl_Position = vec4(xl_retval.pos);
    xlv_TEXCOORD0 = vec3(xl_retval.viewDir);
    xlv_TEXCOORD1 = vec2(xl_retval.cust_viewDist);
    xlv_TEXCOORD2 = vec3(xl_retval.cust_localPos);
    xlv_TEXCOORD3 = vec3(xl_retval.lightDir);
    xlv_TEXCOORD4 = vec3(xl_retval.vlight);
    xlv_TEXCOORD5 = vec4(xl_retval._ShadowCoord);
}


#endif
#ifdef FRAGMENT

#define gl_FragData _glesFragData
layout(location = 0) out mediump vec4 _glesFragData[4];
float xll_shadow2D(mediump sampler2DShadow s, vec3 coord) { return texture (s, coord); }
float xll_saturate_f( float x) {
  return clamp( x, 0.0, 1.0);
}
vec2 xll_saturate_vf2( vec2 x) {
  return clamp( x, 0.0, 1.0);
}
vec3 xll_saturate_vf3( vec3 x) {
  return clamp( x, 0.0, 1.0);
}
vec4 xll_saturate_vf4( vec4 x) {
  return clamp( x, 0.0, 1.0);
}
mat2 xll_saturate_mf2x2(mat2 m) {
  return mat2( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0));
}
mat3 xll_saturate_mf3x3(mat3 m) {
  return mat3( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0));
}
mat4 xll_saturate_mf4x4(mat4 m) {
  return mat4( clamp(m[0], 0.0, 1.0), clamp(m[1], 0.0, 1.0), clamp(m[2], 0.0, 1.0), clamp(m[3], 0.0, 1.0));
}
#line 151
struct v2f_vertex_lit {
    highp vec2 uv;
    lowp vec4 diff;
    lowp vec4 spec;
};
#line 187
struct v2f_img {
    highp vec4 pos;
    mediump vec2 uv;
};
#line 181
struct appdata_img {
    highp vec4 vertex;
    mediump vec2 texcoord;
};
#line 315
struct SurfaceOutput {
    lowp vec3 Albedo;
    lowp vec3 Normal;
    lowp vec3 Emission;
    mediump float Specular;
    lowp float Gloss;
    lowp float Alpha;
};
#line 67
struct appdata_full {
    highp vec4 vertex;
    highp vec4 tangent;
    highp vec3 normal;
    highp vec4 texcoord;
    highp vec4 texcoord1;
    lowp vec4 color;
};
#line 419
struct Input {
    highp vec2 viewDist;
    highp vec3 viewDir;
    highp vec3 localPos;
};
#line 463
struct v2f_surf {
    highp vec4 pos;
    highp vec3 viewDir;
    highp vec2 cust_viewDist;
    highp vec3 cust_localPos;
    lowp vec3 lightDir;
    lowp vec3 vlight;
    highp vec4 _ShadowCoord;
};
uniform highp vec4 _Time;
uniform highp vec4 _SinTime;
#line 3
uniform highp vec4 _CosTime;
uniform highp vec4 unity_DeltaTime;
uniform highp vec3 _WorldSpaceCameraPos;
uniform highp vec4 _ProjectionParams;
#line 7
uniform highp vec4 _ScreenParams;
uniform highp vec4 _ZBufferParams;
uniform highp vec4 unity_CameraWorldClipPlanes[6];
uniform lowp vec4 _WorldSpaceLightPos0;
#line 11
uniform highp vec4 _LightPositionRange;
uniform highp vec4 unity_4LightPosX0;
uniform highp vec4 unity_4LightPosY0;
uniform highp vec4 unity_4LightPosZ0;
#line 15
uniform highp vec4 unity_4LightAtten0;
uniform highp vec4 unity_LightColor[8];
uniform highp vec4 unity_LightPosition[8];
uniform highp vec4 unity_LightAtten[8];
#line 19
uniform highp vec4 unity_SpotDirection[8];
uniform highp vec4 unity_SHAr;
uniform highp vec4 unity_SHAg;
uniform highp vec4 unity_SHAb;
#line 23
uniform highp vec4 unity_SHBr;
uniform highp vec4 unity_SHBg;
uniform highp vec4 unity_SHBb;
uniform highp vec4 unity_SHC;
#line 27
uniform highp vec3 unity_LightColor0;
uniform highp vec3 unity_LightColor1;
uniform highp vec3 unity_LightColor2;
uniform highp vec3 unity_LightColor3;
uniform highp vec4 unity_ShadowSplitSpheres[4];
uniform highp vec4 unity_ShadowSplitSqRadii;
uniform highp vec4 unity_LightShadowBias;
#line 31
uniform highp vec4 _LightSplitsNear;
uniform highp vec4 _LightSplitsFar;
uniform highp mat4 unity_World2Shadow[4];
uniform highp vec4 _LightShadowData;
#line 35
uniform highp vec4 unity_ShadowFadeCenterAndType;
uniform highp mat4 glstate_matrix_mvp;
uniform highp mat4 glstate_matrix_modelview0;
uniform highp mat4 glstate_matrix_invtrans_modelview0;
#line 39
uniform highp mat4 _Object2World;
uniform highp mat4 _World2Object;
uniform highp vec4 unity_Scale;
uniform highp mat4 glstate_matrix_transpose_modelview0;
#line 43
uniform highp mat4 glstate_matrix_texture0;
uniform highp mat4 glstate_matrix_texture1;
uniform highp mat4 glstate_matrix_texture2;
uniform highp mat4 glstate_matrix_texture3;
#line 47
uniform highp mat4 glstate_matrix_projection;
uniform highp vec4 glstate_lightmodel_ambient;
uniform highp mat4 unity_MatrixV;
uniform highp mat4 unity_MatrixVP;
#line 51
uniform lowp vec4 unity_ColorSpaceGrey;
#line 77
#line 82
#line 87
#line 91
#line 96
#line 120
#line 137
#line 158
#line 166
#line 193
#line 206
#line 215
#line 220
#line 229
#line 234
#line 243
#line 260
#line 265
#line 291
#line 299
#line 307
#line 311
#line 325
uniform lowp vec4 _LightColor0;
uniform lowp vec4 _SpecColor;
#line 338
#line 346
#line 360
uniform highp vec4 _ShadowOffsets[4];
uniform lowp sampler2DShadow _ShadowMapTexture;
#line 393
uniform sampler2D _MainTex;
uniform sampler2D _DetailTex;
#line 401
uniform sampler2D _BumpMap;
uniform lowp vec4 _Color;
uniform lowp vec4 _DetailOffset;
uniform lowp vec4 _BumpOffset;
#line 405
uniform highp float _FalloffPow;
uniform highp float _FalloffScale;
uniform highp float _DetailScale;
uniform highp float _DetailDist;
#line 409
uniform highp float _BumpScale;
uniform highp float _MinLight;
#line 426
#line 474
#line 494
#line 411
mediump vec4 LightingSimpleLambert( in SurfaceOutput s, in mediump vec3 lightDir, in mediump float atten ) {
    #line 413
    mediump float NdotL = xll_saturate_f(dot( s.Normal, lightDir));
    mediump vec4 c;
    c.xyz = (s.Albedo * xll_saturate_vf3((_MinLight + (_LightColor0.xyz * ((NdotL * atten) * 2.0)))));
    c.w = s.Alpha;
    #line 417
    return c;
}
#line 272
lowp vec3 UnpackNormal( in lowp vec4 packednormal ) {
    #line 274
    return ((packednormal.xyz * 2.0) - 1.0);
}
#line 436
void surf( in Input IN, inout SurfaceOutput o ) {
    #line 438
    highp vec3 pos = IN.localPos;
    highp vec2 uv;
    uv.x = (0.5 + (0.159155 * atan( pos.z, pos.x)));
    uv.y = (0.31831 * acos((-pos.y)));
    #line 442
    mediump vec4 main = (texture( _MainTex, uv) * _Color);
    mediump vec4 detailX = texture( _DetailTex, ((pos.zy * _DetailScale) + _DetailOffset.xy));
    mediump vec4 detailY = texture( _DetailTex, ((pos.zx * _DetailScale) + _DetailOffset.xy));
    mediump vec4 detailZ = texture( _DetailTex, ((pos.xy * _DetailScale) + _DetailOffset.xy));
    #line 446
    mediump vec4 normalX = texture( _BumpMap, ((pos.zy * _BumpScale) + _BumpOffset.xy));
    mediump vec4 normalY = texture( _BumpMap, ((pos.zx * _BumpScale) + _BumpOffset.xy));
    mediump vec4 normalZ = texture( _BumpMap, ((pos.xy * _BumpScale) + _BumpOffset.xy));
    pos = abs(pos);
    #line 450
    mediump vec4 detail = mix( detailZ, detailX, vec4( pos.x));
    detail = mix( detail, detailY, vec4( pos.y));
    mediump vec4 normal = mix( normalZ, normalX, vec4( pos.x));
    normal = mix( normal, normalY, vec4( pos.y));
    #line 454
    mediump float detailLevel = xll_saturate_f((2.0 * IN.viewDist.x));
    mediump vec3 albedo = (main.xyz * mix( detail.xyz, vec3( 1.0), vec3( detailLevel)));
    o.Normal = vec3( 0.0, 0.0, 1.0);
    o.Albedo = (albedo * _Color.xyz);
    #line 458
    mediump float avg = (main.w * mix( detail.w, 1.0, detailLevel));
    mediump float rim = xll_saturate_f(dot( normalize(IN.viewDir), o.Normal));
    o.Alpha = ((avg * IN.viewDist.y) * xll_saturate_f(((1.0 - IN.viewDist.y) + xll_saturate_f(pow( (_FalloffScale * rim), _FalloffPow)))));
    o.Normal = mix( UnpackNormal( normal), vec3( 0.0, 0.0, 1.0), vec3( detailLevel));
}
#line 393
lowp float unitySampleShadow( in highp vec4 shadowCoord ) {
    lowp float shadow = xll_shadow2D( _ShadowMapTexture, shadowCoord.xyz.xyz);
    shadow = (_LightShadowData.x + (shadow * (1.0 - _LightShadowData.x)));
    #line 397
    return shadow;
}
#line 494
lowp vec4 frag_surf( in v2f_surf IN ) {
    Input surfIN;
    surfIN.viewDist = IN.cust_viewDist;
    #line 498
    surfIN.localPos = IN.cust_localPos;
    surfIN.viewDir = IN.viewDir;
    SurfaceOutput o;
    o.Albedo = vec3( 0.0);
    #line 502
    o.Emission = vec3( 0.0);
    o.Specular = 0.0;
    o.Alpha = 0.0;
    o.Gloss = 0.0;
    #line 506
    surf( surfIN, o);
    lowp float atten = unitySampleShadow( IN._ShadowCoord);
    lowp vec4 c = vec4( 0.0);
    c = LightingSimpleLambert( o, IN.lightDir, atten);
    #line 510
    c.xyz += (o.Albedo * IN.vlight);
    return c;
}
in highp vec3 xlv_TEXCOORD0;
in highp vec2 xlv_TEXCOORD1;
in highp vec3 xlv_TEXCOORD2;
in lowp vec3 xlv_TEXCOORD3;
in lowp vec3 xlv_TEXCOORD4;
in highp vec4 xlv_TEXCOORD5;
void main() {
    lowp vec4 xl_retval;
    v2f_surf xlt_IN;
    xlt_IN.pos = vec4(0.0);
    xlt_IN.viewDir = vec3(xlv_TEXCOORD0);
    xlt_IN.cust_viewDist = vec2(xlv_TEXCOORD1);
    xlt_IN.cust_localPos = vec3(xlv_TEXCOORD2);
    xlt_IN.lightDir = vec3(xlv_TEXCOORD3);
    xlt_IN.vlight = vec3(xlv_TEXCOORD4);
    xlt_IN._ShadowCoord = vec4(xlv_TEXCOORD5);
    xl_retval = frag_surf( xlt_IN);
    gl_FragData[0] = vec4(xl_retval);
}


#endif"
}

}
Program "fp" {
// Fragment combos: 2
//   opengl - ALU: 92 to 94, TEX: 7 to 8
//   d3d9 - ALU: 88 to 89, TEX: 7 to 8
//   d3d11 - ALU: 76 to 77, TEX: 7 to 8, FLOW: 1 to 1
SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Vector 0 [_LightColor0]
Vector 1 [_Color]
Vector 2 [_DetailOffset]
Vector 3 [_BumpOffset]
Float 4 [_FalloffPow]
Float 5 [_FalloffScale]
Float 6 [_DetailScale]
Float 7 [_BumpScale]
Float 8 [_MinLight]
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_DetailTex] 2D
SetTexture 2 [_BumpMap] 2D
"3.0-!!ARBfp1.0
# 92 ALU, 7 TEX
PARAM c[14] = { program.local[0..8],
		{ 0, 3.141593, -0.018729299, 0.074261002 },
		{ 0.21211439, 1.570729, 1, 2 },
		{ 0.31830987, -0.01348047, 0.05747731, 0.1212391 },
		{ 0.1956359, 0.33299461, 0.99999559, 1.570796 },
		{ 0.15915494, 0.5, 0, 1 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
MUL R3.xy, fragment.texcoord[2].zyzw, c[7].x;
ADD R4.xy, R3, c[3];
MUL R2.xy, fragment.texcoord[2].zxzw, c[6].x;
ADD R2.zw, R2.xyxy, c[2].xyxy;
MUL R0.zw, fragment.texcoord[2].xyzy, c[6].x;
ADD R0.zw, R0, c[2].xyxy;
MUL R0.xy, fragment.texcoord[2], c[6].x;
MUL R3.zw, fragment.texcoord[2].xyxy, c[7].x;
ADD R3.zw, R3, c[3].xyxy;
ABS R2.xy, fragment.texcoord[2];
TEX R3.yw, R3.zwzw, texture[2], 2D;
TEX R4.yw, R4, texture[2], 2D;
ADD R4.xy, R4.ywzw, -R3.ywzw;
TEX R1, R0.zwzw, texture[1], 2D;
ADD R0.xy, R0, c[2];
TEX R0, R0, texture[1], 2D;
ADD R1, R1, -R0;
MAD R0, R2.x, R1, R0;
TEX R1, R2.zwzw, texture[1], 2D;
ADD R1, R1, -R0;
MAD R0, R2.y, R1, R0;
MUL R2.zw, fragment.texcoord[2].xyzx, c[7].x;
ADD R4.zw, R2, c[3].xyxy;
MAD R2.zw, R2.x, R4.xyxy, R3.xyyw;
TEX R3.yw, R4.zwzw, texture[2], 2D;
ADD R3.xy, R3.ywzw, -R2.zwzw;
ADD R1.xyz, -R0, c[10].z;
MUL_SAT R1.w, fragment.texcoord[1].x, c[10];
MAD R0.xyz, R1.w, R1, R0;
MAD R1.xy, R2.y, R3, R2.zwzw;
ABS R2.y, fragment.texcoord[2].z;
MAD R1.xy, R1.yxzw, c[10].w, -c[10].z;
MAX R1.z, R2.y, R2.x;
MIN R2.z, R2.y, R2.x;
RCP R1.z, R1.z;
MUL R2.z, R2, R1;
MUL R3.xy, R1, R1;
ADD_SAT R1.z, R3.x, R3.y;
MUL R2.w, R2.z, R2.z;
MAD R3.x, R2.w, c[11].y, c[11].z;
MAD R3.x, R3, R2.w, -c[11].w;
MAD R3.w, R3.x, R2, c[12].x;
ADD R1.z, -R1, c[10];
RSQ R1.z, R1.z;
RCP R1.z, R1.z;
ADD R3.xyz, -R1, c[13].zzww;
MAD R1.xyz, R1.w, R3, R1;
MAD R3.w, R3, R2, -c[12].y;
MAD R2.w, R3, R2, c[12].z;
MUL R2.w, R2, R2.z;
DP3_SAT R1.x, R1, fragment.texcoord[3];
MUL R1.xyz, R1.x, c[0];
MUL R1.xyz, R1, c[10].w;
ABS R3.x, -fragment.texcoord[2].y;
ADD R2.z, -R2.w, c[12].w;
ADD R2.x, R2.y, -R2;
CMP R2.x, -R2, R2.z, R2.w;
ADD R2.y, -R2.x, c[9];
ADD R2.z, -R3.x, c[10];
MAD R2.w, R3.x, c[9].z, c[9];
MAD R2.w, R2, R3.x, -c[10].x;
MAD R2.w, R2, R3.x, c[10].y;
CMP R2.x, fragment.texcoord[2], R2.y, R2;
RSQ R2.z, R2.z;
RCP R2.z, R2.z;
CMP R2.x, fragment.texcoord[2].z, -R2, R2;
MUL R2.w, R2, R2.z;
SLT R3.x, -fragment.texcoord[2].y, c[9];
MUL R2.z, R3.x, R2.w;
MAD R2.y, -R2.z, c[10].w, R2.w;
MAD R2.y, R3.x, c[9], R2;
MAD R2.x, R2, c[13], c[13].y;
MUL R2.y, R2, c[11].x;
TEX R2, R2, texture[0], 2D;
MUL R2, R2, c[1];
MUL R0.xyz, R2, R0;
MUL R0.xyz, R0, c[1];
ADD_SAT R1.xyz, R1, c[8].x;
MUL R1.xyz, R0, R1;
MAD result.color.xyz, R0, fragment.texcoord[4], R1;
DP3 R2.x, fragment.texcoord[0], fragment.texcoord[0];
RSQ R0.x, R2.x;
ADD R0.y, -R0.w, c[10].z;
MAD R0.y, R1.w, R0, R0.w;
MUL R0.z, R2.w, R0.y;
MUL_SAT R0.x, R0, fragment.texcoord[0].z;
MUL R0.x, R0, c[5];
ADD R0.y, -fragment.texcoord[1], c[10].z;
POW_SAT R0.x, R0.x, c[4].x;
ADD_SAT R0.x, R0.y, R0;
MUL R0.y, fragment.texcoord[1], R0.z;
MUL result.color.w, R0.y, R0.x;
END
# 92 instructions, 5 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
Vector 0 [_LightColor0]
Vector 1 [_Color]
Vector 2 [_DetailOffset]
Vector 3 [_BumpOffset]
Float 4 [_FalloffPow]
Float 5 [_FalloffScale]
Float 6 [_DetailScale]
Float 7 [_BumpScale]
Float 8 [_MinLight]
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_DetailTex] 2D
SetTexture 2 [_BumpMap] 2D
"ps_3_0
; 88 ALU, 7 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
def c9, 0.00000000, 1.00000000, -0.01872930, 0.07426100
def c10, -0.21211439, 1.57072902, 2.00000000, 3.14159298
def c11, 0.31830987, -0.01348047, 0.05747731, -0.12123910
def c12, 0.19563590, -0.33299461, 0.99999559, 1.57079601
def c13, 0.15915494, 0.50000000, 2.00000000, -1.00000000
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xy
dcl_texcoord2 v2.xyz
dcl_texcoord3 v3.xyz
dcl_texcoord4 v4.xyz
mul r0.xy, v2.zyzw, c6.x
add r1.xy, r0, c2
mul r0.zw, v2.xyxy, c6.x
add r0.xy, r0.zwzw, c2
mul r2.xy, v2.zxzw, c6.x
mul r3.xy, v2, c7.x
add r3.xy, r3, c3
abs r2.zw, v2.xyxy
add r2.xy, r2, c2
texld r3.yw, r3, s2
texld r0, r0, s1
texld r1, r1, s1
add_pp r1, r1, -r0
mad_pp r0, r2.z, r1, r0
texld r1, r2, s1
add_pp r1, r1, -r0
mad_pp r0, r2.w, r1, r0
abs r2.y, v2.z
add_pp r1.xyz, -r0, c9.y
mul_sat r2.x, v1, c10.z
mad_pp r0.xyz, r2.x, r1, r0
mul r1.zw, v2.xyzy, c7.x
add r4.xy, r1.zwzw, c3
mul r1.xy, v2.zxzw, c7.x
texld r4.yw, r4, s2
add_pp r1.zw, r4.xyyw, -r3.xyyw
mad_pp r1.zw, r2.z, r1, r3.xyyw
add r1.xy, r1, c3
texld r3.yw, r1, s2
add_pp r1.xy, r3.ywzw, -r1.zwzw
mad_pp r1.xy, r2.w, r1, r1.zwzw
max r3.x, r2.y, r2.z
mad_pp r1.xy, r1.yxzw, c13.z, c13.w
rcp r1.w, r3.x
min r1.z, r2.y, r2
mul r2.w, r1.z, r1
mul r3.x, r2.w, r2.w
mul_pp r1.zw, r1.xyxy, r1.xyxy
add_pp_sat r1.w, r1.z, r1
mad r3.y, r3.x, c11, c11.z
mad r1.z, r3.y, r3.x, c11.w
add_pp r1.w, -r1, c9.y
mad r1.z, r1, r3.x, c12.x
rsq_pp r3.y, r1.w
mad r1.w, r1.z, r3.x, c12.y
mad r1.w, r1, r3.x, c12.z
rcp_pp r1.z, r3.y
add_pp r3.xyz, -r1, c9.xxyw
mad_pp r3.xyz, r2.x, r3, r1
mul r1.w, r1, r2
abs r1.z, -v2.y
add r1.x, r2.y, -r2.z
add r1.y, -r1.w, c12.w
cmp r1.x, -r1, r1.w, r1.y
add r1.y, -r1.x, c10.w
add r2.y, -r1.z, c9
mad r1.w, r1.z, c9.z, c9
mad r1.w, r1, r1.z, c10.x
rsq r2.y, r2.y
mad r1.z, r1.w, r1, c10.y
rcp r2.y, r2.y
mul r1.w, r1.z, r2.y
cmp r1.z, -v2.y, c9.x, c9.y
mul r2.y, r1.z, r1.w
cmp r1.y, v2.x, r1.x, r1
mad r1.x, -r2.y, c10.z, r1.w
cmp r1.w, v2.z, r1.y, -r1.y
mad r1.y, r1.z, c10.w, r1.x
dp3_pp_sat r2.y, r3, v3
mad r1.x, r1.w, c13, c13.y
mul r1.y, r1, c11.x
texld r1, r1, s0
mul r1, r1, c1
mul_pp r0.xyz, r1, r0
mul_pp r1.xyz, r2.y, c0
mul_pp r1.xyz, r1, c10.z
dp3 r2.y, v0, v0
rsq r2.y, r2.y
mul_pp r0.xyz, r0, c1
add_sat r1.xyz, r1, c8.x
mul r1.xyz, r0, r1
mad_pp oC0.xyz, r0, v4, r1
mul_sat r2.y, r2, v0.z
mul r0.y, r2, c5.x
pow_sat r3, r0.y, c4.x
add_pp r0.x, -r0.w, c9.y
mad_pp r0.x, r2, r0, r0.w
mul_pp r0.x, r1.w, r0
mov r0.z, r3.x
add r0.y, -v1, c9
add_sat r0.y, r0, r0.z
mul r0.x, v1.y, r0
mul oC0.w, r0.x, r0.y
"
}

SubProgram "d3d11 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
ConstBuffer "$Globals" 128 // 120 used size, 12 vars
Vector 16 [_LightColor0] 4
Vector 48 [_Color] 4
Vector 64 [_DetailOffset] 4
Vector 80 [_BumpOffset] 4
Float 96 [_FalloffPow]
Float 100 [_FalloffScale]
Float 104 [_DetailScale]
Float 112 [_BumpScale]
Float 116 [_MinLight]
BindCB "$Globals" 0
SetTexture 0 [_MainTex] 2D 0
SetTexture 1 [_DetailTex] 2D 1
SetTexture 2 [_BumpMap] 2D 2
// 85 instructions, 6 temp regs, 0 temp arrays:
// ALU 72 float, 0 int, 4 uint
// TEX 7 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0
eefiecedehhdonoebglbchnnlfgfagiopojabblpabaaaaaanaamaaaaadaaaaaa
cmaaaaaaoeaaaaaabiabaaaaejfdeheolaaaaaaaagaaaaaaaiaaaaaajiaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaakeaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaahahaaaakeaaaaaaabaaaaaaaaaaaaaaadaaaaaaacaaaaaa
adadaaaakeaaaaaaacaaaaaaaaaaaaaaadaaaaaaadaaaaaaahahaaaakeaaaaaa
adaaaaaaaaaaaaaaadaaaaaaaeaaaaaaahahaaaakeaaaaaaaeaaaaaaaaaaaaaa
adaaaaaaafaaaaaaahahaaaafdfgfpfaepfdejfeejepeoaafeeffiedepepfcee
aaklklklepfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaaaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklklfdeieefclaalaaaa
eaaaaaaaomacaaaafjaaaaaeegiocaaaaaaaaaaaaiaaaaaafkaaaaadaagabaaa
aaaaaaaafkaaaaadaagabaaaabaaaaaafkaaaaadaagabaaaacaaaaaafibiaaae
aahabaaaaaaaaaaaffffaaaafibiaaaeaahabaaaabaaaaaaffffaaaafibiaaae
aahabaaaacaaaaaaffffaaaagcbaaaadhcbabaaaabaaaaaagcbaaaaddcbabaaa
acaaaaaagcbaaaadhcbabaaaadaaaaaagcbaaaadhcbabaaaaeaaaaaagcbaaaad
hcbabaaaafaaaaaagfaaaaadpccabaaaaaaaaaaagiaaaaacagaaaaaadeaaaaaj
bcaabaaaaaaaaaaaakbabaiaibaaaaaaadaaaaaackbabaiaibaaaaaaadaaaaaa
aoaaaaakbcaabaaaaaaaaaaaaceaaaaaaaaaiadpaaaaiadpaaaaiadpaaaaiadp
akaabaaaaaaaaaaaddaaaaajccaabaaaaaaaaaaaakbabaiaibaaaaaaadaaaaaa
ckbabaiaibaaaaaaadaaaaaadiaaaaahbcaabaaaaaaaaaaaakaabaaaaaaaaaaa
bkaabaaaaaaaaaaadiaaaaahccaabaaaaaaaaaaaakaabaaaaaaaaaaaakaabaaa
aaaaaaaadcaaaaajecaabaaaaaaaaaaabkaabaaaaaaaaaaaabeaaaaafpkokkdm
abeaaaaadgfkkolndcaaaaajecaabaaaaaaaaaaabkaabaaaaaaaaaaackaabaaa
aaaaaaaaabeaaaaaochgdidodcaaaaajecaabaaaaaaaaaaabkaabaaaaaaaaaaa
ckaabaaaaaaaaaaaabeaaaaaaebnkjlodcaaaaajccaabaaaaaaaaaaabkaabaaa
aaaaaaaackaabaaaaaaaaaaaabeaaaaadiphhpdpdiaaaaahecaabaaaaaaaaaaa
bkaabaaaaaaaaaaaakaabaaaaaaaaaaadcaaaaajecaabaaaaaaaaaaackaabaaa
aaaaaaaaabeaaaaaaaaaaamaabeaaaaanlapmjdpdbaaaaajicaabaaaaaaaaaaa
akbabaiaibaaaaaaadaaaaaackbabaiaibaaaaaaadaaaaaaabaaaaahecaabaaa
aaaaaaaadkaabaaaaaaaaaaackaabaaaaaaaaaaadcaaaaajbcaabaaaaaaaaaaa
akaabaaaaaaaaaaabkaabaaaaaaaaaaackaabaaaaaaaaaaadbaaaaaiccaabaaa
aaaaaaaaakbabaaaadaaaaaaakbabaiaebaaaaaaadaaaaaaabaaaaahccaabaaa
aaaaaaaabkaabaaaaaaaaaaaabeaaaaanlapejmaaaaaaaahbcaabaaaaaaaaaaa
bkaabaaaaaaaaaaaakaabaaaaaaaaaaaddaaaaahccaabaaaaaaaaaaaakbabaaa
adaaaaaackbabaaaadaaaaaadbaaaaaiccaabaaaaaaaaaaabkaabaaaaaaaaaaa
bkaabaiaebaaaaaaaaaaaaaadeaaaaahecaabaaaaaaaaaaaakbabaaaadaaaaaa
ckbabaaaadaaaaaabnaaaaaiecaabaaaaaaaaaaackaabaaaaaaaaaaackaabaia
ebaaaaaaaaaaaaaaabaaaaahccaabaaaaaaaaaaackaabaaaaaaaaaaabkaabaaa
aaaaaaaadhaaaaakbcaabaaaaaaaaaaabkaabaaaaaaaaaaaakaabaiaebaaaaaa
aaaaaaaaakaabaaaaaaaaaaadcaaaaajbcaabaaaaaaaaaaaakaabaaaaaaaaaaa
abeaaaaaidpjccdoabeaaaaaaaaaaadpdcaaaaakecaabaaaaaaaaaaabkbabaia
ibaaaaaaadaaaaaaabeaaaaadagojjlmabeaaaaachbgjidndcaaaaakecaabaaa
aaaaaaaackaabaaaaaaaaaaabkbabaiaibaaaaaaadaaaaaaabeaaaaaiedefjlo
dcaaaaakecaabaaaaaaaaaaackaabaaaaaaaaaaabkbabaiaibaaaaaaadaaaaaa
abeaaaaakeanmjdpaaaaaaaiicaabaaaaaaaaaaabkbabaiambaaaaaaadaaaaaa
abeaaaaaaaaaiadpelaaaaaficaabaaaaaaaaaaadkaabaaaaaaaaaaadiaaaaah
bcaabaaaabaaaaaadkaabaaaaaaaaaaackaabaaaaaaaaaaadcaaaaajbcaabaaa
abaaaaaaakaabaaaabaaaaaaabeaaaaaaaaaaamaabeaaaaanlapejeadbaaaaai
ccaabaaaabaaaaaabkbabaiaebaaaaaaadaaaaaabkbabaaaadaaaaaaabaaaaah
bcaabaaaabaaaaaabkaabaaaabaaaaaaakaabaaaabaaaaaadcaaaaajecaabaaa
aaaaaaaackaabaaaaaaaaaaadkaabaaaaaaaaaaaakaabaaaabaaaaaadiaaaaah
ccaabaaaaaaaaaaackaabaaaaaaaaaaaabeaaaaaidpjkcdoefaaaaajpcaabaaa
aaaaaaaaegaabaaaaaaaaaaaeghobaaaaaaaaaaaaagabaaaaaaaaaaadiaaaaai
pcaabaaaaaaaaaaaegaobaaaaaaaaaaaegiocaaaaaaaaaaaadaaaaaadcaaaaal
pcaabaaaabaaaaaaggbcbaaaadaaaaaakgikcaaaaaaaaaaaagaaaaaaegiecaaa
aaaaaaaaaeaaaaaaefaaaaajpcaabaaaacaaaaaaegaabaaaabaaaaaaeghobaaa
abaaaaaaaagabaaaabaaaaaaefaaaaajpcaabaaaabaaaaaaogakbaaaabaaaaaa
eghobaaaabaaaaaaaagabaaaabaaaaaadcaaaaaldcaabaaaadaaaaaaegbabaaa
adaaaaaakgikcaaaaaaaaaaaagaaaaaaegiacaaaaaaaaaaaaeaaaaaaefaaaaaj
pcaabaaaadaaaaaaegaabaaaadaaaaaaeghobaaaabaaaaaaaagabaaaabaaaaaa
aaaaaaaipcaabaaaacaaaaaaegaobaaaacaaaaaaegaobaiaebaaaaaaadaaaaaa
dcaaaaakpcaabaaaacaaaaaaagbabaiaibaaaaaaadaaaaaaegaobaaaacaaaaaa
egaobaaaadaaaaaaaaaaaaaipcaabaaaabaaaaaaegaobaaaabaaaaaaegaobaia
ebaaaaaaacaaaaaadcaaaaakpcaabaaaabaaaaaafgbfbaiaibaaaaaaadaaaaaa
egaobaaaabaaaaaaegaobaaaacaaaaaaaaaaaaalpcaabaaaacaaaaaaegaobaia
ebaaaaaaabaaaaaaaceaaaaaaaaaiadpaaaaiadpaaaaiadpaaaaiadpaacaaaah
bcaabaaaadaaaaaaakbabaaaacaaaaaaakbabaaaacaaaaaadcaaaaajpcaabaaa
abaaaaaaagaabaaaadaaaaaaegaobaaaacaaaaaaegaobaaaabaaaaaadiaaaaah
pcaabaaaaaaaaaaaegaobaaaaaaaaaaaegaobaaaabaaaaaadiaaaaaihcaabaaa
aaaaaaaaegacbaaaaaaaaaaaegiccaaaaaaaaaaaadaaaaaadiaaaaahicaabaaa
aaaaaaaadkaabaaaaaaaaaaabkbabaaaacaaaaaadiaaaaahhcaabaaaabaaaaaa
egacbaaaaaaaaaaaegbcbaaaafaaaaaadcaaaaalpcaabaaaacaaaaaaggbcbaaa
adaaaaaaagiacaaaaaaaaaaaahaaaaaaegiecaaaaaaaaaaaafaaaaaaefaaaaaj
pcaabaaaaeaaaaaaegaabaaaacaaaaaaeghobaaaacaaaaaaaagabaaaacaaaaaa
efaaaaajpcaabaaaacaaaaaaogakbaaaacaaaaaaeghobaaaacaaaaaaaagabaaa
acaaaaaadcaaaaalfcaabaaaacaaaaaaagbbbaaaadaaaaaaagiacaaaaaaaaaaa
ahaaaaaaagibcaaaaaaaaaaaafaaaaaaefaaaaajpcaabaaaafaaaaaaigaabaaa
acaaaaaaeghobaaaacaaaaaaaagabaaaacaaaaaaaaaaaaaifcaabaaaacaaaaaa
pganbaaaaeaaaaaapganbaiaebaaaaaaafaaaaaadcaaaaakfcaabaaaacaaaaaa
agbabaiaibaaaaaaadaaaaaaagacbaaaacaaaaaapganbaaaafaaaaaaaaaaaaai
kcaabaaaacaaaaaaagaibaiaebaaaaaaacaaaaaapgahbaaaacaaaaaadcaaaaak
dcaabaaaacaaaaaafgbfbaiaibaaaaaaadaaaaaangafbaaaacaaaaaaigaabaaa
acaaaaaadcaaaaapdcaabaaaacaaaaaaegaabaaaacaaaaaaaceaaaaaaaaaaaea
aaaaaaeaaaaaaaaaaaaaaaaaaceaaaaaaaaaialpaaaaialpaaaaaaaaaaaaaaaa
apaaaaahicaabaaaabaaaaaaegaabaaaacaaaaaaegaabaaaacaaaaaaddaaaaah
icaabaaaabaaaaaadkaabaaaabaaaaaaabeaaaaaaaaaiadpaaaaaaaiicaabaaa
abaaaaaadkaabaiaebaaaaaaabaaaaaaabeaaaaaaaaaiadpelaaaaafecaabaaa
acaaaaaadkaabaaaabaaaaaaaaaaaaalocaabaaaadaaaaaaagajbaiaebaaaaaa
acaaaaaaaceaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaiadpdcaaaaajhcaabaaa
acaaaaaaagaabaaaadaaaaaajgahbaaaadaaaaaaegacbaaaacaaaaaabacaaaah
icaabaaaabaaaaaaegacbaaaacaaaaaaegbcbaaaaeaaaaaaaaaaaaahicaabaaa
abaaaaaadkaabaaaabaaaaaadkaabaaaabaaaaaadccaaaalhcaabaaaacaaaaaa
egiccaaaaaaaaaaaabaaaaaapgapbaaaabaaaaaafgifcaaaaaaaaaaaahaaaaaa
dcaaaaajhccabaaaaaaaaaaaegacbaaaaaaaaaaaegacbaaaacaaaaaaegacbaaa
abaaaaaabaaaaaahbcaabaaaaaaaaaaaegbcbaaaabaaaaaaegbcbaaaabaaaaaa
eeaaaaafbcaabaaaaaaaaaaaakaabaaaaaaaaaaadicaaaahbcaabaaaaaaaaaaa
akaabaaaaaaaaaaackbabaaaabaaaaaadiaaaaaibcaabaaaaaaaaaaaakaabaaa
aaaaaaaabkiacaaaaaaaaaaaagaaaaaacpaaaaafbcaabaaaaaaaaaaaakaabaaa
aaaaaaaadiaaaaaibcaabaaaaaaaaaaaakaabaaaaaaaaaaaakiacaaaaaaaaaaa
agaaaaaabjaaaaafbcaabaaaaaaaaaaaakaabaaaaaaaaaaaddaaaaahbcaabaaa
aaaaaaaaakaabaaaaaaaaaaaabeaaaaaaaaaiadpaaaaaaaiccaabaaaaaaaaaaa
bkbabaiaebaaaaaaacaaaaaaabeaaaaaaaaaiadpaacaaaahbcaabaaaaaaaaaaa
akaabaaaaaaaaaaabkaabaaaaaaaaaaadiaaaaahiccabaaaaaaaaaaaakaabaaa
aaaaaaaadkaabaaaaaaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES"
}

SubProgram "gles3 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_OFF" }
"!!GLES3"
}

SubProgram "opengl " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Vector 0 [_LightColor0]
Vector 1 [_Color]
Vector 2 [_DetailOffset]
Vector 3 [_BumpOffset]
Float 4 [_FalloffPow]
Float 5 [_FalloffScale]
Float 6 [_DetailScale]
Float 7 [_BumpScale]
Float 8 [_MinLight]
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_DetailTex] 2D
SetTexture 2 [_BumpMap] 2D
SetTexture 3 [_ShadowMapTexture] 2D
"3.0-!!ARBfp1.0
# 94 ALU, 8 TEX
PARAM c[14] = { program.local[0..8],
		{ 0, 3.141593, -0.018729299, 0.074261002 },
		{ 0.21211439, 1.570729, 1, 2 },
		{ 0.31830987, -0.01348047, 0.05747731, 0.1212391 },
		{ 0.1956359, 0.33299461, 0.99999559, 1.570796 },
		{ 0.15915494, 0.5, 0, 1 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
MUL R2.xy, fragment.texcoord[2].zxzw, c[6].x;
ADD R3.xy, R2, c[2];
MUL R0.xy, fragment.texcoord[2].zyzw, c[6].x;
ADD R0.xy, R0, c[2];
MUL R0.zw, fragment.texcoord[2].xyxy, c[6].x;
MUL R2.yw, fragment.texcoord[2].xzzy, c[7].x;
ADD R2.yw, R2, c[3].xxzy;
ABS R2.xz, fragment.texcoord[2].xyyw;
TEX R1, R0, texture[1], 2D;
ADD R0.zw, R0, c[2].xyxy;
TEX R0, R0.zwzw, texture[1], 2D;
ADD R1, R1, -R0;
MAD R0, R2.x, R1, R0;
TEX R1, R3, texture[1], 2D;
ADD R1, R1, -R0;
MAD R0, R2.z, R1, R0;
ABS R1.w, fragment.texcoord[2].z;
MUL R3.xz, fragment.texcoord[2].zyxw, c[7].x;
MUL R3.yw, fragment.texcoord[2].xxzy, c[7].x;
ADD R3.yw, R3, c[3].xxzy;
ADD R3.xz, R3, c[3].xyyw;
MAX R1.z, R1.w, R2.x;
TEX R3.yw, R3.ywzw, texture[2], 2D;
TEX R2.yw, R2.ywzw, texture[2], 2D;
ADD R2.yw, R2, -R3;
MAD R2.yw, R2.x, R2, R3;
TEX R3.yw, R3.xzzw, texture[2], 2D;
ADD R3.xy, R3.ywzw, -R2.ywzw;
MAD R1.xy, R2.z, R3, R2.ywzw;
ADD R3.xyz, -R0, c[10].z;
MUL_SAT R2.w, fragment.texcoord[1].x, c[10];
MAD R1.xy, R1.yxzw, c[10].w, -c[10].z;
MAD R0.xyz, R2.w, R3, R0;
MUL R3.xy, R1, R1;
ADD_SAT R2.y, R3.x, R3;
ADD R2.z, -R2.y, c[10];
RCP R2.y, R1.z;
MIN R1.z, R1.w, R2.x;
MUL R2.y, R1.z, R2;
RSQ R1.z, R2.z;
MUL R2.z, R2.y, R2.y;
RCP R1.z, R1.z;
ADD R3.xyz, -R1, c[13].zzww;
MAD R1.xyz, R2.w, R3, R1;
DP3_SAT R1.z, R1, fragment.texcoord[3];
MAD R3.w, R2.z, c[11].y, c[11].z;
MAD R3.w, R3, R2.z, -c[11];
MAD R3.x, R3.w, R2.z, c[12];
MAD R1.y, R3.x, R2.z, -c[12];
MAD R1.y, R1, R2.z, c[12].z;
TXP R1.x, fragment.texcoord[5], texture[3], 2D;
MUL R1.x, R1.z, R1;
MUL R1.y, R1, R2;
MUL R3.xyz, R1.x, c[0];
ADD R1.z, -R1.y, c[12].w;
ADD R1.x, R1.w, -R2;
CMP R1.x, -R1, R1.z, R1.y;
ABS R1.z, -fragment.texcoord[2].y;
ADD R1.y, -R1.x, c[9];
ADD R2.x, -R1.z, c[10].z;
MAD R1.w, R1.z, c[9].z, c[9];
MAD R1.w, R1, R1.z, -c[10].x;
RSQ R2.x, R2.x;
CMP R1.y, fragment.texcoord[2].x, R1, R1.x;
MAD R1.z, R1.w, R1, c[10].y;
RCP R2.x, R2.x;
MUL R1.w, R1.z, R2.x;
SLT R1.z, -fragment.texcoord[2].y, c[9].x;
MUL R2.x, R1.z, R1.w;
MAD R1.x, -R2, c[10].w, R1.w;
CMP R1.w, fragment.texcoord[2].z, -R1.y, R1.y;
MAD R1.y, R1.z, c[9], R1.x;
MUL R2.xyz, R3, c[10].w;
MAD R1.x, R1.w, c[13], c[13].y;
MUL R1.y, R1, c[11].x;
TEX R1, R1, texture[0], 2D;
MUL R1, R1, c[1];
MUL R0.xyz, R1, R0;
ADD_SAT R1.xyz, R2, c[8].x;
MUL R0.xyz, R0, c[1];
MUL R1.xyz, R0, R1;
MAD result.color.xyz, R0, fragment.texcoord[4], R1;
DP3 R2.x, fragment.texcoord[0], fragment.texcoord[0];
RSQ R0.y, R2.x;
ADD R0.x, -R0.w, c[10].z;
MUL_SAT R0.y, R0, fragment.texcoord[0].z;
MUL R0.y, R0, c[5].x;
POW_SAT R0.z, R0.y, c[4].x;
MAD R0.x, R2.w, R0, R0.w;
MUL R0.x, R1.w, R0;
ADD R0.y, -fragment.texcoord[1], c[10].z;
ADD_SAT R0.y, R0, R0.z;
MUL R0.x, fragment.texcoord[1].y, R0;
MUL result.color.w, R0.x, R0.y;
END
# 94 instructions, 4 R-regs
"
}

SubProgram "d3d9 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
Vector 0 [_LightColor0]
Vector 1 [_Color]
Vector 2 [_DetailOffset]
Vector 3 [_BumpOffset]
Float 4 [_FalloffPow]
Float 5 [_FalloffScale]
Float 6 [_DetailScale]
Float 7 [_BumpScale]
Float 8 [_MinLight]
SetTexture 0 [_MainTex] 2D
SetTexture 1 [_DetailTex] 2D
SetTexture 2 [_BumpMap] 2D
SetTexture 3 [_ShadowMapTexture] 2D
"ps_3_0
; 89 ALU, 8 TEX
dcl_2d s0
dcl_2d s1
dcl_2d s2
dcl_2d s3
def c9, 0.00000000, 1.00000000, -0.01872930, 0.07426100
def c10, -0.21211439, 1.57072902, 2.00000000, 3.14159298
def c11, 0.31830987, -0.01348047, 0.05747731, -0.12123910
def c12, 0.19563590, -0.33299461, 0.99999559, 1.57079601
def c13, 0.15915494, 0.50000000, 2.00000000, -1.00000000
dcl_texcoord0 v0.xyz
dcl_texcoord1 v1.xy
dcl_texcoord2 v2.xyz
dcl_texcoord3 v3.xyz
dcl_texcoord4 v4.xyz
dcl_texcoord5 v5
mul r0.xy, v2.zyzw, c6.x
add r1.xy, r0, c2
mul r0.zw, v2.xyxy, c6.x
add r0.xy, r0.zwzw, c2
mul r2.xy, v2.zxzw, c6.x
mul r3.xy, v2, c7.x
add r3.xy, r3, c3
abs r2.zw, v2.xyxy
add r2.xy, r2, c2
texld r3.yw, r3, s2
texld r0, r0, s1
texld r1, r1, s1
add_pp r1, r1, -r0
mad_pp r0, r2.z, r1, r0
texld r1, r2, s1
add_pp r1, r1, -r0
mad_pp r0, r2.w, r1, r0
add_pp r1.xyz, -r0, c9.y
mul_sat r2.x, v1, c10.z
mad_pp r0.xyz, r2.x, r1, r0
mul r1.zw, v2.xyzy, c7.x
add r4.xy, r1.zwzw, c3
mul r1.xy, v2.zxzw, c7.x
texld r4.yw, r4, s2
add_pp r1.zw, r4.xyyw, -r3.xyyw
mad_pp r1.zw, r2.z, r1, r3.xyyw
add r1.xy, r1, c3
texld r3.yw, r1, s2
add_pp r1.xy, r3.ywzw, -r1.zwzw
mad_pp r1.xy, r2.w, r1, r1.zwzw
abs r2.y, v2.z
max r1.z, r2.y, r2
rcp r1.w, r1.z
min r1.z, r2.y, r2
mul r2.w, r1.z, r1
mad_pp r1.xy, r1.yxzw, c13.z, c13.w
mul_pp r1.zw, r1.xyxy, r1.xyxy
add_pp_sat r1.w, r1.z, r1
mul r3.w, r2, r2
mad r1.z, r3.w, c11.y, c11
add_pp r1.w, -r1, c9.y
mad r1.z, r1, r3.w, c11.w
rsq_pp r3.x, r1.w
mad r1.w, r1.z, r3, c12.x
rcp_pp r1.z, r3.x
add_pp r3.xyz, -r1, c9.xxyw
mad_pp r1.xyz, r2.x, r3, r1
mad r1.w, r1, r3, c12.y
mad r1.w, r1, r3, c12.z
mul r1.w, r1, r2
dp3_pp_sat r2.w, r1, v3
abs r1.z, -v2.y
add r1.x, r2.y, -r2.z
add r1.y, -r1.w, c12.w
cmp r1.x, -r1, r1.w, r1.y
add r1.y, -r1.x, c10.w
add r2.y, -r1.z, c9
mad r1.w, r1.z, c9.z, c9
mad r1.w, r1, r1.z, c10.x
rsq r2.y, r2.y
mad r1.z, r1.w, r1, c10.y
rcp r2.y, r2.y
mul r1.w, r1.z, r2.y
cmp r1.z, -v2.y, c9.x, c9.y
mul r2.y, r1.z, r1.w
cmp r1.y, v2.x, r1.x, r1
mad r1.x, -r2.y, c10.z, r1.w
cmp r1.w, v2.z, r1.y, -r1.y
mad r1.y, r1.z, c10.w, r1.x
texldp r3.x, v5, s3
mul_pp r2.y, r2.w, r3.x
mad r1.x, r1.w, c13, c13.y
mul r1.y, r1, c11.x
texld r1, r1, s0
mul r1, r1, c1
mul_pp r0.xyz, r1, r0
mul_pp r1.xyz, r2.y, c0
mul_pp r1.xyz, r1, c10.z
dp3 r2.y, v0, v0
rsq r2.y, r2.y
mul_pp r0.xyz, r0, c1
add_sat r1.xyz, r1, c8.x
mul r1.xyz, r0, r1
mad_pp oC0.xyz, r0, v4, r1
mul_sat r2.y, r2, v0.z
mul r0.y, r2, c5.x
pow_sat r3, r0.y, c4.x
add_pp r0.x, -r0.w, c9.y
mad_pp r0.x, r2, r0, r0.w
mul_pp r0.x, r1.w, r0
mov r0.z, r3.x
add r0.y, -v1, c9
add_sat r0.y, r0, r0.z
mul r0.x, v1.y, r0
mul oC0.w, r0.x, r0.y
"
}

SubProgram "d3d11 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
ConstBuffer "$Globals" 192 // 184 used size, 13 vars
Vector 16 [_LightColor0] 4
Vector 112 [_Color] 4
Vector 128 [_DetailOffset] 4
Vector 144 [_BumpOffset] 4
Float 160 [_FalloffPow]
Float 164 [_FalloffScale]
Float 168 [_DetailScale]
Float 176 [_BumpScale]
Float 180 [_MinLight]
BindCB "$Globals" 0
SetTexture 0 [_MainTex] 2D 1
SetTexture 1 [_DetailTex] 2D 2
SetTexture 2 [_BumpMap] 2D 3
SetTexture 3 [_ShadowMapTexture] 2D 0
// 87 instructions, 6 temp regs, 0 temp arrays:
// ALU 73 float, 0 int, 4 uint
// TEX 8 (0 load, 0 comp, 0 bias, 0 grad)
// FLOW 1 static, 0 dynamic
"ps_4_0
eefiecedcpfajkcbebhfoflhciidclcoghdcmagpabaaaaaafaanaaaaadaaaaaa
cmaaaaaapmaaaaaadaabaaaaejfdeheomiaaaaaaahaaaaaaaiaaaaaalaaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaalmaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaahahaaaalmaaaaaaabaaaaaaaaaaaaaaadaaaaaaacaaaaaa
adadaaaalmaaaaaaacaaaaaaaaaaaaaaadaaaaaaadaaaaaaahahaaaalmaaaaaa
adaaaaaaaaaaaaaaadaaaaaaaeaaaaaaahahaaaalmaaaaaaaeaaaaaaaaaaaaaa
adaaaaaaafaaaaaaahahaaaalmaaaaaaafaaaaaaaaaaaaaaadaaaaaaagaaaaaa
apalaaaafdfgfpfaepfdejfeejepeoaafeeffiedepepfceeaaklklklepfdeheo
cmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaa
apaaaaaafdfgfpfegbhcghgfheaaklklfdeieefcbiamaaaaeaaaaaaaagadaaaa
fjaaaaaeegiocaaaaaaaaaaaamaaaaaafkaaaaadaagabaaaaaaaaaaafkaaaaad
aagabaaaabaaaaaafkaaaaadaagabaaaacaaaaaafkaaaaadaagabaaaadaaaaaa
fibiaaaeaahabaaaaaaaaaaaffffaaaafibiaaaeaahabaaaabaaaaaaffffaaaa
fibiaaaeaahabaaaacaaaaaaffffaaaafibiaaaeaahabaaaadaaaaaaffffaaaa
gcbaaaadhcbabaaaabaaaaaagcbaaaaddcbabaaaacaaaaaagcbaaaadhcbabaaa
adaaaaaagcbaaaadhcbabaaaaeaaaaaagcbaaaadhcbabaaaafaaaaaagcbaaaad
lcbabaaaagaaaaaagfaaaaadpccabaaaaaaaaaaagiaaaaacagaaaaaadeaaaaaj
bcaabaaaaaaaaaaaakbabaiaibaaaaaaadaaaaaackbabaiaibaaaaaaadaaaaaa
aoaaaaakbcaabaaaaaaaaaaaaceaaaaaaaaaiadpaaaaiadpaaaaiadpaaaaiadp
akaabaaaaaaaaaaaddaaaaajccaabaaaaaaaaaaaakbabaiaibaaaaaaadaaaaaa
ckbabaiaibaaaaaaadaaaaaadiaaaaahbcaabaaaaaaaaaaaakaabaaaaaaaaaaa
bkaabaaaaaaaaaaadiaaaaahccaabaaaaaaaaaaaakaabaaaaaaaaaaaakaabaaa
aaaaaaaadcaaaaajecaabaaaaaaaaaaabkaabaaaaaaaaaaaabeaaaaafpkokkdm
abeaaaaadgfkkolndcaaaaajecaabaaaaaaaaaaabkaabaaaaaaaaaaackaabaaa
aaaaaaaaabeaaaaaochgdidodcaaaaajecaabaaaaaaaaaaabkaabaaaaaaaaaaa
ckaabaaaaaaaaaaaabeaaaaaaebnkjlodcaaaaajccaabaaaaaaaaaaabkaabaaa
aaaaaaaackaabaaaaaaaaaaaabeaaaaadiphhpdpdiaaaaahecaabaaaaaaaaaaa
bkaabaaaaaaaaaaaakaabaaaaaaaaaaadcaaaaajecaabaaaaaaaaaaackaabaaa
aaaaaaaaabeaaaaaaaaaaamaabeaaaaanlapmjdpdbaaaaajicaabaaaaaaaaaaa
akbabaiaibaaaaaaadaaaaaackbabaiaibaaaaaaadaaaaaaabaaaaahecaabaaa
aaaaaaaadkaabaaaaaaaaaaackaabaaaaaaaaaaadcaaaaajbcaabaaaaaaaaaaa
akaabaaaaaaaaaaabkaabaaaaaaaaaaackaabaaaaaaaaaaadbaaaaaiccaabaaa
aaaaaaaaakbabaaaadaaaaaaakbabaiaebaaaaaaadaaaaaaabaaaaahccaabaaa
aaaaaaaabkaabaaaaaaaaaaaabeaaaaanlapejmaaaaaaaahbcaabaaaaaaaaaaa
bkaabaaaaaaaaaaaakaabaaaaaaaaaaaddaaaaahccaabaaaaaaaaaaaakbabaaa
adaaaaaackbabaaaadaaaaaadbaaaaaiccaabaaaaaaaaaaabkaabaaaaaaaaaaa
bkaabaiaebaaaaaaaaaaaaaadeaaaaahecaabaaaaaaaaaaaakbabaaaadaaaaaa
ckbabaaaadaaaaaabnaaaaaiecaabaaaaaaaaaaackaabaaaaaaaaaaackaabaia
ebaaaaaaaaaaaaaaabaaaaahccaabaaaaaaaaaaackaabaaaaaaaaaaabkaabaaa
aaaaaaaadhaaaaakbcaabaaaaaaaaaaabkaabaaaaaaaaaaaakaabaiaebaaaaaa
aaaaaaaaakaabaaaaaaaaaaadcaaaaajbcaabaaaaaaaaaaaakaabaaaaaaaaaaa
abeaaaaaidpjccdoabeaaaaaaaaaaadpdcaaaaakecaabaaaaaaaaaaabkbabaia
ibaaaaaaadaaaaaaabeaaaaadagojjlmabeaaaaachbgjidndcaaaaakecaabaaa
aaaaaaaackaabaaaaaaaaaaabkbabaiaibaaaaaaadaaaaaaabeaaaaaiedefjlo
dcaaaaakecaabaaaaaaaaaaackaabaaaaaaaaaaabkbabaiaibaaaaaaadaaaaaa
abeaaaaakeanmjdpaaaaaaaiicaabaaaaaaaaaaabkbabaiambaaaaaaadaaaaaa
abeaaaaaaaaaiadpelaaaaaficaabaaaaaaaaaaadkaabaaaaaaaaaaadiaaaaah
bcaabaaaabaaaaaadkaabaaaaaaaaaaackaabaaaaaaaaaaadcaaaaajbcaabaaa
abaaaaaaakaabaaaabaaaaaaabeaaaaaaaaaaamaabeaaaaanlapejeadbaaaaai
ccaabaaaabaaaaaabkbabaiaebaaaaaaadaaaaaabkbabaaaadaaaaaaabaaaaah
bcaabaaaabaaaaaabkaabaaaabaaaaaaakaabaaaabaaaaaadcaaaaajecaabaaa
aaaaaaaackaabaaaaaaaaaaadkaabaaaaaaaaaaaakaabaaaabaaaaaadiaaaaah
ccaabaaaaaaaaaaackaabaaaaaaaaaaaabeaaaaaidpjkcdoefaaaaajpcaabaaa
aaaaaaaaegaabaaaaaaaaaaaeghobaaaaaaaaaaaaagabaaaabaaaaaadiaaaaai
pcaabaaaaaaaaaaaegaobaaaaaaaaaaaegiocaaaaaaaaaaaahaaaaaadcaaaaal
pcaabaaaabaaaaaaggbcbaaaadaaaaaakgikcaaaaaaaaaaaakaaaaaaegiecaaa
aaaaaaaaaiaaaaaaefaaaaajpcaabaaaacaaaaaaegaabaaaabaaaaaaeghobaaa
abaaaaaaaagabaaaacaaaaaaefaaaaajpcaabaaaabaaaaaaogakbaaaabaaaaaa
eghobaaaabaaaaaaaagabaaaacaaaaaadcaaaaaldcaabaaaadaaaaaaegbabaaa
adaaaaaakgikcaaaaaaaaaaaakaaaaaaegiacaaaaaaaaaaaaiaaaaaaefaaaaaj
pcaabaaaadaaaaaaegaabaaaadaaaaaaeghobaaaabaaaaaaaagabaaaacaaaaaa
aaaaaaaipcaabaaaacaaaaaaegaobaaaacaaaaaaegaobaiaebaaaaaaadaaaaaa
dcaaaaakpcaabaaaacaaaaaaagbabaiaibaaaaaaadaaaaaaegaobaaaacaaaaaa
egaobaaaadaaaaaaaaaaaaaipcaabaaaabaaaaaaegaobaaaabaaaaaaegaobaia
ebaaaaaaacaaaaaadcaaaaakpcaabaaaabaaaaaafgbfbaiaibaaaaaaadaaaaaa
egaobaaaabaaaaaaegaobaaaacaaaaaaaaaaaaalpcaabaaaacaaaaaaegaobaia
ebaaaaaaabaaaaaaaceaaaaaaaaaiadpaaaaiadpaaaaiadpaaaaiadpaacaaaah
bcaabaaaadaaaaaaakbabaaaacaaaaaaakbabaaaacaaaaaadcaaaaajpcaabaaa
abaaaaaaagaabaaaadaaaaaaegaobaaaacaaaaaaegaobaaaabaaaaaadiaaaaah
pcaabaaaaaaaaaaaegaobaaaaaaaaaaaegaobaaaabaaaaaadiaaaaaihcaabaaa
aaaaaaaaegacbaaaaaaaaaaaegiccaaaaaaaaaaaahaaaaaadiaaaaahicaabaaa
aaaaaaaadkaabaaaaaaaaaaabkbabaaaacaaaaaadiaaaaahhcaabaaaabaaaaaa
egacbaaaaaaaaaaaegbcbaaaafaaaaaadcaaaaalpcaabaaaacaaaaaaggbcbaaa
adaaaaaaagiacaaaaaaaaaaaalaaaaaaegiecaaaaaaaaaaaajaaaaaaefaaaaaj
pcaabaaaaeaaaaaaegaabaaaacaaaaaaeghobaaaacaaaaaaaagabaaaadaaaaaa
efaaaaajpcaabaaaacaaaaaaogakbaaaacaaaaaaeghobaaaacaaaaaaaagabaaa
adaaaaaadcaaaaalfcaabaaaacaaaaaaagbbbaaaadaaaaaaagiacaaaaaaaaaaa
alaaaaaaagibcaaaaaaaaaaaajaaaaaaefaaaaajpcaabaaaafaaaaaaigaabaaa
acaaaaaaeghobaaaacaaaaaaaagabaaaadaaaaaaaaaaaaaifcaabaaaacaaaaaa
pganbaaaaeaaaaaapganbaiaebaaaaaaafaaaaaadcaaaaakfcaabaaaacaaaaaa
agbabaiaibaaaaaaadaaaaaaagacbaaaacaaaaaapganbaaaafaaaaaaaaaaaaai
kcaabaaaacaaaaaaagaibaiaebaaaaaaacaaaaaapgahbaaaacaaaaaadcaaaaak
dcaabaaaacaaaaaafgbfbaiaibaaaaaaadaaaaaangafbaaaacaaaaaaigaabaaa
acaaaaaadcaaaaapdcaabaaaacaaaaaaegaabaaaacaaaaaaaceaaaaaaaaaaaea
aaaaaaeaaaaaaaaaaaaaaaaaaceaaaaaaaaaialpaaaaialpaaaaaaaaaaaaaaaa
apaaaaahicaabaaaabaaaaaaegaabaaaacaaaaaaegaabaaaacaaaaaaddaaaaah
icaabaaaabaaaaaadkaabaaaabaaaaaaabeaaaaaaaaaiadpaaaaaaaiicaabaaa
abaaaaaadkaabaiaebaaaaaaabaaaaaaabeaaaaaaaaaiadpelaaaaafecaabaaa
acaaaaaadkaabaaaabaaaaaaaaaaaaalocaabaaaadaaaaaaagajbaiaebaaaaaa
acaaaaaaaceaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaiadpdcaaaaajhcaabaaa
acaaaaaaagaabaaaadaaaaaajgahbaaaadaaaaaaegacbaaaacaaaaaabacaaaah
icaabaaaabaaaaaaegacbaaaacaaaaaaegbcbaaaaeaaaaaaaoaaaaahdcaabaaa
acaaaaaaegbabaaaagaaaaaapgbpbaaaagaaaaaaefaaaaajpcaabaaaacaaaaaa
egaabaaaacaaaaaaeghobaaaadaaaaaaaagabaaaaaaaaaaaapaaaaahicaabaaa
abaaaaaapgapbaaaabaaaaaaagaabaaaacaaaaaadccaaaalhcaabaaaacaaaaaa
egiccaaaaaaaaaaaabaaaaaapgapbaaaabaaaaaafgifcaaaaaaaaaaaalaaaaaa
dcaaaaajhccabaaaaaaaaaaaegacbaaaaaaaaaaaegacbaaaacaaaaaaegacbaaa
abaaaaaabaaaaaahbcaabaaaaaaaaaaaegbcbaaaabaaaaaaegbcbaaaabaaaaaa
eeaaaaafbcaabaaaaaaaaaaaakaabaaaaaaaaaaadicaaaahbcaabaaaaaaaaaaa
akaabaaaaaaaaaaackbabaaaabaaaaaadiaaaaaibcaabaaaaaaaaaaaakaabaaa
aaaaaaaabkiacaaaaaaaaaaaakaaaaaacpaaaaafbcaabaaaaaaaaaaaakaabaaa
aaaaaaaadiaaaaaibcaabaaaaaaaaaaaakaabaaaaaaaaaaaakiacaaaaaaaaaaa
akaaaaaabjaaaaafbcaabaaaaaaaaaaaakaabaaaaaaaaaaaddaaaaahbcaabaaa
aaaaaaaaakaabaaaaaaaaaaaabeaaaaaaaaaiadpaaaaaaaiccaabaaaaaaaaaaa
bkbabaiaebaaaaaaacaaaaaaabeaaaaaaaaaiadpaacaaaahbcaabaaaaaaaaaaa
akaabaaaaaaaaaaabkaabaaaaaaaaaaadiaaaaahiccabaaaaaaaaaaaakaabaaa
aaaaaaaadkaabaaaaaaaaaaadoaaaaab"
}

SubProgram "gles " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES"
}

SubProgram "glesdesktop " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES"
}

SubProgram "gles3 " {
Keywords { "DIRECTIONAL" "LIGHTMAP_OFF" "DIRLIGHTMAP_OFF" "SHADOWS_SCREEN" }
"!!GLES3"
}

}
	}

#LINE 99

	
	}
	
	 
	FallBack "Diffuse"
}