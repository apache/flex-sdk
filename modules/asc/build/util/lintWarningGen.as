////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

/*
 *
 *          lintWarningGen.as
 *
 *   "lintWarningGen" is an AS3 script which reads an
 *   XML file containing (localized) warning messages, descriptions of 
 *   depricated methods and properties, and descriptions of
 *   event handlers which are no longer automatically invoked,
 *   and creates .cpp, .h and .java files which
 *   describe the same data.
 *
 *   Chris Nuuja
 *   December 30, 2004
 *
 */
import avmplus.*

const CONFIG_FILE:String = "lintConfig.xml";
const SCRIPT_NAME:String = "lintWarningGen";

var config:XML = XML(File.read(CONFIG_FILE));

var IFDEF:String            = String(config.Ifdef);
var XML_INPUT_BASE:String   = String(config.InputFileBase);
var XML_INPUT_FILE:String   = String(config.XmlInputFile);
var OUTPUT_CPP_FILE:String  = String(config.OutputCppFile);
var OUTPUT_JAVA_FILE:String  = String(config.OutputJavaFile);
var OUTPUT_H_FILE:String    = String(config.OutputHFile);
var ARRAY_NAME:String       = String(config.ArrayName);
var LANG_COUNT_NAME:String  = String(config.LangCountName);
var COUNT_NAME:String       = String(config.CountName);
var STRUCT_NAME:String		= String(config.NamespaceName);
var MAIN_INCLUDE:String     = String(config.MainInclude);


class LocalizedLanguage				 // one of these per localzed .xml file
{
	public var language:String;		 // language name
	public var sourceXML:XML;		 // original .xml file
	public var messages:Array;		 // array of WarningMessages, indexed by the WarningMessage's id.
}

class WarningMessage				// one of these per message in the an .xml file
{
	public var id:Number;
	public var label:String;
	public var message:String;
	public var language:String;
	
	public function toString():String { return(" " + id + " " + label + " " + message + " " + language); }
}

var localizedMessages:Object = new Object(); // holds all LocalizedLanguages, indexed by the LocalizedLanguage's language (i.e. localizedMessages["EN"] for english)
var languageNames:Array = [];				 // holds all language names, indexed from 0 to numLanguages-1
var numLanguages:int;
var numWarnings:int;						 // The number of WarningMessages in the master "EN" LocalizedLanguage	

var maxStringLength:int=0;					 // maximum length of any warning string.  Used when generating padding white space for pretty output


for each ( var language:XML in config..Language )
{
	var languageRec:LocalizedLanguage = new LocalizedLanguage();
	var languageName:String = String(language);
	languageRec.language = languageName;
	languageRec.sourceXML = XML(File.read(XML_INPUT_BASE + language + XML_INPUT_FILE));
	languageRec.messages = [];

	for each (var warning:XML in (languageRec.sourceXML)..warning)
	{
		// Remove IMD's <description> elements
		delete warning.description;
		// skip removed elements (for english only.  Don't skip elements which were removed in past but have been re-added)
		if (languageName == "EN" && warning.@removed == true)
			continue;
				
		var message:WarningMessage = new WarningMessage();
		//print("About to dump id: " + warning.@id + " = " + warning);				
		message.id      = Number(warning.@id); 
		message.language= languageName;
		message.label   = String(warning.@label);
		message.message = String(warning);
		
		languageRec.messages[message.id] = message;
		
		maxStringLength = Math.max(maxStringLength, message.label.length);

		// english is the reference language
		if (languageName == "EN")
			numWarnings++;
	}
	
	languageNames.push(languageName);
	localizedMessages[languageName] = languageRec;
}
numLanguages = languageNames.length;

print("Number of Languages="+languageNames.length);
print("got XML");

print("warnings: " + numWarnings);

class WarningTypeRec {
	var label:String;
	var base:String;
	var name:String;
	var isStatic:String;
}

