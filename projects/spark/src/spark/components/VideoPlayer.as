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

package spark.components
{
import fl.video.VideoEvent;
import fl.video.VideoState;
import fl.video.flvplayback_internal;

import flash.display.DisplayObject;
import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.FullScreenEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;
import flash.geom.Rectangle;
import flash.utils.Timer;

import mx.core.IVisualElementContainer;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.SandboxMouseEvent;
import mx.utils.BitFlagUtil;

import spark.components.supportClasses.ButtonBase;
import spark.components.supportClasses.Range;
import spark.components.supportClasses.SkinnableComponent;
import spark.components.supportClasses.ToggleButtonBase;
import spark.events.TrackBaseEvent;
import spark.events.VideoEvent;
import spark.primitives.VideoElement;
import spark.primitives.supportClasses.TextGraphicElement;

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
//  SkinStates
//--------------------------------------

/**
 *  Connection Error State of the VideoPlayer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("connectionError")]

/**
 *  Disabled State of the VideoPlayer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("disabled")]

/**
 *  Disconnected State of the VideoPlayer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("disconnected")]

/**
 *  Connection Error State of the VideoPlayer when 
 *  in full screen mode.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("fullScreenConnectionError")]

/**
 *  Disabled State of the VideoPlayer when 
 *  in full screen mode.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("fullScreenDisabled")]

/**
 *  Disconnected State of the VideoPlayer when 
 *  in full screen mode.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("fullScreenDisconnected")]

/**
 *  Loading State of the VideoPlayer when 
 *  in full screen mode.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("fullScreenLoading")]

/**
 *  Playing State of the VideoPlayer when 
 *  in full screen mode.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("fullScreenPlaying")]

/**
 *  Stopped State of the VideoPlayer when 
 *  in full screen mode.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("fullScreenStopped")]

/**
 *  Loading State of the VideoPlayer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("loading")]

/**
 *  Playing State of the VideoPlayer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("playing")]

/**
 *  Stopped State of the VideoPlayer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("stopped")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("source")]

[IconFile("VideoPlayer.png")]

/**
 *  The VideoPlayer class is skinnable video player that supports
 *  progressive download, multi-bitrate streaming, and streaming video.
 * 
 *  <p><code>VideoElement</code> is the chromeless version.</p>
 *
 *  @see spark.primitives.VideoElement
 *  @see spark.skins.default.VideoPlayerSkin
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class VideoPlayer extends SkinnableComponent
{
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private static const AUTO_PLAY_PROPERTY_FLAG:uint = 1 << 0;
    
    /**
     *  @private
     */
    private static const AUTO_REWIND_PROPERTY_FLAG:uint = 1 << 1;
    
    /**
     *  @private
     */
    private static const MAINTAIN_ASPECT_RATIO_PROPERTY_FLAG:uint = 1 << 2;
    
    /**
     *  @private
     */
    private static const MUTED_PROPERTY_FLAG:uint = 1 << 3;
    
    /**
     *  @private
     */
    private static const SOURCE_PROPERTY_FLAG:uint = 1 << 4;
    
    /**
     *  @private
     */
    private static const VOLUME_PROPERTY_FLAG:uint = 1 << 5;
    
    /**
     *  @private
     *  The default value that we wait in fullscreen mode with no user-interaction 
     *  before the play controls go away.
     *
     *  @default 3000
     */
    private static const FULL_SCREEN_HIDE_CONTROLS_DELAY:Number = 3000;
    
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
    public function VideoPlayer()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin Parts
    //
    //--------------------------------------------------------------------------
    
    [SkinPart(required="true")]
    
    /**
     *  A required skin part that defines the VideoElement.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var videoElement:VideoElement;
    
    [SkinPart(required="false")]
    
    /**
     *  An optional skin part to display the current playheadTime.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var playheadTimeLabel:TextGraphicElement;
    
    [SkinPart(required="false")]
    
    /**
     *  An optional skin part for a fullScreen button.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var fullScreenButton:ButtonBase;
    
    [SkinPart(required="false")]
    
    /**
     *  An optional skin part for the mute button.  When the 
     *  video is muted, the selected property will be set to 
     *  <code>true</code>.  When the video is not muted, 
     *  the selected property will be set to <code>false</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var muteButton:ToggleButtonBase;
    
    [SkinPart(required="false")]
    
    /**
     *  An optional skin part for the pause button
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var pauseButton:ButtonBase;
    
    [SkinPart(required="false")]
    
    /**
     *  An optional skin part for the play button
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var playButton:ButtonBase;
    
    [SkinPart(required="false")]
    
    /**
     *  An optional skin part for all of the player controls.  We 
     *  need this skin part to know what to hide when in full screen 
     *  mode and there's been no user-interaction.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var playerControls:DisplayObject;
    
    [SkinPart(required="false")]
    
    /**
     *  An optional skin part for a play/pause button.  When the 
     *  video is playing, the selected property will be set to 
     *  <code>true</code>.  When the video is paused or stopped, 
     *  the selected property will be set to <code>false</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var playPauseButton:ToggleButtonBase;
    
    [SkinPart(required="false")]
    
    /**
     *  An optional skin part for the scrub bar (the 
     *  timeline).
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var scrubBar:VideoPlayerScrubBar;
    
    [SkinPart(required="false")]
    
    /**
     *  An optional skin part for the stop button
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var stopButton:ButtonBase;
    
    [SkinPart(required="false")]
    
    /**
     *  An optional skin part to display the totalTime.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var totalTimeLabel:TextGraphicElement;
    
    [SkinPart(required="false")]
    
    /**
     *  An optional skin part for the volume control.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var volumeBar:VideoPlayerVolumeBar;
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Several properties are proxied to videoElement.  However, when videoElement
     *  is not around, we need to store values set on VideoPlayer.  This object 
     *  stores those values.  If videoElement is around, the values are stored 
     *  on the videoElement directly.  However, we need to know what values 
     *  have been set by the developer on the VideoPlayer (versus set on 
     *  the videoElement or defaults of the videoElement) as those are values 
     *  we want to carry around if the videoElement changes (via a new skin). 
     *  In order to store this info effeciently, videoElementProperties becomes 
     *  a uint to store a series of BitFlags.  These bits represent whether a 
     *  property has been explicitely set on this VideoPlayer.  When the 
     *  contentGroup is not around, videoElementProperties is a typeless 
     *  object to store these proxied properties.  When videoElement is around,
     *  videoElementProperties stores booleans as to whether these properties 
     *  have been explicitely set or not.
     */
    private var videoElementProperties:Object;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  enabled
    //----------------------------------

    /**
     *  @inheritDoc
     * 
     *  <p>Setting enabled to <code>false</code> disables the UI and 
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    override public function set enabled(value:Boolean):void
    {
        super.enabled = value;
        
        if (videoElement)
            videoElement.enabled = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  autoPlay
    //----------------------------------

    [Inspectable(category="General", defaultValue="true")]
    
    /**
     *  @copy spark.primitives.VideoElement#autoPlay
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get autoPlay():Boolean
    {
        if (videoElement)
        {
            return videoElement.autoPlay;
        }
        else
        {
            var v:* = videoElementProperties.autoPlay;
            return (v === undefined) ? true : v;
        }
    }

    /**
     * @private
     */
    public function set autoPlay(value:Boolean):void
    {
        if (videoElement)
        {
            videoElement.autoPlay = value;
            videoElementProperties = BitFlagUtil.update(videoElementProperties as uint, 
                                                        AUTO_PLAY_PROPERTY_FLAG, true);
        }
        else if (videoElementProperties)
        {
            videoElementProperties.autoPlay = value;
        }
        else
        {
            videoElementProperties = {autoPlay: value};
        }
    }
    
    //----------------------------------
    //  autoRewind
    //----------------------------------
    
    [Inspectable(category="General", defaultValue="true")]
    
    /**
     *  @copy spark.primitives.VideoElement#autoRewind
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get autoRewind():Boolean
    {
        if (videoElement)
        {
            return videoElement.autoRewind;
        }
        else
        {
            var v:* = videoElementProperties.autoRewind;
            return (v === undefined) ? true : v;
        }
    }
    
    /**
     * @private
     */
    public function set autoRewind(value:Boolean):void
    {
        if (videoElement)
        {
            videoElement.autoRewind = value;
            videoElementProperties = BitFlagUtil.update(videoElementProperties as uint, 
                                                        AUTO_REWIND_PROPERTY_FLAG, true);
        }
        else if (videoElementProperties)
        {
            videoElementProperties.autoRewind = value;
        }
        else
        {
            videoElementProperties = {autoRewind: value};
        }
    }
    
    //----------------------------------
    //  maintainAspectRatio
    //----------------------------------
    
    [Inspectable(Category="General", defaultValue="true")]

    /**
     *  @copy spark.primitives.VideoElement#maintainAspectRatio
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get maintainAspectRatio():Boolean
    {
        if (videoElement)
        {
            return videoElement.maintainAspectRatio;
        }
        else
        {
            var v:* = videoElementProperties.maintainAspectRatio;
            return (v === undefined) ? true : v;
        }
    }
    
    /**
     *  @private
     */
    public function set maintainAspectRatio(value:Boolean):void
    {
        if (videoElement)
        {
            videoElement.maintainAspectRatio = value;
            videoElementProperties = BitFlagUtil.update(videoElementProperties as uint, 
                                                        MAINTAIN_ASPECT_RATIO_PROPERTY_FLAG, true);
        }
        else if (videoElementProperties)
        {
            videoElementProperties.maintainAspectRatio = value;
        }
        else
        {
            videoElementProperties = {maintainAspectRatio: value};
        }
    }
    
    //----------------------------------
    //  muted
    //----------------------------------
    
    [Inspectable(category="General", defaultValue="false")]
    
    /**
     *  @copy spark.primitives.VideoElement#muted
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get muted():Boolean
    {
        if (videoElement)
        {
            return videoElement.muted;
        }
        else
        {
            var v:* = videoElementProperties.muted;
            return (v === undefined) ? false : v;
        }
    }
    
    /**
     *  @private
     */
    public function set muted(value:Boolean):void
    {
        if (videoElement)
        {
            videoElement.muted = value;
            videoElementProperties = BitFlagUtil.update(videoElementProperties as uint, 
                                                        MUTED_PROPERTY_FLAG, true);
        }
        else if (videoElementProperties)
        {
            videoElementProperties.muted = value;
        }
        else
        {
            videoElementProperties = {muted: value};
        }
    }
    
    //----------------------------------
    //  playheadTime
    //----------------------------------
    
    [Bindable("playheadUpdate")]
    [Bindable("autoRewound")]
    [Inspectable(Category="General", defaultValue="0")]
    
    /**
     *  @copy spark.primitives.VideoElement#playheadTime
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get playheadTime():Number
    {
        if (videoElement)
            return videoElement.playheadTime;
        else
            return 0;
    }
    
    //----------------------------------
    //  playing
    //----------------------------------
    
    [Inspectable(category="General")]
    
    /**
     *  @copy spark.primitives.VideoElement#playing
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get playing():Boolean
    {
        if (videoElement)
            return videoElement.playing;
        else
            return false;
    }
    
    //----------------------------------
    //  source
    //----------------------------------
    
    [Bindable("sourceChanged")]
    [Inspectable(category="General", defaultValue="null")]
    
    /**
     *  @copy spark.primitives.VideoElement#source
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get source():Object
    {
        if (videoElement)
        {
            return videoElement.source;
        }
        else
        {
            var v:* = videoElementProperties.source;
            return (v === undefined) ? null : v;
        }
    }

    /**
     * @private
     */
    public function set source(value:Object):void
    {
        if (videoElement)
        {
            videoElement.source = value;
            videoElementProperties = BitFlagUtil.update(videoElementProperties as uint, 
                                                        SOURCE_PROPERTY_FLAG, true);
        }
        else if (videoElementProperties)
        {
            videoElementProperties.source = value;
        }
        else
        {
            videoElementProperties = {source: value};
        }
    }
    
    //----------------------------------
    //  totalTime
    //----------------------------------
    
    [Bindable("complete")]
    [Bindable("metadataReceived")]
    [Inspectable(Category="General", defaultValue="0")]
    
    /**
     *  @copy spark.primitives.VideoElement#totalTime
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get totalTime():Number
    {
        if (videoElement)
            return videoElement.totalTime;
        else
            return 0;
    }
    
    //----------------------------------
    //  volume
    //----------------------------------
    
    [Bindable("volumeChanged")]
    [Inspectable(category="General", defaultValue="1.0")]
    
    /**
     *  @copy spark.primitives.VideoElement#volume
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get volume():Number
    {
        if (videoElement)
        {
            return videoElement.volume;
        }
        else
        {
            var v:* = videoElementProperties.volume;
            return (v === undefined) ? 1 : v;
        }
    }
    
    /**
     * @private
     */
    public function set volume(value:Number):void
    {
        if (videoElement)
        {
            videoElement.volume = value;
            videoElementProperties = BitFlagUtil.update(videoElementProperties as uint, 
                                                        VOLUME_PROPERTY_FLAG, true);
        }
        else if (videoElementProperties)
        {
            videoElementProperties.volume = value;
        }
        else
        {
            videoElementProperties = {volume: value};
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Keep track of what the previous state was.  This is because when we're 
     *  figuring out our currentState, we look at 1) whether we're disabled
     *  2) what our videoPlayer state is 3) what our previous state was
     */
    private var previousState:String = VideoState.DISCONNECTED;
    
    /**
     *  @private
     */
    override protected function getCurrentSkinState():String
    {
        var state:String;
        
        var currentState:String;
        
        if (videoElement)
            currentState = videoElement.mx_internal::videoPlayer.state;
        
        // only push certain video player states to our skins.
        // Resizing, rewinding, and execQueuedCmd are ignored, 
        // and that's why we keep track of the previousState, which 
        // is the last state we care about and want to push to our skin
        switch (currentState)
        {
            case VideoState.BUFFERING:
            case VideoState.LOADING:
                state = VideoState.LOADING;
                break;
            case VideoState.PAUSED:
                state = VideoState.STOPPED;
                break;
            case VideoState.CONNECTION_ERROR:
            case VideoState.DISCONNECTED:
            case VideoState.PLAYING:
            case VideoState.STOPPED:
            {
                state = currentState;
                break;
            }
        }
        
        if (!state)
            state = previousState;
        else
            previousState = state;
        
        // now that we have our video player's current state (atleast the one we care about)
        // and that we've set the previous state to something we care about, let's figure 
        // out our skin's state
        
        if (!enabled)
            state="disabled"
        
        if (fullScreen)
            return "fullScreen" + state.charAt(0).toUpperCase() + state.substring(1);
        
        return state;
    }
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        if (instance == videoElement)
        {
            videoElement.addEventListener(spark.events.VideoEvent.CLOSE, dispatchEvent);
            videoElement.addEventListener(spark.events.VideoEvent.COMPLETE, dispatchEvent);
            videoElement.addEventListener(spark.events.VideoEvent.METADATA_RECEIVED, videoElement_metaDataReceivedHandler);
            videoElement.addEventListener(spark.events.VideoEvent.PLAYHEAD_UPDATE, videoElement_playHeadUpdateHandler);
            videoElement.addEventListener(ProgressEvent.PROGRESS, videoElement_progressHandler);
            videoElement.addEventListener(spark.events.VideoEvent.READY, dispatchEvent);
            videoElement.addEventListener(fl.video.VideoEvent.STATE_CHANGE, videoElement_stateChangeHandler);
            videoElement.addEventListener("playingChanged", videoElement_playingChangedHandler);
            
            // just strictly for binding purposes
            videoElement.addEventListener("autoRewound", videoElement_autoRewoundHandler);
            videoElement.addEventListener("sourceChanged", dispatchEvent);
            videoElement.addEventListener("volumeChanged", videoElement_volumeChangedHandler);
            
            // copy proxied values from videoProperties (if set) to video
            
            var newVideoProperties:uint = 0;
            
            if (videoElementProperties)
            {
                if (videoElementProperties.source !== undefined)
                {
                    videoElement.source = videoElementProperties.source;
                    newVideoProperties = BitFlagUtil.update(newVideoProperties as uint, 
                                                            SOURCE_PROPERTY_FLAG, true);
                }
                
                if (videoElementProperties.autoPlay !== undefined)
                {
                    videoElement.autoPlay = videoElementProperties.autoPlay;
                    newVideoProperties = BitFlagUtil.update(newVideoProperties as uint, 
                                                            AUTO_PLAY_PROPERTY_FLAG, true);
                }
                
                if (videoElementProperties.volume !== undefined)
                {
                    videoElement.volume = videoElementProperties.volume;
                    newVideoProperties = BitFlagUtil.update(newVideoProperties as uint, 
                                                            VOLUME_PROPERTY_FLAG, true);
                }
                
                if (videoElementProperties.autoRewind !== undefined)
                {
                    videoElement.autoRewind = videoElementProperties.autoRewind;
                    newVideoProperties = BitFlagUtil.update(newVideoProperties as uint, 
                                                            AUTO_REWIND_PROPERTY_FLAG, true);
                }
                
                if (videoElementProperties.maintainAspectRatio !== undefined)
                {
                    videoElement.maintainAspectRatio = videoElementProperties.maintainAspectRatio;
                    newVideoProperties = BitFlagUtil.update(newVideoProperties as uint, 
                                                            MAINTAIN_ASPECT_RATIO_PROPERTY_FLAG, true);
                }
                
                if (videoElementProperties.muted !== undefined)
                {
                    videoElement.muted = videoElementProperties.muted;
                    newVideoProperties = BitFlagUtil.update(newVideoProperties as uint, 
                                                            MUTED_PROPERTY_FLAG, true);
                }
            }
            
            videoElementProperties = newVideoProperties;
            
            videoElement.enabled = enabled;
            
            if (volumeBar)
                volumeBar.value = volume;
            
            if (scrubBar)
                updateScrubBar();

            if (playheadTimeLabel)
                updatePlayheadTime();
            
            if (totalTimeLabel)
                updateTotalTime();
            
            if (muteButton)
                muteButton.selected = videoElement.muted;
        }
        else if (instance == playButton)
        {
            playButton.addEventListener(MouseEvent.CLICK, playButton_clickHandler);
        }
        else if (instance == pauseButton)
        {
            pauseButton.addEventListener(MouseEvent.CLICK, pauseButton_clickHandler);
        }
        else if (instance == playPauseButton)
        {
            playPauseButton.addEventListener(MouseEvent.CLICK, playPauseButton_clickHandler);
        }
        else if (instance == stopButton)
        {
            stopButton.addEventListener(MouseEvent.CLICK, stopButton_clickHandler);
        }
        else if (instance == muteButton)
        {
            muteButton.selected = muted;
            muteButton.addEventListener(MouseEvent.CLICK, muteButton_clickHandler);
        }
        else if (instance == volumeBar)
        {
            volumeBar.addEventListener(Event.CHANGE, volumeBar_changeHandler);
            // TODO (rfrishbe): Need this to be a real event
            volumeBar.addEventListener("muteButtonClick", muteButton_clickHandler);
            volumeBar.minimum = 0;
            volumeBar.maximum = 1;
            if (videoElement)
                volumeBar.value = volume;
        }
        else if (instance == scrubBar)
        {
            if (scrubBar)
                updateScrubBar();
            
            scrubBar.addEventListener(TrackBaseEvent.THUMB_PRESS, scrubBar_thumbPressHandler);
            scrubBar.addEventListener(TrackBaseEvent.THUMB_RELEASE, scrubBar_thumbReleaseHandler);
            scrubBar.addEventListener(Event.CHANGE, scrubBar_changeHandler);
            scrubBar.addEventListener("changing", scrubBar_changingHandler);
        }
        else if (instance == fullScreenButton)
        {
            fullScreenButton.addEventListener(MouseEvent.CLICK, fullScreenButton_clickHandler);
        }
        else if (instance == playheadTimeLabel)
        {
            if (videoElement)
                updatePlayheadTime();
        }
        else if (instance == totalTimeLabel)
        {
            if (totalTimeLabel)
                updateTotalTime();
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        if (instance == videoElement)
        {           
            // copy proxied values from video (if explicitely set) to videoProperties
            
            var newVideoProperties:Object = {};
            var propertySet:Boolean = false;
            
            if (BitFlagUtil.isSet(videoElementProperties as uint, SOURCE_PROPERTY_FLAG))
            {
                newVideoProperties.source = videoElement.source;
                propertySet = true;
            }
            
            if (BitFlagUtil.isSet(videoElementProperties as uint, AUTO_PLAY_PROPERTY_FLAG))
            {
                newVideoProperties.autoPlay = videoElement.autoPlay;
                propertySet = true;
            }
            
            if (BitFlagUtil.isSet(videoElementProperties as uint, VOLUME_PROPERTY_FLAG))
            {
                newVideoProperties.volume = videoElement.volume;
                propertySet = true;
            }
            
            if (BitFlagUtil.isSet(videoElementProperties as uint, AUTO_REWIND_PROPERTY_FLAG))
            {
                newVideoProperties.autoRewind = videoElement.autoRewind;
                propertySet = true;
            }
            
            if (BitFlagUtil.isSet(videoElementProperties as uint, MAINTAIN_ASPECT_RATIO_PROPERTY_FLAG))
            {
                newVideoProperties.maintainAspectRatio = videoElement.maintainAspectRatio;
                propertySet = true;
            }
            
            if (BitFlagUtil.isSet(videoElementProperties as uint, MUTED_PROPERTY_FLAG))
            {
                newVideoProperties.muted = videoElement.muted;
                propertySet = true;
            }
            
            if (propertySet)
                videoElementProperties = newVideoProperties;
            
            videoElement.removeEventListener(spark.events.VideoEvent.CLOSE, dispatchEvent);
            videoElement.removeEventListener(spark.events.VideoEvent.COMPLETE, videoElement_completeHandler);
            videoElement.removeEventListener(spark.events.VideoEvent.METADATA_RECEIVED, videoElement_metaDataReceivedHandler);
            videoElement.removeEventListener(spark.events.VideoEvent.PLAYHEAD_UPDATE, videoElement_playHeadUpdateHandler);
            videoElement.removeEventListener(ProgressEvent.PROGRESS, videoElement_progressHandler);
            videoElement.removeEventListener(spark.events.VideoEvent.READY, dispatchEvent);
            videoElement.removeEventListener(fl.video.VideoEvent.STATE_CHANGE, videoElement_stateChangeHandler);
            videoElement.removeEventListener("playingChanged", videoElement_playingChangedHandler);
            
            // just strictly for binding purposes
            videoElement.removeEventListener("autoRewound", videoElement_autoRewoundHandler);
            videoElement.removeEventListener("sourceChanged", dispatchEvent);
            videoElement.removeEventListener("volumeChanged", videoElement_volumeChangedHandler);
        }
        else if (instance == playButton)
        {
            playButton.removeEventListener(MouseEvent.CLICK, playButton_clickHandler);
        }
        else if (instance == pauseButton)
        {
            pauseButton.removeEventListener(MouseEvent.CLICK, pauseButton_clickHandler);
        }
        else if (instance == playPauseButton)
        {
            playPauseButton.removeEventListener(MouseEvent.CLICK, playPauseButton_clickHandler);
        }
        else if (instance == stopButton)
        {
            stopButton.removeEventListener(MouseEvent.CLICK, stopButton_clickHandler);
        }
        else if (instance == muteButton)
        {
            playButton.removeEventListener(MouseEvent.CLICK, muteButton_clickHandler);
        }
        else if (instance == volumeBar)
        {
            volumeBar.removeEventListener(Event.CHANGE, volumeBar_changeHandler);
            volumeBar.removeEventListener("muteButtonClick", muteButton_clickHandler);
        }
        else if (instance == scrubBar)
        {
            scrubBar.removeEventListener(TrackBaseEvent.THUMB_PRESS, scrubBar_thumbPressHandler);
            scrubBar.removeEventListener(TrackBaseEvent.THUMB_RELEASE, scrubBar_thumbReleaseHandler);
            scrubBar.removeEventListener(Event.CHANGE, scrubBar_changeHandler);
            scrubBar.removeEventListener("changing", scrubBar_changingHandler);
        }
        else if (instance == fullScreenButton)
        {
            fullScreenButton.removeEventListener(MouseEvent.CLICK, fullScreenButton_clickHandler);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @throws TypeError If the skin hasn't been loaded and there is no videoElement.    
     *
     *  @copy spark.primitives.VideoElement#pause()
     * 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function pause():void
    {
        videoElement.pause();
    }
    
    /**
     *  @copy spark.primitives.VideoElement#play()
     * 
     *  @throws TypeError if the skin hasn't been loaded up yet
     *                    and there's no videoElement.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function play():void
    {
        videoElement.play();
    }
    
    /**
     *  @copy spark.primitives.VideoElement#seek()
     * 
     *  @throws TypeError if the skin hasn't been loaded up yet
     *                    and there's no videoElement.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function seek(time:Number):void
    {
        videoElement.seek(time);
    }
    
    /**
     *  @copy spark.primitives.VideoElement#stop()
     * 
     *  @throws TypeError if the skin hasn't been loaded up yet
     *                    and there's no videoElement.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function stop():void
    {
        videoElement.stop();
    }
    
    /**
     *  @private
     */
    private function updateScrubBar():void
    {
        if (!videoElement)
            return;
        
        if (!scrubBarMouseCaptured && !scrubBarChanging)
        {
            scrubBar.minimum = 0;
            scrubBar.maximum = videoElement.totalTime;
            scrubBar.value = videoElement.playheadTime;
        }
        
        if (scrubBar is VideoPlayerScrubBar)
            VideoPlayerScrubBar(scrubBar).bufferedValue = videoElement.mx_internal::videoPlayer.bytesLoaded/videoElement.mx_internal::videoPlayer.bytesTotal * videoElement.totalTime;
    }
     
   /**
    *  @private
    */
    private function updateTotalTime():void
    {
        totalTimeLabel.text = formatTimeValue(totalTime);
    }
    
    /**
     *  Formats a time value, given in seconds, into a string that 
     *  gets used for the playheadTimeLabel and the totalTimeLabel.
     * 
     *  @param value Value in seconds of the time to format
     * 
     *  @return Formatted time value
     */
    protected function formatTimeValue(value:Number):String
    {
        // default format: hours:minutes:seconds
        var hours:uint = Math.floor(value/3600) % 24;
        var minutes:uint = Math.floor(value/60) % 60;
        var seconds:uint = Math.round(value) % 60;
        
        var result:String = "";
        if (hours != 0)
            result = hours + ":";
        
        if (result && minutes < 10)
            result += "0" + minutes + ":";
        else
            result += minutes + ":";
        
        if (seconds < 10)
            result += "0" + seconds;
        else
            result += seconds;
        
        return result;
    }
     
    /**
     *  @private
     */
    private function updatePlayheadTime():void
    {
        playheadTimeLabel.text = formatTimeValue(playheadTime);
    } 
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function videoElement_completeHandler(event:spark.events.VideoEvent):void
    {
        // TODO: needed??
        if (totalTimeLabel)
            updateTotalTime();
        
        dispatchEvent(event);
    }
    
    /**
     *  @private
     */
    private function videoElement_metaDataReceivedHandler(event:spark.events.VideoEvent):void
    {
        if (scrubBar)
            updateScrubBar();
        
        if (totalTimeLabel)
            updateTotalTime();
        
        dispatchEvent(event);
    }
    
    /**
     *  @private
     */
    private function videoElement_autoRewoundHandler(event:Event):void
    {
        updateScrubBar();
        
        if (playheadTimeLabel)
            updatePlayheadTime();
        
        // for binding purposes:
        dispatchEvent(event);
    }
    
    /**
     *  @private
     */
    private function videoElement_playHeadUpdateHandler(event:spark.events.VideoEvent):void
    {
        updateScrubBar();
        
        if (playheadTimeLabel)
            updatePlayheadTime();
        
        dispatchEvent(event);
    }
    
    /**
     *  @private
     */
    private function videoElement_progressHandler(event:ProgressEvent):void
    {
        if (scrubBar)
            updateScrubBar();
        
        dispatchEvent(event);
    }
    
    /**
     *  @private
     */
    private function videoElement_stateChangeHandler(event:fl.video.VideoEvent):void
    {
        invalidateSkinState();
        
        // don't dispatch the event here...this is an internal event
    }
    
   /**
    *  @private
    */
    private function videoElement_playingChangedHandler(event:Event):void
    {
        if (playPauseButton)
            playPauseButton.selected = playing;
    }
    
    /**
     *  @private
     */
    private function videoElement_volumeChangedHandler(event:Event):void
    {
        if (volumeBar)
            volumeBar.value = volume;
        
        dispatchEvent(event);
    }
    
    /**
     *  @private
     *  Indicates whether we are in the full screen state or not.
     *  We use this when determining our current skin state.
     */
    private var fullScreen:Boolean = false;
    
    /**
     *  @private
     *  X-value before going in to full screen mode.  This way we 
     *  can reset it to this afterwards.
     */
    private var beforeFullScreenX:Number;
    
    /**
     *  @private
     *  Y-value before going in to full screen mode.  This way we 
     *  can reset it to this afterwards.
     */
    private var beforeFullScreenY:Number;
    
    /**
     *  @private
     *  Timer, which waits for 3 seconds by default to hide the 
     *  playback controls.  If there's interaction by the user, then 
     *  these playback controls are show again, and the timer will reset 
     *  and start the countdown.
     */
    private var fullScreenHideControlTimer:Timer;
    
    /**
     *  @private
     */
    private function fullScreenButton_clickHandler(event:MouseEvent):void
    {
        if (!fullScreen)
        {
            fullScreen = true;
            
            // need it to go into full screen state for the skin
            invalidateSkinState();
            
            // let's get it off of our layout system so it doesn't interfere with 
            // the sizing and positioning. Then let's resize it to be 
            // the full size of our screen.  Then let's position it off-screen so
            // there are no other elements in the way. 
            beforeFullScreenX = this.x;
            beforeFullScreenY = this.y;
            includeInLayout = false;
            setLayoutBoundsSize(stage.fullScreenWidth, stage.fullScreenHeight);
            this.validateNow();
            this.x = -(2*width);
            this.y = -(2*height);
            
            // this is for video performance reasons
            videoElement.mx_internal::videoPlayer.smoothing = false;
            videoElement.mx_internal::videoPlayer.deblocking = 0;
            
            // now into full screen we go
            // TODO: what if we're sandboxed...can we get the stage?
            stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenEventHandler);
            stage.fullScreenSourceRect = new Rectangle(x, y, width, height);
            stage.displayState = StageDisplayState.FULL_SCREEN;
            
            // start timer for detecting for mouse movements/clicks to hide the controls
            fullScreenHideControlTimer = new Timer(FULL_SCREEN_HIDE_CONTROLS_DELAY, 1);
            fullScreenHideControlTimer.addEventListener(TimerEvent.TIMER_COMPLETE, 
                fullScreenHideControlTimer_timerCompleteHandler, false, 0, true);
            
            // use stage or systemManager?
            systemManager.addEventListener(MouseEvent.MOUSE_DOWN, resetFullScreenHideControlTimer);
            systemManager.addEventListener(MouseEvent.MOUSE_MOVE, resetFullScreenHideControlTimer);
            systemManager.addEventListener(MouseEvent.MOUSE_WHEEL, resetFullScreenHideControlTimer);
            
            // keyboard events don't happen when in fullScreen mode, but could be in fullScreen and interactive mode
            systemManager.addEventListener(KeyboardEvent.KEY_DOWN, resetFullScreenHideControlTimer);
            fullScreenHideControlTimer.start();
        }
        else
        {
            stage.displayState = StageDisplayState.NORMAL;
        }
    }
    
    /**
     *  @private
     *  After waiting a certain time perdiod, we hide the controls if no 
     *  user-interaction has occurred on-screen.
     */
    private function fullScreenHideControlTimer_timerCompleteHandler(event:TimerEvent):void
    {
        playerControls.visible = false;
    }
    
    /**
     *  @private
     *  Handles when mouse interaction happens, and we are in the fullscreen mode.  This 
     *  resets the fullScreenHideControlTimer.
     */
    private function resetFullScreenHideControlTimer(event:Event):void
    {
        playerControls.visible = true;
        
        if (fullScreenHideControlTimer)
        {
            fullScreenHideControlTimer.reset();
            fullScreenHideControlTimer.start();
        }
        else
        {
            fullScreenHideControlTimer = new Timer(FULL_SCREEN_HIDE_CONTROLS_DELAY, 1);
            fullScreenHideControlTimer.addEventListener(TimerEvent.TIMER_COMPLETE, 
                fullScreenHideControlTimer_timerCompleteHandler, false, 0, true);
        }
    }
    
    /**
     *  @private
     *  Handles when coming out the full screen mode
     */
    private function fullScreenEventHandler(event:FullScreenEvent):void
    {
        // going in to full screen is handled by the 
        // fullScreenButton_clickHandler
        if (event.fullScreen)
            return;
        
        // set the fullScreen variable back to false and remove this event listener
        fullScreen = false;
        stage.removeEventListener(FullScreenEvent.FULL_SCREEN, fullScreenEventHandler);
        fullScreenHideControlTimer.reset();
        fullScreenHideControlTimer = null;
        
        // remove the event listeners to hide the controls
        systemManager.removeEventListener(MouseEvent.MOUSE_DOWN, resetFullScreenHideControlTimer);
        systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, resetFullScreenHideControlTimer);
        systemManager.removeEventListener(MouseEvent.MOUSE_WHEEL, resetFullScreenHideControlTimer);
        systemManager.removeEventListener(KeyboardEvent.KEY_DOWN, resetFullScreenHideControlTimer);
        
        // make the controls visible no matter what
        playerControls.visible = true;
        
        // reset it so we're re-included in the layout
        this.x = beforeFullScreenX;
        this.y = beforeFullScreenY;
        includeInLayout = true;
        invalidateSkinState();
        invalidateSize();
        invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    private function playButton_clickHandler(event:MouseEvent):void
    {
        if (!playing)
            play();
    }
    
    /**
     *  @private
     */
    private function pauseButton_clickHandler(event:MouseEvent):void
    {
        pause();
    }
    
    /**
     *  @private
     */
    private function stopButton_clickHandler(event:MouseEvent):void
    {
        stop();
    }
    
    /**
     *  @private
     */
    private function playPauseButton_clickHandler(event:MouseEvent):void
    {
        if (playing)
            pause();
        else
            play();
    }
    
    /**
     *  @private
     */
    private function muteButton_clickHandler(event:MouseEvent):void
    {
        if (muted)
            muted = false;
        else
            muted = true;
    }
    
    /**
     *  @private
     */
    private function volumeBar_changeHandler(event:Event):void
    {
        volume = volumeBar.value;
    }
    
    /**
     *  @private
     *  When someone is holding the scrubBar, we don't want to update the 
     *  range's value--for this time period, we'll let the user completely 
     *  control the range.
     */
    private var scrubBarMouseCaptured:Boolean;
    
    /**
     *  @private
     *  We pause the video when dragging the thumb for the scrub bar.  This 
     *  stores whether we were paused or not.
     */
    private var wasPlayingBeforeSeeking:Boolean;
    
    /**
     *  @private
     *  We are in the process of changing the timestamp
     */
    private var scrubBarChanging:Boolean;
    
    /**
     *  @private
     */
    private function scrubBar_changingHandler(event:Event):void
    {
        scrubBarChanging = true;
    }
    
    /**
     *  @private
     */
    private function scrubBar_thumbPressHandler(event:TrackBaseEvent):void
    {
        scrubBarMouseCaptured = true;
        if (playing)
        {
            pause();
            wasPlayingBeforeSeeking = true;
        }
    }
    
    /**
     *  @private
     */
    private function scrubBar_thumbReleaseHandler(event:TrackBaseEvent):void
    {
        scrubBarMouseCaptured = false;
        if (wasPlayingBeforeSeeking)
        {
            play();
            wasPlayingBeforeSeeking = false;
        }
    }
    
    /**
     *  @private
     */
    private function scrubBar_changeHandler(event:Event):void
    {
        if (scrubBarMouseCaptured)
        {
            videoElement.mx_internal::videoPlayer.flvplayback_internal::flushQueuedCmds();
            seek(scrubBar.value);
        }
        else
        {
            scrubBarChanging = false;
            seek(scrubBar.value);
        }
    }
}
}