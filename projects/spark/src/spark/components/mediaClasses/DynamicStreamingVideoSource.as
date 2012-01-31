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
 *  used for streaming pre-recorded video or live streaming video.  In addition, 
 *  it can support a single stream or multiple streams associated with different 
 *  bitrates.  The <code>VideoPlayer</code> and <code>VideoDisplay</code>
 *  classes can take a DynamicStreamingVideoSource instance as its <code>source</code>
 *  property.
 *
 *  @see spark.components.VideoPlayer 
 *  @see spark.components.VideoDisplay
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
    //  serverURI
    //----------------------------------
   
    private var _serverURI:String;

    [Inspectable(category="General")]

    /**
     *  The uri pointing to the location of the server
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function get serverURI():String
    {
        return _serverURI;
    }

    /**
     *  @private
     */
    public function set serverURI(value:String):void
    {
        _serverURI = value;
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
     *  The type of stream we are trying to connect to.
     * 
     *  <p>If the streamType is <code>any</code>, then we will attempt to 
     *  connect to a live stream first.  If no live stream is found, we will 
     *  attempt to connect to a recorded stream.  If no recorded stream is found, 
     *  then a live stream will be created.</p>
     * 
     *  @default any
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