////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.flash
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.geom.Rectangle;
import flash.utils.getDefinitionByName;

import mx.core.IUIComponent;
import mx.core.mx_internal;

/**
 *  The FlexContentHolder class is for internal use only.
 */
public dynamic class FlexContentHolder extends ContainerMovieClip 
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     */
    public function FlexContentHolder()
    {
        super();
        trackSizeChanges = false;
        showInAutomationHierarchy = false;

    }
    
    //--------------------------------------------------------------------------
    //
    //  Internal variables
    //
    //--------------------------------------------------------------------------
    
    private var flexContent:IUIComponent;           // The Flex content
    
    private var pendingFlexContent:IUIComponent;    // Only used if flexContent is set early

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
        
    //----------------------------------
    //  content
    //----------------------------------
     
    /**
     *  @inheritDoc
     */
    override public function get content():IUIComponent
    {
        return flexContent;
    }
        
    override public function set content(value:IUIComponent):void
    {
        if (initialized)
            setFlexContent(value);
        else
            pendingFlexContent = value;
    }

    //--------------------------------------------------------------------------
    //
    //  IUIComponent methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Initialize the object.
     *
     *  @see mx.core.UIComponent#initialize()
     */
    override public function initialize():void
    {
        super.initialize();
        
        _width = bounds.width;
        _height = bounds.height;
        
        // initialize is only called when we are running in Flex. 
        // Since we are in Flex, let's hide the content placeholder.
        // Rather than removing it (which can cause problems with
        // sizing), we set the alpha to 0.
        getChildAt(0).alpha = 0;

        // See if we have any pending flex content
        if (pendingFlexContent)
        {
            setFlexContent(pendingFlexContent);
            pendingFlexContent = null;
        }
    }

    //--------------------------------------------------------------------------
    //
    //  IFlexDisplayObject methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Sets the actual size of this object.
     *
     *  <p>This method is mainly for use in implementing the
     *  <code>updateDisplayList()</code> method, which is where
     *  this object's actual size is computed based on
     *  its explicit size, parent-relative (percent) size,
     *  and measured size.
     *  Apply this actual size to the object
     *  by calling the <code>setActualSize()</code> method.</p>
     *
     *  <p>In other situations, you should be setting properties
     *  such as <code>width</code>, <code>height</code>,
     *  <code>percentWidth</code>, or <code>percentHeight</code>
     *  rather than calling this method.</p>
     * 
     *  @param newWidth The new width for this object.
     * 
     *  @param newHeight The new height for this object.
     */
    override public function setActualSize(newWidth:Number, newHeight:Number):void
    {
        if (sizeChanged(_width, newWidth) || sizeChanged(_height, newHeight))
            dispatchResizeEvent();
            
        // Remember our new actual size so we can report it later in the
        // width/height getters.
        _width = newWidth;
        _height = newHeight;
        
        scaleX = scaleY = 1;
        
        if (flexContent)
        {
            sizeFlexContent();
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Layout methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Notify parent that the size of this object has changed.
     */
    override protected function notifySizeChanged():void
    {
        super.notifySizeChanged();
        
        sizeFlexContent();
    }
     
    //--------------------------------------------------------------------------
    //
    //  Flex content methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Utility function that prepares Flex content to be used as a child of
     *  this component. 
     *  Set the <code>content</code> property rather than calling
     *  this method directly.
     */
    protected function setFlexContent(value:IUIComponent):void
    {
        // Remove any existing content
        if (flexContent)
        {
            removeChild(DisplayObject(flexContent));
            flexContent = null;
        }
        
        // Add the new content
        flexContent = value;
        if (flexContent)
        {
            addChild(DisplayObject(flexContent));
            
            var uiComponentClass:Class;
            
            // Dynamically load the UIComponent class, but don't fail on error.
            // This allows us to work in Flex (where UIComponent is defined), and 
            // in Flash (where it UIComponent is not defined).
            try
            {
                uiComponentClass = Class(getDefinitionByName("mx.core::UIComponent"));
            }
            catch (e:Error)
            {
            }
            
            // Do the Flex initialization
            if (uiComponentClass)
            {
                // Find our parent UIComponent
                var uicParent:Object;
                var p:DisplayObjectContainer = parent;
                
                while (p)
                {
                    if (p is uiComponentClass)
                    {
                        uicParent = p;
                        break;
                    }
                    p = p.parent;
                }
                
                if (!uicParent)
                {
                    try
                    {
                        var applicationClass:Class = Class(getDefinitionByName("mx.core::ApplicationGlobals"));
                        
                        uicParent = applicationClass.application;
                    }
                    catch (e:Error)
                    {                       
                    }
                }
                
                if (!uicParent)
                    return;
                
                flexContent.initialize();
                
                // The rest of this was copied from UIComponent.addingChild()...
                
                // If the document property isn't already set on the child,
                // set it to be the same as this component's document.
                // The document setter will recursively set it on any
                // descendants of the child that exist.
                if (!flexContent.document)
                {
                    flexContent.document = uicParent.document;
                }
        
                if (flexContent is InteractiveObject)
                    if (doubleClickEnabled)
                        InteractiveObject(flexContent).doubleClickEnabled = true;
                    
                
                // Sets up the inheritingStyles and nonInheritingStyles objects
                // and their proto chains so that getStyle() works.
                // If this object already has some children,
                // then reinitialize the children's proto chains.
                if (flexContent is uiComponentClass)
                {     
                    flexContent.mx_internal::_parent = this;

                    var child:Object = flexContent;
                    
                    // Set the nestLevel of the child to be one greater
                    // than the nestLevel of this component.
                    // The nestLevel setter will recursively set it on any
                    // descendants of the child that exist.
                    child.nestLevel = uicParent.nestLevel + 1;

                    // Temporarily set the _parent property of the child to the nearest UIComponent
                    // parent. This allows inheriting styles to be picked up correctly.
                    child.mx_internal::_parent = uicParent;
                    child.regenerateStyleCache(true);
                    child.styleChanged(null);
                    child.notifyStyleChangeInChildren(null, true);
                    child.mx_internal::initThemeColor();
                    // Reset the _parent property.
                    child.mx_internal::_parent = this;

                    // Inform the component that it's style properties
                    // have been fully initialized. Most components won't care,
                    // but some need to react to even this early change.
                    child.stylesInitialized();
                 }

                 _width *= scaleX;
                 _height *= scaleY;
                 scaleX = scaleY = 1;
                
                 sizeFlexContent();
            }
        }
    }

    /**
     *  @private
     */
    protected function sizeFlexContent():void
    {
        if (!flexContent)
            return;
            
        // Scale the flex content to the inverse of our nested scale
        flexContent.scaleX = 1;
        flexContent.scaleY = 1;
        
        // Size the flex content to our size
        var contentWidth:Number = _width;
        var contentHeight:Number = _height;
        
        if (flexContent.explicitWidth)
            contentWidth = Math.min(contentWidth, flexContent.explicitWidth);
        
        if (flexContent.explicitHeight)
            contentHeight = Math.min(contentHeight, flexContent.explicitHeight);
            
        flexContent.setActualSize(contentWidth, contentHeight);
    }
}
}
