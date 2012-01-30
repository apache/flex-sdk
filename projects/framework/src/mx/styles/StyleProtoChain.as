////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2004-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.styles
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.system.ApplicationDomain;
import flash.utils.getQualifiedClassName;
import flash.utils.getQualifiedSuperclassName;
import mx.core.ApplicationGlobals;
import mx.core.FlexVersion;
import mx.core.IFlexDisplayObject;
import mx.core.IFontContextComponent;
import mx.core.IInvalidating;
import mx.core.IFlexModuleFactory;
import mx.core.IUITextField;
import mx.core.mx_internal;
import mx.core.UIComponent;
import mx.effects.EffectManager;
import mx.managers.SystemManager;
import mx.modules.ModuleManager;
import mx.styles.IStyleClient;
import mx.styles.StyleProxy;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 *  This is an all-static class with methods for building the protochains
 *  that Flex uses to look up CSS style properties.
 */
public class StyleProtoChain
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  The inheritingStyles and nonInheritingStyles properties
     *  are initialized to this empty Object.
     *  This allows the getStyle() and getStyle()
     *  methods to simply access inheritingStyles[] and nonInheritingStyles[]
     *  without needing to first check whether those objects exist.
     *  If they were simply initialized to {}, we couldn't determine
     *  whether the style chain has already been built or not.
     */
    public static var STYLE_UNINITIALIZED:Object = {};

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Implements the getClassStyleDeclarations() logic
     *  for UIComponent and TextGraphicElement.
     *  The 'object' parameter will be one or the other.
     */
    public static function getClassStyleDeclarations(object:IStyleClient):Array
    {
        var myApplicationDomain:ApplicationDomain;

        var factory:IFlexModuleFactory = ModuleManager.getAssociatedFactory(object);
        if (factory != null)
        {
            myApplicationDomain = ApplicationDomain(factory.info()["currentDomain"]);
        }
        else
        {
            var myRoot:DisplayObject = SystemManager.getSWFRoot(object);
            if (!myRoot)
                return [];
            myApplicationDomain = myRoot.loaderInfo.applicationDomain;
        }

        var className:String = getQualifiedClassName(object)
        className = className.replace("::", ".");
        
        var cache:Array = StyleManager.typeSelectorCache[className];
        if (cache)
            return cache;
                
        var decls:Array = [];
        var classNames:Array = [];
        var caches:Array = [];
        var declcache:Array = [];

        while (className != null &&
               className != "mx.core.UIComponent" &&
               className != "mx.core.UITextField" &&
               className != "flex.graphics.graphicsClasses.GraphicElement")
        {
            var s:CSSStyleDeclaration;
            cache = StyleManager.typeSelectorCache[className];
            if (cache)
            {
                decls = decls.concat(cache);
                break;
            }

            s = StyleManager.getStyleDeclaration(className);
            
            if (s)
            {
                decls.unshift(s);
                // We found one so the next set define the selectors
                // for this found class and its ancestors.
                // Save the old list and start a new list.
                classNames.push(className);
                caches.push(classNames);
                declcache.push(decls);
                decls = [];
                classNames = [];
            }
            else
            {
                classNames.push(className);
            }

            try
            {
                className = getQualifiedSuperclassName(
                    myApplicationDomain.getDefinition(className));
                className = className.replace("::", ".");
            }
            catch(e:ReferenceError)
            {
                className = null;
            }
        }

        caches.push(classNames);
        declcache.push(decls);
        decls = [];
        
        while (caches.length)
        {
            classNames = caches.pop();
            decls = decls.concat(declcache.pop());
            while (classNames.length)
            {
                StyleManager.typeSelectorCache[classNames.pop()] = decls;
            }
        }

        return decls;
    }

    /**
     *  @private
     *  Implements the initProtoChain() logic for UIComponent and TextGraphicElement.
     *  The 'object' parameter will be one or the other.
     */
    public static function initProtoChain(object:IStyleClient):void
    {
        var n:int;
        var i:int;

        var uicObject:UIComponent = object as UIComponent;
        
        var classSelectors:Array = [];
        var styleName:Object = object.styleName;
        if (styleName)
        {
            if (styleName is CSSStyleDeclaration)
            {
                // Get the style sheet referenced by the styleName property.
                classSelectors.push(CSSStyleDeclaration(styleName));
            }
            else if (styleName is IFlexDisplayObject || styleName is IStyleClient)
            {
                // If the styleName property is a UIComponent, then there's a
                // special search path for that case.
                StyleProtoChain.initProtoChainForUIComponentStyleName(object);
                return;
            }
            else if (styleName is String)
            {
                // Get the style sheets referenced by the styleName property             
                var styleNames:Array = styleName.split(/\s+/);
                n = styleNames.length;
                for (i = 0; i < n; i++)
                {
                    if (styleNames[i].length)
                    {
                        classSelectors.push(
                            StyleManager.getStyleDeclaration("." + styleNames[i]));
                    }
                }
            }
        }

        // To build the proto chain, we start at the end and work forward.
        // Referring to the list at the top of this function, we'll start
        // by getting the tail of the proto chain, which is:
        //  - for non-inheriting styles, the global style sheet
        //  - for inheriting styles, my parent's style object
        var nonInheritChain:Object = StyleManager.stylesRoot;

        if (nonInheritChain && nonInheritChain.effects)
            object.registerEffects(nonInheritChain.effects);

        // TODO: Unify concept of parent for UIComponents and GraphicElements
        var p:IStyleClient;
        if (uicObject)
            p = uicObject.parent as IStyleClient;
        else if ("elementHost" in object) // object is TextGraphicElement
            p = object["elementHost"] as IStyleClient;

        if (p)
        {
            var inheritChain:Object = p.inheritingStyles;
            if (inheritChain == StyleProtoChain.STYLE_UNINITIALIZED)
                inheritChain = nonInheritChain;
        }
        else
        {
            // Pop ups inheriting chain starts at Application instead of global.
            // This allows popups to grab styles like themeColor that are
            // set on Application.
            if (uicObject && uicObject.isPopUp)
            {
                var owner:DisplayObjectContainer = uicObject._owner;
                if (FlexVersion.compatibilityVersion >= FlexVersion.VERSION_3_0 && 
                    owner && owner is IStyleClient)
                {
                    inheritChain = IStyleClient(owner).inheritingStyles;
                }
                else
                {
                    inheritChain = ApplicationGlobals.application.inheritingStyles;
                }
            }
            else
            {
                inheritChain = StyleManager.stylesRoot;
            }
        }

        // Working backwards up the list, the next element in the
        // search path is the type selector
        var typeSelectors:Array = object.getClassStyleDeclarations();
        n = typeSelectors.length;
        for (i = 0; i < n; i++)
        {
            var typeSelector:CSSStyleDeclaration = typeSelectors[i];
            
            inheritChain =
                typeSelector.addStyleToProtoChain(inheritChain, uicObject);

            nonInheritChain =
                typeSelector.addStyleToProtoChain(nonInheritChain, uicObject);

            if (typeSelector.effects)
                object.registerEffects(typeSelector.effects);
        }

        // Next are the class selectors
        n = classSelectors.length;
        for (i = 0; i < n; i++)
        {
            var classSelector:CSSStyleDeclaration = classSelectors[i];
            if (classSelector)
            {
                inheritChain =
                    classSelector.addStyleToProtoChain(inheritChain, uicObject);

                nonInheritChain =
                    classSelector.addStyleToProtoChain(nonInheritChain, uicObject);

                if (classSelector.effects)
                    object.registerEffects(classSelector.effects);
            }
        }

        // Finally, we'll add the in-line styles
        // to the head of the proto chain.
        
        var styleDeclaration:CSSStyleDeclaration = object.styleDeclaration;
        
        object.inheritingStyles =
            styleDeclaration ?
            styleDeclaration.addStyleToProtoChain(inheritChain, uicObject) :
            inheritChain;

        object.nonInheritingStyles =
            styleDeclaration ?
            styleDeclaration.addStyleToProtoChain(nonInheritChain, uicObject) :
            nonInheritChain;
    }

    /**
     *  @private
     *  If the styleName property points to a UIComponent, then we search
     *  for stylable properties in the following order:
     *  
     *  1) Look for inline styles on this object
     *  2) Look for inline styles on the styleName object
     *  3) Look for class selectors on the styleName object
     *  4) Look for type selectors on the styleName object
     *  5) Look for type selectors on this object
     *  6) Follow the usual search path for the styleName object
     *  
     *  If this object doesn't have any type selectors, then the
     *  search path can be simplified to two steps:
     *  
     *  1) Look for inline styles on this object
     *  2) Follow the usual search path for the styleName object
     */
    public static function initProtoChainForUIComponentStyleName(
                                    obj:IStyleClient):void
    {
        var styleName:IStyleClient = IStyleClient(obj.styleName);
        var target:DisplayObject = obj as DisplayObject;
        
        // Push items onto the proto chain in reverse order, beginning with
        // 6) Follow the usual search path for the styleName object
        var nonInheritChain:Object = styleName.nonInheritingStyles;
        if (!nonInheritChain ||
            nonInheritChain == StyleProtoChain.STYLE_UNINITIALIZED)
        {
            nonInheritChain = StyleManager.stylesRoot;

            if (nonInheritChain.effects)
                obj.registerEffects(nonInheritChain.effects);
        }

        var inheritChain:Object = styleName.inheritingStyles;
        if (!inheritChain ||
            inheritChain == StyleProtoChain.STYLE_UNINITIALIZED)
        {
            inheritChain = StyleManager.stylesRoot;
        }

        // If there's no type selector on this object, then we can collapse
        // 6 steps to 2 (see above)
        var typeSelectors:Array = obj.getClassStyleDeclarations();
        var n:int = typeSelectors.length;
        
        // If we are a StyleProxy and we aren't building the protochain from
        // our type selectors, then we need to build the protochain from
        // the styleName since styleName.nonInheritingStyles is always null.
        if (styleName is StyleProxy)
        {   
            if (n == 0)
            {   
                // 4) Look for type selectors on the styleName object
                // 3) Look for class selectors on the styleName object
                // 2) Look for inline styles on the styleName object
                nonInheritChain = addProperties(nonInheritChain, styleName, false);
            }
            target = StyleProxy(styleName).source as DisplayObject;
        }
        
        for (var i:int = 0; i < n; i++)
        {
            var typeSelector:CSSStyleDeclaration = typeSelectors[i];

            // If there's no *inheriting* type selector on this object, then we
            // can still collapse 6 steps to 2 for the inheriting properties.

            // 5) Look for type selectors on this object
            inheritChain = typeSelector.addStyleToProtoChain(inheritChain, target); 

            // 4) Look for type selectors on the styleName object
            // 3) Look for class selectors on the styleName object
            // 2) Look for inline styles on the styleName object
            inheritChain = addProperties(inheritChain, styleName, true);

            // 5) Look for type selectors on this object
            nonInheritChain = typeSelector.addStyleToProtoChain(nonInheritChain, target);   

            // 4) Look for type selectors on the styleName object
            // 3) Look for class selectors on the styleName object
            // 2) Look for inline styles on the styleName object
            nonInheritChain = addProperties(nonInheritChain, styleName, false);

            if (typeSelector.effects)
                obj.registerEffects(typeSelector.effects);
        }
        
        // 1) Look for inline styles on this object
        
        obj.inheritingStyles =
            obj.styleDeclaration ? 
            obj.styleDeclaration.addStyleToProtoChain(inheritChain, target) :
            inheritChain;
        
        obj.nonInheritingStyles =
            obj.styleDeclaration ? 
            obj.styleDeclaration.addStyleToProtoChain(nonInheritChain, target) :
            nonInheritChain;
    }
    
    /**
     *  See the comment for the initProtoChainForUIComponentStyleName
     *  function. The comment for that function includes a six-step
     *  sequence. This sub-function implements the following pieces
     *  of that sequence:
     *  
     *  2) Look for inline styles on the styleName object
     *  3) Look for class selectors on the styleName object
     *  4) Look for type selectors on the styleName object
     *  
     *   This piece is broken out as a separate function so that it
     *  can be called recursively when the styleName object has a
     *  styleName property is itself another UIComponent.
     */
    private static function addProperties(chain:Object, obj:IStyleClient,
                                          bInheriting:Boolean):Object
    {
        // Only use a filter map if styleName is a StyleProxy and we are building the nonInheritingStyles chain
        var filterMap:Object = obj is StyleProxy && !bInheriting ? StyleProxy(obj).filterMap : null;
        
        // StyleProxy's usually have sources that are DisplayObject's, but a StyleProxy can also have 
        // another StyleProxy as it's source (Example: CalendarLayout's source is a StyleProxy for DateChooser, 
        // whose style is a StyleProxy for DateField)
        
        // The way we use target is a bit hacky, but we always assume that styles (if pointed to DisplayObjects)
        // are the parent (or atleast an ancestor), and we rely on this down the line (such as in 
        // DataGridColumn.addStyleToProtoChain)
        var curObj:IStyleClient = obj;
        while (curObj is StyleProxy)
        {
            curObj = StyleProxy(curObj).source;
        }
        var target:DisplayObject = curObj as DisplayObject;
        
        // 4) Add type selectors 
        var typeSelectors:Array = obj.getClassStyleDeclarations();
        var n:int = typeSelectors.length;
        for (var i:int = 0; i < n; i++)
        {
            var typeSelector:CSSStyleDeclaration = typeSelectors[i];
            chain = typeSelector.addStyleToProtoChain(chain, target, filterMap);

            if (typeSelector.effects)
                obj.registerEffects(typeSelector.effects);
        }

        // 3) Add class selectors
        var styleName:Object = obj.styleName;
        if (styleName)
        {
            var classSelectors:Array = [];
            
            if (typeof(styleName) == "object")
            {
                if (styleName is CSSStyleDeclaration)
                {
                    // Get the style sheet referenced by the styleName property.
                    classSelectors.push(CSSStyleDeclaration(styleName));
                }
                else
                {               
                    // If the styleName property is another UIComponent, then
                    // recursively add type selectors, class selectors, and
                    // inline styles for that UIComponent
                    chain = addProperties(chain, IStyleClient(styleName),
                                          bInheriting);
                }
            }
            else
            {
                // Get the style sheets referenced by the styleName property             
                var styleNames:Array = styleName.split(/\s+/);
                for (var c:int=0; c < styleNames.length; c++)
                {
                    if (styleNames[c].length) {
                        classSelectors.push(StyleManager.getStyleDeclaration("." + 
                            styleNames[c]));
                    }
                }
            }

            for (i = 0; i < classSelectors.length; i++)
            {
                var classSelector:CSSStyleDeclaration = classSelectors[i];
                if (classSelector)
                {
                    chain = classSelector.addStyleToProtoChain(chain, target, filterMap);
                    if (classSelector.effects)
                        obj.registerEffects(classSelector.effects);
                }
            }
        
        }       

        // 2) Add inline styles 
        if (obj.styleDeclaration)
            chain = obj.styleDeclaration.addStyleToProtoChain(chain, target, filterMap);

        return chain;
    }

    /**
     *  @private
     */
    public static function initTextField(obj:IUITextField):void
    {
        // TextFields never have any inline styles or type selector, so
        // this is an optimized version of the initObject function (above)
        var styleName:Object = obj.styleName;
        var classSelectors:Array = [];
        
        if (styleName)
        {
            if (typeof(styleName) == "object")
            {
                if (styleName is CSSStyleDeclaration)
                {
                    // Get the style sheet referenced by the styleName property.
                    classSelectors.push(CSSStyleDeclaration(styleName));
                }
                else if (styleName is StyleProxy)
                {
                    obj.inheritingStyles =
                        IStyleClient(styleName).inheritingStyles;
                        
                    obj.nonInheritingStyles = addProperties(StyleManager.stylesRoot, IStyleClient(styleName), false);
                    
                    return;
                }
                else
                {               
                    // styleName points to a UIComponent, so just set
                    // this TextField's proto chains to be the same
                    // as that UIComponent's proto chains.          
                    obj.inheritingStyles =
                        IStyleClient(styleName).inheritingStyles;
                    obj.nonInheritingStyles =
                        IStyleClient(styleName).nonInheritingStyles;
                    return;
                }
            }
            else
            {                   
                // Get the style sheets referenced by the styleName property             
                var styleNames:Array = styleName.split(/\s+/);
                for (var c:int=0; c < styleNames.length; c++)
                {
                    if (styleNames[c].length) {
                        classSelectors.push(StyleManager.getStyleDeclaration("." + 
                            styleNames[c]));
                    }
                }    
            }
        }
        
        // To build the proto chain, we start at the end and work forward.
        // We'll start by getting the tail of the proto chain, which is:
        //  - for non-inheriting styles, the global style sheet
        //  - for inheriting styles, my parent's style object
        var inheritChain:Object = IStyleClient(obj.parent).inheritingStyles;
        var nonInheritChain:Object = StyleManager.stylesRoot;
        if (!inheritChain)
            inheritChain = StyleManager.stylesRoot;
                
        // Next are the class selectors
        for (var i:int = 0; i < classSelectors.length; i++)
        {
            var classSelector:CSSStyleDeclaration = classSelectors[i];
            if (classSelector)
            {
                inheritChain =
                    classSelector.addStyleToProtoChain(inheritChain, DisplayObject(obj));

                nonInheritChain =
                    classSelector.addStyleToProtoChain(nonInheritChain, DisplayObject(obj));
            }
        }
        
        obj.inheritingStyles = inheritChain;
        obj.nonInheritingStyles = nonInheritChain;
    }

    /**
     *  @private
     *  Implements the setStyle() logic for UIComponent and TextGraphicElement.
     *  The 'object' parameter will be one or the other.
     */
    public static function setStyle(object:IStyleClient, styleProp:String,
                                    newValue:*):void
    {
        if (styleProp == "styleName")
        {
            // Let the setter handle this one, see UIComponent.
            object.styleName = newValue;

            // Short circuit, because styleName isn't really a style.
            return;
        }

        if (EffectManager.getEventForEffectTrigger(styleProp) != "")
            EffectManager.setStyle(styleProp, object);

        // If this object didn't previously have any inline styles,
        // then regenerate its proto chain
        // (and the proto chains of its descendants).
        var isInheritingStyle:Boolean =
            StyleManager.isInheritingStyle(styleProp);
        var isProtoChainInitialized:Boolean =
            object.inheritingStyles != StyleProtoChain.STYLE_UNINITIALIZED;
        var valueChanged:Boolean = object.getStyle(styleProp) != newValue;
        
        if (!object.styleDeclaration)
        {
            object.styleDeclaration = new CSSStyleDeclaration();
           
            object.styleDeclaration.mx_internal::setStyle(styleProp, newValue);

            // If inheritingStyles is undefined, then this object is being
            // initialized and we haven't yet generated the proto chain.  To
            // avoid redundant work, don't bother to create the proto chain here.
            if (isProtoChainInitialized)
                object.regenerateStyleCache(isInheritingStyle);
        }
        else
        {
            object.styleDeclaration.mx_internal::setStyle(styleProp, newValue);
        }

        if (isProtoChainInitialized && valueChanged)
        {
            object.styleChanged(styleProp);
            object.notifyStyleChangeInChildren(styleProp, isInheritingStyle);
        }
    }

    /**
     *  @private
     *  Implements the styleChanged() logic for UIComponent and TextGraphicElement.
     *  The 'object' parameter will be one or the other.
     */
    public static function styleChanged(object:IInvalidating, styleProp:String):void
    {
        // If font changed, then invalidateProperties so
        // we can re-create the text field in commitProperties
        // TODO: Should hasFontContextChanged() be added to IFontContextComponent?
        if (object is IFontContextComponent &&
            "hasFontContextChanged" in object &&
            object["hasFontContextChanged"]())
        {
            object.invalidateProperties();
        }
        
        // Check to see if this is one of the style properties
        // that is known to affect layout.
        if (!styleProp ||
            styleProp == "styleName" ||
            StyleManager.isSizeInvalidatingStyle(styleProp))
        {
            // This style property change may affect the layout of this
            // object. Signal the LayoutManager to re-measure the object.
            object.invalidateSize();
        }

        // TODO: Should initThemeColor() be in some interface?
        if (!styleProp || 
            styleProp == "styleName" ||
            styleProp == "themeColor")
        {
            if ("initThemeColor" in object)
                object["initThemeColor"]();
        }
        
        object.invalidateDisplayList();

        // TODO: Unify concept of parent for UIComponents and GraphicElements
        var parent:IInvalidating;
        if (object is UIComponent)
            parent = UIComponent(object).parent as IInvalidating;
        else if ("elementHost" in object) // object is TextGraphicElement
            parent = object["elementHost"] as IInvalidating;

        if (parent)
        {
            if (StyleManager.isParentSizeInvalidatingStyle(styleProp))
                parent.invalidateSize();

            if (StyleManager.isParentDisplayListInvalidatingStyle(styleProp))
                parent.invalidateDisplayList();
        }
    }
}

}