var properties:Array  = [];
var sourceXML:XML = localizedMessages["EN"].sourceXML;
var propList:XMLList = sourceXML.properties.unsupported;
for each (var warningProp:XML in propList)
{
 	var obj:WarningTypeRec = new WarningTypeRec();
	obj.label   = String(warningProp.@label);
	obj.base    = String(warningProp.baseType);
	obj.name    = String(warningProp.propName);
	obj.isStatic = String(warningProp.isStatic);
	properties.push(obj);
}
var methods:Array  = [];
var methodList:XMLList = sourceXML.methods.unsupported;
for each (var warningMethod:XML in methodList)
{
 	var obj:WarningTypeRec = new WarningTypeRec();
	obj.label = String(warningMethod.@label);
	obj.base  = String(warningMethod.baseType);
	obj.name  = String(warningMethod.methodName);
	obj.isStatic = String(warningMethod.isStatic);
	methods.push(obj);
}

var events:Array = [];
var eventList:XMLList = sourceXML.events.unsupported;
for each (var warningEvent:XML in eventList)
{
 	var obj:WarningTypeRec = new WarningTypeRec();
	obj.label = String(warningEvent.@label);
	obj.base  = String(warningEvent.baseType);
	obj.name  = String(warningEvent.methodName);
	obj.isStatic = "false";
	events.push(obj);
}
//print("Inited: " + events.length + " " + methods.length + " " + properties.length);

function compare(a:Object, b:Object):Number
{
	if (a.label < b.label) {
		return -1;
	} else if (a.label > b.label) {
		return 1;
	} else {
		return 0;
	}
}


var s:String;

s = "\
/*\n\
 *\n\
 *  THIS FILE IS AUTO-GENERATED. DO NOT EDIT THIS FILE.\n\
 *  Use the script '" + SCRIPT_NAME + "' to generate this file.\n\
 */\n\
\n\
/*\n\
 *\n\
 *  Licensed to the Apache Software Foundation (ASF) under one or more\n\
 *  contributor license agreements.  See the NOTICE file distributed with\n\
 *  this work for additional information regarding copyright ownership.\n\
 *  The ASF licenses this file to You under the Apache License, Version 2.0\n\
 *  (the \"License\"); you may not use this file except in compliance with\n\
 *  the License.  You may obtain a copy of the License at\n\
 *\n\
 *      http://www.apache.org/licenses/LICENSE-2.0\n\
 *\n\
 *  Unless required by applicable law or agreed to in writing, software\n\
 *  distributed under the License is distributed on an \"AS IS\" BASIS,\n\
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n\
 *  See the License for the specific language governing permissions and\n\
 *  limitations under the License.\n\
 *\n\
\n\
/* \n\
 *  ErrorConstants.java defines the ID's of error messages output\n\
 *  by the compiler.  Localized tables of strings exist for\n\
 *  each language supported.  These ids are used to reference \n\
 *  the error message without regard to language \n\
 */\n\
\n";

s += "package macromedia.asc.embedding;\n";

s += "public class WarningConstants\n";
s += "{\n";
s += "   static final int kNumWarningConstants = " + numWarnings + ";\n";
s += "   static final int kNumPropertyWarnings = " + properties.length + ";\n";
s += "   static final int kNumMethodWarnings = " + methods.length + ";\n";
s += "   static final int kNumEventWarnings = " + events.length + ";\n";
s += "\n";
s += "\n";

for each (var w:WarningMessage in localizedMessages["EN"].messages)
{
	if (w != null)
	{
		s += "      public static final int " + w.label + " = " + w.id + ";\n";
	}
	// else its a BUG!!!!
}


