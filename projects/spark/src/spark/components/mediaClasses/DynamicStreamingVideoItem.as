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
 *  The StreamItem class represents a stream on the server plus a 
 *  bitRate for that stream.
 *
 *  @see spark.components.VideoPlayer 
 *  @see spark.primitives.VideoElement
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class StreamItem extends Object
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function StreamItem()
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
    //  bitRate
    //----------------------------------
    
    private var _bitRate:Number = 0;

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
    public function get bitRate():Number
    {
        return _bitRate;
    }

    /**
     *  @private
     */
    public function set bitRate(value:Number):void
    {
        _bitRate = value;
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