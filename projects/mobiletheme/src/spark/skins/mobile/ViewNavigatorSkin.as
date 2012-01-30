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
import mx.effects.IEffect;
import mx.states.State;
import mx.states.Transition;

import spark.components.ActionBar;
import spark.components.ButtonBar;
import spark.components.Group;
import spark.components.ViewNavigator;
import spark.effects.ViewTransition;
import spark.effects.Move;
import spark.effects.SlideViewTransition;
import spark.skins.MobileSkin;

/**
 *  The ActionScript based skin for view navigators in mobile
 *  applications.  This skin lays out the action bar and content
 *  group in a vertical fashion, where the action bar is on top.
 *  This skin also supports navigator overlay modes.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class ViewNavigatorSkin extends MobileSkin
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
    // TODO (chiedozi): File a request to exclude skinstates
    public function ViewNavigatorSkin()
    {
        super();
        
        states = [
            new State({name:"portrait"}),
            new State({name:"portraitAndOverlay"}),
            new State({name:"landscape"}),
            new State({name:"landscapeAndOverlay"})
            ];
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    // TODO (chiedozi): ASDOC propeties
    
    // Responsible for storing the views
    public var contentGroup:Group;
    
    // The action bar to use for the navigator
    public var actionBar:ActionBar;
    
    // The default transitions to run
    public var defaultPushTransition:ViewTransition;
    public var defaultPopTransition:ViewTransition;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    // TODO (chiedozi): ASDOC
    public var hostComponent:ViewNavigator;
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function createChildren():void
    {
        contentGroup = new Group();
        contentGroup.id = "contentGroup";
    	
        actionBar = new ActionBar();
        actionBar.id = "actionBar";
        
        addChild(contentGroup);
        addChild(actionBar);
        
        defaultPushTransition = new SlideViewTransition(300, SlideViewTransition.SLIDE_LEFT);
        defaultPopTransition = new SlideViewTransition(300, SlideViewTransition.SLIDE_RIGHT);
    }
    
    /**
     *  @private
     *  When the current state is set, need to invalidate the display list
     *  so that a validation pass runs. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function set currentState(value:String):void
    {
        if (super.currentState != value)
        {
            super.currentState = value;
            
            // Force a layout pass on the components
            invalidateSize();
            invalidateDisplayList();
        }
    }
    
    override protected function measure():void
    {
        super.measure();
        
        measuredWidth = Math.max(actionBar.getPreferredBoundsWidth(), 
                                 contentGroup.getPreferredBoundsWidth());
        
        if (currentState == "portraitAndOverlay" || currentState == "landscapeAndOverlay")
        {
            measuredHeight = Math.max(actionBar.getPreferredBoundsHeight(), 
                                  contentGroup.getPreferredBoundsHeight());
        }
        else
        {
            measuredHeight = actionBar.getPreferredBoundsHeight() + 
                                                 contentGroup.getPreferredBoundsHeight();
        }
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        var actionBarHeight:Number;
        
        // The action bar is always placed at 0,0 and stretches the entire
        // width of the navigator
        if (actionBar.includeInLayout)
        {
            actionBarHeight = Math.min(actionBar.getPreferredBoundsHeight(), unscaledHeight);
            actionBar.setLayoutBoundsSize(unscaledWidth, actionBarHeight);
            actionBar.setLayoutBoundsPosition(0, 0);
            actionBarHeight = actionBar.getLayoutBoundsHeight();
        }
        
        // If the hostComponent is in overlay mode, the contentGroup extends
        // the entire bounds of the navigator and the alpha for the action 
        // bar changes
        if (currentState == "portraitAndOverlay" || currentState == "landscapeAndOverlay")
        {
            // FIXME (chiedozi): Update when XD spec is written
            actionBar.alpha = .6;
            
            if (contentGroup.includeInLayout)
            {
                contentGroup.setLayoutBoundsSize(unscaledWidth, unscaledHeight);
                contentGroup.setLayoutBoundsPosition(0, 0);
            }
        }
        else
        {
            actionBar.alpha = 1.0;
            
            // The content group is placed below the actionBar and spans the
            // remaining space of the navigator.
    		if (contentGroup.includeInLayout)
    		{
    			var contentGroupHeight:Number = Math.max(unscaledHeight - actionBarHeight, 0);
                
    			
                contentGroup.setLayoutBoundsSize(unscaledWidth, contentGroupHeight);
                contentGroup.setLayoutBoundsPosition(0, actionBarHeight);
    		}
        }
    }
}
}