s += "   \n";
s += "   \n";
s += "   \n";
s += "   // enum for common types we need to lookup quickly\n";
s += "   public static final int kVoidType = 0;\n";
s += "   public static final int kObjectType = 1;\n";
s += "   public static final int kFunctionType = 2;\n";
s += "   public static final int kStringType = 3;\n";
s += "   public static final int kNumberType = 4;\n";
s += "   public static final int kBooleanType = 5;\n";
s += "   public static final int kArrayType = 6;\n";
s += "   public static final int kDateType = 7;\n";
s += "   public static final int kMathType = 8;\n";
s += "   public static final int kErrorType = 9;\n";
s += "   public static final int kRegExpType = 10;\n";
s += "   public static final int kDisplayObjectType = 11;\n";
s += "   public static final int kMovieClipType = 12;\n";
s += "   public static final int kTextFieldType = 13;\n";
s += "   public static final int kTextFormatType = 14;\n";
s += "   public static final int kMicrophoneType = 15;\n";
s += "   public static final int kSimpleButtonType = 16;\n";
s += "   public static final int kVideoType = 17;\n";
s += "   public static final int kStyleSheetType = 18;\n";
s += "   public static final int kSelectionType = 19;\n";
s += "   public static final int kColorType = 20;\n";
s += "   public static final int kStageType = 21;\n";
s += "   public static final int kMouseType = 22;\n";
s += "   public static final int kKeyboardType = 23;\n";
s += "   public static final int kSoundType = 24;\n";
s += "   public static final int kSystemType = 25;\n";
s += "   public static final int kXMLType = 26;\n";
s += "   public static final int kXMLSocketType = 27;\n";
s += "   public static final int kXMLListType = 28;\n";
s += "   public static final int kQNameType = 29;\n";
s += "   public static final int kLoadVarsType = 30;\n";
s += "   public static final int kCameraType = 31;\n";
s += "   public static final int kContextMenuType = 32;\n";
s += "   public static final int kContextMenuItemType = 33;\n";
s += "   public static final int kMovieClipLoaderType = 34;\n";
s += "   public static final int kNetStreamType = 35;\n";
s += "   public static final int kAccessibilityType = 36;\n";
s += "   public static final int kActivityEventType = 37;\n";
s += "   public static final int kByteArrayType = 38;\n";
s += "   public static final int kColorTransformType = 39;\n";
s += "   public static final int kDisplayObjectContainerType = 40;\n";
s += "   public static final int kCustomActionsType = 41;\n";
s += "   public static final int kDataEventType = 42;\n";
s += "   public static final int kExternalInterfaceType = 43;\n";
s += "   public static final int kErrorEventType = 44;\n";
s += "   public static final int kEventType = 45;\n";
s += "   public static final int kFocusEventType = 46;\n";
s += "   public static final int kGraphicsType = 47;\n";
s += "   public static final int kBitmapFilterType = 48;\n";
s += "   public static final int kInteractiveObjectType = 49;\n";
s += "   public static final int kKeyboardEventType = 50;\n";
s += "   public static final int kLoaderType = 51;\n";
s += "   public static final int kLoaderInfoType = 52;\n";
s += "   public static final int kLocalConnectionType = 53;\n";
s += "   public static final int kContextMenuEventType = 54;\n";
s += "   public static final int kProductManagerType = 55;\n";
s += "   public static final int kPointType = 56;\n";
s += "   public static final int kProxyType = 57;\n";
s += "   public static final int kProfilerType = 58;\n";
s += "   public static final int kProgressEventType = 59;\n";
s += "   public static final int kRectangleType = 60;\n";
s += "   public static final int kSoundTransformType = 61;\n";
s += "   public static final int kSocketType = 62;\n";
s += "   public static final int kSharedObjectType = 63;\n";
s += "   public static final int kSpriteType = 64;\n";
s += "   public static final int kIMEType = 65;\n";
s += "   public static final int kSWFLoaderInfoType = 66;\n";
s += "   public static final int kTextSnapshotType = 67;\n";
s += "   public static final int kURLLoaderType = 68;\n";
s += "   public static final int kURLStreamType = 69;\n";
s += "   public static final int kURLRequestType = 70;\n";
s += "   public static final int kXMLDocumentType = 71;\n";
s += "   public static final int kXMLNodeType = 72;\n";
s += "   public static final int kNetConnectionType = 73;\n";
s += "   public static final int kSyncEventType = 74;\n";
s += "   public static final int kBitmapDataType = 75;\n";
s += "   public static final int kXMLUIType = 76;\n";
s += "   public static final int kFileReferenceListType = 77;\n";
s += "   public static final int kFileReferenceType = 78;\n";
s += "   public static final int kNumDefaultTypes =  79;\n";

