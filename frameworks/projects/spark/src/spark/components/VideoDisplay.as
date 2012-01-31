////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
///////////////////////////////////////////////////////////////////////////////

package spark.primitives
{
import fl.video.DynamicStream;
import fl.video.DynamicStreamItem;
import fl.video.MetadataEvent;
import fl.video.VideoAlign;
import fl.video.VideoEvent;
import fl.video.VideoPlayer;
import fl.video.VideoScaleMode;
import fl.video.VideoState;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.geom.Matrix;
import flash.media.Video;

import mx.core.mx_internal;

import spark.components.supportClasses.StreamItem;
import spark.components.supportClasses.StreamingVideoSource;
import spark.core.IGraphicElement;
import spark.events.VideoEvent;
import spark.primitives.supportClasses.GraphicElement;

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
 *  @eventType spark.events.VideoEvent.METADATA_RECEIVED
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="metadataReceived", type="spark.events.VideoEvent")]

/**
 *  Dispatched every 0.25 seconds while the 
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
 *  Indicates progress made in number of bytes downloaded. Dispatched starting 
 *  when the load begins and ending when all bytes are loaded or there is a network error. 
 *  Dispatched every 0.25 seconds starting when load is called and ending
 *  when all bytes are loaded or if there is a network error. Use this event to check 
 *  bytes loaded or number of bytes in the buffer. 
 *
 *  <p>Dispatched only for a progressive HTTP download. Indicates progress in number of 
 *  downloaded bytes. The event object has the <code>bytesLoaded</code> and <code>bytesTotal</code>
 *  properties.</p>
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

[IconFile("VideoElement.png")]

/**
 *  The VideoElement class is chromeless video player that supports
 *  progressive download, multi-bitrate, and streaming video.
 * 
 *  <p><code>VideoPlayer</code> is the skinnable version.</p>
 *
 *  @see mx.components.VideoPlayer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class VideoElement extends GraphicElement
{
    include "../core/Version.as";
    
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
        
        var flvPlayer:VideoPlayer = new VideoPlayer();
        mx_internal::videoPlayer = flvPlayer;
        
        flvPlayer.align = VideoAlign.CENTER;
        // unfortunately, there's a bug in the video player that 
        // won't easily let align center if we set x and y directly 
        // on the video player.  So to work-around this, we always 
        // create a transform and set x/y that way
        allocateLayoutFeatures();
               
        flvPlayer.addEventListener(fl.video.VideoEvent.CLOSE, videoPlayer_closeHandler);
        flvPlayer.addEventListener(fl.video.VideoEvent.COMPLETE, videoPlayer_completeHandler);
        flvPlayer.addEventListener(fl.video.MetadataEvent.METADATA_RECEIVED, videoPlayer_metaDataReceivedHandler);
        flvPlayer.addEventListener(fl.video.VideoEvent.PLAYHEAD_UPDATE, videoPlayer_playHeadUpdateHandler);
        flvPlayer.addEventListener(ProgressEvent.PROGRESS, dispatchEvent);
        flvPlayer.addEventListener(fl.video.VideoEvent.STATE_CHANGE, videoPlayer_stateChangeHandler);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  This is the underlying VideoPlayer object. At some point in the 
     *  future, we may change to a new implementation.
     */
    mx_internal var videoPlayer:VideoPlayer;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function get displayObject():DisplayObject
    {
        // The VideoElement always has its own DisplayObject
        return mx_internal::videoPlayer;
    }

    /**
     *  @private
     */
    override public function setSharedDisplayObject(sharedDisplayObject:DisplayObject):Boolean
    {
        // The VideoElement never uses shared DisplayObject
        return false;
    }
    
    /**
     *  @private
     */
    override public function canShareWithNext(element:IGraphicElement):Boolean
    {
        // Other GraphicElements should never use our DisplayObject
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
        
        _playing = value;
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
     *  <p>This property has no effect for live streaming video.</p>
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
        var myVideoPlayer:VideoPlayer = mx_internal::videoPlayer;
        return myVideoPlayer.autoRewind;
    }
    
    public function set autoRewind(value:Boolean):void
    {
        mx_internal::videoPlayer.autoRewind = value;
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
    //  muted
    //----------------------------------
    
    /**
     *  @private
     *  mutedVolume tracks what the volume was before we were 
     *  muted. If we aren't muted, mutedVolume = -1.
     */
    private var mutedVolume:Number = -1;
    
    [Inspectable(category="General", defaultValue="false")]
    
    /**
     *  Set to <code>true</code> to mute the video, <code>false</code> 
     *  to unmute the video.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get muted():Boolean
    {
        return mutedVolume != -1;
    }
    
    /**
     *  @private
     */
    public function set muted(value:Boolean):void
    {
        // if trying to unmute and we're muted
        if (!value && mutedVolume != -1)
        {
            mx_internal::videoPlayer.volume = mutedVolume;
            mutedVolume = -1;
            dispatchEvent(new Event("volumeChanged"));
        }
        // if trying to mute and we're not muted
        else if (value && mutedVolume == -1)
        {
            mutedVolume = mx_internal::videoPlayer.volume;
            mx_internal::videoPlayer.volume = 0;
            dispatchEvent(new Event("volumeChanged"));
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
    //  playing
    //----------------------------------
    
    [Inspectable(category="General")]
    
    private var _playing:Boolean = false;
    
    [Bindable("playingChanged")]
    /**
     *  Returns true if the video is playing or is attempting to play.
     *  
     *  <p>The video may not be currently playing, as it may be seeking 
     *  or buferring, but the video is attempting to play.</p> 
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
    public function get playing():Boolean
    {
        return _playing;
    }
    
    /**
     *  @private
     *  Sets the playing variable to true or false and dispatches 
     *  the appropriate event.  We don't check to compare it to 
     *  the last value because we want this event to dispatch every 
     *  time.  This way when the playPauseButton is toggled in VideoPlayer, 
     *  this binding event has the last word as to whether we are actually 
     *  playing or paused (Someone could click the play button, but if there's 
     *  no source, we want to still show the play button rather than toggle it 
     *  as ToggleButton's do naturally).
     */
    private function setPlaying(value:Boolean):void
    {
        _playing = value;
        dispatchEvent(new Event("playingChanged"));
    }
    
    //----------------------------------
    //  source
    //----------------------------------
    
    private var _source:Object;
    private var sourceChanged:Boolean;
    
    /**
     *  @private
     *  Keeps track of the last source that's been played.  That way if 
     *  we've been paused, we pass in play(null) to the underlying video player.  
     *  Passing in play(source) resets the stream back to 0.
     */
    private var sourceLastPlayed:Object;
    
    [Bindable("sourceChanged")]
    [Inspectable(category="General", defaultValue="null")]
    
    /**
     *  For progressive download, the source is just a path or URL pointing 
     *  to the video file to play.  For streaming (streaming, live streaming, 
     *  or multi-bitrate streaming), the source property is a 
     *  StreamingVideoSource object.
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
    //  videoObject
    //----------------------------------

    /**
     *  The underlying flash player flash.media.Video object
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get videoObject():Video
    {
        return mx_internal::videoPlayer as Video;
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
        return mx_internal::videoPlayer.volume;
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
                load();
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
        
        var flvPlayer:VideoPlayer = mx_internal::videoPlayer;
        
        flvPlayer.width = Math.floor(unscaledWidth);
        flvPlayer.height = Math.floor(unscaledHeight);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
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
        setPlaying(false);
        mx_internal::videoPlayer.pause();
    }
    
    /**
     *  Causes the video to play.  Can be called while the video is
     *  paused, stopped, or while the video is already playing.
     *
     *  @param startTime Time to start playing the clip from.  
     *  Pass in NaN to start at the beginning or the 
     *  current spot in the clip if paused.  Default is NaN.
     *  
     *  @param duration Duration, in seconds, to play.  Pass in NaN 
     *  to automatically detect length from metadata, server
     *  or xml.  Default is NaN.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function play(startTime:Number=NaN, duration:Number=NaN):void
    {
        // check for 2 cases: streaming video or progressive download
        if (source is StreamingVideoSource)
        {
            // the streaming video case.
            // build up a DynamicStreamItem to pass in to 
            // play2();
            var streamingSource:StreamingVideoSource = source as StreamingVideoSource;
            var flvSource:DynamicStreamItem;
        
            // if paused, pass in null as the flvSource.  Otherwise, calling 
            // play(source) will reset the stream back to zero.  To restart the 
            // stream where it was paused, one needs to call play(null).
            if (sourceLastPlayed == this.source)
            {
                flvSource = null;
            }
            else
            {
                flvSource =  new DynamicStreamItem();
                sourceLastPlayed = source;
        
                flvSource.uri = streamingSource.serverURI;
            
                var n:int = streamingSource.streamItems.length;
                var item:StreamItem;
                for (var i:int = 0; i < n; i++)
                {
                    item = StreamItem(streamingSource.streamItems[i]);
                    flvSource.addStream(item.streamName, item.bitRate);
                }
            }
            
            // could wait for stateChange event, but let's do it early
            // so the UI is more responsive
            setPlaying(true);
            
            // we don't do anything with the duration or startTime in 
            // the play2() case, as the underlying FLVPlayback VideoPlayer
            // doesn't handle it right now.
            
            // TODO (rfrishbe): Could we just call play2() and then call seek()
            // like we do in the progressive case?  Is it worth it?  Need to talk
            // to Strobe team about this.

            mx_internal::videoPlayer.play2(flvSource);
        }
        else if (source is String && String(source).length != 0)
        {
            // The progressive case
            var sourceString:String;
        
            // if paused, pass in null as the flvSource.  Otherwise, calling 
            // play(source) will reset the stream back to zero.  To restart the 
            // stream where it was paused, one needs to call play(null).
            if (sourceLastPlayed == this.source)
            {
                sourceString = null;
            }
            else
            {
                sourceString = String(this.source);
                sourceLastPlayed = sourceString;
            }
            
            // could wait for stateChange event, but let's do it early
            // so the UI is more responsive
            setPlaying(true);
            
            // TODO (rfrishbe): how we handle startTime is pretty hacky.
            // Need to figure out if there's a better way or talk to Strobe 
            // team to see if this is even worth it.  Right now, we're also 
            // inconsistent with the streaming case.
            
            if (sourceString != null && !isNaN(startTime))
            {
                // If we need to seek before playing, and we haven't 
                // seen this video yet, 
                // we load up the video, call seek(), and then 
                // call play(null)
                mx_internal::videoPlayer.load(sourceString);
                
                seek(startTime);
                
                if (isNaN(duration))
                    mx_internal::videoPlayer.play(null);
                else
                    mx_internal::videoPlayer.play(null, false, duration);
            }
            else
            {
                // if we've played this video before or we don't 
                // need to seek (startTime is null), we can handle these 
                // cases separately
                if (!isNaN(startTime))
                    seek(startTime);
   
                if (isNaN(duration))
                    mx_internal::videoPlayer.play(sourceString);
                else
                    mx_internal::videoPlayer.play(sourceString, false, duration);
            }
        }
        else
        {
            setPlaying(false);
        }
    }
    
    /**
     *  @private
     *  Load the video.  This allows seeks and other operations to 
     *  be performed before the video's started to play.
     */
    private function load():void
    {
        // essentially a load is a play and then a pause
        
        // check for 2 cases: streaming video or progressive download
        if (source is StreamingVideoSource)
        {
            // can't load in the streaming video case
            play();
            pause();
        }
        else if (source is String && String(source).length != 0)
        {
            // The progressive case
            var sourceString:String;
        
            // if paused, pass in null as the flvSource.  Otherwise, calling 
            // play(source) will reset the stream back to zero.  To restart the 
            // stream where it was paused, one needs to call play(null).
            if (sourceLastPlayed == this.source)
            {
                sourceString = null;
            }
            else
            {
                sourceString = String(this.source);
                sourceLastPlayed = sourceString;
            }
           
            // load the video up
            mx_internal::videoPlayer.load(sourceString);
        }
        
        setPlaying(false);
    }
   
    /**
     *  Seeks to given second in video. If video is playing,
     *  continues playing from that point. If video is paused, seek to
     *  that point and remain paused. If video is stopped, seek to
     *  that point and enters paused state. Has no effect with live
     *  streams.
     *
     *  <p>If time is less than 0 or NaN, throws exeption. If time
     *  is past the end of the stream, or past the amount of file
     *  downloaded so far, then will attempt seek and when fails
     *  will recover.</p>
     * 
     *  <p>The <code>playheadTime</code> property might not have the expected value 
     *  immediately after you call one of the seek methods or set  
     *  <code>playheadTime</code> to cause seeking. For a progressive download,
     *  you can seek only to a keyframe; therefore, a seek takes you to the 
     *  time of the first keyframe after the specified time.</p>
     *  
     *  <p><strong>Note</strong>: When streaming, a seek always goes to the precise specified 
     *  time even if the source FLV file doesn't have a keyframe there.</p>
     *
     *  <p>Seeking is asynchronous, so if you call a seek method or set the 
     *  <code>playheadTime</code> property, <code>playheadTime</code> does not update immediately. 
     *  To obtain the time after the seek is complete, listen for the <code>seek</code> event, 
     *  which does not start until the <code>playheadTime</code> property is updated.</p>
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
        setPlaying(false);
        mx_internal::videoPlayer.stop();
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
        var sparkVideoEvent:spark.events.VideoEvent = 
            new spark.events.VideoEvent(event.type, event.bubbles, event.cancelable, event.playheadTime);
        dispatchEvent(sparkVideoEvent);
    }
    
    /**
     *  @private
     */
    private function videoPlayer_completeHandler(event:fl.video.VideoEvent):void
    {
        var sparkVideoEvent:spark.events.VideoEvent = 
            new spark.events.VideoEvent(event.type, event.bubbles, event.cancelable, event.playheadTime);
        dispatchEvent(sparkVideoEvent);
    }
    
    /**
     *  @private
     */
    private function videoPlayer_metaDataReceivedHandler(event:fl.video.MetadataEvent):void
    {
        invalidateSize();
        var sparkVideoEvent:spark.events.VideoEvent = 
            new spark.events.VideoEvent(event.type, event.bubbles, event.cancelable, playheadTime, event.info);
        dispatchEvent(sparkVideoEvent);
    }
    
    /**
     *  @private
     */
    private function videoPlayer_playHeadUpdateHandler(event:fl.video.VideoEvent):void
    {
        var sparkVideoEvent:spark.events.VideoEvent = 
            new spark.events.VideoEvent(event.type, event.bubbles, event.cancelable, event.playheadTime);
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
                setPlaying(true);
                break;
            case VideoState.STOPPED:
            case VideoState.DISCONNECTED:
            case VideoState.CONNECTION_ERROR:
                setPlaying(false);
                break;
        }
        
        dispatchEvent(event);
    }
}
}
