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

package spark.skins.mobile
{

import spark.components.ActionBar;
import spark.components.Group;
import spark.components.ViewNavigator;
import spark.skins.mobile.supportClasses.MobileSkin;

/**
 *  The ActionScript-based skin for view navigators in mobile
 *  applications.  This skin lays out the action bar and content
 *  group in a vertical fashion, where the action bar is on top.
 *  This skin also supports navigator overlay modes.
 * 
 *  @langversion 3.0
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function ViewNavigatorSkin()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @copy spark.components.SkinnableContainer#contentGroup
     */
    public var contentGroup:Group;
    
    /**
     *  @copy spark.components.ViewNavigator#actionBar
     */ 
    public var actionBar:ActionBar;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    /** 
     *  @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
    public var hostComponent:ViewNavigator;
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    private var _isOverlay:Boolean;
    
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        contentGroup = new Group();
        contentGroup.id = "contentGroup";
        
        actionBar = new ActionBar();
        actionBar.id = "actionBar";
        
        addChild(contentGroup);
        addChild(actionBar);
    }
    
    /**
     *  @private 
     */ 
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
     */ 
    override protected function commitCurrentState():void
    {
        super.commitCurrentState();
        
        _isOverlay = (currentState.indexOf("Overlay") >= 1);
        
        // Force a layout pass on the components
        invalidateProperties();
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        var actionBarHeight:Number = 0;
        
        // The action bar is always placed at 0,0 and stretches the entire
        // width of the navigator
        if (actionBar.includeInLayout)
        {
            actionBarHeight = Math.min(actionBar.getPreferredBoundsHeight(), unscaledHeight);
            actionBar.setLayoutBoundsSize(unscaledWidth, actionBarHeight);
            actionBar.setLayoutBoundsPosition(0, 0);
            actionBarHeight = actionBar.getLayoutBoundsHeight();
            
            // update ActionBar backgroundAlpha when in overlay mode
            var backgroundAlpha:Number = (_isOverlay) ? 0.75 : 1;
            actionBar.setStyle("backgroundAlpha", backgroundAlpha);
        }
        
        if (contentGroup.includeInLayout)
        {
            // If the hostComponent is in overlay mode, the contentGroup extends
            // the entire bounds of the navigator and the alpha for the action 
            // bar changes
            // If this changes, also update validateEstimatedSizesOfChild
            var contentGroupHeight:Number = (_isOverlay) ? unscaledHeight : Math.max(unscaledHeight - actionBarHeight, 0);
            var contentGroupPosition:Number = (_isOverlay) ? 0 : actionBarHeight;
            
            contentGroup.setLayoutBoundsSize(unscaledWidth, contentGroupHeight);
            contentGroup.setLayoutBoundsPosition(0, contentGroupPosition);
        }
    }
}
}