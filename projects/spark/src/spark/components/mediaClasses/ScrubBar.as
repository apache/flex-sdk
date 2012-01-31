////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////


package spark.components
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.events.Event;

import mx.core.IVisualElement;

/**
 *  The VideoScrubBar class is a video scrubbar/timeline that can show the
 *  current playHead, the amount previously played, and the buffered video.  
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */  
public class VideoPlayerScrubBar extends HSlider
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
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function VideoPlayerScrubBar()
    {
        super();
        
        dataTipFormatFunction = formatTimeValue;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    [SkinPart(required="false")]
    
    /**
     *  An optional skin part for the area on the track 
     *  representing the video that's been played.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var playedArea:IVisualElement;
    
    [SkinPart(required="false")]
    
    /**
     *  An optional skin part for the area on the track 
     *  representing the buffered video.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var bufferedArea:IVisualElement;
    
    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------
    
    //--------------------------------- 
    // bufferedValue
    //---------------------------------
    
    private var _bufferedRange:Array;
    
    /**
     *  The range of values that are currently in the buffer.  The first value 
     *  the array indicates the starting buffered value.  The second value 
     *  indicates the end of buffered in video.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get bufferedRange():Array
    {
        return _bufferedRange;
    }
    
    /**
     *  @private
     */
    public function set bufferedRange(value:Array):void
    {
        if (value == _bufferedRange)
            return;
        
        _bufferedRange = value;
        invalidateDisplayList();
    }

    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == playedArea)
        {
            if (playedArea is InteractiveObject)
                InteractiveObject(playedArea).mouseEnabled = false;
            if (playedArea is DisplayObjectContainer)
                DisplayObjectContainer(playedArea).mouseChildren = false;
            
            invalidateDisplayList();
        }
        else if (instance == bufferedArea)
        {
            if (bufferedArea is InteractiveObject)
                InteractiveObject(bufferedArea).mouseEnabled = false;
            if (bufferedArea is DisplayObjectContainer)
                DisplayObjectContainer(bufferedArea).mouseChildren = false;
            
            invalidateDisplayList();
        }
    }
    
    /**
     *  @private
     */
    override protected function completeTrackLayout():void
    {
        super.completeTrackLayout();
        sizeBufferedArea(valueToPosition(bufferedRange[1]) + thumbSize);
        sizePlayedArea(valueToPosition(value) + thumbSize);
    }
    
    /**
     *  Sets the size of the buffered area
     *
     *  @param bufferedAreaSize The new size of the buffered area
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function sizeBufferedArea(bufferedAreaSize:Number):void
    {
        if (bufferedArea)
            bufferedArea.setLayoutBoundsSize(Math.round(bufferedAreaSize), NaN);
    }
    
    /**
     *  Sets the size of the played area
     *
     *  @param playedAreaSize The new size of the played area
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function sizePlayedArea(playedAreaSize:Number):void
    {
        if (playedArea)
            playedArea.setLayoutBoundsSize(Math.round(playedAreaSize), NaN);            
    }
    
    /**
     *  @private
     */
    private function formatTimeValue(value:Number):String
    {
        // default format: hours:minutes:seconds
        var hours:uint = Math.floor(value/3600) % 24;
        var minutes:uint = Math.floor(value/60) % 60;
        var seconds:uint = Math.round(value) % 60;
        
        var result:String = "";
        if (hours != 0)
            result = hours + ":";
        
        if (result && minutes < 10)
            result += "0" + minutes + ":";
        else
            result += minutes + ":";
        
        if (seconds < 10)
            result += "0" + seconds;
        else
            result += seconds;
        
        return result;
    }
}
}