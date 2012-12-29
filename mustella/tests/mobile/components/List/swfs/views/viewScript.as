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
//
// ActionScript file for methods that are shared by the different views
// for example creating a set of data items.
//

import comps.DataItem;

import mx.collections.ArrayList;

import renderers.*;

/*
// TODO: Need cleaner images, this is for demo purposes only
[Embed(source="../assets/resicons/androidIcon1.png")][Bindable]public var androidIcon1:Class;
[Embed(source="../assets/resicons/androidIcon2.png")][Bindable]public var androidIcon2:Class;
[Embed(source="../assets/resicons/androidIcon3.png")][Bindable]public var androidIcon3:Class;
[Embed(source="../assets/resicons/androidIcon4.png")][Bindable]public var androidIcon4:Class;
[Embed(source="../assets/resicons/androidIcon5.png")][Bindable]public var androidIcon5:Class;
[Embed(source="../assets/resicons/androidIcon6.png")][Bindable]public var androidIcon6:Class;
[Embed(source="../assets/resicons/androidIcon7.png")][Bindable]public var androidIcon7:Class;
[Embed(source="../assets/resicons/androidIcon8.png")][Bindable]public var androidIcon8:Class;
[Embed(source="../assets/resicons/androidIcon9.png")][Bindable]public var androidIcon9:Class;
[Embed(source="../assets/resicons/androidIcon10.png")][Bindable]public var androidIcon10:Class;
[Embed(source="../assets/resicons/androidIcon11.png")][Bindable]public var androidIcon11:Class;
[Embed(source="../assets/resicons/androidIcon12.png")][Bindable]public var androidIcon12:Class;
[Embed(source="../assets/resicons/androidIcon13.png")][Bindable]public var androidIcon13:Class;
[Embed(source="../assets/resicons/androidIcon14.png")][Bindable]public var androidIcon14:Class;
[Embed(source="../assets/resicons/androidIcon15.png")][Bindable]public var androidIcon15:Class;
[Embed(source="../assets/resicons/androidIcon16.png")][Bindable]public var androidIcon16:Class;
[Embed(source="../assets/resicons/androidIcon17.png")][Bindable]public var androidIcon17:Class;
[Embed(source="../assets/resicons/androidIcon18.png")][Bindable]public var androidIcon18:Class;
[Embed(source="../assets/resicons/androidIcon19.png")][Bindable]public var androidIcon19:Class;
[Embed(source="../assets/resicons/androidIcon20.png")][Bindable]public var androidIcon20:Class;
[Embed(source="../assets/resicons/androidIcon21.png")][Bindable]public var androidIcon21:Class;
[Embed(source="../assets/resicons/androidIcon22.png")][Bindable]public var androidIcon22:Class;
[Embed(source="../assets/resicons/androidIcon23.png")][Bindable]public var androidIcon23:Class;
[Embed(source="../assets/resicons/androidIcon24.png")][Bindable]public var androidIcon24:Class;
[Embed(source="../assets/resicons/androidIcon25.png")][Bindable]public var androidIcon25:Class;
[Embed(source="../assets/resicons/androidIcon26.png")][Bindable]public var androidIcon26:Class;
[Embed(source="../assets/resicons/androidIcon27.png")][Bindable]public var androidIcon27:Class;
[Embed(source="../assets/resicons/androidIcon28.png")][Bindable]public var androidIcon28:Class;
[Embed(source="../assets/resicons/androidIcon29.png")][Bindable]public var androidIcon29:Class;
[Embed(source="../assets/resicons/androidIcon30.png")][Bindable]public var androidIcon30:Class;
[Embed(source="../assets/resicons/androidIcon31.png")][Bindable]public var androidIcon31:Class;
[Embed(source="../assets/resicons/androidIcon32.png")][Bindable]public var androidIcon32:Class;
[Embed(source="../assets/resicons/androidIcon33.png")][Bindable]public var androidIcon33:Class;
[Embed(source="../assets/resicons/androidIcon34.png")][Bindable]public var androidIcon34:Class;
[Embed(source="../assets/resicons/androidIcon35.png")][Bindable]public var androidIcon35:Class;
[Embed(source="../assets/resicons/androidIcon36.png")][Bindable]public var androidIcon36:Class;
[Embed(source="../assets/resicons/androidIcon37.png")][Bindable]public var androidIcon37:Class;
[Embed(source="../assets/resicons/androidIcon38.png")][Bindable]public var androidIcon38:Class;
[Embed(source="../assets/resicons/androidIcon39.png")][Bindable]public var androidIcon39:Class;
[Embed(source="../assets/resicons/androidIcon40.png")][Bindable]public var androidIcon40:Class;
[Embed(source="../assets/resicons/androidIcon41.png")][Bindable]public var androidIcon41:Class;
[Embed(source="../assets/resicons/androidIcon42.png")][Bindable]public var androidIcon42:Class;
[Embed(source="../assets/resicons/androidIcon43.png")][Bindable]public var androidIcon43:Class;
[Embed(source="../assets/resicons/androidIcon44.png")][Bindable]public var androidIcon44:Class;
[Embed(source="../assets/resicons/androidIcon45.png")][Bindable]public var androidIcon45:Class;
[Embed(source="../assets/resicons/androidIcon46.png")][Bindable]public var androidIcon46:Class;
[Embed(source="../assets/resicons/androidIcon47.png")][Bindable]public var androidIcon47:Class;
[Embed(source="../assets/resicons/androidIcon48.png")][Bindable]public var androidIcon48:Class;
[Embed(source="../assets/resicons/androidIcon49.png")][Bindable]public var androidIcon49:Class;
[Embed(source="../assets/resicons/androidIcon50.png")][Bindable]public var androidIcon50:Class;
[Embed(source="../assets/resicons/androidIcon51.png")][Bindable]public var androidIcon51:Class;
[Embed(source="../assets/resicons/androidIcon52.png")][Bindable]public var androidIcon52:Class;
[Embed(source="../assets/resicons/androidIcon53.png")][Bindable]public var androidIcon53:Class;
[Embed(source="../assets/resicons/androidIcon54.png")][Bindable]public var androidIcon54:Class;
*/