s += "   \n";
s += "   public static class AscWarning\n";
s += "   {\n";
s += "      int code;  // enum used to identify or lookup this message/problem\n";
s += "      String pWarning; // a particular warning message    '\n";
s += "      AscWarning(int c, String s) { code = c; pWarning = s; }\n";
s += "   } ;\n";
s += "   \n";
s += "   public static class AscWarningInstance\n";
s += "   {\n";
s += "      int code;			// enum identifying the warning to use if we find a match for baseType and name\n";
s += "      int baseType;		// type of the base in the member expression we are looking for \n";
s += "      boolean is_static;  // is a static property or method\n";
s += "      String name;		// name of the property or method we are looking for\n";
s += "      AscWarningInstance(int c, int b, String s, boolean isStatic) { code = c; baseType = b; name = s; is_static = isStatic; }\n";
s += "   } ;\n";
s += "   \n";
s += "   \n";

s += "   public static void initWarningConstants() \n";
s += "   {\n";
for ( var i:int=0; i < languageNames.length; i++ )
{
	s += "      initWarningConstants"+languageNames[i]+"();\n";
}
s += "   }\n\n";

var englishMessages:Array = localizedMessages["EN"].messages;
for ( i=0; i < languageNames.length; i++ )
{
	s += "   static final AscWarning[] warningConstants"+languageNames[i]+"= new AscWarning[kNumWarningConstants]; \n";
	s += "\n";
	s += "   private static void initWarningConstants"+languageNames[i]+"() \n";
	s += "   {\n";
	s += "      int index=0;\n";
	
	var thisLang:String = languageNames[i];
	var messages:Array = localizedMessages[thisLang].messages;
	if (thisLang == "EN")
	{
		for (var j:int = 0; j<messages.length; j++)
		{
			if (messages[j] != undefined)
				s += "        warningConstantsEN[index++] = new AscWarning(" + messages[j].label + ", \"" + quote(messages[j].message) + "\" );\n";
		}
	}
	else
	{
		
		for (j=0; j<messages.length; j++)
		{
			if ( messages[j] != undefined && englishMessages[ messages[j].id ] != undefined ) // don't add if it was removed from the English list
			{
				s += "        warningConstants"+languageNames[i]+"[index++] = new AscWarning(" + messages[j].label + ", \"" + quote(messages[j].message) + "\" );\n";
			}
		}
		// add the new ones recently added to English but not yet translated
		for (j=0;j<englishMessages.length; j++)
		{
			if (englishMessages[j] != undefined && messages[j] == undefined)
			{
				s += "        warningConstants"+languageNames[i]+"[index++] = new AscWarning(" + englishMessages[j].label + ", \"" + quote(englishMessages[j].message) + "\" );\n";
			}
		}
	}
	s += "   };\n\n";
}
s += "    static final AscWarningInstance[] unsupportedProperties =\n";
s += "    {\n";
for (var x:int=0; x<properties.length; x++)
{
	s += "        new AscWarningInstance(" + properties[x].label+ ", " + properties[x].base + ", \"" + quote(properties[x].name) + "\", " + properties[x].isStatic + " ),\n";
}
s += "        };\n\n";


s += "    static final AscWarningInstance[] unsupportedMethods =\n";
s += "    {\n";
for (x=0; x<methods.length; x++)
{
	s += "        new AscWarningInstance(" + methods[x].label+ ", " + methods[x].base + ", \"" + quote(methods[x].name) + "\", " + methods[x].isStatic + " ),\n";
}
s += "        };\n\n";


