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

import mx.core.IUIComponent;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;

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
 * Dispatched when the data is received as a download operation progresses.
 *
 * @eventType flash.events.ProgressEvent
 */
[Event(name="bytesDownloadedChange",type="org.osmf.events.BytesDownloadedChangeEvent")]

/**
 * Dispatched when the MediaPlayer's state has changed.
 * 
 * @eventType org.osmf.events.PlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE
 */	
[Event(name="mediaPlayerStateChange", type="org.osmf.events.MediaPlayerStateChangeEvent")]

/**
 * Dispatched when the <code>playhead</code> property of the MediaPlayer has changed.
 * This value is updated at the interval set by 
 * the MediaPlayer's <code>playheadUpdateInterval</code> property.
 *
 * @eventType org.osmf.events.PlayheadChangeEvent.PLAYHEAD_CHANGE
 **/
[Event(name="playheadChange",type="org.osmf.events.PlayheadChangeEvent")]  

/**
 * Dispatched when the <code>duration</code> property of the media has changed.
 * 
 * @eventType org.osmf.events.DurationChangeEvent.DURATION_CHANGE
 */
[Event(name="durationChange", type="org.osmf.events.DurationChangeEvent")]

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
        super();
        
        // create the underlying MediaPlayer class first.
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
    mx_internal var videoPlayer:MediaPlayer;
    
    /**
     *  @private
     *  This is the underlying VideoPlayer object. At some point in the 
     *  future, we may change to a new implementation.
     */
    mx_internal var videoSprite:MediaPlayerSprite;
    
    /**
     *  @private
     *  Whether the video is on the display list or not
     */
    private var _isOnDisplayList:Boolean = false;
    
    /**
     *  @private
     *  Whether the we should play the video when the video 
     *  becomes playable again (visible, on display list, and enabled).
     *  This starts out as true, but when we pause the video is changePlayback(), 
     *  we set it to false.  Also, when a user action occurs, like pause() or play()
     *  or stop() is called, we set it to false as well.
     */
    private var playTheVideoOnVisible:Boolean = true;
    
    /**
     *  @private
     */
    private var effectiveVisibility:Boolean = false;
    
    /**
     *  @private
     */
    private var effectiveVisibilityChanged:Boolean = false;
        
    /**
     *  @private
     */
    private var effectiveEnabled:Boolean = false;
    
    /**
     *  @private
     */
    private var effectiveEnabledChanged:Boolean = false;
    
    /**
     *  @private
     *  Object for holding videoPlayer properties that we mutate when 
     *  we go in to full screen mode so that we can set them back 
     *  when we go back in to the normal mode.
     */
    private var videoPlayerProperties:Object;
    
    /**
     *  @private
     *  We do different things in the source setter based on if we 
     *  are initialized or not.
     */
    private var initializedOnce:Boolean = false;
    
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
        
        // call changePlayback() but don't immediately play or pause
        // based on this change to autoPlay
        changePlayback(false, false);
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
        return videoPlayer.autoRewind;
    }
    
    public function set autoRewind(value:Boolean):void
    {
        videoPlayer.autoRewind = value;
    }
    
    //----------------------------------
    //  bytesLoaded
    //----------------------------------
    
    [Inspectable(Category="General", defaultValue="0")]
    [Bindable("bytesDownloadedChange")]
    
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
    [Bindable("mediaPlayerStateChange")]
    
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
    
    [Inspectable(Category="General", defaultValue="0")]
    [Bindable("playheadChange")]
    
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
    
    [Inspectable(Category="General", defaultValue="0")]
    [Bindable("durationChange")]
    
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
    //  pauseWhenHidden
    //----------------------------------
    
    /**
     *  @private
     *  Storage variable for pauseWhenHidden
     */
    private var _pauseWhenHidden:Boolean = true;
    
    [Inspectable(category="General", defaultValue="true")]
    
    /**
     *  Controls whether the video continues to play when it is
     *  "hidden".  The video is "hidden" when either <code>visible</code>
     *  is set to <code>false</code> on it or one of its ancestors,  
     *  or when the video is taken off 
     *  of the display list.  If set to <code>true</code>, the video 
     *  will pause playback until the video is visible again.  If set to 
     *  <code>false</code> the video will continue to play when it is hidden.
     * 
     *  <p>If the video is disabled (or one of the video's parents are 
     *  disabled), the video will pause as well, but when it is re-enabled, 
     *  the video will not play again.  This behavior is not controlled through 
     *  pauseWhenHidden; it is baked in to the VideoDisplay component.</p>
     * 
     *  @default true
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get pauseWhenHidden():Boolean
    {
        return _pauseWhenHidden;
    }
    
    /**
     *  @private
     */
    public function set pauseWhenHidden(value:Boolean):void
    {
        if (_pauseWhenHidden == value)
            return;
        
        _pauseWhenHidden = value;
        
        if (_pauseWhenHidden)
            addVisibilityListeners();
        else
            removeVisibilityListeners();
        
        // call changePlayback().  If we're invisible or off the stage, 
        // setting this to true can pause the video.  However, setting it 
        // to false should have no immediate impact.
        changePlayback(value, false);
    }
    
    //----------------------------------
    //  playing
    //----------------------------------
    
    [Inspectable(category="General")]
    [Bindable("mediaPlayerStateChange")]
    
    /**
     *  Returns true if the video is playing or is attempting to play.
     *  
     *  <p>The video may not be currently playing, as it may be seeking 
     *  or buffering, but the video is attempting to play.</p> 
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
    //  scaleMode
    //----------------------------------
    
    [Inspectable(Category="General", enumeration="none,stretch,letterbox,zoom", defaultValue="letterbox")]
    
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
        if (scaleMode == value)
            return;
        
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
        
        invalidateSize();
        invalidateDisplayList();
    }
    
    //----------------------------------
    //  source
    //----------------------------------
    
    private var _source:Object;
    private var sourceChanged:Boolean;
        
    [Inspectable(category="General", defaultValue="null")]
    [Bindable("sourceChanged")]
    
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
            var dsi:DynamicStreamingItem;
            for (var i:int = 0; i < n; i++)
            {
                item = DynamicStreamingVideoItem(streamingSource.streamItems[i]);
                dsi = new DynamicStreamingItem(item.streamName, item.bitrate);
                dsr.addItem(dsi);
            }
            
            dsr.initialIndex = streamingSource.initialIndex;
            
            videoElement = new org.osmf.video.VideoElement(new DynamicStreamingNetLoader(), dsr);
        }
        else if (source is String)
        {
            var urlResource:URLResource = new URLResource(new URL(source as String));
            videoElement = new org.osmf.video.VideoElement(new NetLoader(), urlResource);
        }
        
        // reset the visibilityPausedTheVideo flag
        playTheVideoOnVisible = true;
        
        // set up videoPlayer.autoPlay based on whether this.autoPlay is 
        // set and whether we are visible and the other typical conditions.
        changePlayback(false, false);

        videoPlayer.element = videoElement;
    }
    
    //----------------------------------
    //  thumbnailSource
    //----------------------------------
    
    /**
     *  @private
     */
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
        return videoPlayer.view as Video;
    }
    
    //----------------------------------
    //  volume
    //----------------------------------
    
    [Inspectable(category="General", defaultValue="1.0")]
    [Bindable("volumeChanged")]
    
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
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        initializedOnce = true;
        
        if (effectiveVisibilityChanged || effectiveEnabledChanged)
        {
            // if either visibility of enabled changed, re-compute them here
            computeEffectiveVisibilityAndEnabled();
            
            // if visibility changed and we care about it, we can 
            // cause a play or a pause depending on our visibility
            var causePause:Boolean = false;
            var causePlay:Boolean = false;
            if (effectiveVisibilityChanged && pauseWhenHidden)
            {
                causePause = !effectiveVisibility;
                causePlay = effectiveVisibility;
            }
            
            // if enabled changed, we can only cause a pause.  
            // Re-enabling a component doesn't cause a play.
            if (effectiveEnabledChanged)
            {
                if (!effectiveEnabled)
                    causePause = true;
            }
            
            changePlayback(causePause, causePlay);
            
            effectiveVisibilityChanged = false;
            effectiveEnabledChanged = false;
        }
        
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
    override protected function measure() : void
    {
        super.measure();
        
        var intrinsicWidth:Number;
        var intrinsicHeight:Number;
        
        // if showing the thumbnail, just use the thumbnail's size
        if (thumbnailSource && thumbnailGroup)
        {
            intrinsicWidth = thumbnailGroup.getPreferredBoundsWidth();
            intrinsicHeight = thumbnailGroup.getPreferredBoundsHeight();
        }
        else
        {
            intrinsicWidth = videoPlayer.width;
            intrinsicHeight = videoPlayer.height;
        }

        measuredWidth = intrinsicWidth;
        measuredHeight = intrinsicHeight;
        
        // Determine whether 'width' and 'height' have been set.
        var bExplicitWidth:Boolean = !isNaN(explicitWidth);
        var bExplicitHeight:Boolean = !isNaN(explicitHeight);

        // If only one has been set, calculate the other based on aspect ratio.
        if (bExplicitWidth && !bExplicitHeight && intrinsicWidth > 0)
            measuredHeight = explicitWidth * intrinsicHeight / intrinsicWidth;
        else if (bExplicitHeight && !bExplicitWidth && intrinsicHeight > 0)
            measuredWidth = explicitHeight * intrinsicWidth / intrinsicHeight;
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
        
        playTheVideoOnVisible = false;
        
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
        
        playTheVideoOnVisible = false;
        
        videoPlayer.play();
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
        
        playTheVideoOnVisible = false;
        
        videoPlayer.stop();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
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
        
        addChild(videoSprite);
    }
    
    //--------------------------------------------------------------------------
    //
    //  pauseWhenHidden: Event handlers and Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Whether the video should be playing based on enabled, 
     *  pauseWhenHidden, whether it's on the display list, and its
     *  effective visibility.
     */
    private function get shouldBePlaying():Boolean
    {
        // if disabled, return false
        if (!effectiveEnabled)
            return false;
        
        // if we want to look at visibility, check to 
        // see if we are on the display list and check out 
        // effectiveVisibility (which looks up our parent chain 
        // to make sure us and all of our ancestors are visible)
        if (pauseWhenHidden)
        {
            if (!_isOnDisplayList)
                return false;
            
            if (!effectiveVisibility)
                return false;
        }
        
        return true;
    }
    
    /**
     *  @private
     *  This method will pause or play the video by looking at the state of 
     *  the component and determining whether it should play or pause.  This 
     *  method gets called when an important event occurs, such as 
     *  the component being added/removed from the stage, the component's 
     *  effective visibility changing, or when autoPlay is set.  
     * 
     *  <p>Only certain events are "action events" which can cause the video 
     *  to pause or play immediately.  For example, when autoPlay is set to 
     *  true/false, that shouldn't cause any immediate action, but changePlayback()
     *  is still called so that autoPlay can be set on the underlying media player.</p>
     * 
     *  <p>Actions that can pause the video are:
     *  <ul>
     *      <li>Changes in effective enablement</li>
     *      <li>Changes in effective visibility</li>
     *      <li>Changes in staging (added or removed from display list)</li>
     *      <li>Setting pauseWhenHidden = true</li>
     *  </ul></p>
     * 
     *  <p>Actions that can play the video are:
     *  <ul>
     *      <li>Changes in effective visibility</li>
     *      <li>Changes in staging (added or removed from display list)</li>
     *  </ul></p>
     * 
     *  @param causePause Whether this action can cause a currently playing video to pause
     *  @param causePlay Whether this action can cause a currently paused video to play
     */
    private function changePlayback(causePause:Boolean, causePlay:Boolean):void
    {
        // if we shouldn't be playing, we pause the video.
        // if we come back up and should be playing, we will
        // start playing the video again if the video wasn't paused 
        // by the user or developer and autoPlay is true.       
        if (shouldBePlaying)
        {
            videoPlayer.autoPlay = autoPlay;
            
            // only play the video if visibility caused it to pause 
            // (instead of a user or developer calling video.pause()).
            // Also, only play if autoPlay is true.  Otherwise when 
            // the visibility changes, we won't automatically 
            // play the video
            if (causePlay && (playTheVideoOnVisible && autoPlay))
            {
                playTheVideoOnVisible = false;
                
                // set autoplay and call play() if the 
                // source has loaded up and it's playable
                if (videoPlayer.playable)
                    videoPlayer.play();
            }
        }
        else
        {
            // there are really three states the video player can 
            // be in with respect to play vs. paused:
            // 1) playing
            // 2) paused
            // 3) loading
            // Here we are checking if we are playing or loading
            // and going to play soon (autoPlay = true)
            if (causePause && (playing || (videoPlayer.state == MediaPlayerState.INITIALIZING && autoPlay)))
                playTheVideoOnVisible = true;

            // always set autoPlay to false here and 
            // if pausable, pause the video
            videoPlayer.autoPlay = false;
            if (causePause && videoPlayer.pausable)
                videoPlayer.pause();
        }
    }
    
    /**
     *  @private
     */
    private function addedToStageHandler(event:Event):void
    {
        _isOnDisplayList = true;
        
        // add listeners to current parents to see if their visibility has changed
        if (pauseWhenHidden)
            addVisibilityListeners();
        
        addEnabledListeners();
        
        computeEffectiveVisibilityAndEnabled();
        
        // being added to the display list will not pause the video, but 
        // it may play the video if pauseWhenHidden = true
        changePlayback(false, pauseWhenHidden);
    }
    
    /**
     *  @private
     */
    private function removedFromStageHandler(event:Event):void
    {
        _isOnDisplayList = false;
        
        // remove listeners from old parents
        if (pauseWhenHidden)
            removeVisibilityListeners();
        
        removeEnabledListeners();
        
        // being removed from the display list will pause the video if 
        // pauseWhenHidden = true
        changePlayback(pauseWhenHidden, false);
    }
    
    /**
     *  @private
     *  Add event listeners for SHOW and HIDE on all the ancestors up the parent chain.
     *  Adding weak event listeners just to be safe.
     */
    private function addVisibilityListeners():void
    {
        var current:IVisualElement = this;
        while (current)
        {
            current.addEventListener(FlexEvent.HIDE, visibilityChangedHandler, false, 0, true);
            current.addEventListener(FlexEvent.SHOW, visibilityChangedHandler, false, 0, true);
            
            current = current.parent as IVisualElement;
        }
    }
    
    /**
     *  @private
     *  Add event listeners for "enabledChanged" event on all ancestors up the parent chain.
     *  Adding weak event listeners just to be safe.
     */
    private function addEnabledListeners():void
    {
        var current:IVisualElement = this;
        while (current)
        {
            current.addEventListener("enabledChanged", enabledChangedHandler, false, 0, true);
            current.addEventListener("enabledChanged", enabledChangedHandler, false, 0, true);
            
            current = current.parent as IVisualElement;
        }
    }
    
    /**
     *  @private
     *  Remove event listeners for SHOW and HIDE on all the ancestors up the parent chain.
     */
    private function removeVisibilityListeners():void
    {
        var current:IVisualElement = this;
        while (current)
        {
            current.removeEventListener(FlexEvent.HIDE, visibilityChangedHandler, false);
            current.removeEventListener(FlexEvent.SHOW, visibilityChangedHandler, false);
            
            current = current.parent as IVisualElement;
        }
    }
    
    /**
     *  @private
     *  Remove event listeners for "enabledChanged" event on all ancestors up the parent chain.
     */
    private function removeEnabledListeners():void
    {
        var current:IVisualElement = this;
        while (current)
        {
            current.removeEventListener("enabledChanged", enabledChangedHandler, false);
            current.removeEventListener("enabledChanged", enabledChangedHandler, false);
            
            current = current.parent as IVisualElement;
        }
    }
    
    /**
     *  @private
     *  Event call back whenever the visibility of us or one of our ancestors 
     *  changes
     */
    private function visibilityChangedHandler(event:FlexEvent):void
    {
        effectiveVisibilityChanged = true;
        invalidateProperties();
    }
    
    /**
     *  @private
     *  Event call back whenever the enablement of us or one of our ancestors 
     *  changes
     */
    private function enabledChangedHandler(event:Event):void
    {
        effectiveEnabledChanged = true;
        invalidateProperties();
    }
    
    /**
     *  @private
     */
    private function computeEffectiveVisibilityAndEnabled():void
    {
        // start out with true visibility and enablement
        // then loop up parent-chain to see if any of them are false
        effectiveVisibility = true;
        effectiveEnabled = true;
        var current:IVisualElement = this;
        
        while (current)
        {
            if (!current.visible)
            {
                effectiveVisibility = false;
                if (!effectiveEnabled)
                    break;
            }
            
            if (current is IUIComponent && !IUIComponent(current).enabled)
            {
                effectiveEnabled = false;
                if (!effectiveVisibility)
                    break;
            }
            
            current = current.parent as IVisualElement;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
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