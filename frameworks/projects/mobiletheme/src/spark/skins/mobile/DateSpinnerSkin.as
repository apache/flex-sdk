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
import mx.core.IVisualElementContainer;

import spark.components.DateSpinner;
import spark.components.SpinnerList;
import spark.components.SpinnerListContainer;
import spark.components.calendarClasses.DateSpinnerItemRenderer;
import spark.skins.mobile.supportClasses.MobileSkin;

/**
 *  ActionScript-based skin for the DateSpinner in mobile applications.
 *  
 * @see spark.components.DateSpinner
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 *  
 */
public class DateSpinnerSkin extends MobileSkin
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
     *  @productversion Flex 4.6
     */
    public function DateSpinnerSkin()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Factory for creating dateItem list parts.
     *
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public var dateItemList:IFactory;
    
    /**
     *  Skin part; container of dateItem list(s).
     *
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public var listContainer:IVisualElementContainer;
    
    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------
    /** 
     *  @copy spark.skins.spark.ApplicationSkin#hostComponent
     */
    public var hostComponent:DateSpinner;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    override protected function createChildren():void
    {
        listContainer = new SpinnerListContainer();
        
        addChild(SpinnerListContainer(listContainer));
        
        dateItemList = new ClassFactory(SpinnerList);
        
        (dateItemList as ClassFactory).properties = { itemRenderer: new ClassFactory(spark.components.calendarClasses.DateSpinnerItemRenderer),
            percentHeight : 100 };
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    override protected function measure():void
    {
        measuredWidth = SpinnerListContainer(listContainer).getPreferredBoundsWidth();
        measuredHeight = SpinnerListContainer(listContainer).getPreferredBoundsHeight();
        measuredMinWidth = SpinnerListContainer(listContainer).getMinBoundsWidth();
        measuredMinHeight = SpinnerListContainer(listContainer).getMinBoundsHeight();
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        // Always set the SpinnerListContainer to its measured width, regardless of our size
        var containerWidth:Number = SpinnerListContainer(listContainer).getPreferredBoundsWidth();
        var containerHeight:Number = unscaledHeight;
        
        setElementSize(listContainer, containerWidth, containerHeight);
        // if width is greater than necessary, center the component
        setElementPosition(listContainer, Math.max((unscaledWidth - containerWidth)/2, 0), 0);
    }
    
}
}