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
import flash.utils.describeType;

import mx.core.ApplicationGlobals;
import mx.core.FlexVersion;
import mx.core.IFlexDisplayObject;

import mx.core.IFontContextComponent;
import mx.core.IInvalidating;
import mx.core.IUITextField;
import mx.core.mx_internal;
import mx.core.UIComponent;
import mx.effects.EffectManager;
import mx.managers.SystemManager;
import mx.modules.ModuleManager;
import mx.styles.IStyleClient;
import mx.styles.StyleProxy;
import mx.utils.NameUtil;
import mx.utils.object_proxy;
import mx.utils.OrderedObject;

use namespace mx_internal;
use namespace object_proxy;

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
        var className:String = object.className;
        var advancedObject:IAdvancedStyleClient = object as IAdvancedStyleClient;

        var typeHierarchy:OrderedObject = getUnqualifiedTypeHierarchy(object);
        var types:Array = typeHierarchy.propertyList;
        var typeCount:int = types.length;
        var classDecls:Array = null;

        if (!StyleManager.hasAdvancedSelectors())
        {
            classDecls = StyleManager.typeSelectorCache[className];
            if (classDecls)
                return classDecls;
        }

        classDecls = [];

        // Loop over the type hierarhcy starting at the base type and work
        // down the chain of subclasses.
        for (var i:int = typeCount - 1; i >= 0; i--)
        {
            var type:String = types[i].toString();
            if (StyleManager.hasAdvancedSelectors() && advancedObject != null)
            {
                var decls:Object = StyleManager.getStyleDeclarations(type);
                if (decls)
                {
                    var matchingDecls:Array = getMatchingStyleDeclarations(decls, advancedObject);
                    classDecls = classDecls.concat(matchingDecls);
                }
            }
            else
            {
                var decl:CSSStyleDeclaration = StyleManager.getStyleDeclaration(type);
                if (decl)
                    classDecls.push(decl);
            }
        }

        if (StyleManager.hasAdvancedSelectors() && advancedObject != null)
        {        
            // Advanced selectors may mean more than one match per type so we
            // sort based on specificity, but preserving the declaration
            // order for equal selectors.
            classDecls = sortOnSpecificity(classDecls);
        }
        else
        {
            // Cache the simple type declarations for this class 
            StyleManager.typeSelectorCache[className] = classDecls;
        }

        return classDecls;
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
        var advancedObject:IAdvancedStyleClient = object as IAdvancedStyleClient;
        var styleDeclaration:CSSStyleDeclaration = null;

        var globalClassSelectors:Array = [];
        var styleName:Object = object.styleName;
        if (styleName)
        {
            if (styleName is CSSStyleDeclaration)
            {
                // Get the styles referenced by the styleName property.
                globalClassSelectors.push(CSSStyleDeclaration(styleName));
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
                // Get the styles referenced by the styleName property             
                var styleNames:Array = styleName.split(/\s+/);
                n = styleNames.length;
                for (i = 0; i < n; i++)
                {
                    if (styleNames[i].length)
                    {
                        styleDeclaration = StyleManager.getStyleDeclaration("." + styleNames[i]);
                        if (styleDeclaration)
                            globalClassSelectors.push(styleDeclaration);
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

        var styleDeclarations:Array = null;

        // If we have an advanced style client, we handle this separately
        // because of the considerably more complex selector matches...
        if (StyleManager.hasAdvancedSelectors() && advancedObject != null)
        {
            styleDeclarations = [];

            // Check for global class selector that matches our styleName(s)
            if (globalClassSelectors.length > 0)
            {
                styleDeclarations = styleDeclarations.concat(globalClassSelectors);
            }

            // Check for a global pseudo selector that matches our current state.
            if (advancedObject.currentState)
            {
                styleDeclaration = StyleManager.getStyleDeclaration(":" + advancedObject.currentState);
                if (styleDeclaration)
                    styleDeclarations.push(styleDeclaration);
            }

            // Check for a global id selector that matches our current id
            if (advancedObject.id)
            {
                styleDeclaration = StyleManager.getStyleDeclaration("#" + advancedObject.id);
                if (styleDeclaration)
                    styleDeclarations.push(styleDeclaration);
            }

            // If we had global selectors, concatenate them with our type
            // selectors and resort by specificity...
            if (styleDeclarations.length > 0)
            {
                styleDeclarations = advancedObject.getClassStyleDeclarations().concat(styleDeclarations);
                styleDeclarations = sortOnSpecificity(styleDeclarations);
            }
            else
            {
                // We only have type selectors
                styleDeclarations = advancedObject.getClassStyleDeclarations();
            }

            n = styleDeclarations.length;
            for (i = 0; i < n; i++)
            {
                styleDeclaration = styleDeclarations[i];
                
                inheritChain =
                    styleDeclaration.addStyleToProtoChain(inheritChain, uicObject);
    
                nonInheritChain =
                    styleDeclaration.addStyleToProtoChain(nonInheritChain, uicObject);

                if (styleDeclaration.effects)
                    object.registerEffects(styleDeclaration.effects);
            }
        }
        // Otherwise we use the legacy Flex 3 logic for simple selectors.
        else
        {
            // Working backwards up the list, the next element in the
            // search path is the type selector
            styleDeclarations = object.getClassStyleDeclarations();
            n = styleDeclarations.length;
            for (i = 0; i < n; i++)
            {
                styleDeclaration = styleDeclarations[i];
                
                inheritChain =
                    styleDeclaration.addStyleToProtoChain(inheritChain, uicObject);
    
                nonInheritChain =
                    styleDeclaration.addStyleToProtoChain(nonInheritChain, uicObject);
    
                if (styleDeclaration.effects)
                    object.registerEffects(styleDeclaration.effects);
            }

            // Next are the class selectors
            n = globalClassSelectors.length;
            for (i = 0; i < n; i++)
            {
                styleDeclaration = globalClassSelectors[i];
                if (styleDeclaration)
                {
                    inheritChain =
                        styleDeclaration.addStyleToProtoChain(inheritChain, uicObject);
    
                    nonInheritChain =
                        styleDeclaration.addStyleToProtoChain(nonInheritChain, uicObject);
    
                    if (styleDeclaration.effects)
                        object.registerEffects(styleDeclaration.effects);
                }
            }
        }

        // Finally, we'll add the in-line styles
        // to the head of the proto chain.
        
        styleDeclaration = object.styleDeclaration;

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

    /**
     *  @private
     */
    public static function isAssignableToType(object:IAdvancedStyleClient, type:String):Boolean
    {
        return getUnqualifiedTypeHierarchy(object)[type] != null;
    }

    /**
     *  @private  
     *  Find all matching style declarations for an IAdvancedStyleClient
     *  component. The result is unsorted in terms of specificity, but the
     *  declaration order is preserved.
     *
     *  @param declarations - an Array of declarations to be searched for
     *  matches.
     *  @param object - an instance of the component to match.
     *
     *  @return An unsorted Array of matching style declarations for the given
     *  subject.
     */
    private static function getMatchingStyleDeclarations(declarations:Object,
            object:IAdvancedStyleClient):Array // of CSSStyleDeclaration
    {
        var matchingDecls:Array = [];

        // Find the subset of declarations that match this component
        for (var selector:String in declarations)
        {
            var decl:CSSStyleDeclaration = declarations[selector];
            if (decl.isMatch(object))
                matchingDecls.push(decl);
        }

        return matchingDecls;
    }

    /**
     *  @private 
     *  This should only be called once per type so avoiding a dependency on
     *  DescribeTypeCache and using describeType() directly.
     */
    private static function getUnqualifiedTypeHierarchy(object:IStyleClient):OrderedObject
    {
        var className:String = object.className;
        var hierarchy:OrderedObject = StyleManager.typeHierarchyCache[className];
        if (!hierarchy)
        {
            hierarchy = new OrderedObject();
            hierarchy[className] = true;

            var typeDescription:XML = describeType(object);
            var superClasses:XMLList = typeDescription..extendsClass;
            for each (var superClass:XML in superClasses)
            {
                var type:String = superClass.@type.toString();
                if (isStopClass(type))
                    break;
    
                type = NameUtil.getUnqualifiedClassName(type);
                hierarchy[type] = true;
            }
            StyleManager.typeHierarchyCache[className] = hierarchy;
        }

        return hierarchy;
    }

    /**
     *  @private
     *  Our style type hierarhcy stops at UIComponent, UITextField or
     *  GraphicElement, not Object.
     */  
    private static function isStopClass(value:String):Boolean
    {
        return value == null ||
               value == "mx.core::UIComponent" ||
               value == "mx.core::UITextField" ||
               value == "mx.graphics.graphicsClasses::GraphicElement";
    }

    /**
     *  @private
     *  Sort algorithm to order style declarations by specificity. Note that 
     *  Array.sort() is not used as it does not employ a stable algorithm and
     *  CSS requires the order of equal style declaration to be preserved.
     */ 
    private static function sortOnSpecificity(decls:Array):Array 
    {
        // TODO: Copied algorithm from Group.sortOnLayer as a temporary measure.
        // We may consider replacing this insertion sort with an efficient but
        // stable merge sort or the like if many style declarations need to
        // sorted.
        var len:Number = decls.length;
        var tmp:CSSStyleDeclaration;

        if (len <= 1)
            return decls;

        for (var i:int = 1; i < len; i++)
        {
            for (var j:int = i; j > 0; j--)
            {
                if (decls[j].specificity < decls[j-1].specificity)
                {
                    tmp = decls[j];
                    decls[j] = decls[j-1];
                    decls[j-1] = tmp;
                }
                else
                {
                    break;
                }
            }
        }

        return decls; 
    }
}

}
