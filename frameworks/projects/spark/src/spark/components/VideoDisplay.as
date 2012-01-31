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

package spark.components
{

import flash.events.Event;
import flash.events.ProgressEvent;
import flash.geom.Point;
import flash.media.Video;

import mx.core.UIComponent;
import mx.core.mx_internal;

import org.osmf.display.MediaPlayerSprite;
import org.osmf.display.ScaleMode;
import org.osmf.events.BufferTimeChangeEvent;
import org.osmf.events.BytesDownloadedChangeEvent;
import org.osmf.events.DimensionChangeEvent;
import org.osmf.events.DurationChangeEvent;
import org.osmf.events.LoadableStateChangeEvent;
import org.osmf.events.MediaPlayerStateChangeEvent;
import org.osmf.events.MutedChangeEvent;
import org.osmf.events.PlayheadChangeEvent;
import org.osmf.events.PlayingChangeEvent;
import org.osmf.events.SeekingChangeEvent;
import org.osmf.events.TraitEvent;
import org.osmf.events.VolumeChangeEvent;
import org.osmf.media.IMediaResource;
import org.osmf.media.MediaFactory;
import org.osmf.media.MediaPlayer;
import org.osmf.media.MediaPlayerState;
import org.osmf.media.URLResource;
import org.osmf.net.NetLoader;
import org.osmf.net.NetStreamCodes;
import org.osmf.net.dynamicstreaming.DynamicStreamingItem;
import org.osmf.net.dynamicstreaming.DynamicStreamingNetLoader;
import org.osmf.net.dynamicstreaming.DynamicStreamingResource;
import org.osmf.traits.ILoadable;
import org.osmf.traits.LoadState;
import org.osmf.traits.MediaTraitType;
import org.osmf.utils.FMSURL;
import org.osmf.utils.MediaFrameworkStrings;
import org.osmf.utils.URL;
import org.osmf.video.VideoElement;

import spark.components.mediaClasses.DynamicStreamingVideoItem;
import spark.components.mediaClasses.DynamicStreamingVideoSource;
import spark.events.VideoEvent;
import spark.primitives.BitmapImage;

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

[IconFile("VideoDisplay.png")]

/**
 *  The VideoDisplay class is chromeless video player that supports
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
public class VideoDisplay extends UIComponent
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
    public function VideoDisplay()
    {
        // create the underlying MediaPlayer class first because 
        // the super() call will set enabled=true, and we have assumptions baked 
        // in to the component that videoPlayer is always around.
        createUnderlyingVideoPlayer();
        
        super();
        
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
    mx_internal var videoPlayer:MediaPlayer;
    
    /**
     *  @private
     *  This is the underlying VideoPlayer object. At some point in the 
     *  future, we may change to a new implementation.
     */
    mx_internal var videoSprite:MediaPlayerSprite;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  autoPlay
    //----------------------------------
    
    [Inspectable(category="General", defaultValue="true")]
    
    private var _autoPlay:Boolean = true;
    
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
     *  If <code>playWhenHidden</code> is set to <code>false</code>, then 
     *  <code>autoPlay</code> also affects what happens when the video 
     *  comes back on stage and is enabled and visible.
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
        if (autoPlay == value)
            return;
        
        _autoPlay = value;
        effectiveAutoPlayChanged(false);
    }
    
    // FIXME (rfrishbe): Copy this behavior correctly from the spark checked-in versions
    private function effectiveAutoPlayChanged(takeAction:Boolean):void
    {
        if (!playWhenHidden)
        {
            var shouldBePlaying:Boolean = visible && _isOnDisplayList && enabled && _parentVisibility;
            
            if (shouldBePlaying)
            {
                if (!playing && takeAction && videoPlayer.playable)
                    play(); 
            }
            else
            {
                if (playing && takeAction && videoPlayer.playable)
                    pause();
            }
            
            if (videoPlayer)
                videoPlayer.autoPlay = shouldBePlaying && autoPlay;
        }
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
        var myVideoPlayer:MediaPlayer = videoPlayer;
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
        
        super.enabled = value;
        
        effectiveAutoPlayChanged(true);
    }
    
    //----------------------------------
    //  bytesDownloaded
    //----------------------------------
    
    [Bindable("bytesDownloadedChange")]
    [Inspectable(Category="General", defaultValue="0")]
    
    /**
     *  The number of bytes of data that have been downloaded into the application.
     *
     *  @return The number of bytes of data that have been downloaded into the application.
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get bytesLoaded():Number
    {
        return videoPlayer.bytesDownloaded;
    }
    
    //----------------------------------
    //  bytesTotal
    //----------------------------------
    
    [Inspectable(Category="General", defaultValue="0")]
    
    /**
     *  The total size in bytes of the data being downloaded into the application.
     *
     *  @return The total size in bytes of the data being downloaded into the application.
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get bytesTotal():Number
    {
        return videoPlayer.bytesTotal;
    }
    
    //----------------------------------
    //  currentTime
    //----------------------------------
    
    [Bindable("playheadUpdate")]
    [Bindable("playheadTimeChanged")]
    [Inspectable(Category="General", defaultValue="0")]
    
    /**
     *  Current time of the playhead, measured in seconds, 
     *  since the video starting playing. 
     *
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get currentTime():Number
    {
        return videoPlayer.currentTime;
    }
    
    //----------------------------------
    //  duration
    //----------------------------------
    
    [Bindable("totalTimeChanged")]
    [Inspectable(Category="General", defaultValue="0")]
    
    /**
     *  Duration of the video's playback, in seconds
     *
     *  @return The total running time of the video in seconds
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get duration():Number
    {
        return videoPlayer.duration;
    }
    
    //----------------------------------
    //  loop
    //----------------------------------
    
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
        return videoPlayer.loop;
    }
    
    /**
     *  @private
     */
    public function set loop(value:Boolean):void
    {
        if (loop == value)
            return;
        
        videoPlayer.loop = value;
    }
    
    //----------------------------------
    //  maintainAspectRatio
    //----------------------------------
    
    /**
     *  @private
     *  Storage for maintainAspectRatio property.
     */
    private var _maintainAspectRatio:Boolean = true;
    
    [Inspectable(Category="General", enumeration="none,stretch,letterBox,zoom", defaultValue="letterBox")]
    
    /**
     *  The <code>scaleMode</code> property describes different ways of 
     *  sizing the video content.  <code>scaleMode</code> can be set to 
     *  <code>NONE</code>, <code>STRETCH</code>, <code>LETTERBOX</code> or <code>ZOOM</code>.
     * 
     *  <p>If no width, height, or constraints are specified on the component, 
     *  this property has no effect.</p>
     *
     *  @default letterbox
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get scaleMode():String
    {
        return videoSprite.scaleMode.toString().toLowerCase();
    }
    
    /**
     *  @private
     */
    public function set scaleMode(value:String):void
    {
        if (scaleMode != value)
        {
            switch(value.toLowerCase())
            {
                case "none":
                    videoSprite.scaleMode = ScaleMode.NONE;
                    break;
                case "stretch":
                    videoSprite.scaleMode = ScaleMode.STRETCH;
                    break;
                case "letterbox":
                    videoSprite.scaleMode = ScaleMode.LETTERBOX;
                    break;
                case "zoom":
                    videoSprite.scaleMode = ScaleMode.ZOOM;
                    break;
            }
        }
    }
    
    //----------------------------------
    //  muted
    //----------------------------------
    
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
        return videoPlayer.muted;
    }
    
    /**
     *  @private
     */
    public function set muted(value:Boolean):void
    {
        if (muted == value)
            return;
        
        videoPlayer.muted = value;
    }
    
    //----------------------------------
    //  playing
    //----------------------------------
    
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
        return videoPlayer.playing;
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
        
        if (value)
            videoPlayer.autoPlay = autoPlay;
    }
    
    //----------------------------------
    //  source
    //----------------------------------
    
    private var _source:Object;
    private var sourceChanged:Boolean;
        
    [Bindable("sourceChanged")]
    [Inspectable(category="General", defaultValue="null")]
    
    /**
     *  For progressive download, the source is just a path or URL pointing 
     *  to the video file to play.  For streaming (streaming, live streaming, 
     *  or multi-bitrate streaming), the source property is a 
     *  DynamicStreamingVideoSource object.
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
    
    override public function setVisible(value:Boolean, noEvent:Boolean=false) : void
    {
        super.setVisible(value, noEvent);
        
        effectiveAutoPlayChanged(true);
    }
    
    private var _parentVisibility:Boolean = true;
    
    mx_internal function set parentVisibility(value:Boolean) : void
    {
        _parentVisibility = value;
        
        effectiveAutoPlayChanged(true);
    }
    
    /**
     *  @private
     *  Sets up the source for use.
     */
    private function setUpSource():void
    {
        var videoElement:org.osmf.video.VideoElement;
        
        // check for 2 cases: streaming video or progressive download
        if (source is DynamicStreamingVideoSource)
        {
            // the streaming video case.
            // build up a DynamicStreamingResource to pass in to OSMF
            var streamingSource:DynamicStreamingVideoSource = source as DynamicStreamingVideoSource;
            var dsr:DynamicStreamingResource;
            
            dsr =  new DynamicStreamingResource(new FMSURL(streamingSource.serverURI));
            
            // if dealing with a live streaming video, set start = -1
            // otherwise we don't worry about the start parameter
            if (streamingSource.streamType == "live")
                dsr.start = DynamicStreamingResource.START_LIVE;
            else if (streamingSource.streamType == "recorded")
                dsr.start = DynamicStreamingResource.START_VOD;
            
            var n:int = streamingSource.streamItems.length;
            var item:DynamicStreamingVideoItem;
            for (var i:int = 0; i < n; i++)
            {
                item = DynamicStreamingVideoItem(streamingSource.streamItems[i]);
                var dsi:DynamicStreamingItem = new DynamicStreamingItem(item.streamName, item.bitrate);
                dsr.addItem(dsi);
            }
            
            dsr.initialIndex = streamingSource.initialIndex;
            
            videoElement = new org.osmf.video.VideoElement(new DynamicStreamingNetLoader(), dsr);
        }
        else if (source is String)
        {
            var urlResource:URLResource = new URLResource(new URL(source as String));
            videoElement = new org.osmf.video.VideoElement(new NetLoader(), urlResource );
        }
        
        videoPlayer.element = videoElement;
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
        if (muted)
            return 0;
        
        return videoPlayer.volume;
    }
    
    /**
     *  @private
     */
    public function set volume(value:Number):void
    {
        if (volume == value)
            return;
        
        videoPlayer.volume = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
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
        // create new video player
        videoPlayer = new MediaPlayer();
        videoSprite = new MediaPlayerSprite(videoPlayer);
        
        videoPlayer.addEventListener(DimensionChangeEvent.DIMENSION_CHANGE, videoPlayer_dimensionChangeHandler);
        videoPlayer.addEventListener(VolumeChangeEvent.VOLUME_CHANGE, videoPlayer_volumeChangeHandler);
        videoPlayer.addEventListener(MutedChangeEvent.MUTED_CHANGE, videoPlayer_mutedChangeHandler);
        videoPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, dispatchEvent);
        videoPlayer.addEventListener(PlayheadChangeEvent.PLAYHEAD_CHANGE, dispatchEvent);
        videoPlayer.addEventListener(BytesDownloadedChangeEvent.BYTES_DOWNLOADED_CHANGE, dispatchEvent);
        videoPlayer.addEventListener(DurationChangeEvent.DURATION_CHANGE, dispatchEvent);
        
        videoPlayer.autoPlay = false;
        
        addChild(videoSprite);
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
        var vw:Number = videoPlayer.width;
        var vh:Number = videoPlayer.height;
        
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
            // get what the size of our image should be
            var newSize:Point = videoSprite.scaleMode.getScaledSize(unscaledWidth, unscaledHeight, 
                thumbnailGroup.getPreferredBoundsWidth(), thumbnailGroup.getPreferredBoundsHeight());
            
            thumbnailGroup.setLayoutBoundsSize(newSize.x, newSize.y);
            
            // center the thumbnailGroup
            thumbnailGroup.x = (unscaledWidth - newSize.x)/2;
            thumbnailGroup.y = (unscaledHeight - newSize.y)/2;
            
            return;
        }
        
        videoSprite.width = Math.floor(unscaledWidth);
        videoSprite.height = Math.floor(unscaledHeight);
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
        // check to see if we can call methods on the video player object yet
        if (!videoPlayerResponsive())
            return;
        
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
        // check to see if we can call methods on the video player object yet
        if (!videoPlayerResponsive())
            return;
        
        videoPlayer.play();
    }
    
    /**
     *  @private
     *  If the video player is responsive, then methods can be called on the underlying 
     *  video player.
     */
    private function videoPlayerResponsive():Boolean
    {
        // can't call any methods before we've initialized
        if (!initializedOnce)
            return false;
        
        // if displaying a thumbnail, no methods can be called b/c there's no video 
        // loaded up
        if (thumbnailSource)
            return false;
        
        // if the video player's in a bad state, we can't do anything
        if (videoPlayer.state == MediaPlayerState.PLAYBACK_ERROR)
            return false;
        
        // if no source, return false as well
        if (!source)
            return false;
        
        // otherwise, we are in a good state and have a source, so let's go
        return true;
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
        // check to see if we can call methods on the video player object yet
        if (!videoPlayerResponsive())
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
        // check to see if we can call methods on the video player object yet
        if (!videoPlayerResponsive())
            return;
        
        videoPlayer.pause();
        videoPlayer.seek(0);
        // should be stop()
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    private var _isOnDisplayList:Boolean = false;
    
    /**
     *  @private
     */
    private function addedToStageHandler(event:Event):void
    {
        _isOnDisplayList = true;
        
        effectiveAutoPlayChanged(true);
    }
    
    /**
     *  @private
     */
    private function removedFromStageHandler(event:Event):void
    {
        _isOnDisplayList = false;
        
        effectiveAutoPlayChanged(true);
    }
    
    /**
     *  @private
     */
    private function videoPlayer_dimensionChangeHandler(event:DimensionChangeEvent):void
    {
        invalidateSize();
    }
    
    /**
     *  @private
     */
    private function videoPlayer_volumeChangeHandler(event:VolumeChangeEvent):void
    {
        dispatchEvent(new Event("volumeChanged"));
    }
    
    /**
     *  @private
     */
    private function videoPlayer_mutedChangeHandler(event:MutedChangeEvent):void
    {
        dispatchEvent(new Event("volumeChanged"));
    }
}
}