s += "    static final AscWarningInstance[] unsupportedEvents =\n";
s += "    {\n";
for (x=0; x<events.length; x++)
{
	s += "        new AscWarningInstance(" + events[x].label+ ", " + events[x].base + ", \"" + quote(events[x].name) + "\", false ),\n";
}
s += "        };\n\n";
s += "        public static final AscWarning[][] " + ARRAY_NAME + " =\n";
s += "        {\n";

for (x=0; x < languageNames.length; x++ )
{
	s += "              warningConstants" + languageNames[x] + ",\n";
}

s += "        };\n\n";

s += "};\n";

File.write(OUTPUT_JAVA_FILE, s);



// finally, update the enabledWarnings.xml file:
// ------------------------------------------------------------------------------------------------------------------
var enabledWarnings:XML = 
<AS2LintWarnings>
	<warnings></warnings>
</AS2LintWarnings>;
englishMessages = englishMessages.sort(compare);
for (var j:int = 0; j<englishMessages.length; j++)
{
	if (englishMessages[j] != undefined)
	{
		var thisLabel:String = String(englishMessages[j].label);
		if (thisLabel.indexOf("kWarning_") == 0 && thisLabel.indexOf("_specific") == -1 && thisLabel.indexOf("kWarning_Event") == -1)
		{
			enabledWarnings.warnings.warning += 
				<warning id={englishMessages[j].id} enabled="true"  label={englishMessages[j].label}>{englishMessages[j].message}</warning>;
		}
	}
}
s = "<?xml version='1.0' encoding='utf-8' standalone='no' ?>\n";
s += enabledWarnings.toXMLString()
File.write("EnabledWarnings.xml", s);
// --------------------------------------------------------------------------------------------------------------------

print("lintWarningGen completed successfully");

function pad(s:Object, len:int):String
{
	var s2:String = String(s);
	while (s2.length < len) {
		s2 += ' ';
	}
	return s2;
}

function quote(s:String):String
{
	var r:String = "";
	for (var i:int=0; i<s.length; i++) {
		var c:String = s.charAt(i);
		if (c == '"') {
			r += "\\";
		}
		r += c;
	}
	return r;
}
		


