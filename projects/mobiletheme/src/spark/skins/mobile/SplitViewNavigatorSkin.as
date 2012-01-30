////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.mobile
{
import spark.components.Callout;
import spark.components.CalloutPosition;
import spark.components.Group;
import spark.components.SplitViewNavigator;
import spark.layouts.HorizontalLayout;
import spark.skins.mobile.supportClasses.MobileSkin;

/**
 *  The default skin for the SplitViewNavigator component.  This skin is
 *  chromeless and doesn't draw a background, border or separator.  It
 *  only contains a single content group with a horizontal layout to hold 
 *  the navigators, and a Callout component.  The Callout component uses
 *  the default values for its layout properties.
 * 
 *  @see spark.components.Callout
 *  @see spark.components.SplitViewNavigator
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */
public class SplitViewNavigatorSkin extends MobileSkin
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
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
	 */
    public function SplitViewNavigatorSkin()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  SkinParts
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @copy spark.components.SkinnableContainer#contentGroup
     */
    public var contentGroup:Group;
    
    /**
     *  @copy spark.components.SplitViewNavigator#viewNavigatorCallout
     */ 
    public var viewNavigatorCallout:Callout;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @copy spark.skins.spark.ApplicationSkin#hostComponent
	 */
    public var hostComponent:SplitViewNavigator;
    
    //--------------------------------------------------------------------------
    //
    // Overridden Methods
    //
    //--------------------------------------------------------------------------
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        // Create the layout for the content group
        var hLayout:HorizontalLayout = new HorizontalLayout();
        hLayout.gap = 0;
        
        // Create the contentGroup
        contentGroup = new Group();
        contentGroup.id = "contentGroup";
        contentGroup.layout = hLayout;
        addChild(contentGroup);
        
        // Create the callout but don't add it to display list
        viewNavigatorCallout = new Callout();
        viewNavigatorCallout.id = "viewNavigatorCallout";
        viewNavigatorCallout.height = 500;
        viewNavigatorCallout.setStyle("color", 0x000000);
        viewNavigatorCallout.setStyle("contentBackgroundAlpha", 0);
    }
    
	/**
	 *  @private
	 */
    override protected function measure():void
    {
        super.measure();
        
        measuredWidth = contentGroup.getPreferredBoundsWidth();
        measuredHeight = contentGroup.getPreferredBoundsHeight();
    }
    
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);

        contentGroup.setLayoutBoundsSize(unscaledWidth, unscaledHeight);
        contentGroup.setLayoutBoundsPosition(0, 0);
    }
}
}