/**
 * An embedded image of a 100x100 grid part
 */
[Embed(source="../../../../../../Assets/Images/GridImages/100x100.png")]
[Bindable]
public var gridImage:Class;


/**
 * Returns a set of items for snapping
 */
protected function createData():ArrayList
{
	var tempArray:Array = new Array(20);
	
	for (var i:int = 0; i < 50; i++){
		var newItem:Object = new Object();
		newItem.label = "item - "+i;
		tempArray[i] = (newItem);
	}				
	return new ArrayList(tempArray);	
}


/**
 * Returns a set of items of the same size.
 */
public function createIdenticalItems(numItems:int, objMinor:int = 0, objMajor:int = 0, axis:String = 'none'):ArrayList {
    
    var tempArray:Array = new Array(numItems);
    
    for (var i:int = 0; i < numItems; i++){
        var newItem:DataItem = new DataItem();
        newItem.myItemIndex = i;
        newItem.majorAxis = axis;
        newItem.minorSize = objMinor;
        newItem.majorSize = objMajor;
        tempArray[i] = (newItem);
    }
    
    return new ArrayList(tempArray);
}	 

/**
 * Returns a string of real world sample contact list data with
 * letters in between each group of names.
 * 
 * @param includeLetters - set to true if you want single letter item's before names
 */
