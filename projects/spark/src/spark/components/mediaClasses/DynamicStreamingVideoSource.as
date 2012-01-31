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
    
[DefaultProperty("streamItems")]

/**
 *  The DynamicStreamingVideoSource class represents a streaming video source and can be 
 *  used for streaming pre-recorded video or live streaming video.  
 *  You use this class to define a video stream for the VideoPlayer and VideoDisplay controls.
 *
 *  <p>This class supports a single stream or multiple streams associated with different 
 *  bitrates.  The <code>VideoPlayer</code> and <code>VideoDisplay</code>
 *  classes can take a DynamicStreamingVideoSource instance as its <code>source</code>
 *  property.</p>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:DynamicStreamingVideoSource&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:DynamicStreamingVideoSource 
 *    <strong>Properties</strong>
 *    host=""
 *    initialIndex="0"
 *    streamType="any"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.components.VideoPlayer 
 *  @see spark.components.VideoDisplay
 *  @see spark.components.mediaClasses.DynamicStreamingVideoItem
 *
 *  @includeExample examples/DynamicStreamingVideoSourceExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class DynamicStreamingVideoSource extends Object
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
    public function DynamicStreamingVideoSource()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  host
    //----------------------------------
   
    private var _host:Object;

    [Inspectable(category="General")]

    /**
     *  The URI of the location of the video server.
     *  While this property is of type Object, pass 
     *  the URI as a String. 
     *
     *  <p>Use the <code>streamName</code> property of the 
     *  DynamicStreamingVideoItem class to specify stream name on the server.</p>
     *
     *  @see spark.components.mediaClasses.DynamicStreamingVideoItem#streamName
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function get host():Object
    {
        return _host;
    }

    /**
     *  @private
     */
    public function set host(value:Object):void
    {
        _host = value;
    }
    
    //----------------------------------
    //  initialIndex
    //----------------------------------
   
    private var _initialIndex:int;

    [Inspectable(category="General")]

    /**
     *  The preferred starting index.  This corresponds to 
     *  the stream item that should be attempted first.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function get initialIndex():int
    {
        return _initialIndex;
    }

    /**
     *  @private
     */
    public function set initialIndex(value:int):void
    {
        _initialIndex = value;
    }
    
    //----------------------------------
    //  streamItems
    //----------------------------------
    
    private var _streamItems:Vector.<DynamicStreamingVideoItem>;

    [Inspectable(category="General")]

    /**
     *  The metadata info object with properties describing the FLB file.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function get streamItems():Vector.<DynamicStreamingVideoItem>
    {
        return _streamItems;
    }
    
    /**
     *  @private
     */
    public function set streamItems(value:Vector.<DynamicStreamingVideoItem>):void
    {
        _streamItems = value;
    }
    
    //----------------------------------
    //  streamType
    //----------------------------------
    
    private var _streamType:String = "any";
    
    [Inspectable(category="General", enumeration="any,live,recorded", defaultValue="any")]
    
    /**
     *  The type of stream we are trying to connect to: any, live, or recorded.
     * 
     *  <p>If the streamType is <code>any</code>, then we will attempt to 
     *  connect to a live stream first.  If no live stream is found, we will 
     *  attempt to connect to a recorded stream.  If no recorded stream is found, 
     *  then a live stream will be created.</p>
     * 
     *  @default any
     * 
     *  @see org.osmf.net.StreamType
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get streamType():String
    {
        return _streamType;
    }

    /**
     *  @private
     */
    public function set streamType(value:String):void
    {
        _streamType = value;
    }

}
}