/*
s += "\n";
s += "#ifndef " + IFDEF + "\n";
s += "#define " + IFDEF + "\n";
s += "\n";
s += "namespace asc {\n";
s += "namespace v1 {\n\n";
s += "struct " + STRUCT_NAME + " {\n";
s += "   static const int " + LANG_COUNT_NAME + " = " + numLanguages + ";\n";
s += "   static const int kNumWarningConstants = " + numWarnings + ";\n";
s += "   static const int kNumPropertyWarnings = " + properties.length + ";\n";
s += "   static const int kNumMethodWarnings = " + methods.length + ";\n";
s += "   static const int kNumEventWarnings = " + events.length + ";\n";
s += "\n";
s += "   typedef enum\n";
s += "   {\n";

var first = true;

for (var i=0; i<messages.length; i++)
{
	if ( messages[i].language == "EN" )
	{
		if (!first) {
			s += ",\n";
		}
		s += "      " + pad(messages[i].label, maxStringLength) + " = " + messages[i].id;
		first = false;
	}
}

s += "\n";
s += "   } WarningCode;\n\n";


//s += "    }\n";
s += "\n";
s += "   // enum for common types we need to lookup quickly\n";
s += "   typedef enum {\n";
s += "      kVoidType = 0,\n";
s += "      kObjectType = 1,\n";
s += "      kFunctionType = 2,\n";
s += "      kStringType = 3,\n";
s += "      kNumberType = 4,\n";
s += "      kBooleanType = 5,\n";
s += "      kArrayType = 6,\n";
s += "      kDateType = 7,\n";
s += "      kMathType = 8,\n";
s += "      kErrorType = 9,\n";
s += "      kRegExpType = 10,\n";
s += "      kDisplayObjectType = 11,\n";
s += "      kMovieClipType = 12,\n";
s += "      kTextFieldType = 13,\n";
s += "      kTextFormatType = 14,\n";
s += "      kMicrophoneType = 15,\n";
s += "      kSimpleButtonType = 16,\n";
s += "      kVideoType = 17,\n";
s += "      kStyleSheetType = 18,\n";
s += "      kSelectionType = 19,\n";
s += "      kColorType = 20,\n";
s += "      kStageType = 21,\n";
s += "      kMouseType = 22,\n";
s += "      kKeyboardType = 23,\n";
s += "      kSoundType = 24,\n";
s += "      kSystemType = 25,\n";
s += "      kXMLType = 26,\n";
s += "      kXMLSocketType = 27,\n";
s += "      kXMLListType = 28,\n";
s += "      kQNameType = 29,\n";
s += "      kLoadVarsType = 30,\n";
s += "      kCameraType = 31,\n";
s += "      kContextMenuType = 32,\n";
s += "      kContextMenuItemType = 33,\n";
s += "      kMovieClipLoaderType = 34,\n";
s += "      kNetStreamType = 35,\n";
s += "      kAccessibilityType = 36,\n";
s += "      kActivityEventType = 37,\n";
s += "      kByteArrayType = 38,\n";
s += "      kColorTransformType = 39,\n";
s += "      kDisplayObjectContainerType = 40,\n";
s += "      kCustomActionsType = 41,\n";
s += "      kDataEventType = 42,\n";
s += "      kExternalInterfaceType = 43,\n";
s += "      kErrorEventType = 44,\n";
s += "      kEventType = 45,\n";
s += "      kFocusEventType = 46,\n";
s += "      kGraphicsType = 47,\n";
s += "      kBitmapFilterType = 48,\n";
s += "      kInteractiveObjectType = 49,\n";
s += "      kKeyboardEventType = 50,\n";
s += "      kLoaderType = 51,\n";
s += "      kLoaderInfoType = 52,\n";
s += "      kLocalConnectionType = 53,\n";
s += "      kContextMenuEventType = 54,\n";
s += "      kProductManagerType = 55,\n";
s += "      kPointType = 56,\n";
s += "      kProxyType = 57,\n";
s += "      kProfilerType = 58,\n";
s += "      kProgressEventType = 59,\n";
s += "      kRectangleType = 60,\n";
s += "      kSoundTransformType = 61,\n";
s += "      kSocketType = 62,\n";
s += "      kSharedObjectType = 63,\n";
s += "      kSpriteType = 64,\n";
s += "      kIMEType = 65,\n";
s += "      kSWFLoaderInfoType = 66,\n";
s += "      kTextSnapshotType = 67,\n";
s += "      kURLLoaderType = 68,\n";
s += "      kURLStreamType = 69,\n";
s += "      kURLRequestType = 70,\n";
s += "      kXMLDocumentType = 71,\n";
s += "		kXMLNodeType= 72,\n";
s += "      kNetConnectionType = 73,\n";
s += "      kSyncEventType = 74,\n";
s += "      kBitmapDataType = 75,\n";
s += "      kXMLUIType = 76,\n";
s += "      kFileReferenceListType = 77,\n";
s += "      kFileReferenceType = 78,\n";
s += "      kNumDefaultTypes = kFileReferenceType+1\n"
s += "   } TypeCode;\n";

s += "\n";
s += "   typedef struct {\n";
s += "      WarningCode code;		// enum used to identify or lookup this message/problem\n";
s += "      std::string pWarning;	// a particular warning message \n";
s += "   } AscWarning;\n";
s += "\n";
s += "   typedef struct {\n";
s += "      WarningCode code;		// enum identifying the warning to use if we find a match for baseType and name\n";
s += "      TypeCode	baseType;	// type of the base in the member expression we are looking for \n";
s += "      std::string name;		// name of the property or method we are looking for\n";
s += "      bool        is_static;  //  is a static property or method\n";
s += "   } AscWarningInstance;\n";
s += "\n";
s += "   static AscWarning*			allWarningConstants[" + numLanguages + "]; // table of all language tables.\n";
for ( var i=0; i < languageNames.length; i++ )
{
	s += "   static AscWarning  warningConstants"+ languageNames[i] + "[" + numWarnings + "];\n";
}
s += "   static AscWarningInstance	unsupportedProps[kNumPropertyWarnings];  // table of all unsupported AS2 properties\n";
s += "   static AscWarningInstance	unsupportedMethods[kNumMethodWarnings];	 // table of all unsupported AS2 methods\n";
s += "   static AscWarningInstance	unsupportedEvents[kNumEventWarnings];	 // table of all AS2 event handlers which no longer get called automatically.\n";
s += "	};\n";

s += "}\n";
s += "}\n";
s += "#endif //" + IFDEF + "\n";
s += "\n";



File.write(OUTPUT_H_FILE, s);

s += "\n";
s += "#include \"" + MAIN_INCLUDE + "\"\n";
s += "\n";
s += "namespace asc {\n";
s += "namespace v1 {\n";
//s += "namespace " + STRUCT_NAME + "{\n"; // Uncomment if we want a new namespace for just the errors
for ( var i=0; i < languageNames.length; i++ )
{
	s += "        " + STRUCT_NAME + "::AscWarning " + STRUCT_NAME + "::" + "warningConstants"+ languageNames[i] + "[" + COUNT_NAME + "] =\n";
	s += "        {\n";
	for (var j=0; j<messages.length; j++)
	{
		if ( messages[j].language == languageNames[i] && removedWarnings[messages[j].id] == undefined )
		{
			s += "            { " + messages[j].label + ", \"" + quote(messages[j].message) + "\" },\n";
		}
	}
	// If the current output language is not English add on each of the newly added error strings that have not been localized
	for (var k=0; k < nonLocalizedLanguages.length; k++)
	{
		if ( languageNames[i] != "EN" )
		{
			s += "            { " + nonLocalizedLanguages[k].label + ", \"" + quote(nonLocalizedLanguages[k].message) + "\" },\n";	
		}
	}
	s += "        };\n\n";
	
}
s += "        " + STRUCT_NAME + "::AscWarningInstance " + STRUCT_NAME + "::unsupportedProps[" + properties.length + "] =\n";
s += "        {\n";
for (var x=0; x<properties.length; x++)
{
 	s += "            { " + properties[x].label + ", " + properties[x].base + ", \"" + quote(properties[x].name) + "\", " + properties[x].isStatic + " },\n";
}
s += "        };\n\n";


s += "        " + STRUCT_NAME + "::AscWarningInstance " + STRUCT_NAME + "::unsupportedMethods[" + methods.length + "] =\n";
s += "        {\n";
for (var x=0; x<methods.length; x++)
{
 	s += "            { " + methods[x].label + ", " + methods[x].base + ", \"" + quote(methods[x].name) + "\", " + methods[x].isStatic + " },\n";
}
s += "        };\n\n";


s += "        " + STRUCT_NAME + "::AscWarningInstance " + STRUCT_NAME + "::unsupportedEvents[" + events.length + "] =\n";
s += "        {\n";
for (var x=0; x<events.length; x++)
{
 	s += "            { " + events[x].label + ", " + events[x].base + ", \"" + quote(events[x].name) + "\", false },\n";
}
s += "        };\n\n";
s += "        " + STRUCT_NAME + "::AscWarning* " + STRUCT_NAME + "::" + ARRAY_NAME + "[" + LANG_COUNT_NAME + "] =\n";
s += "        {\n";

for ( var i=0; i < languageNames.length; i++ )
{
	s += "              " + STRUCT_NAME + "::warningConstants" + languageNames[i] + ",\n";
}
s += "        };\n";

s += "}\n";
s += "}\n";

File.write(OUTPUT_CPP_FILE, s);
*/
