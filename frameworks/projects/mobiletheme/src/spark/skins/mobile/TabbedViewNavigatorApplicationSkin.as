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

package spark.skins.mobile
{
import mx.core.ClassFactory;
import mx.core.IContainerInvalidating;
import mx.core.IFactory;
import mx.core.ILayoutElement;
import mx.core.mx_internal;
import mx.managers.ILayoutManagerContainerClient;
use namespace mx_internal;

import spark.components.TabbedViewNavigator;
import spark.components.TabbedViewNavigatorApplication;
import spark.components.ViewMenu;
import spark.skins.mobile.supportClasses.MobileSkin;

/**
 *  The ActionScript based skin used for TabbedViewNavigatorApplication.  
 *  This skin contains a single TabbedViewNavigator that spans the
 *  entire content area of the application.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class TabbedViewNavigatorApplicationSkin extends MobileSkin
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
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function TabbedViewNavigatorApplicationSkin()
    {
        super();
        
        viewMenu = new ClassFactory(ViewMenu);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     * The navigator for the application
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var navigator:TabbedViewNavigator;
    
    
    /**
     *  Creates an action menu from this factory when the menu button is pressed 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public var viewMenu:IFactory;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Properties
    //
    //--------------------------------------------------------------------------
    public var hostComponent:TabbedViewNavigatorApplication;
    
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        navigator = new TabbedViewNavigator();
        addChild(navigator);
    }
    
    /**
     *  @private 
     */
    override mx_internal function validateEstimatedSizesOfChild(child:ILayoutElement):void
    {
        var cw:Number;
        var ch:Number;
        var c:Number;
        var oldcw:Number = child.estimatedWidth;
        var oldch:Number = child.estimatedHeight;
        // the child navigator is constrained to the size of the skin
        cw = estimatedWidth;
        if (isNaN(cw) && !isNaN(explicitWidth))
            cw = explicitWidth;
        ch = estimatedHeight;
        if (isNaN(ch) && !isNaN(explicitHeight))
            ch = explicitHeight;
        
        child.setEstimatedSize(cw, ch);
        if (child is ILayoutManagerContainerClient)
        {
            var sameWidth:Boolean = isNaN(cw) && isNaN(oldcw) || cw == oldcw;
            var sameHeight:Boolean = isNaN(ch) && isNaN(oldch) || ch == oldch;
            if (!(sameHeight && sameWidth))
            {
                if (child is IContainerInvalidating)
                    IContainerInvalidating(child).invalidateEstimatedSizesOfChildren();
                ILayoutManagerContainerClient(child).validateEstimatedSizesOfChildren();
            }
        }
    }    
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        // navigator is constrained to the size of the skin.
        // if you change this, also update validateEstimatedSizesOfChild
        navigator.setLayoutBoundsSize(unscaledWidth, unscaledHeight);
        navigator.setLayoutBoundsPosition(0, 0);
    }
}
}