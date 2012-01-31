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
    //  Variables
    //
    //--------------------------------------------------------------------------

    private var tempTrackSize:Number = NaN;
    
    //--------------------------------------------------------------------------
    //
    // Properties
    //
    //--------------------------------------------------------------------------
    
    //--------------------------------- 
    // bufferedValue
    //---------------------------------
    
    private var _bufferedValue:Number;
    
    /**
     *  The value of the video that's been buferred in.  This property 
     *  should be greater than value and less than maximum.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get bufferedValue():Number
    {
        return _bufferedValue;
    }
    
    /**
     *  @private
     */
    public function set bufferedValue(value:Number):void
    {
        if (value == _bufferedValue)
            return;
        
        _bufferedValue = value;
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
        else if (instance == track)
        {
            tempTrackSize = NaN;                                      
        }
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, 
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        sizeBufferedArea(valueToPosition(bufferedValue) + thumbSize);
        sizePlayedArea(valueToPosition(value) + thumbSize);
    }
    
    /**
     *  @private
     *  Force the component to set itself up correctly now that the
     *  track is completely loaded.
     */
    override protected function track_updateCompleteHandler(event:Event):void
    {
        super.track_updateCompleteHandler(event);
        
        //TODO: Consider the case where the track moves (like the move
        //effect). Perhaps this handler should run every time... 
        if (trackSize != tempTrackSize)
        {
            sizeBufferedArea(valueToPosition(bufferedValue) + thumbSize);
            sizePlayedArea(valueToPosition(value) + thumbSize);
            tempTrackSize = trackSize;
        }
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
            DisplayObject(bufferedArea).width = Math.round(bufferedAreaSize);
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
            DisplayObject(playedArea).width = Math.round(playedAreaSize);
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