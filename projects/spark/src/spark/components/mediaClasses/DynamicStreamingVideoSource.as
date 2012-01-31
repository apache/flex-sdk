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
 *  The StreamingVideoSource class represents a streaming video source and can be 
 *  used for streaming pre-recorded video or live streaming video.  In addition, 
 *  it can support a single stream or multiple streams associated with different 
 *  bitrates.  The <code>VideoPlayer</code> and <code>VideoElement</code>
 *  classes can take a StreamingVideoSource instance as its <code>source</code>
 *  property.
 *
 *  @see spark.components.VideoPlayer 
 *  @see spark.primitives.VideoElement
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class StreamingVideoSource extends Object
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function StreamingVideoSource()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  live
    //----------------------------------
    
    private var _live:Boolean = false;
    
    [Inspectable(category="General", defaultValue="false")]
    
    /**
     *  A Boolean value that is <code>true</code> if the video stream is live. 
     * 
     *  <p>Set the <code>live</code> property to <code>false</code> when sending 
     *  a prerecorded video stream to the video player and to <code>true</code> 
     *  when sending real-time data such as a live broadcast.</p>
     * 
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get live():Boolean
    {
        return _live;
    }

    /**
     *  @private
     */
    public function set live(value:Boolean):void
    {
        _live = value;
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
    
    private var _streamItems:Array;

    [Inspectable(category="General")]
    [ArrayElementType("spark.components.mediaClasses.StreamItem")]
    
    // FIXME (rfrishbe): change to vectors when possible

    /**
     *  The metadata info object with properties describing the FLB file.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function get streamItems():Array
    {
        return _streamItems;
    }
    
    /**
     *  @private
     */
    public function set streamItems(value:Array):void
    {
        _streamItems = value;
    }

}
}