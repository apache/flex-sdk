////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.styles
{

import flash.events.*;

import mx.core.FlexGlobals;
import mx.core.IFlexDisplayObject;
import mx.core.IFlexModule;
import mx.core.IFlexModuleFactory;
import mx.core.IMXMLObject;
import mx.core.UIComponent;
import mx.styles.*;
import mx.utils.NameUtil;

/**
 *  A base class that can be used
 *  when implementing an object that uses the
 *  <code>IAdvancedStyleClient</code> interface.  The base class supplies
 *  implementations of the methods and properties required for an object
 *  to participate in the style subsystem.
 *
 *  <p>In addition to the <code>IAdvancedStyleClient</code> interface,
 *  this object also implements the <code>IFlexModule</code> and
 *  <code>IMXMLObject</code> interfaces. The <code>IMXMLObject</code>
 *  interface contains an <code>initialized</code> method that is called
 *  when the class is instantiated using an MXML declaration.
 *  The  implementation of the <code>initialized</code> method provided
 *  by this base class will add the class instance to the document object
 *  that contains the MXML declaration. For more details, see the description
 *  of the <code>initilized</code> method.</p>
 *
 *  @see mx.styles.IAdvancedStyleClient
 *  @see #initialized
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class AdvancedStyleClient extends EventDispatcher
                        implements IAdvancedStyleClient,IFlexModule,IMXMLObject
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function AdvancedStyleClient()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Keeps track of the setStyles() calls that have been deferred
     *  until a moduleFactory is set.
     */
    private var deferredSetStyles:Object;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  className
    //----------------------------------

    /**
     *  The name of the component class.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get className():String
    {
        return NameUtil.getUnqualifiedClassName(this);
    }

    //----------------------------------
    //  inheritingStyles
    //----------------------------------

    private var _inheritingStyles:Object = StyleProtoChain.STYLE_UNINITIALIZED;

    /**
     *  An object containing the inheritable styles for this non-visual
     *  style client instance.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get inheritingStyles():Object
    {
        return _inheritingStyles;
    }

    /**
     *  @private
     */
    public function set inheritingStyles(value:Object):void
    {
        _inheritingStyles= value;
    }

    //----------------------------------
    //  nonInheritingStyles
    //----------------------------------

    /**
     *  @private
     *  Storage for the nonInheritingStyles property.
     */
    private var _nonInheritingStyles:Object
                                        = StyleProtoChain.STYLE_UNINITIALIZED;

    [Inspectable(environment="none")]

    /**
     *  The beginning of this component's chain of non-inheriting styles.
     *  The <code>getStyle()</code> method simply accesses
     *  <code>nonInheritingStyles[styleName]</code> to search the entire
     *  prototype-linked chain.
     *  This object is set up by <code>initProtoChain()</code>.
     *  Developers typically never need to access this property directly.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get nonInheritingStyles():Object
    {
        return _nonInheritingStyles;
    }

    /**
     *  @private
     */
    public function set nonInheritingStyles(value:Object):void
    {
        _nonInheritingStyles = value;
    }

    //----------------------------------
    //  styleDeclaration
    //----------------------------------

    /**
     *  @private
     */
    private var _styleDeclarationVar:CSSStyleDeclaration;

    [Inspectable(environment="none")]

    /**
     *  The style declaration that holds the inline styles declared by this
     *  object.
     *
     *  @see mx.styles.CSSStyleDeclaration
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get styleDeclaration():CSSStyleDeclaration
    {
        return _styleDeclarationVar;
    }

    /**
     *  @private
     */
    public function set styleDeclaration(value:CSSStyleDeclaration):void
    {
        _styleDeclarationVar = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Returns the StyleManager instance used by this component.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get styleManager():IStyleManager2
    {
        return StyleManager.getStyleManager(moduleFactory);
    }

    private function setDeferredStyles():void
    {
        if (!deferredSetStyles)
            return;

        for (var styleProp:String in deferredSetStyles)
        {
            StyleProtoChain.setStyle(
                                this, styleProp, deferredSetStyles[styleProp]);
        }

        deferredSetStyles = null;
    }

    [Bindable(style="true")]

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function getStyle(styleProp:String):*
    {
        // If a moduleFactory has not be set yet, first check for any deferred
        // styles. If there are no deferred styles or the styleProp is not in
        // the deferred styles, the look in the proto chain.
        if (!moduleFactory)
        {
            if (deferredSetStyles && deferredSetStyles[styleProp] !== undefined)
                return deferredSetStyles[styleProp];
        }

        return styleManager.inheritingStyles[styleProp] ?
                   (_inheritingStyles    ? _inheritingStyles[styleProp]    
                                         : undefined) :
                   (_nonInheritingStyles ? _nonInheritingStyles[styleProp] 
                                         : undefined);
    }

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function setStyle(styleProp:String, newValue:*):void
    {
        // If there is no module factory then defer the set
        // style until a module factory is set.
        if (moduleFactory)
        {
            StyleProtoChain.setStyle(this, styleProp, newValue);
        }
        else
        {
            if (!deferredSetStyles)
                deferredSetStyles = new Object();

            deferredSetStyles[styleProp] = newValue;
        }
    }

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function clearStyle(styleProp:String):void
    {
        setStyle(styleProp, undefined);
    }

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function getClassStyleDeclarations():Array
    {
        return StyleProtoChain.getClassStyleDeclarations(this);
    }

    /**
     *  Propagates style changes to the children of this style client
     *  instance.  A non-visual style client (i.e. a style client that is
     *  not a DisplayObject) does not have children, therefore this method
     *  does not do anything for non-visual style clients.
     *
     *  @param styleProp Name of the style property.
     *
     *  @param recursive Whether to propagate the style changes to the
     *  children's children.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function notifyStyleChangeInChildren(
                                    styleProp:String, recursive:Boolean):void
    {
    }

    /**
     *  Sets up the internal style cache values so that the
     *  <code>getStyle()</code>
     *  method functions.
     *
     *  @param recursive Regenerate the proto chains of the children.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function regenerateStyleCache(recursive:Boolean):void
    {
        StyleProtoChain.initProtoChain(this);
    }

    /**
     *  Registers the EffectManager as one of the event listeners
     *  for each effect event.
     *
     *  @param effects An Array of Strings of effect names.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function registerEffects(effects:Array /* of String */):void
    {
    }

    /**
     *  Detects changes to style properties. When any style property is set,
     *  Flex calls the <code>styleChanged()</code> method,
     *  passing to it the name of the style being set.
     *
     *  <p>This is an advanced method that you might override
     *  when creating a subclass of <code>AdvancedStyleClient</code>.
     *  When you create a custom class,
     *  you can override the <code>styleChanged()</code> method
     *  to check the style name passed to it, and handle the change
     *  accordingly.
     *  This lets you override the default behavior of an existing style,
     *  or add your own custom style properties.</p>
     *
     *  @param styleProp The name of the style property, or null if all
     *  styles for this
     *  style client have changed.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function styleChanged(styleProp:String):void
    {
        if (styleProp && (styleProp != "styleName"))
        {
            if (hasEventListener(styleProp + "Changed"))
                dispatchEvent(new Event(styleProp + "Changed"));
        }
        else
        {
            if (hasEventListener("allStylesChanged"))
                dispatchEvent(new Event("allStylesChanged"));
        }
    }

    /**
     *  @private
     *  Storage for the styleName property.
     */
    private var _styleName:Object;
                    // It can be String, CSSStyleDeclaration, or UIComponent.

    [Inspectable(category="General")]

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get styleName():Object
            // Return type can be String, CSSStyleDeclaration, or UIComponent.
    {
        return _styleName;
    }

    /**
     *  @private
     */
    public function set styleName(value:Object):void
                // The value can be String, CSSStyleDeclaration, or UIComponent.
    {
        if (_styleName === value)
            return;

        _styleName = value;

        styleChanged("styleName");
    }

    /**
     *  @private
     */
    private var _styleParent:IAdvancedStyleClient;

    //----------------------------------
    //  IAdvancedStyleClient methods
    //----------------------------------

    //----------------------------------
    //  id
    //----------------------------------

    /**
     *  @private
     */
    private var _id:String;

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get id():String
    {
        return _id;
    }

    /**
     *  @private
     */
    public function set id(value:String):void
    {
        _id = value;
    }

    /**
     *  A component's parent is used to evaluate descendant selectors.
     *  A parent must also be an IAdvancedStyleClient to participate in
     *  advanced style declarations.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get styleParent():IAdvancedStyleClient
    {
        return  _styleParent;
    }

    public function set styleParent(styleParent:IAdvancedStyleClient):void
    {
        _styleParent= styleParent;
    }

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function stylesInitialized():void
    {
    }

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */

    public function matchesCSSState(cssState:String):Boolean
    {
        return false;
    }

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */

    public function matchesCSSType(cssType:String):Boolean
    {
        return StyleProtoChain.matchesCSSType(this, cssType);
    }

    /**
     *  @inheritDoc
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.6
     */
    public function hasCSSState():Boolean
    {
        return false;
    }
    
    //----------------------------------
    //  IFlexModule methods
    //----------------------------------

    /**
     *  @private
     *  Storage for the moduleFactory property.
     */
    private var _moduleFactory:IFlexModuleFactory;

    [Inspectable(environment="none")]

    /**
     *  A module factory is used as context for
     *  finding the style manager that controls the styles for this
     *  non-visual style client instance.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get moduleFactory():IFlexModuleFactory
    {
        return _moduleFactory;
    }

    /**
     *  @private
     */
    public function set moduleFactory(factory:IFlexModuleFactory):void
    {
        _moduleFactory = factory;

        setDeferredStyles();
    }

    /**
     *  The initialized method is called when this class or a class that
     *  extends this class is used in an MXML declaration.
     *  It is called after the implementing object has been created and all
     *  component properties specified on the MXML tag have
     *  been initialized.
     *  <p>
     *  If the document that created this object is a <code>UIComponent</code>,
     *  (e.g. Application, Module, etc.) then the UIComponent's
     *  <code>addStyleClient</code> method will be called to add this object to the
     *  UIComponent's list of non-visual style clients. This allows the
     *  object to inherit styles from the document. </p>
     *
     *  @param document The MXML document that created this object.
     *  @param id The identifier used by the document object to refer to
     *  this object.
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function initialized(document:Object, id:String):void
    {
        var uiComponent:UIComponent = document as UIComponent;

        if (uiComponent == null)
            uiComponent = FlexGlobals.topLevelApplication as UIComponent;

        this.id = id;

        this.moduleFactory = uiComponent.moduleFactory;

        uiComponent.addStyleClient(this);
    }
}
}
