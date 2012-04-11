/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flash.swf;

/**
 * Tag values that represent actions or data in a Flash script.
 *
 * @author Edwin Smith
 */
public interface TagValues
{
	// Flash 1 tags
	int stagEnd						= 0;
	int stagShowFrame				= 1;
	int stagDefineShape				= 2;
	int stagFreeCharacter			= 3;
	int stagPlaceObject				= 4;
	int stagRemoveObject			= 5;
	int stagDefineBits				= 6; // id,w,h,colorTab,bits - bitmap referenced by a fill(s)
	int stagDefineButton			= 7; // up obj, down obj, action (URL, Page, ???)
	int stagJPEGTables				= 8; // id,w,h,colorTab,bits - bitmap referenced by a fill(s)
	int stagSetBackgroundColor		= 9;

	int stagDefineFont				= 10;
	int stagDefineText				= 11;
	int stagDoAction				= 12;
	int stagDefineFontInfo			= 13;

	int stagDefineSound				= 14;	// Event sound tags.
	int stagStartSound				= 15;
	// int stagStopSound			= 16;

	int stagDefineButtonSound		= 17;

	int stagSoundStreamHead			= 18;
	int stagSoundStreamBlock		= 19;

	// Flash 2 tags
	int stagDefineBitsLossless		= 20;	// A bitmap using lossless zlib compression.
	int stagDefineBitsJPEG2			= 21;	// A bitmap using an internal JPEG compression table.

	int stagDefineShape2			= 22;
	int stagDefineButtonCxform		= 23;

	int stagProtect					= 24;	// This file should not be importable for editing.

	int stagPathsArePostScript		= 25;	// assume shapes are filled as PostScript style paths

	// Flash 3 tags
	int stagPlaceObject2			= 26;	// The new style place w/ alpha color transform and name.
	int stagRemoveObject2			= 28;	// A more compact remove object that omits the character tag (just depth).

	// This tag is used for RealMedia only
	// int stagSyncFrame			= 29; // OBSOLETE...Handle a synchronization of the display list
	// int stagFreeAll				= 31; // OBSOLETE...Free all of the characters

	int stagDefineShape3			= 32;	// A shape V3 includes alpha values.
	int stagDefineText2				= 33;	// A text V2 includes alpha values.
	int stagDefineButton2			= 34;	// a Flash 3 button that contains color transform and sound info
	// int stagMoveObject			= 34;	// OBSOLETE
	int stagDefineBitsJPEG3			= 35;	// A JPEG bitmap with alpha info.
	int stagDefineBitsLossless2		= 36;	// A lossless bitmap with alpha info.
	// int stagDefineButtonCxform2	= 37;	// OBSOLETE...a button color transform with alpha info

	// int stagDefineMouseTarget	= 38;	// define a sequence of tags that describe the behavio
	int stagDefineSprite			= 39;	// Define a sequence of tags that describe the behavior of a sprite.
	// int stagNameCharacter		= 40;	// OBSOLETE...name a character definition, character id and a string, (used for buttons, bitmaps, sprites and sounds)
	// int stagNameObject			= 41;	// OBSOLETE...name an object instance layer, layer number and a string, clear the name when no longer valid
	int stagProductInfo				= 41;	// a tag command for the Flash Generator customer serial id and cpu information.  [preilly] Repurposed for Flex Audit info.
	// int stagDefineTextFormat		= 42;	// OBSOLETE...define the contents of a text block with formating information
	int stagFrameLabel				= 43;	// A string label for the current frame.
	// int stagDefineButton2		= 44,	// unused, this is defined as 34 above
	int stagSoundStreamHead2		= 45;	// For lossless streaming sound; should not have needed this...
	int stagDefineMorphShape		= 46;	// A morph shape definition
	// int stagFrameTag				= 47;	// OBSOLETE...a tag command for the Flash Generator (WORD duration, STRING label)
	int stagDefineFont2				= 48;	// defines a font with extended information
	// int stagGenCommand			= 49;	// OBSOLETE...a tag command for the Flash Generator intrinsic
	// int stagDefineCommandObj		= 50;	// OBSOLETE...a tag command for the Flash Generator intrinsic Command
	// int stagCharacterSet			= 51;	// OBSOLETE...defines the character set used to store strings
	// int stagFontRef				= 52;   // OBSOLETE...defines a reference to an external font source

	// Flash 4 tags
	int stagDefineEditText			= 37;	// an edit text object (bounds; width; font, variable name)
	// int stagDefineVideo			= 38;	// OBSOLETE...a reference to an external video stream

	// Flash 5 tags
	// int stagDefineBehavior		= 44;   // OBSOLETE...a behavior which can be attached to a movie clip
	// int stagDefineFunction		= 53;   // OBSOLETE...defines a refernece to internals of a function
	// int stagPlaceFunction		= 54;   // OBSOLETE...creates an instance of a function in a thread

	// int stagGenTagObject			= 55;	// OBSOLETE...a generator tag object written to the swf.

	int stagExportAssets			= 56; // export assets from this swf file
	int stagImportAssets			= 57; // import assets into this swf file

	int stagEnableDebugger			= 58; // OBSOLETE...this movie may be debugged

	// Flash 6 tags
	int stagDoInitAction			= 59;

	int stagDefineVideoStream		= 60;
	int stagVideoFrame				= 61;

