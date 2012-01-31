package mx.graphics
{
import fl.video.MetadataEvent;
import fl.video.VideoAlign;
import fl.video.VideoEvent;
import fl.video.VideoPlayer;
import fl.video.VideoScaleMode;
import fl.video.VideoState;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.ProgressEvent;

import mx.core.mx_internal;
import mx.graphics.baseClasses.GraphicElement;

import spark.events.MetadataEvent;
import spark.events.VideoEvent;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the <code>NetConnection</code> is closed,
 *  whether by being timed out, by calling the <code>close()</code> method, 
 *  or by loading a new video stream.  This event is only dispatched 
 *  with RTMP streams, never HTTP.
 *
 *  @eventType spark.events.VideoEvent.CLOSE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="close", type="spark.events.VideoEvent")]

/**
 * Dispatched when playing completes because the player reached the end of the FLV file. 
 * The component does not dispatch the event if you call the <code>stop()</code> or 
 * <code>pause()</code> methods 
 * or click the corresponding controls. 
 *
 *  @eventType spark.events.VideoEvent.COMPLETE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="complete", type="spark.events.VideoEvent")]

/**
 *  Dispatched the first time the FLV file's metadata is reached.
 *  The event object has an <code>info</code> property that contains the 
 *  info object received by the <code>NetStream.onMetaData</code> event callback.
 * 
 *  @eventType spark.events.MetadataEvent.METADATA_RECEIVED
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="metadataReceived", type="spark.events.MetadataEvent")]

/**
 *  Dispatched every 0.25 seconds, or how often the underlying video
 *  player's <code>playheadUpdateInterval</code> is set to, while the 
 *  video is playing.  This event is not dispatched when it is paused 
 *  or stopped, unless a seek occurs.
 *
 *  @eventType spark.events.VideoEvent.PLAYHEAD_UPDATE
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="playheadUpdate", type="spark.events.VideoEvent")]

/**
 *  Indicates progress made in number of bytes downloaded. Dispatched at the frequency 
 *  specified by the underlying video player's <code>progressInterval</code> property, starting 
 *  when the load begins and ending when all bytes are loaded or there is a network error. 
 *  The default is every 0.25 seconds starting when load is called and ending
 *  when all bytes are loaded or if there is a network error. Use this event to check 
 *  bytes loaded or number of bytes in the buffer. 
 *
 *  <p>Dispatched only for a progressive HTTP download. Indicates progress in number of 
 *  downloaded bytes. The event object has the <code>bytesLoaded</code> and <code>bytesTotal</code>
 *  properties</p>
 * 
 *  @eventType flash.events.ProgressEvent.PROGRESS
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="progress", type="flash.events.ProgressEvent")]

/**
 *  Dispatched when the video is loaded and ready to display.
 *
 *  <p>This event is dispatched the first time the VideoPlayer
 *  enters a responsive state after a new FLV is loaded
 *  with the <code>play()</code> or <code>load()</code> method.
 *  It is dispatched once for each FLV loaded.</p>
 *
 *  @eventType spark.events.VideoEvent.READY
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="ready", type="spark.events.VideoEvent")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("source")]

//[IconFile("VideoElement.png")]

/**
 *  The VideoElement class is chromeless video player that supports
 *  progressive download, multi-bitrate, and streaming video.
 * 
 *  <p><code>FxVideoDisplay</code> is the skinnable version.</p>
 *
 *  @see mx.components.FxVideoDisplay
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class VideoElement extends GraphicElement
{
    /**
     *  Constructor.
     *   
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function VideoElement()
    {
        super();
        VideoPlayer.iNCManagerClass = fl.video.NCManagerDynamicStream;
        mx_internal::videoPlayer = new VideoPlayer();
        mx_internal::videoPlayer.align = VideoAlign.CENTER;
        
        mx_internal::videoPlayer.addEventListener(fl.video.VideoEvent.CLOSE, videoPlayer_closeHandler);
        mx_internal::videoPlayer.addEventListener(fl.video.VideoEvent.COMPLETE, videoPlayer_completeHandler);
        mx_internal::videoPlayer.addEventListener(fl.video.MetadataEvent.METADATA_RECEIVED, videoPlayer_metaDataReceivedHandler);
        mx_internal::videoPlayer.addEventListener(fl.video.VideoEvent.PLAYHEAD_UPDATE, videoPlayer_playHeadUpdateHandler);
        mx_internal::videoPlayer.addEventListener(ProgressEvent.PROGRESS, dispatchEvent);
        mx_internal::videoPlayer.addEventListener(fl.video.VideoEvent.STATE_CHANGE, videoPlayer_stateChangeHandler);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  This is the underlying VideoPlayer object.  At some point in the 
     *  future, we may change to a new implementation.
     */
    mx_internal var videoPlayer:VideoPlayer;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    // We're overriding the displayObject getters/setters and methods to make 
    // videoPlayer the DisplayObject for this video graphic element.
    
    /**
     *  @private
     */
    override public function get displayObject():DisplayObject
    {
        return mx_internal::videoPlayer;
    }

    /**
     *  @private
     */
    override public function set displayObject(value:DisplayObject):void
    {
        // no-op
    }
    
    /**
     *  @private
     */
    override public function canDrawToShared(sharedDisplayObject:DisplayObject):Boolean
    {
        return false;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  autoPlay
    //----------------------------------

    /**
     *  @private
     *  Storage for autoPlay property.
     */
    private var _autoPlay:Boolean = true;

    [Inspectable(category="General", defaultValue="true")]

    /**
     *  Specifies whether the video should start playing immediately when the
     *  <code>source</code> property is set.
     *  If <code>true</code>, the video file immediately begins to buffer and
     *  play.
     *
     *  <p>Even if <code>autoPlay</code> is set to <code>false</code>, Flex
     *  starts loading the video after the <code>initialize()</code> method is
     *  called.
     *  For Flash Media Server, this means creating the stream and loading
     *  the first frame to display.
     *  In the case of an HTTP download, Flex starts downloading the stream
     *  and shows the first frame.</p>
     *  
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get autoPlay():Boolean
    {
        return _autoPlay;
    }

    /**
     * @private (setter)
     */
    public function set autoPlay(value:Boolean):void
    {
        if (_autoPlay == value)
            return;
        
        _isPlaying = value;
        _autoPlay = value;
    }
    
    //----------------------------------
    //  autoRewind
    //----------------------------------
    
    [Inspectable(category="General", defaultValue="true")]
    
    /**
     *  Specifies whether the FLV file should be rewound to the first frame
     *  when play stops, either by calling the <code>stop()</code> method or by
     *  reaching the end of the stream.
     *
     *  This property has no effect for live streaming video.
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get autoRewind():Boolean
    {
        return mx_internal::videoPlayer.autoRewind;
    }
    
    public function set autoRewind(value:Boolean):void
    {
        mx_internal::videoPlayer.autoRewind = value;
    }
        
    //----------------------------------
    //  isLive
    //----------------------------------

    /**
     *  @private
     *  Storage for isLive property.
     */
    private var _isLive:Boolean = false;

    [Inspectable(category="General", defaultValue="false")]

    /**
     *  A Boolean value that is <code>true</code> if the video stream is live. 
     *  This property is effective only when streaming from Flash Media Server 
     *  or Flash Video Streaming Service (FVSS). The value of this 
     *  property is ignored for an HTTP download.
     * 
     *  <p>Set the <code>isLive</code> property to <code>false</code> when sending 
     *  a prerecorded video stream to the video player and to <code>true</code> 
     *  when sending real-time data such as a live broadcast.
     *
     *  @see #source 
     *  @see VideoPlayer#isLive 
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get isLive():Boolean
    {
        return _isLive;
    }
    
    /**
     *  @private
     */
    public function set isLive(value:Boolean):void
    {
        _isLive = value;
        sourceChanged = true;
        invalidateProperties();
    }
    
    //----------------------------------
    //  isMuted
    //----------------------------------
    
    [Inspectable(category="General", defaultValue="false")]
    
    /**
     *  Returns true if the video is muted, false 
     *  if the video is not muted.
     *
     *  @see #mute()
     *  @see #unmute()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get isMuted():Boolean
    {
        return mutedVolume != -1;
    }
    
    //----------------------------------
    //  isPlaying
    //----------------------------------
    
    [Inspectable(category="General")]
    
    private var _isPlaying:Boolean = true; // initialize to same value as autoPlay
    
    /**
     *  Returns true if the video is playing or is attempting to play.
     *  
     *  <p>The video may not be currently playing, as it may be seeking 
     *  or buferring, but the video is attempting to play.<p> 
     *
     *  @see #play()
     *  @see #pause()
     *  @see #stop()
     *  @see #autoPlay
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get isPlaying():Boolean
    {
        return _isPlaying;
    }
        
    //----------------------------------
    //  maintainAspectRatio
    //----------------------------------

    /**
     *  @private
     *  Storage for maintainAspectRatio property.
     */
    private var _maintainAspectRatio:Boolean = true;
    
    [Inspectable(Category="General", defaultValue="true")]

    /**
     *  Specifies whether the control should maintain the original aspect ratio
     *  while resizing the video.
     * 
     *  <p>If no width, height, or constraints are specified on the VideoElement, 
     *  this property has no effect.</p>
     *
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get maintainAspectRatio():Boolean
    {
        return _maintainAspectRatio;
    }
    
    /**
     *  @private
     */
    public function set maintainAspectRatio(value:Boolean):void
    {
        if (_maintainAspectRatio != value)
        {
            _maintainAspectRatio = value;
            
            // VideoPlayer has MAINTAIN_ASPECT_RATIO, EXACT_FIT, and NO_SCALE
            // We don't need to worry about NO_SCALE as that's just not putting 
            // an explicit width on the VideoElement.
            if (value)
                mx_internal::videoPlayer.scaleMode = VideoScaleMode.MAINTAIN_ASPECT_RATIO;
            else
                mx_internal::videoPlayer.scaleMode = VideoScaleMode.EXACT_FIT;

            invalidateSize();
            invalidateDisplayList();
        }
    }
    
    //----------------------------------
    //  playheadTime
    //----------------------------------
    
    [Bindable("playheadUpdate")]
    [Inspectable(Category="General", defaultValue="0")]

    /**
     *  Playhead position, measured in seconds, since the video starting
     *  playing. 
     *  The event object for many of the VideoPlay events include the playhead
     *  position so that you can determine the location in the video file where
     *  the event occurred.
     * 
     *  <p>Setting this property to a value in seconds performs a seek
     *  operation. 
     *  If the video is currently playing,
     *  it continues playing from the new playhead position.  
     *  If the video is paused, it seeks to
     *  the new playhead position and remains paused.  
     *  If the video is stopped, it seeks to
     *  the new playhead position and enters the paused state.  
     *  Setting this property has no effect with live video streams.</p>
     *
     *  <p>If the new playhead position is less than 0 or NaN, 
     *  the control throws an exception. If the new playhead position
     *  is past the end of the video, or past the amount of the video file
     *  downloaded so far, then the control still attempts the seek.</p>
     *
     *  <p>For an FLV file, setting the <code>playheadTime</code> property seeks 
     *  to the keyframe closest to the specified position, where 
     *  keyframes are specified in the FLV file at the time of encoding. 
     *  Therefore, you might not seek to the exact time if there 
     *  is no keyframe specified at that position.</p>
     *
     *  <p>This property throws an exception if set when no stream is
     *  connected.  Use the <code>stateChange</code> event and the
     *  <code>connected</code> property to determine when it is
     *  safe to set this property.</p>
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get playheadTime():Number
    {
        return mx_internal::videoPlayer.playheadTime;
    }
    
    public function set playheadTime(value:Number):void
    {
        mx_internal::videoPlayer.playheadTime = value;
    }
    
    //----------------------------------
    //  source
    //----------------------------------
    
    private var _source:Object;
    private var sourceChanged:Boolean;
    
    [Bindable("sourceChanged")]
    [Inspectable(category="General", defaultValue="null")]
    
    /**
     *  Path or URL of the video file or stream to play.  For 
     *  multi-bitrate, <code>source</code> can be set to an Array 
     *  of objects, where each object has a streamName and a bitRate
     *  property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get source():Object
    {
        return _source;
    }

    /**
     * @private (setter)
     */
    public function set source(value:Object):void
    {
        if (_source == value)
            return;
        
        _source = value;
        sourceChanged = true;
        dispatchEvent(new Event("sourceChanged"));
        invalidateProperties();
    }
    
    //----------------------------------
    //  totalTime
    //----------------------------------

    [Bindable("complete")]
    [Bindable("metadataReceived")]
    [Inspectable(Category="General", defaultValue="0")]
    
    /**
     *  Total time for the video feed.  -1 means that property
     *  was not pass into <code>play()</code> or
     *  we were unable to detect the total time automatically,
     *  or have not yet.
     *
     *  @return The total running time of the FLV in seconds
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get totalTime():Number
    {
        return mx_internal::videoPlayer.totalTime;
    }
    
    //----------------------------------
    //  volume
    //----------------------------------
    
    [Bindable("volumeChanged")]
    [Inspectable(category="General", defaultValue="1.0")]

    /**
     *  The volume level, specified as an value between 0 and 1.
     * 
     *  @default 1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get volume():Number
    {
        if (mutedVolume == -1)
            return mx_internal::videoPlayer.volume;
        else
            return mutedVolume;
    }
    
    /**
     *  @private
     */
    public function set volume(value:Number):void
    {
        mutedVolume = -1;
        mx_internal::videoPlayer.volume = value;
        dispatchEvent(new Event("volumeChanged"));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (sourceChanged)
        {
            sourceChanged = false;
            if (autoPlay)
            {
                play();
            }
            else
            {
                // TODO: should we load the video if autoPlay is false?
                mx_internal::videoPlayer.load(source as String, NaN, isLive);
            }
        }
    }
    
    /**
     *  @private
     */
    override protected function measure() : void
    {
        super.measure();

        var vw:Number = mx_internal::videoPlayer.videoWidth;
        var vh:Number = mx_internal::videoPlayer.videoHeight;

        measuredWidth = vw;
        measuredHeight = vh;

        // Determine whether 'width' and 'height' have been set.
        var bExplicitWidth:Boolean = !isNaN(explicitWidth);
        var bExplicitHeight:Boolean = !isNaN(explicitHeight);

        // If only one has been set, calculate the other based on aspect ratio.
        if (_maintainAspectRatio && (bExplicitWidth || bExplicitHeight))
        {
            if (bExplicitWidth && !bExplicitHeight && vw > 0)
                measuredHeight = explicitWidth * vh / vw;
            else if (bExplicitHeight && !bExplicitWidth && vh > 0)
                measuredWidth = explicitHeight * vw / vh;
        }
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number) : void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        mx_internal::videoPlayer.width = Math.floor(unscaledWidth);
        mx_internal::videoPlayer.height = Math.floor(unscaledHeight);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  mutedVolume tracks what the volume was before we were 
     *  muted.  If we aren't muted, mutedVolume = -1.
     */
    private var mutedVolume:Number = -1;
    
    /**
     *  Mutes the volume of the video.  The volume property will be 
     *  unaffected by this method, but the volume will be muted.  If the 
     *  volume is already muted, this method will have no effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function mute():void
    {
        if (mutedVolume != -1)
            return;
        
        mutedVolume = volume;
        mx_internal::videoPlayer.volume = 0;
    }
    
    /**
     *  Pauses playback without moving the playhead. 
     *  If playback is already is paused or is stopped, this method has no
     *  effect.  
     *
     *  <p>To start playback again, call the <code>play()</code> method.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function pause():void
    {
        mx_internal::videoPlayer.pause();
    }
    
    /**
     *  Causes the video to play.  Can be called while the video is
     *  paused, stopped, or while the video is already playing.
     *
     *  @param startTime Time to start playing the clip from.  
     *  Pass in -1 to start at the beginning or the 
     *  current spot in the clip if paused.  Default is -1.
     *  @param duration Duration, in seconds, to play.  Pass in -1 
     *  to automatically detect length from metadata, server
     *  or xml.  Default is -1.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function play(startTime:Number=-1, duration:Number=-1):void
    {
        if (startTime != -1)
            seek(startTime);
        
        var source:String;
        
        if (mx_internal::videoPlayer.state == VideoState.PAUSED)
            source = null;
        else
            source = this.source as String;
        
        mx_internal::videoPlayer.play(source, duration, isLive);
    }
   
    /**
     *  Seeks to given second in video.  If video is playing,
     *  continues playing from that point.  If video is paused, seek to
     *  that point and remain paused.  If video is stopped, seek to
     *  that point and enters paused state.  Has no effect with live
     *  streams.
     *
     *  <p>If time is less than 0 or NaN, throws exeption.  If time
     *  is past the end of the stream, or past the amount of file
     *  downloaded so far, then will attempt seek and when fails
     *  will recover.</p>
     *
     *  @param time seconds
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function seek(time:Number):void
    {
        if (time < 0)
            time = 0;
        
        mx_internal::videoPlayer.seek(time);
    }
    
    /**
     *  Stops video playback.  If <code>autoRewind</code> is set to
     *  <code>true</code>, rewinds to first frame.  If video is already
     *  stopped, has no effect.  To start playback again, call
     *  <code>play()</code>.
     *
     *  @see #autoRewind
     *  @see #play()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function stop():void
    {
        mx_internal::videoPlayer.stop();
    }

    /**
     *  Unmutes the volume of the video.  If the volume was muted, this 
     *  method will set the volume at its previous level.  If the 
     *  volume was not muted, this method will have no effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */    
    public function unmute():void
    {
        if (mutedVolume == -1)
            return;
        
        mx_internal::videoPlayer.volume = mutedVolume;
        mutedVolume = -1;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function videoPlayer_closeHandler(event:fl.video.VideoEvent):void
    {
        var sparkVideoEvent:spark.events.VideoEvent = new spark.events.VideoEvent(event.type, event.bubbles, event.cancelable, event.playheadTime);
        dispatchEvent(sparkVideoEvent);
    }
    
    /**
     *  @private
     */
    private function videoPlayer_completeHandler(event:fl.video.VideoEvent):void
    {
        var sparkVideoEvent:spark.events.VideoEvent = new spark.events.VideoEvent(event.type, event.bubbles, event.cancelable, event.playheadTime);
        dispatchEvent(sparkVideoEvent);
    }
    
    /**
     *  @private
     */
    private function videoPlayer_metaDataReceivedHandler(event:fl.video.MetadataEvent):void
    {
        invalidateSize();
        var sparkMetadataEvent:spark.events.MetadataEvent = new spark.events.MetadataEvent(event.type, event.bubbles, event.cancelable, event.info);
        dispatchEvent(sparkMetadataEvent);
    }
    
    /**
     *  @private
     */
    private function videoPlayer_playHeadUpdateHandler(event:fl.video.VideoEvent):void
    {
        var sparkVideoEvent:spark.events.VideoEvent = new spark.events.VideoEvent(event.type, event.bubbles, event.cancelable, event.playheadTime);
        dispatchEvent(sparkVideoEvent);
    }
    
    /**
     *  @private
     */
    private function videoPlayer_stateChangeHandler(event:fl.video.VideoEvent):void
    {
        switch (event.state)
        {
            case VideoState.PLAYING:
                _isPlaying = true;
                break;
            case VideoState.PAUSED:
            case VideoState.STOPPED:
            case VideoState.DISCONNECTED:
            case VideoState.CONNECTION_ERROR:
                _isPlaying = false;
                break;
        }
        
        dispatchEvent(event);
    }
}
}