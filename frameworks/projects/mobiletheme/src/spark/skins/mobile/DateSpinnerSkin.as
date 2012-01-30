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
import mx.core.ClassFactory;
import mx.core.IFactory;
import mx.core.IVisualElementContainer;

import spark.components.DateSpinner;
import spark.components.SpinnerList;
import spark.components.SpinnerListContainer;
import spark.skins.mobile.supportClasses.MobileSkin;

/**
 *  ActionScript-based skin for the DateSpinner in mobile applications.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
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
     *  Constructor
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
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
     *  Factory for creating dateItem list parts
     *
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public var dateItemList:IFactory;
    
    /**
     *  Skin part; container of dateItem list(s) 
     *
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
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
    
    override protected function createChildren():void
    {
        listContainer = new SpinnerListContainer();
        
        addChild(SpinnerListContainer(listContainer));
        
        dateItemList = new ClassFactory(SpinnerList);
    }
    
    override protected function measure():void
    {
        measuredWidth = SpinnerListContainer(listContainer).getPreferredBoundsWidth();
        measuredHeight = SpinnerListContainer(listContainer).getPreferredBoundsHeight();
        measuredMinWidth = SpinnerListContainer(listContainer).getMinBoundsWidth();
        measuredMinHeight = SpinnerListContainer(listContainer).getMinBoundsHeight();
    }
    
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