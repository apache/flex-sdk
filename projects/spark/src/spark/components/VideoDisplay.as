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

// FIXME (rfrishbe): Change package name and classname

import fl.video.DynamicStreamItem;
import fl.video.MetadataEvent;
import fl.video.NCManagerDynamicStream;
import fl.video.VideoError;
import fl.video.VideoEvent;
import fl.video.VideoPlayer;
import fl.video.VideoScaleMode;
import fl.video.VideoState;
import fl.video.flvplayback_internal;

import flash.events.Event;
import flash.events.ProgressEvent;
import flash.media.Video;

import mx.core.UIComponent;
import mx.core.mx_internal;

import spark.components.Group;
import spark.components.mediaClasses.StreamItem;
import spark.components.mediaClasses.StreamingVideoSource;
import spark.events.VideoEvent;

use namespace mx_internal;

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
public class VideoElement extends UIComponent
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
        
        // set up the VideoPlayer's iNCManagerClass to point to our FlexNCManager, 
        // which is a private class
        VideoPlayer.iNCManagerClass = FlexNCManager;
        
        // create the underlying FLVPlayback class
        createUnderlyingVideoPlayer();
        
        // added and removed event listeners to see whether we should
        // start or stop the video
        addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
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
        
        _autoPlay = value;
    }
    
    /**
     *  @private
     *  Whether we should be playing or not
     */
    private function get effectivePlay():Boolean
    {
        return playWhenHidden || (visible && _isOnDisplayList && enabled && _parentVisibility);
    }
    
    /**
     *  @private
     *  Whether we should autoPlay or not
     */
    private function get effectiveAutoPlay():Boolean
    {
        return autoPlay && effectivePlay;
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
        var myVideoPlayer:VideoPlayer = videoPlayer;
        return myVideoPlayer.autoRewind;
    }
    
    public function set autoRewind(value:Boolean):void
    {
        videoPlayer.autoRewind = value;
    }
    
    //----------------------------------
    //  enabled
    //----------------------------------
    
    [Inspectable(category="General", enumeration="true,false", defaultValue="true")]
    [Bindable("enabledChanged")]
    
    /**
     *  @inheritDoc
     * 
     *  <p>Setting enabled to <code>false</code> 
     *  pauses the video if it was currently playing.  Re-enabling the component
     *  does not cause the video to continue playing again; you must 
     *  explicitly call <code>play()</code>.</p>
     * 
     *  <p>Even though the component is initially paused while disabled, 
     *  if you would like to play the video or perform some other action 
     *  while disabled, you may still do so through method calls, like 
     *  <code>play()</code>.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function set enabled(value:Boolean):void
    {
        if (value == enabled)
            return;
        
        if (!value)
        {
            if (playing)
                pause();
        }
        
        super.enabled = value;
    }
    
    //----------------------------------
    //  loop
    //----------------------------------
    
    /**
     *  @private
     *  Storage for loop property.
     */
    private var _loop:Boolean = false;
    
    [Inspectable(Category="General", defaultValue="false")]
    
    /**
     *  Indicates whether the media should play again after playback has completed. 
     *  The <code>loop</code> property takes precedence over the the <code>autoRewind</code>
     *  property, so if loop is set to <code>true</code>, the <code>autoRewind</code> 
     *  property is ignored. 
     *
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get loop():Boolean
    {
        return _loop;
    }
    
    /**
     *  @private
     */
    public function set loop(value:Boolean):void
    {
        _loop = value;
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
                videoPlayer.scaleMode = VideoScaleMode.MAINTAIN_ASPECT_RATIO;
            else
                videoPlayer.scaleMode = VideoScaleMode.EXACT_FIT;
            
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
    [Bindable("volumeChanged")]
    
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
            videoPlayer.volume = mutedVolume;
            mutedVolume = -1;
            dispatchEvent(new Event("volumeChanged"));
        }
        // if trying to mute and we're not muted
        else if (value && mutedVolume == -1)
        {
            mutedVolume = videoPlayer.volume;
            videoPlayer.volume = 0;
            dispatchEvent(new Event("volumeChanged"));
        }
    }
    
    //----------------------------------
    //  parentVisibility
    //----------------------------------
    
    /**
     *  @private
     */
    private var _parentVisibility:Boolean = true;
    
    /**
     *  @private
     *  Used so that VideoPlayer can reach down and change our effectivePlay/effectiveAutoPlay flag
     */
    mx_internal function set parentVisibility(value:Boolean) : void
    {
        _parentVisibility = value;
        
        // if we want our playback to be controlled by visibility
        if (!playWhenHidden)
        {
            // if we shouldn't be playing and we are, then pause it
            // otherwise if we aren't playing and we should be, then play
            if (!effectivePlay && playing)
                pause();
            else if (effectiveAutoPlay && !playing)
                play();
        }
    }
    
    //----------------------------------
    //  playheadTime
    //----------------------------------
    
    [Bindable("playheadUpdate")]
    [Bindable("playheadTimeChanged")]
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
        return videoPlayer.playheadTime;
    }
    
    //----------------------------------
    //  playing
    //----------------------------------
    
    private var _playing:Boolean = false;
    
    [Inspectable(category="General")]
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
    //  playWhenHidden
    //----------------------------------
    
    /**
     *  @private
     *  Storage variable for playWhenHidden
     */
    private var _playWhenHidden:Boolean = false;
    
    [Inspectable(category="General", defaultValue="false")]
    
    /**
     *  Controls whether the video continues to play when it is
     *  hidden.  The video is hidden when either <code>visible</code>
     *  is set to <code>false</code> or when the video is taken off 
     *  of the display list.  If set to <code>false</code>, the video 
     *  will pause playback until the video is visible again.  If set to 
     *  <code>true</code> the video will continue to play when it is hidden.
     *  The default is <code>false</code>.
     * 
     *  @default false
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get playWhenHidden():Boolean
    {
        return _playWhenHidden;
    }
    
    /**
     *  @private
     */
    public function set playWhenHidden(value:Boolean):void
    {
        _playWhenHidden = value;
        
        // if we want our playback to be controlled by visibility
        if (!playWhenHidden)
        {
            // if we shouldn't be playing and we are, then pause it
            // otherwise if we aren't playing and we should be, then play
            if (!effectivePlay && playing)
                pause();
            else if (effectiveAutoPlay && !playing)
                play();
        }
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
        
        // if we haven't initialized, let's wait to set up the 
        // source in commitProperties() as it is dependent on other 
        // properties, like autoPlay and enabled, and those may not 
        // be set yet, especially if they are set via MXML.
        // Otherwise, if we have initialized, let's just set up the 
        // source immediately.  This way people can change the source 
        // and immediately call methods like seek().
        if (!initializedOnce)
        {
            sourceChanged = true;
            invalidateProperties();
        }
        else
        {
            setUpSource();
        }
        
        dispatchEvent(new Event("sourceChanged"));
    }
    
    /**
     *  @private
     *  Sets up the source for use.  Also throws away the underlying video player object 
     *  if needed.
     */
    private function setUpSource():void
    {
        // Reset the video component under certain conditions: 
        // Only keep the video player if the last item played was a 
        // String and the current item being played is a String
        // or if the last item was null or an empty string
        if ( !((sourceLastPlayed is String && source is String) ||
            (sourceLastPlayed == null || (sourceLastPlayed is String && String(sourceLastPlayed).length == 0))))
        {
            createUnderlyingVideoPlayer();
        }
        
        sourceLastPlayed = null;
        
        // play if we should be autoPlaying.  Otherwise, just load the video.
        if (effectiveAutoPlay)
            play();
        else
            load();
    }
    
    //----------------------------------
    //  thumbnailSource
    //----------------------------------
    
    private var _thumbnailSource:Object;
    
    /**
     *  @private
     *  Group that holds the BitmapImage for the thumbnail
     */
    private var thumbnailGroup:Group;
    
    [Inspectable(Category="General")]
    
    /**
     *  @private
     *  Thumbnail source is an internal property used to replace the video with a thumbnail.
     *  This is for places where we just want to load in a placeholder object for the video 
     *  and don't want to incur the extra load-time or memory of loading up the video.
     * 
     *  <p>Thumbnail source can take any valid source that can be passed in to 
     *  <code>spark.primitivies.BitmapImage#source</code>.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    mx_internal function get thumbnailSource():Object
    {
        return _thumbnailSource;
    }
    
    /**
     *  @private
     */
    mx_internal function set thumbnailSource(value:Object):void
    {
        if (_thumbnailSource == value)
            return;
        
        _thumbnailSource = value;
        
        // if we haven't initialized, let's wait to set up the 
        // source in commitProperties() as it is dependent on other 
        // properties, like autoPlay and enabled, and those may not 
        // be set yet, especially if they are set via MXML.
        // Otherwise, if we have initialized, let's just set up the 
        // source immediately.  This way people can change the source 
        // and immediately call methods like seek().
        if (!initializedOnce)
        {
            sourceChanged = true;
            invalidateProperties();
        }
        else
        {
            setUpThumbnailSource();
        }
    }
    
    /**
     *  @private
     *  Sets up the thumbnail source for use.
     */
    private function setUpThumbnailSource():void
    {
        if (thumbnailSource)
        {
            var bitmapImage:BitmapImage;
            if (!thumbnailGroup)
            {
                bitmapImage = new BitmapImage();
                
                bitmapImage.left = 0;
                bitmapImage.right = 0;
                bitmapImage.top = 0;
                bitmapImage.bottom = 0;
                
                thumbnailGroup = new Group();
                thumbnailGroup.addElement(bitmapImage);
                addChild(thumbnailGroup);
            }
            else
            {
                bitmapImage = thumbnailGroup.getElementAt(0) as BitmapImage;
            }
            
            bitmapImage.source = thumbnailSource;
        }
    }
    
    //----------------------------------
    //  totalTime
    //----------------------------------
    
    [Bindable("complete")]
    [Bindable("metadataReceived")]
    [Bindable("totalTimeChanged")]
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
        return videoPlayer.totalTime;
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
        return videoPlayer as Video;
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
        return videoPlayer.volume;
    }
    
    /**
     *  @private
     */
    public function set volume(value:Number):void
    {
        mutedVolume = -1;
        videoPlayer.volume = value;
        dispatchEvent(new Event("volumeChanged"));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Override setVisible to see if we should pause or play or video
     */
    override public function setVisible(value:Boolean, noEvent:Boolean=false) : void
    {
        super.setVisible(value, noEvent);
        
        // if we want our playback to be controlled by visibility
        if (!playWhenHidden)
        {
            // if we shouldn't be playing and we are, then pause it
            // otherwise if we aren't playing and we should be, then play
            if (!effectivePlay && playing)
                pause();
            else if (effectiveAutoPlay && !playing)
                play();
        }
    }
    
    /**
     *  @private
     *  We do different things in the source setter based on if we 
     *  are initialized or not.
     */
    private var initializedOnce:Boolean = false;
    
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        initializedOnce = true;
        
        if (sourceChanged)
        {
            sourceChanged = false;
            
            if (thumbnailSource)
                setUpThumbnailSource();
            else
                setUpSource();
        }
    }
    
    /**
     *  @private
     */
    private var videoPlayerProperties:Object;
    
    /**
     *  @private
     */
    private function createUnderlyingVideoPlayer():void
    {
        // if old one, destroy it
        if (videoPlayer)
        {
            videoPlayerProperties = {autoRewind: videoPlayer.autoRewind,
                                     scaleMode: videoPlayer.scaleMode};
            
            // if we try to stop and are throwing away this video, just 
            // ignore any errors. This might happen if the connection went 
            // bad or something else and we're trying to throw it away anyways.
            try
            {
                videoPlayer.stop();
            } catch (e:VideoError) {};
            
            // clear out old video player and close the connection
            videoPlayer.close();
            videoPlayer.clear();
            
            videoPlayer.removeEventListener(fl.video.VideoEvent.AUTO_REWOUND, videoPlayer_autoRewoundHandler);
            videoPlayer.removeEventListener(fl.video.VideoEvent.CLOSE, videoPlayer_closeHandler);
            videoPlayer.removeEventListener(fl.video.VideoEvent.COMPLETE, videoPlayer_completeHandler);
            videoPlayer.removeEventListener(fl.video.MetadataEvent.METADATA_RECEIVED, videoPlayer_metaDataReceivedHandler);
            videoPlayer.removeEventListener(fl.video.VideoEvent.PLAYHEAD_UPDATE, videoPlayer_playHeadUpdateHandler);
            videoPlayer.removeEventListener(ProgressEvent.PROGRESS, dispatchEvent);
            videoPlayer.removeEventListener(fl.video.VideoEvent.READY, videoPlayer_readyHandler);
            videoPlayer.removeEventListener(fl.video.VideoEvent.STATE_CHANGE, videoPlayer_stateChangeHandler);
            
            removeChild(videoPlayer);
        }
        
        // create new video player
        videoPlayer = new VideoPlayer();
        
        if (videoPlayerProperties)
        {
            videoPlayer.autoRewind = videoPlayerProperties.autoRewind;
            videoPlayer.scaleMode = videoPlayerProperties.scaleMode;
            
            videoPlayerProperties = null;
        }
        
        videoPlayer.addEventListener(fl.video.VideoEvent.AUTO_REWOUND, videoPlayer_autoRewoundHandler);
        videoPlayer.addEventListener(fl.video.VideoEvent.CLOSE, videoPlayer_closeHandler);
        videoPlayer.addEventListener(fl.video.VideoEvent.COMPLETE, videoPlayer_completeHandler);
        videoPlayer.addEventListener(fl.video.MetadataEvent.METADATA_RECEIVED, videoPlayer_metaDataReceivedHandler);
        videoPlayer.addEventListener(fl.video.VideoEvent.PLAYHEAD_UPDATE, videoPlayer_playHeadUpdateHandler);
        videoPlayer.addEventListener(ProgressEvent.PROGRESS, dispatchEvent);
        videoPlayer.addEventListener(fl.video.VideoEvent.READY, videoPlayer_readyHandler);
        videoPlayer.addEventListener(fl.video.VideoEvent.STATE_CHANGE, videoPlayer_stateChangeHandler);
        
        addChild(videoPlayer);
        
        dispatchEvent(new Event("playheadTimeChanged"));
        dispatchEvent(new Event("totalTimeChanged"));
    }
    
    /**
     *  @private
     */
    override protected function measure() : void
    {
        super.measure();
        
        // if showing the thumbnail, just use the thumbnail's size
        if (thumbnailSource && thumbnailGroup)
        {
            measuredWidth = thumbnailGroup.getPreferredBoundsWidth();
            measuredHeight = thumbnailGroup.getPreferredBoundsHeight();
            return;
        }
        
        // otherwise grab the width/height from the video
        var vw:Number = videoPlayer.videoWidth;
        var vh:Number = videoPlayer.videoHeight;
        
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
        
        // if just showing the thumbnail, push this width/height in to the thumbnail
        // otherwise we'll push it in to the video object
        if (thumbnailSource && thumbnailGroup)
        {
            var imageWidth:Number;
            var imageHeight:Number;
            var bitmapImage:BitmapImage = thumbnailGroup.getElementAt(0) as BitmapImage;
            
            if (!maintainAspectRatio)
            {
                // if not maintainAspectRatio, the width and height of the image 
                // are what the layout wants them to be and the image is stretched or shrunken
                imageWidth = unscaledWidth;
                imageHeight = unscaledHeight;
                
                thumbnailGroup.setLayoutBoundsSize(imageWidth, imageHeight);
            }
            else
            {
                // the image dimensions need to maintain aspect ratio
                var realRatio:Number = thumbnailGroup.getPreferredBoundsWidth()/thumbnailGroup.getPreferredBoundsHeight();
                
                if (unscaledWidth / realRatio < unscaledHeight)
                {
                    // width is restrictive size
                    imageWidth = unscaledWidth;
                    imageHeight = unscaledWidth / realRatio;
                }
                else
                {
                    // height is restrictive size
                    imageWidth = unscaledHeight * realRatio;
                    imageHeight = unscaledHeight;
                }
                
                thumbnailGroup.setLayoutBoundsSize(imageWidth, imageHeight);
                
                // center the thumbnailGroup
                thumbnailGroup.x = (unscaledWidth - imageWidth)/2;
                thumbnailGroup.y = (unscaledHeight - imageHeight)/2;
            }
            
            return;
        }
        
        var flvPlayer:VideoPlayer = videoPlayer;
        
        // check to see whether the video width/height has been set before to this value.
        // if it has, let's not set it again as we could be in an animation where we keep 
        // setting this value, and if that's the case, then the video won't play at all.
        if (lastSetVideoWidth != Math.floor(unscaledWidth) || lastSetVideoHeight != Math.floor(unscaledHeight))
        {
            lastSetVideoWidth = Math.floor(unscaledWidth);
            lastSetVideoHeight = Math.floor(unscaledHeight);
            
            flvPlayer.width = lastSetVideoWidth;
            flvPlayer.height = lastSetVideoHeight;
        }
    }
    
    // FIXME (rfrishbe): remove these "lastSet" variables...should not be needed 
    // when switching to Strobe
    
    /**
     *  @private 
     *  Used to store the last video width/height we've set the 
     *  underlying video player to
     */
    private var lastSetVideoWidth:Number;
    
    /**
     *  @private 
     *  Used to store the last video width/height we've set the 
     *  underlying video player to
     */
    private var lastSetVideoHeight:Number;
    
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
        // can't call any methods before we've initialized
        if (!initializedOnce)
            return;
        
        // if source is null or in a bad connection state, don't do anything
        if (source == null || videoPlayer.state == VideoState.CONNECTION_ERROR)
            return;
        
        // if have a thumbnailSource, no method calls are valid
        if (thumbnailSource)
            return;
        
        setPlaying(false);
        videoPlayer.pause();
    }
    
    /**
     *  Causes the video to play.  Can be called while the video is
     *  paused, stopped, or while the video is already playing.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function play():void
    {
        // can't call any methods before we've initialized
        if (!initializedOnce || thumbnailSource)
            return;
        
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
                if (videoPlayer.state == VideoState.CONNECTION_ERROR)
                {
                    setPlaying(false);
                    return;
                }
                flvSource = null;
            }
            else
            {
                flvSource =  new DynamicStreamItem();
                sourceLastPlayed = source;
                
                flvSource.uri = streamingSource.serverURI;
                
                // if dealing with a live streaming video, set start = -1
                // otherwise we don't worry about the start parameter
                if (streamingSource.live)
                    flvSource.start = -1;
                
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
            
            // if it's null, we just call the play() method
            if (flvSource == null)
            {
                videoPlayer.play(null, NaN, streamingSource.live);
            }
            else
            {
                videoPlayer.play2(flvSource);
            }
        }
        else if (source is String && String(source).length > 0)
        {
            // The progressive case
            var sourceString:String;
            
            // if paused, pass in null as the flvSource.  Otherwise, calling 
            // play(source) will reset the stream back to zero.  To restart the 
            // stream where it was paused, one needs to call play(null).
            if (sourceLastPlayed == this.source)
            {
                if (videoPlayer.state == VideoState.CONNECTION_ERROR)
                {
                    setPlaying(false);
                    return;
                }
                
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
            
            videoPlayer.play(sourceString);
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
        // check for 2 cases: streaming video or progressive download
        if (source is StreamingVideoSource)
        {
            // can't load in the streaming video case, so just call play(), then pause()
            play();
            pause();
            seek(0);
        }
        else if (source is String && String(source).length > 0)
        {
            // The progressive case
            var sourceString:String = String(this.source);
            sourceLastPlayed = sourceString;
            
            // load the video up
            videoPlayer.load(sourceString);
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
        // can't call any methods before we've initialized
        if (!initializedOnce)
            return;
        
        // if source is null or in a bad connection state, don't do anything
        if (source == null || videoPlayer.state == VideoState.CONNECTION_ERROR)
            return;
        
        // if have a thumbnailSource, no method calls are valid
        if (thumbnailSource)
            return;
        
        if (time < 0)
            time = 0;
        
        videoPlayer.seek(time);
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
        // can't call any methods before we've initialized
        if (!initializedOnce)
            return;
        
        // if source is null or in a bad connection state, don't do anything
        if (source == null || videoPlayer.state == VideoState.CONNECTION_ERROR)
            return;
        
        // if have a thumbnailSource, no method calls are valid
        if (thumbnailSource)
            return;
        
        setPlaying(false);
        videoPlayer.stop();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Keeps track of whether we are on the display list or not
     */
    private var _isOnDisplayList:Boolean = false;
    
    /**
     *  @private
     */
    private function addedToStageHandler(event:Event):void
    {
        _isOnDisplayList = true;
        
        // if visiblity/onstage shouldn't effect whether we are playing or not, just return
        if (playWhenHidden)
            return;
        
        // if we should start autoPlaying and we're not, let's do that
        if (effectiveAutoPlay && !playing)
            play();
    }
    
    /**
     *  @private
     */
    private function removedFromStageHandler(event:Event):void
    {
        _isOnDisplayList = false;
        
        // if visiblity/onstage shouldn't effect whether we are playing or not, just return
        if (playWhenHidden)
            return;
        
        // if we're removed from the stage and we're playing, let's pause
        if (playing)
            pause();
    }
    
    /**
     *  @private
     */
    private function videoPlayer_autoRewoundHandler(event:fl.video.VideoEvent):void
    {
        // just for binding purposes on VideoElement.playheadTime
        dispatchEvent(new Event("playheadTimeChanged"));
    }
    
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
        
        if (loop)
        {
            seek(0);
            play();
        }
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
    private function videoPlayer_readyHandler(event:fl.video.VideoEvent):void
    {
        // sometimes we don't get a metadata event, so let's check the size here and see 
        // if we need to invalidateSize()
        if (measuredWidth != videoPlayer.videoWidth || measuredHeight != videoPlayer.videoHeight)
            invalidateSize();
        
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
            case VideoState.STOPPED:
            case VideoState.DISCONNECTED:
            case VideoState.CONNECTION_ERROR:
                dispatchEvent(new Event("playheadTimeChanged"));
                dispatchEvent(new Event("totalTimeChanged"));
                setPlaying(false);
                break;
            case VideoState.PLAYING:
                setPlaying(true);
                break;
        }
        
        dispatchEvent(event);
    }
}
}

