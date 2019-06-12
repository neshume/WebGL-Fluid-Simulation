package;


import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets;

#if sys
import sys.FileSystem;
#end

@:access(lime.utils.Assets)


@:keep @:dox(hide) class ManifestResources {


	public static var preloadLibraries:Array<AssetLibrary>;
	public static var preloadLibraryNames:Array<String>;
	public static var rootPath:String;


	public static function init (config:Dynamic):Void {

		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();

		rootPath = null;

		if (config != null && Reflect.hasField (config, "rootPath")) {

			rootPath = Reflect.field (config, "rootPath");

		}

		if (rootPath == null) {

			#if (ios || tvos || emscripten)
			rootPath = "assets/";
			#elseif console
			rootPath = lime.system.System.applicationDirectory;
			#elseif (winrt)
			rootPath = "./";
			#elseif (sys && windows && !cs)
			rootPath = FileSystem.absolutePath (haxe.io.Path.directory (#if (haxe_ver >= 3.3) Sys.programPath () #else Sys.executablePath () #end)) + "/";
			#else
			rootPath = "";
			#end

		}

		Assets.defaultRootPath = rootPath;

		#if (openfl && !flash && !display)
		openfl.text.Font.registerFont (__ASSET__OPENFL__assets_iconfont_ttf);
		
		#end

		var data, manifest, library;

		#if kha

		null
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("null", library);

		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("null");

		#else

		data = '{"name":null,"assets":"aoy4:pathy19:assets%2Findex.htmly4:sizei2828y4:typey4:TEXTy2:idR1y7:preloadtgoR0y20:assets%2Fmain.js.mapR2i5804R3R4R5R7R6tgoR2i2008R3y4:FONTy9:classNamey28:__ASSET__assets_iconfont_ttfR5y21:assets%2Ficonfont.ttfR6tgoR0y16:assets%2Fmain.jsR2i9565R3R4R5R12R6tgoR0y17:assets%2Flogo.pngR2i344888R3y5:IMAGER5R13R6tgoR0y35:assets%2Fshaders%2FsplatShader.glslR2i395R3R4R5R15R6tgoR0y39:assets%2Fshaders%2FadvectionShader.glslR2i367R3R4R5R16R6tgoR0y40:assets%2Fshaders%2FbackgroundShader.glslR2i319R3R4R5R17R6tgoR0y49:assets%2Fshaders%2FdisplayBloomShadingShader.glslR2i1041R3R4R5R18R6tgoR0y39:assets%2Fshaders%2FbloomBlurShader.glslR2i379R3R4R5R19R6tgoR0y44:assets%2Fshaders%2FdisplayShadingShader.glslR2i734R3R4R5R20R6tgoR0y35:assets%2Fshaders%2FclearShader.glslR2i198R3R4R5R21R6tgoR0y40:assets%2Fshaders%2FbaseVertexShader.glslR2i411R3R4R5R22R6tgoR0y40:assets%2Fshaders%2FdivergenceShader.glslR2i650R3R4R5R23R6tgoR0y42:assets%2Fshaders%2FdisplayBloomShader.glslR2i537R3R4R5R24R6tgoR0y34:assets%2Fshaders%2FcurlShader.glslR2i479R3R4R5R25R6tgoR0y46:assets%2Fshaders%2FgradientSubtractShader.glslR2i686R3R4R5R26R6tgoR0y38:assets%2Fshaders%2FpressureShader.glslR2i815R3R4R5R27R6tgoR0y54:assets%2Fshaders%2FadvectionManualFilteringShader.glslR2i857R3R4R5R28R6tgoR0y39:assets%2Fshaders%2FvorticityShader.glslR2i681R3R4R5R29R6tgoR0y44:assets%2Fshaders%2FbloomPrefilterShader.glslR2i409R3R4R5R30R6tgoR0y37:assets%2Fshaders%2FdisplayShader.glslR2i227R3R4R5R31R6tgoR0y35:assets%2Fshaders%2FcolorShader.glslR2i89R3R4R5R32R6tgoR0y40:assets%2Fshaders%2FbloomFinalShader.glslR2i416R3R4R5R33R6tgoR0y23:assets%2FLDR_RGB1_0.pngR2i14245R3R14R5R34R6tgoR0y26:shaders%2FsplatShader.glslR2i395R3R4R5R35R6tgoR0y30:shaders%2FadvectionShader.glslR2i367R3R4R5R36R6tgoR0y31:shaders%2FbackgroundShader.glslR2i319R3R4R5R37R6tgoR0y40:shaders%2FdisplayBloomShadingShader.glslR2i1041R3R4R5R38R6tgoR0y30:shaders%2FbloomBlurShader.glslR2i379R3R4R5R39R6tgoR0y35:shaders%2FdisplayShadingShader.glslR2i734R3R4R5R40R6tgoR0y26:shaders%2FclearShader.glslR2i198R3R4R5R41R6tgoR0y31:shaders%2FbaseVertexShader.glslR2i411R3R4R5R42R6tgoR0y31:shaders%2FdivergenceShader.glslR2i650R3R4R5R43R6tgoR0y33:shaders%2FdisplayBloomShader.glslR2i537R3R4R5R44R6tgoR0y25:shaders%2FcurlShader.glslR2i479R3R4R5R45R6tgoR0y37:shaders%2FgradientSubtractShader.glslR2i686R3R4R5R46R6tgoR0y29:shaders%2FpressureShader.glslR2i815R3R4R5R47R6tgoR0y45:shaders%2FadvectionManualFilteringShader.glslR2i857R3R4R5R48R6tgoR0y30:shaders%2FvorticityShader.glslR2i681R3R4R5R49R6tgoR0y35:shaders%2FbloomPrefilterShader.glslR2i409R3R4R5R50R6tgoR0y28:shaders%2FdisplayShader.glslR2i227R3R4R5R51R6tgoR0y26:shaders%2FcolorShader.glslR2i89R3R4R5R52R6tgoR0y31:shaders%2FbloomFinalShader.glslR2i416R3R4R5R53R6tgh","rootPath":null,"version":2,"libraryArgs":[],"libraryType":null}';
		manifest = AssetManifest.parse (data, rootPath);
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("default", library);
		

		library = Assets.getLibrary ("default");
		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("default");
		

		#end

	}


}


#if kha

null

#else

#if !display
#if flash

@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_index_html extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_main_js_map extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_iconfont_ttf extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_main_js extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_logo_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_splatshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_advectionshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_backgroundshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_displaybloomshadingshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_bloomblurshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_displayshadingshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_clearshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_basevertexshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_divergenceshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_displaybloomshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_curlshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_gradientsubtractshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_pressureshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_advectionmanualfilteringshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_vorticityshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_bloomprefiltershader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_displayshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_colorshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_shaders_bloomfinalshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_ldr_rgb1_0_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_splatshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_advectionshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_backgroundshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_displaybloomshadingshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_bloomblurshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_displayshadingshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_clearshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_basevertexshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_divergenceshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_displaybloomshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_curlshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_gradientsubtractshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_pressureshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_advectionmanualfilteringshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_vorticityshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_bloomprefiltershader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_displayshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_colorshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__shaders_bloomfinalshader_glsl extends null { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__manifest_default_json extends null { }


#elseif (desktop || cpp)

@:keep @:file("Assets/index.html") @:noCompletion #if display private #end class __ASSET__assets_index_html extends haxe.io.Bytes {}
@:keep @:file("Assets/main.js.map") @:noCompletion #if display private #end class __ASSET__assets_main_js_map extends haxe.io.Bytes {}
@:keep @:font("Export/html5/obj/webfont/iconfont.ttf") @:noCompletion #if display private #end class __ASSET__assets_iconfont_ttf extends lime.text.Font {}
@:keep @:file("Assets/main.js") @:noCompletion #if display private #end class __ASSET__assets_main_js extends haxe.io.Bytes {}
@:keep @:image("Assets/logo.png") @:noCompletion #if display private #end class __ASSET__assets_logo_png extends lime.graphics.Image {}
@:keep @:file("Assets/shaders/splatShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_splatshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/advectionShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_advectionshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/backgroundShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_backgroundshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/displayBloomShadingShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_displaybloomshadingshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/bloomBlurShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_bloomblurshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/displayShadingShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_displayshadingshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/clearShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_clearshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/baseVertexShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_basevertexshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/divergenceShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_divergenceshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/displayBloomShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_displaybloomshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/curlShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_curlshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/gradientSubtractShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_gradientsubtractshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/pressureShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_pressureshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/advectionManualFilteringShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_advectionmanualfilteringshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/vorticityShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_vorticityshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/bloomPrefilterShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_bloomprefiltershader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/displayShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_displayshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/colorShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_colorshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/bloomFinalShader.glsl") @:noCompletion #if display private #end class __ASSET__assets_shaders_bloomfinalshader_glsl extends haxe.io.Bytes {}
@:keep @:image("Assets/LDR_RGB1_0.png") @:noCompletion #if display private #end class __ASSET__assets_ldr_rgb1_0_png extends lime.graphics.Image {}
@:keep @:file("Assets/shaders/splatShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_splatshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/advectionShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_advectionshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/backgroundShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_backgroundshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/displayBloomShadingShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_displaybloomshadingshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/bloomBlurShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_bloomblurshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/displayShadingShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_displayshadingshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/clearShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_clearshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/baseVertexShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_basevertexshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/divergenceShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_divergenceshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/displayBloomShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_displaybloomshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/curlShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_curlshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/gradientSubtractShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_gradientsubtractshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/pressureShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_pressureshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/advectionManualFilteringShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_advectionmanualfilteringshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/vorticityShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_vorticityshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/bloomPrefilterShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_bloomprefiltershader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/displayShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_displayshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/colorShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_colorshader_glsl extends haxe.io.Bytes {}
@:keep @:file("Assets/shaders/bloomFinalShader.glsl") @:noCompletion #if display private #end class __ASSET__shaders_bloomfinalshader_glsl extends haxe.io.Bytes {}
@:keep @:file("") @:noCompletion #if display private #end class __ASSET__manifest_default_json extends haxe.io.Bytes {}



#else

@:keep @:expose('__ASSET__assets_iconfont_ttf') @:noCompletion #if display private #end class __ASSET__assets_iconfont_ttf extends lime.text.Font { public function new () { #if !html5 __fontPath = "assets/iconfont"; #else ascender = 960; descender = -64; height = 1024; numGlyphs = 8; underlinePosition = 0; underlineThickness = 0; unitsPerEM = 1024; #end name = "icomoon"; super (); }}


#end

#if (openfl && !flash)

#if html5
@:keep @:expose('__ASSET__OPENFL__assets_iconfont_ttf') @:noCompletion #if display private #end class __ASSET__OPENFL__assets_iconfont_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__assets_iconfont_ttf ()); super (); }}

#else
@:keep @:expose('__ASSET__OPENFL__assets_iconfont_ttf') @:noCompletion #if display private #end class __ASSET__OPENFL__assets_iconfont_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__assets_iconfont_ttf ()); super (); }}

#end

#end
#end

#end