public function createContactListItems(includeLetters:Boolean = false):ArrayList {
    var names:Array = [
        "A",
        "AdaFN Case",
        "AjaFN Juneka",
        "AlaFN Sinis",
        "AleFN Auchler",
        "AliFN Gjahernie",
        "AllFN Blackstill",
        "AndFN Huwon",
        "AndFN Lee",
        "AndFN Phone",
        "AngFN Goh",
        "AniFN Villas",
        "AnnFN Koa",
        "AnnFN Xei",
        "AnnFN Webster",
        "AsaFN Hakoshi",
        "B",
        "BeaFN Trent",
        "BerFN Perry",
        "BriFN Telintelo",
        "BryFN Esriant",
        "BuzFN",
        "C",
        "CarFN K",
        "CatFN Hanny",
        "CatFN Lee",
        "CheFN Hazy",
        "ChiFN Alonaku",
        "ChrFN Chuw",
        "ChrFN King",
        "ChrFN Chan",
        "ChrFN Lee",
        "ChrFN Wong",
        "CliFN Lee",
        "CorFN Lucerne",
        "D",
        "DadFN",
        "DanFN Muich",
        "DavFN Kentii",
        "DeeFN Submarine",
        "DocFN Mike Smith",
        "E",
        "EmiFN Hee",
        "EriFN Fifa",
        "EriFN Shawn",
        "EthFN Codean",
        "EvtFN Godfather",
        "G",
        "GabFN Leann",
        "GarFN Tsoa",
        "GraFN Le",
        "GraFN Yusai",
        "GraFN", 
        "GreFN Branch",
        "GreFN Jessef",
        "H",
        "HanFN Melike",
        "HarFN Banshee",
        "HemFN S",
        "HemFN Sikers",
        "HenFN Tsoi",
        "HilFN Ngen",
        "HoiFN Wang",
        "HolFN Mettle",
        "HomFN",
        "I",
        "InbFN Lu",
        "J",
        "JamFN Wang",
        "JarFN Messet",
        "JasFN Enlepeo",
        "JasFN Szee",
        "JayFN Kheal",
        "JefFN Chang",
        "JenFN Kwon",
        "JenFN Tilley",
        "JerFN Astolly",
        "JesFN De la C",
        "JesFN Feinberg",
        "JesFN Lee",
        "JesFN Mintul",
        "JioFN Lee",
        "JoaFN Ladd",
        "JoaFN Chow",
        "JoeFN Moe",
        "JonFN Silo",
        "JorFN Kosinksi",
        "JulFN Gillman",
        "JusFN Holiand",
        "K",
        "KaiFN Hanhsion",
        "KakFN Tsui",
        "KenFN Coborn",
        "KetFN Anjeliev",
        "KevFN Lee",
        "KevFN Phi",
        "KuaFN Ke",
        "KylFN Jenifo",
        "L",
        "LauFN Holland",
        "LauFN Pari",
        "LizFN Carlisle",
        "LydFN Wang",
        "M",
        "MarFN Hadie",
        "MatFN Chancy",
        "MatFN Chancy",
        "MeeFN Place",
        "MegFN Miyago",
        "MicFN Annerheim",
        "MicFN Pelosi",
        "MicFN Yee",
        "MomFN",
        "MosFN Sossal",
        "MukFN Soribela",
        "N",
        "NanFN We",
        "NatFN Gitter",
        "NavFN Shasu",
        "NayFN Kee",
        "NicFN Braan",
        "NoaFN Fickleson",
        "P",
        "PauFN Thornton",
        "PetFN Faraway",
        "PetFN Hoessel",
        "PraFN Saingh",
        "PunFN Goh",
        "R",
        "RayFN Teata",
        "RobFN Branfly",
        "RoxFN",
        "RyaFN Chag",
        "RyaFN Fenderson",
        "RyaFN Fenderson",
        "RyaFN Shandon",
        "S",
        "SaaFN Peetl",
        "SanFN Janido",
        "SanFN Lee",
        "SanFN Me",
        "SarFN Gilroy",
        "SatFN Pari",
        "SedFN",
        "ShaFN Teata",
        "ShaFN Faik",
        "SheFN Lee",
        "SivFN Shandon",
        "SonFN Yee",
        "SteFN Lund",
        "SteFN Tsai",
        "SteFN Bourgoise",
        "SteFN Shanti",
        "SteFN Tso",
        "SteFN Tswo",
        "SueFN Ria",
        "SusFN Hadie",
        "T",
        "TarFN Fundland",
        "ThoFN Soley",
        "TomFN Kaitket",
        "TomFN Sanders",
        "TonFN Boine",
        "TorFN McDettler",
        "TreFN Seton",
        "U",
        "UncFN Moses",
        "V",
        "VanFN Chee",
        "VerFN Chu",
        "VicFN Le",
        "VivFN Shanci",
        "W",
        "WenFN Kelvin",
        "WilFN Lee",
        "WofFN Stongbit",
        "X",
        "Xi Wein",
        "Y",
        "YanFN Miselword",
        "Z",
        "ZekFN Chastitie"];
    
    var output:Array = new Array();
    for (var i:int = 0; i < names.length; i++)
    {
        if ((names[i] as String).length == 1){ // letter item
            if (includeLetters)
                output.push(names[i]);
        } else { // name item
            output.push(names[i]);
        }
    }
    
    return new ArrayList(output);
}