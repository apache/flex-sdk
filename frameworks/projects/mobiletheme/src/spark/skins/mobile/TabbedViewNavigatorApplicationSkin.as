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
import mx.core.IFactory;

import spark.components.TabbedViewNavigator;
import spark.components.TabbedViewNavigatorApplication;
import spark.components.ViewMenu;
import spark.skins.mobile.supportClasses.MobileSkin;

/**
 *  The ActionScript-based skin used for TabbedViewNavigatorApplication.  
 *  This skin contains a single TabbedViewNavigator that spans the
 *  entire content area of the application.
 * 
 * @see spark.components.TabbedViewNavigatorApplication
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
    /** 
     *  @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
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
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        navigator.setLayoutBoundsSize(unscaledWidth, unscaledHeight);
        navigator.setLayoutBoundsPosition(0, 0);
    }
}
}