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


package spark.components.mediaClasses
{

/**
 *  The DynamicStreamingVideoItem class represents a stream on the server plus a 
 *  bitrate for that stream.
 *
 *  @see spark.components.VideoPlayer 
 *  @see spark.components.VideoDisplay
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class DynamicStreamingVideoItem extends Object
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function DynamicStreamingVideoItem()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    [Inspectable(category="General", defaultValue="0")]
    
    //----------------------------------
    //  bitrate
    //----------------------------------
    
    private var _bitrate:Number = 0;

    /**
     *  The bitRate for this particular stream.
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function get bitrate():Number
    {
        return _bitrate;
    }

    /**
     *  @private
     */
    public function set bitrate(value:Number):void
    {
        _bitrate = value;
    }
    
    //----------------------------------
    //  streamName
    //----------------------------------
    
    private var _streamName:String;

    [Inspectable(category="General")]

    /**
     *  The stream name on the server
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function get streamName():String
    {
        return _streamName;
    }

    /**
     *  @private
     */
    public function set streamName(value:String):void
    {
        _streamName = value;
    }

}
}