	int stagDefineFontInfo2			= 62; // just like a font info except adds a language tag
	int stagDebugID					= 63;  // unique id to match up swf to swd
	int stagEnableDebugger2			= 64; //this movie may be debugged (see 59)
    int stagScriptLimits			= 65; // Allow authoring tool to override some AS limits

	// Flash 7 tags
    int stagSetTabIndex				= 66; // allows us to set .tabindex via tags, not actionscript

	// Flash 8 tags
	//int stagDefineShape4			= 67;	// OBSOLETE... use 83

	int stagFileAttributes			= 69;	// FileAttributes defines whole-SWF attributes
											// (must be the FIRST tag after the SWF header)

	int stagPlaceObject3			= 70;	// includes optional surface filter list for object
	int stagImportAssets2			= 71;   // import assets into this swf file using the SHA-1 digest to
											// enable cached cross domain RSL downloads.
	int stagDoABC					= 72;   // embedded .abc (AVM+) bytecode
    int stagDefineFontAlignZones	= 73;   // ADF alignment zones
    int stagCSMTextSettings     	= 74;

    int stagDefineFont3				= 75;	// defines a font with saffron information
	int stagSymbolClass				= 76;
    int stagMetadata                = 77;   // XML blob with comments, description, copyright, etc
    int stagDefineScalingGrid       = 78;   // Scale9 grid
    
    int stagDoABC2                  = 82;   // new in 9, revised ABC version with a name

    int stagDefineShape4            = 83;
	int stagDefineMorphShape2		= 84;	// includes enhanced line style abd gradient properties

	// Flash 9 tags
    int stagDefineSceneAndFrameLabelData = 86;  // new in 9, only works on root timeline
    int stagDefineBinaryData        = 87;
	int stagDefineFontName          = 88;   // adds name and copyright information for a font

	// Flash 10 tags
	int stagDefineFont4             = 91;   // new in 10, embedded cff fonts
    // NOTE: If tag values exceed 255 we need to expand SCharacter::tagCode from a BYTE to a WORD

	String[] names = {
		"End",					// 00
		"ShowFrame",			// 01
		"DefineShape",			// 02
		"FreeCharacter",		// 03
		"PlaceObject",			// 04
		"RemoveObject",			// 05
		"DefineBits",			// 06
		"DefineButton",			// 07
		"JPEGTables",			// 08
		"SetBackgroundColor",	// 09

		"DefineFont",			// 10
		"DefineText",			// 11
		"DoAction",				// 12
		"DefineFontInfo",		// 13

		"DefineSound",			// 14
		"StartSound",			// 15
		"StopSound",			// 16

		"DefineButtonSound",	// 17

		"SoundStreamHead",		// 18
		"SoundStreamBlock",		// 19

		"DefineBitsLossless",	// 20
		"DefineBitsJPEG2",		// 21

		"DefineShape2",			// 22
		"DefineButtonCxform",	// 23

		"Protect",				// 24

		"PathsArePostScript",	// 25

		"PlaceObject2",			// 26
		"27 (invalid)",			// 27
		"RemoveObject2",		// 28

		"SyncFrame",			// 29
		"30 (invalid)",			// 30
		"FreeAll",				// 31

		"DefineShape3",			// 32
		"DefineText2",			// 33
		"DefineButton2",		// 34
		"DefineBitsJPEG3",		// 35
		"DefineBitsLossless2",	// 36
		"DefineEditText",		// 37

		"DefineVideo",			// 38

		"DefineSprite",			// 39
		"NameCharacter",		// 40
		"ProductInfo",			// 41
		"DefineTextFormat",		// 42
		"FrameLabel",			// 43
		"DefineBehavior",		// 44
		"SoundStreamHead2",		// 45
		"DefineMorphShape",		// 46
		"FrameTag",				// 47
		"DefineFont2",			// 48
		"GenCommand",			// 49
		"DefineCommandObj",		// 50
		"CharacterSet",			// 51
		"FontRef",				// 52

		"DefineFunction",		// 53
		"PlaceFunction",		// 54

		"GenTagObject",			// 55

		"ExportAssets",			// 56
		"ImportAssets",			// 57

		"EnableDebugger",		// 58

		"DoInitAction",			// 59
		"DefineVideoStream",	// 60
		"VideoFrame",			// 61

		"DefineFontInfo2",		// 62
		"DebugID", 				// 63
		"EnableDebugger2", 		// 64
        "ScriptLimits", 		// 65

        "SetTabIndex", 			// 66

		"DefineShape4", 		// 67
		"68 (invalid)",			// 68

		"FileAttributes", 		// 69

		"PlaceObject3", 		// 70
		"ImportAssets2", 		// 71

		"DoABC", 				// 72
		"DefineFontAlignZones",	// 73
		"CSMTextSettings",		// 74
		"DefineFont3",			// 75
		"SymbolClass",			// 76
        "Metadata",             // 77
        "ScalingGrid",          // 78
        "79 (invalid)",         // 79
        "80 (invalid)",         // 80
        "81 (invalid)",         // 81
        "DoABC2",               // 82
        "DefineShape4",         // 83        
        "DefineMorphShape2",    // 84
        "85 (invalid)",         // 85
        "DefineSceneAndFrameLabelData",         // 86
        "DefineBinaryData",     // 87
        "DefineFontName",       // 88
        "89 (unknown)  ",       // 89
        "90 (unknown)  ",       // 90
        "DefineFont4",          // 91
        "(invalid)"             // end 
    };
}
