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
import flash.events.Event;
import flash.utils.getDefinitionByName;

import mx.core.IFlexModule;
import mx.core.IUIComponent;
import mx.core.mx_internal;

use namespace mx_internal;

[ExcludeClass]

/**
 *  The FlexContentHolder class is for internal use only.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function FlexContentHolder()
    {
        super();
        showInAutomationHierarchy = false;
        
        // grab our width and height before setting scaleX=scaleY=1
        _width = this.width;
        _height = this.height;
        
        // set scaleX, scaleY to 1 in case the user scaled the 
        // FlexContentHolder when creating this ContainerMovieClip.
        // If we don't set scale here, then the content in the container
        // would be scaled as well
        $scaleX = $scaleY = 1;
        
        removeEventListener(Event.ADDED, addedHandler);
        removeEventListener(Event.REMOVED, removedHandler);
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function initialize():void
    {
        super.initialize();
        
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function setActualSize(newWidth:Number, newHeight:Number):void
    {
        if (sizeChanged(_width, newWidth) || sizeChanged(_height, newHeight))
            dispatchResizeEvent();
            
        // Remember our new actual size so we can report it later in the
        // width/height getters.
        _width = newWidth;
        _height = newHeight;
        
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
                    
                // Propagate moduleFactory to the child, but don't overwrite an existing moduleFactory.
                if (flexContent is IFlexModule && IFlexModule(flexContent).moduleFactory == null)
                {
                    if (uicParent is IFlexModule && IFlexModule(uicParent).moduleFactory != null)
                        IFlexModule(flexContent).moduleFactory = IFlexModule(uicParent).moduleFactory;
                        
                    else if (document is IFlexModule && uicParent.document.moduleFactory != null)
                        IFlexModule(flexContent).moduleFactory = uicParent.document.moduleFactory;
                        
                    else if (uicParent is IFlexModule && IFlexModule(uicParent).moduleFactory != null)
                        IFlexModule(flexContent).moduleFactory = IFlexModule(uicParent).moduleFactory;
                }
                
                // Sets up the inheritingStyles and nonInheritingStyles objects
                // and their proto chains so that getStyle() works.
                // If this object already has some children,
                // then reinitialize the children's proto chains.
                if (flexContent is uiComponentClass)
                {     
                    var child:Object = flexContent;
                    
                    // set the child's parent to this for now (when initializing styles,
                    // we'll have to do some funky business).
                    child._parent = this;
                    
                    // Set the nestLevel of the child to be one greater
                    // than the nestLevel of this component.
                    // The nestLevel setter will recursively set it on any
                    // descendants of the child that exist.
                    child.nestLevel = uicParent.nestLevel + 1;

                    // Temporarily set the _parent property of the child to the nearest UIComponent
                    // parent. This allows inheriting styles to be picked up correctly.
                    child._parent = uicParent;
                    child.regenerateStyleCache(true);
                    child.styleChanged(null);
                    child.notifyStyleChangeInChildren(null, true);
                    child.initThemeColor();
                    // Reset the _parent property.
                    child._parent = this;

                    // Inform the component that it's style properties
                    // have been fully initialized. Most components won't care,
                    // but some need to react to even this early change.
                    child.stylesInitialized();
                 }
                
                flexContent.initialize();
            }
        }
    }
    
    /**
     *  @private
     */
    public function sizeFlexContent():void
    {
        if (!flexContent)
            return;
        
        var myParent:ContainerMovieClip = ContainerMovieClip(parent);
        var contentWidth:Number;
        var contentHeight:Number;
        
        var containerWidth:Number = _width;
        var containerHeight:Number = _height;
        
        // width and height are what we actually want our content
        // to fill up, but it doesn't take in to account our secretScale.
        if (!myParent.scaleContentWhenResized)
        {
            // apply the scale to the width/height
            if (myParent._layoutFeatures != null)
            {
                containerWidth *= myParent._layoutFeatures.stretchX;
                containerHeight *= myParent._layoutFeatures.stretchY;
            }
        }
        
        // Size the flex content to what they want to be, 
        // making sure we size them to their minimum size and 
        // making sure we fit within this container.
        // We don't do anything too fancy here for layout, try percent
        // widths and heights and make sure 
        // our size is large enough to hold our content in the first place
        
        if (!isNaN(content.percentWidth))
            contentWidth = containerWidth * Math.min(content.percentWidth * .01, 1);
        else
            contentWidth = Math.min(containerWidth, flexContent.getExplicitOrMeasuredWidth());
        
        // above: should we size to explicWidth if it's larger than containerWidth?  Or should we do the min here?
        
        if (!isNaN(content.percentHeight))
            contentHeight = containerHeight * Math.min(content.percentHeight * .01, 1);
        else
            contentHeight = Math.min(containerHeight, flexContent.getExplicitOrMeasuredHeight());
        
        contentWidth = Math.max(flexContent.minWidth, contentWidth);
        contentHeight = Math.max(flexContent.minHeight, contentHeight);
        contentWidth = Math.min(flexContent.maxWidth, contentWidth);
        contentHeight = Math.min(flexContent.maxHeight, contentHeight);
        
        flexContent.setActualSize(contentWidth, contentHeight);
    }
}
}
