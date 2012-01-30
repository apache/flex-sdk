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

package
{

/**
 *  @private
 *  In some projects, this class is used to link additional classes
 *  into the SWC beyond those that are found by dependency analysis
 *  starting from the classes specified in manifest.xml.
 *  This project has no manifest file (because there are no MXML tags
 *  corresponding to any classes in it) so all the classes linked into
 *  the SWC are found by a dependency analysis starting from the classes
 *  listed here.
 */
internal class CoreClasses
{
	import mx.core.BitmapAsset; BitmapAsset;
	import mx.core.ByteArrayAsset; ByteArrayAsset;
	import mx.core.ButtonAsset; ButtonAsset;
	import mx.core.FontAsset; FontAsset;
	import mx.core.FlexLoader; FlexLoader;
	import mx.core.IFlexModule; IFlexModule;
	import mx.core.MovieClipAsset; MovieClipAsset;
	import mx.core.MovieClipLoaderAsset; MovieClipLoaderAsset;
	import mx.core.SimpleApplication; SimpleApplication;
	import mx.core.SoundAsset; SoundAsset;
	import mx.core.SpriteAsset; SpriteAsset;
	import mx.core.TextFieldAsset; TextFieldAsset;
	import mx.events.ModuleEvent; ModuleEvent;
	import mx.modules.IModuleInfo; IModuleInfo;
	import mx.modules.ModuleBase; ModuleBase;
	import mx.modules.ModuleManager; ModuleManager;
	import mx.resources.IResourceBundle; IResourceBundle;
	import mx.resources.IResourceManager; IResourceManager;
	import mx.resources.IResourceModule; IResourceModule;
	import mx.resources.Locale; Locale;
	import mx.resources.ResourceBundle; ResourceBundle;
	import mx.resources.ResourceManager; ResourceManager;
	// Maintain alphabetical order
}

}
