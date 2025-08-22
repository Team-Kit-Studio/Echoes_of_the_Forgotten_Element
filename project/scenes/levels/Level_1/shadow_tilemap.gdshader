shader_type canvas_item;
render_mode unshaded;

uniform float shadowAngle: hint_range(0.0, 360.0) = 45; //Angle (in degrees) of the shadow
uniform float wallHeight: hint_range(0.0,5.0) = 1.0; //Shadow height multiplier
uniform ivec2 floorStart;
//Start (in pixels) of the floor
//ex. if the floor is 7 pixels down from the top of the sprite, y = 7
uniform vec4 shadowColor: source_color = vec4(0.0,0.0,0.0,0.4);
uniform ivec2 shadowCutoffStart = ivec2(0); //Cutoff (in pixels) from the top left of the sprite
uniform ivec2 shadowCutoffEnd = ivec2(0); //Cutoff (in pixels) from the bottom right of the sprite
uniform ivec2 shadowOffset = ivec2(0); //Offset (in pixels) of shadow
uniform bool maskWrap = true; //Wrap if the shadow leaves the UV
uniform sampler2D maskTop: filter_nearest, hint_default_transparent; //Mask for Y Values, opaque pixels cast shadows
uniform sampler2D maskLeft: filter_nearest, hint_default_transparent; //Mask for X Values, opaque pixels cast shadows
uniform sampler2D coverMask: filter_nearest, hint_default_transparent;
//Mask for if a part of the sprite should appear in front of the shadow

group_uniforms depthSetup;
uniform float wallDepth: hint_range(0.0, 50.0,0.1) = 1.5;
uniform int sampleMult: hint_range(1, 10, 1) = 3; //Lower values lead to pixelated depth
uniform bool floorDepthAutoCutoff = true; //Auto cutoff unwanted stretching at bottom of wall from depth

group_uniforms tilemapSetup;
uniform bool isTileMap = false;
uniform ivec2 tileSize = ivec2(0); //Size (in pixels) of each tile in the tilemap

//Tilemap converter by Award
vec2 get_tile_uvs(vec2 p_uv,vec2 p_tex_size,vec2 p_region_size) {
	vec2 uv = p_uv - p_tex_size;
	uv = fract(uv * p_tex_size / p_region_size);
	return uv * p_region_size / p_region_size;
}

//2D top-down shadow shader by WizardWand123
void fragment() {
	COLOR = texture(TEXTURE,UV);

	vec2 uv = UV;
	vec2 tileUV = UV;
	//Change uv value for tilemap
	if(isTileMap){
		tileUV = get_tile_uvs(UV,vec2(textureSize(TEXTURE,0)),vec2(tileSize));
		uv = tileUV;
	}

	vec2 pixSize = TEXTURE_PIXEL_SIZE * (isTileMap ? vec2(textureSize(TEXTURE,0))/vec2(tileSize) : vec2(1));

	uv += vec2(shadowOffset) * pixSize;
	//Test for cutoff or cover mask
	vec2 modCutoff = vec2(shadowCutoffStart) * pixSize;
	vec2 modCutoffEnd = vec2(1.0)-(vec2(shadowCutoffEnd) * pixSize);
	if(clamp(tileUV,modCutoff,modCutoffEnd) == tileUV && texture(coverMask,tileUV).a == 0.0){
		//Find direction of angle
		vec2 direct = vec2(cos(shadowAngle * (PI/180.0)),sin(shadowAngle * (PI/180.0)));

		vec2 depthUV = uv;
		vec2 floorCorner = (vec2(floorStart)*pixSize);
		vec2 floorAutoStart = sign(uv-floorCorner);

		int loopTimeout = 0;
		while(loopTimeout < max(int(wallDepth*10.0) * sampleMult,1)){
			loopTimeout += 1;

			vec2 floorDifference = depthUV-floorCorner;
			bvec2 skip = bvec2(sign(depthUV.x-floorCorner.x) != floorAutoStart.x && floorDepthAutoCutoff,sign(depthUV.y-floorCorner.y) != floorAutoStart.y && floorDepthAutoCutoff);

			//Find UV for Shadow
			vec2 flipUV = floorCorner-((floorDifference/direct)/wallHeight);
			vec2 maskUVTop = vec2(uv.x,flipUV.y) + vec2(-(floorDifference.y/direct.y)*direct.x,0.0);
			vec2 maskUVLeft = vec2(flipUV.x,uv.y) + vec2(0.0,-(floorDifference.x/direct.x)*direct.y);

			if(maskWrap){
				maskUVTop = vec2(fract(maskUVTop.x),maskUVTop.y);
				maskUVLeft = vec2(maskUVLeft.x,fract(maskUVLeft.y));
			}

			//Test if UV is beyond usual values (only useful when maskwrap disabled) to prevent stretching
			bool offMaskTop = clamp(maskUVTop,vec2(0.0),vec2(1.0)) != maskUVTop;
			bool offMaskLeft = clamp(maskUVLeft,vec2(0.0),vec2(1.0)) != maskUVLeft;

			//Test if moddified UV collides with mask
			if((texture(maskTop,maskUVTop).a > 0.0 && !offMaskTop && !skip.y) || (texture(maskLeft,maskUVLeft).a > 0.0 && !offMaskLeft && !skip.x)){
				COLOR.rgb = mix(COLOR.rgb,shadowColor.rgb,shadowColor.a);
				break;
			}else{
				//Change UV for depth
				depthUV.y += (0.005/float(sampleMult)) * sign(direct.y);
				depthUV.x += (0.005/(float(sampleMult))) * sign(direct.x);
			}
		}
	}
}