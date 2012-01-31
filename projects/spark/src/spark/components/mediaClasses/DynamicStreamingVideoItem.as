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
 *  The DynamicStreamingVideoItem class represents a video stream on the server plus a 
 *  bitrate for that stream. 
 *  Use this class to define the values of the <code>streamItems</code> property
 *  of the DynamicStreamingVideoSource class.
 *  The DynamicStreamingVideoSource class represents a streaming video source and can be 
 *  used for streaming pre-recorded video or live streaming video.  
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:DynamicStreamingVideoItem&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:DynamicStreamingVideoItem 
 *    <strong>Properties</strong>
 *    bitrate="0"
 *    streamName=""
 *  /&gt;
 *  </pre>
 *
 *  @see spark.components.VideoPlayer 
 *  @see spark.components.VideoDisplay
 *  @see spark.components.mediaClasses.DynamicStreamingVideoSource
 *
 *  @includeExample examples/DynamicStreamingVideoSourceExample.mxml
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
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function DynamicStreamingVideoItem()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  bitrate
    //----------------------------------
    
    private var _bitrate:Number = 0;

    [Inspectable(category="General", defaultValue="0")]
    
    /**
     *  The bit rate for the video stream.
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
     *  The stream name on the server.
     *  Use the <code>host</code> property of the DynamicStreamingVideoSource class
     *  to specify the URI of the server.
     *
     *  @see spark.components.mediaClasses.DynamicStreamingVideoSource#host
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
