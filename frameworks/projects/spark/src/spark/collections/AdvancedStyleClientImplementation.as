import mx.core.IFlexModuleFactory;
import mx.core.UIComponent;
import mx.styles.AdvancedStyleClient;
import mx.styles.CSSStyleDeclaration;
import mx.styles.IAdvancedStyleClient;
import mx.styles.IStyleManager2;
import mx.styles.StyleProtoChain;
import mx.utils.NameUtil;

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

private var _advancedStyleClient:AdvancedStyleClient_;

private function initAdvancedStyleClient():void
{
    _advancedStyleClient = new AdvancedStyleClient_(this);
    _advancedStyleClient.addEventListener("allStylesChanged", dispatchIfListenersExist);
}

private function dispatchIfListenersExist(event:Event):void
{
    if(hasEventListener(event.type))
        dispatchEvent(event);
}

public function get id():String
{
    return _advancedStyleClient.id;
}

public function set id(value:String):void
{
    _advancedStyleClient.id = value;
}

public function get styleParent():IAdvancedStyleClient
{
    return _advancedStyleClient.styleParent;
}

public function set styleParent(parent:IAdvancedStyleClient):void
{
    _advancedStyleClient.styleParent = parent;
}

public function stylesInitialized():void
{
    _advancedStyleClient.stylesInitialized();
}

public function matchesCSSState(cssState:String):Boolean
{
    return _advancedStyleClient.matchesCSSState(cssState);
}

public function matchesCSSType(cssType:String):Boolean
{
    return _advancedStyleClient.matchesCSSType(cssType);
}

public function hasCSSState():Boolean
{
    return _advancedStyleClient.hasCSSState();
}

public function get className():String
{
    return _advancedStyleClient.className;
}

public function get inheritingStyles():Object
{
    return _advancedStyleClient.inheritingStyles;
}

public function set inheritingStyles(value:Object):void
{
    _advancedStyleClient.inheritingStyles = value;
}

public function get nonInheritingStyles():Object
{
    return _advancedStyleClient.nonInheritingStyles;
}

public function set nonInheritingStyles(value:Object):void
{
    _advancedStyleClient.nonInheritingStyles = value;
}

public function get styleDeclaration():CSSStyleDeclaration
{
    return _advancedStyleClient.styleDeclaration;
}

public function set styleDeclaration(value:CSSStyleDeclaration):void
{
    _advancedStyleClient.styleDeclaration = value;
}

public function getStyle(styleProp:String):*
{
    return _getStyle(styleProp);
}

public function setStyle(styleProp:String, newValue:*):void
{
    _setStyle(styleProp, newValue);
}

public function clearStyle(styleProp:String):void
{
    _advancedStyleClient.clearStyle(styleProp);
}

public function getClassStyleDeclarations():Array
{
    return _advancedStyleClient.getClassStyleDeclarations();
}

public function notifyStyleChangeInChildren(styleProp:String, recursive:Boolean):void
{
    _advancedStyleClient.notifyStyleChangeInChildren(styleProp, recursive)
}

public function regenerateStyleCache(recursive:Boolean):void
{
    _advancedStyleClient.regenerateStyleCache(recursive);
}

public function registerEffects(effects:Array):void
{
    _advancedStyleClient.registerEffects(effects);
}

public function get styleName():Object
{
    return _advancedStyleClient.styleName;
}

public function set styleName(value:Object):void
{
    _advancedStyleClient.styleName = value;
}

public function styleChanged(styleProp:String):void
{
    _advancedStyleClient.addEventListener(styleProp + "Changed", dispatchIfListenersExist);
    _styleChanged(styleProp);
    _advancedStyleClient.removeEventListener(styleProp + "Changed", dispatchIfListenersExist);
}

public function get styleManager():IStyleManager2
{
    return _advancedStyleClient.styleManager;
}

public function get moduleFactory():IFlexModuleFactory
{
    return _advancedStyleClient.moduleFactory;
}

public function set moduleFactory(factory:IFlexModuleFactory):void
{
    _advancedStyleClient.moduleFactory = factory;
}

public function initialized(document:Object, id:String):void
{
    _advancedStyleClient.initialized(document, id);
}