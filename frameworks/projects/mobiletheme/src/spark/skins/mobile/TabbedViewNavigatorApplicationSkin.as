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
     * The tabbed navigator for the application
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var tabbedNavigator:TabbedViewNavigator;
    
    
    /**
     *  Creates an action menu from this factory when the menu button is pressed 
     *  
     *  @langversion 3.0
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
        tabbedNavigator = new TabbedViewNavigator();
        tabbedNavigator.id = "tabbedNavigator";
        
        addChild(tabbedNavigator);
    }
    
    /**
     *  @private 
     */ 
    override protected function measure():void
    {        
        super.measure();
        
        measuredWidth = tabbedNavigator.getPreferredBoundsWidth();
        measuredHeight = tabbedNavigator.getPreferredBoundsHeight();
    }
    
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        tabbedNavigator.setLayoutBoundsSize(unscaledWidth, unscaledHeight);
        tabbedNavigator.setLayoutBoundsPosition(0, 0);
    }
}
}