import fl.video.flvplayback_internal;
import fl.video.NCManagerDynamicStream;
import fl.video.VideoError;
import fl.video.SMILManager;
import fl.video.ParseResults;

use namespace flvplayback_internal;

/**
 *  @private
 *  We only have this class to fix a bug when handling "?"
 *  in URLs.  Hopefully Strobe will fix this directly.
 */
class FlexNCManager extends NCManagerDynamicStream
{
    public function FlexNCManager()
    {
        super();
    }
    
    /**
     * @copy INCManager#connectToURL()
     * @see INCManager#connectToURL() 
     *
     */
    override public function connectToURL(url:String):Boolean {
        //ifdef DEBUG
        //debugTrace("connectToURL(" + url + ")");
        //endif
        
        // init
        initOtherInfo();
        _contentPath = url;
        if (_contentPath == null || _contentPath == "") {
            throw new VideoError(VideoError.INVALID_SOURCE);
        }
        
        // parse URL to determine what to do with it
        var parseResults:ParseResults = parseURL(_contentPath);
        if (parseResults.streamName == null || parseResults.streamName == "") {
            throw new VideoError(VideoError.INVALID_SOURCE, url);
        }
        
        // connect to either rtmp or http or download and parse smil
        var canReuse:Boolean;
        if (parseResults.isRTMP) {
            canReuse = canReuseOldConnection(parseResults);
            _isRTMP = true;
            _protocol = parseResults.protocol;
            _streamName = parseResults.streamName;
            _serverName = parseResults.serverName;
            _wrappedURL = parseResults.wrappedURL;
            _portNumber = parseResults.portNumber;
            _appName = parseResults.appName;
            if ( _appName == null || _appName == "" ||
                 _streamName == null || _streamName == "" ) {
                throw new VideoError(VideoError.INVALID_SOURCE, url);
            }
            _autoSenseBW = (_streamName.indexOf(",") >= 0);
            return (canReuse || connectRTMP());
        } else {
            var name:String = parseResults.streamName;
            if ( name.indexOf("?") < 0 &&
                (name.length < 4 || name.slice(-4).toLowerCase() != ".txt") &&
                (name.length < 4 || name.slice(-4).toLowerCase() != ".xml") &&
                (name.length < 5 || name.slice(-5).toLowerCase() != ".smil") ) {
                canReuse = canReuseOldConnection(parseResults);
                _isRTMP = false;
                _streamName = name;
                return (canReuse || connectHTTP());
            }
            // special flex case to deal with blah.flv?t=ojoj
            else if ( name.indexOf("?") != -1 ) 
            {
                // common types of video files
                var streamTypes:Array = ["mp4", "mov", "m4v", "m4a", "f4v", "3gp", "3g2", "flv"];
                // if "?" then idx 0 should always be stream name, unless someone messed up URL
                var preQueryString:String = name.split("?")[0];
                // check extension and treat as vid file if exists
                if (preQueryString.length >= 3 && streamTypes.indexOf(preQueryString.slice(-3).toLowerCase()) != -1) 
                {
                    canReuse = canReuseOldConnection(parseResults);
                    _isRTMP = false;
                    _streamName = name;
                    return (canReuse || connectHTTP());
                }
            }
            
            if (name.indexOf("/fms/fpad") >= 0) {
                try {
                    return connectFPAD(name);
                } catch (err:Error) {
                    // just use SMILManager if there is any error
                    //ifdef DEBUG
                    //debugTrace("fpad error: " + err);
                    //endif
                }
            }
            _smilMgr = new SMILManager(this);
            return _smilMgr.connectXML(name);
        }
    }
}
