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
import spark.components.Group;
import spark.components.SkinnableContainer;
import spark.skins.mobile.supportClasses.MobileSkin;

/**
 *  ActionScript-based skin for SkinnableContainer in mobile applications.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */
public class SkinnableContainerSkin extends MobileSkin
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
     * 
     */ 
    public function SkinnableContainerSkin()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  SkinParts
    //
    //--------------------------------------------------------------------------
    /**
     *  An optional skin part that defines the Group where the content 
     *  children get pushed into and laid out.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public var contentGroup:Group;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /** 
     * @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
    public var hostComponent:SkinnableContainer; // SkinnableComponent will popuplate
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     */ 
    override protected function commitCurrentState():void
    {
        super.commitCurrentState();
        
        alpha = currentState.indexOf("disabled") == -1 ? 1 : 0.5;
    }
    
    /**
     *  @private 
     */ 
    override protected function createChildren():void
    {      
        contentGroup = new Group();
        contentGroup.id = "contentGroup";
        contentGroup.left = contentGroup.right = contentGroup.top = contentGroup.bottom = 0;
        contentGroup.minWidth = contentGroup.minHeight = 0;
        
        addChild(contentGroup);
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
    
    /**
     *  @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.drawBackground(unscaledWidth, unscaledHeight);

        // Draw the background
        graphics.beginFill(getStyle("backgroundColor"), getStyle("backgroundAlpha"));
        graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
        graphics.endFill();
    }
}
}