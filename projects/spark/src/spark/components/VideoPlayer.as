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

import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.FullScreenEvent;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.geom.Rectangle;

import mx.core.IVisualElementContainer;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.SandboxMouseEvent;
import mx.utils.BitFlagUtil;

import spark.components.supportClasses.ButtonBase;
import spark.components.supportClasses.Range;
import spark.components.supportClasses.SkinnableComponent;
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
 *  Buffering State of the VideoPlayer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("buffering")]

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
 *  FullScreen State of the VideoPlayer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("fullScreen")]

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
 *  Pause State of the VideoPlayer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("paused")]

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
 *  Seeking State of the VideoPlayer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("seeking")]

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
 *  progressive download, multi-bitrate, and streaming video.
 * 
 *  <p><code>VideoElement</code> is the chromeless version.</p>
 *
 *  @see spark.primitives.VideoElement
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
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *   
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
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
    public var muteButton:ToggleButton;
    
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
    public var playPauseButton:ToggleButton;
    
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
    public var scrubBar:Range;
    
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
    private var videoElementProperties:Object = {};
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  enabled
    //----------------------------------

    private var wasPlayingBeforeDisabled:Boolean;

    /**
     *  @private
     */
    override public function set enabled(value:Boolean):void
    {
        // TODO (rfrishbe): what about autoPlay and manual calls to play()?
        super.enabled = value;
        
        if (!value && videoElement)
        {
            if (playing || wasPlayingBeforeDisabled)
                wasPlayingBeforeDisabled = true;
            else
                wasPlayingBeforeDisabled = false;
            videoElement.pause();
        }
        else if (wasPlayingBeforeDisabled)
        {
            wasPlayingBeforeDisabled = false;
            videoElement.play();
        }
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
        return (videoElement) ? videoElement.autoPlay : videoElementProperties.autoPlay;
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
        else
            videoElementProperties.autoPlay = value;
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
        return (videoElement) ? videoElement.autoRewind : videoElementProperties.autoRewind;
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
        else
            videoElementProperties.autoRewind = value;
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
        return (videoElement) ? videoElement.maintainAspectRatio : videoElementProperties.maintainAspectRatio;
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
        else
            videoElementProperties.maintainAspectRatio = value;
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
        return (videoElement) ? videoElement.muted : videoElementProperties.muted;
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
        else
            videoElementProperties.muted = value;
        
        if (muteButton)
            muteButton.selected = value;
    }
    
    //----------------------------------
    //  playheadTime
    //----------------------------------
    
    [Bindable("playheadUpdate")]
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
        return (videoElement) ? videoElement.source : videoElementProperties.source;
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
        else
            videoElementProperties.source = value;
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
        return (videoElement) ? videoElement.volume : videoElement.volume;
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
        else
            videoElementProperties.volume = value;
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
            // copy proxied values from videoProperties (if set) to video
            
            var newVideoProperties:uint = 0;
            
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
            
            videoElementProperties = newVideoProperties;
            
            videoElement.addEventListener(spark.events.VideoEvent.CLOSE, dispatchEvent);
            videoElement.addEventListener(spark.events.VideoEvent.COMPLETE, dispatchEvent);
            videoElement.addEventListener(spark.events.VideoEvent.METADATA_RECEIVED, videoElement_metaDataReceivedHandler);
            videoElement.addEventListener(spark.events.VideoEvent.PLAYHEAD_UPDATE, videoElement_playHeadUpdateHandler);
            videoElement.addEventListener(ProgressEvent.PROGRESS, videoElement_progressHandler);
            videoElement.addEventListener(fl.video.VideoEvent.STATE_CHANGE, videoElement_stateChangeHandler);
            
            // just strictly for binding purposes
            videoElement.addEventListener("sourceChanged", dispatchEvent);
            videoElement.addEventListener("volumeChanged", videoElement_volumeChangedHandler);
            
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
            
            if (BitFlagUtil.isSet(videoElementProperties as uint, SOURCE_PROPERTY_FLAG))
                newVideoProperties.source = videoElement.source;
            
            if (BitFlagUtil.isSet(videoElementProperties as uint, AUTO_PLAY_PROPERTY_FLAG))
                newVideoProperties.autoPlay = videoElement.autoPlay;
            
            if (BitFlagUtil.isSet(videoElementProperties as uint, VOLUME_PROPERTY_FLAG))
                newVideoProperties.volume = videoElement.volume;
            
            if (BitFlagUtil.isSet(videoElementProperties as uint, AUTO_REWIND_PROPERTY_FLAG))
                newVideoProperties.autoRewind = videoElement.autoRewind;
            
            if (BitFlagUtil.isSet(videoElementProperties as uint, MAINTAIN_ASPECT_RATIO_PROPERTY_FLAG))
                newVideoProperties.maintainAspectRatio = videoElement.maintainAspectRatio;
            
            if (BitFlagUtil.isSet(videoElementProperties as uint, MUTED_PROPERTY_FLAG))
                newVideoProperties.muted = videoElement.muted;
                
            videoElementProperties = newVideoProperties;
            
            videoElement.removeEventListener(spark.events.VideoEvent.CLOSE, dispatchEvent);
            videoElement.removeEventListener(spark.events.VideoEvent.COMPLETE, videoElement_completeHandler);
            videoElement.removeEventListener(spark.events.VideoEvent.METADATA_RECEIVED, videoElement_metaDataReceivedHandler);
            videoElement.removeEventListener(spark.events.VideoEvent.PLAYHEAD_UPDATE, videoElement_playHeadUpdateHandler);
            videoElement.removeEventListener(ProgressEvent.PROGRESS, videoElement_progressHandler);
            videoElement.removeEventListener(fl.video.VideoEvent.STATE_CHANGE, videoElement_stateChangeHandler);
            
            // just strictly for binding purposes
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
     *  @copy spark.primitives.VideoElement#pause()
     * 
     *  @throws TypeError if the skin hasn't been loaded up yet
     *                    and there's no videoElement.
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
    public function play(startTime:Number=NaN, duration:Number=NaN):void
    {
        videoElement.play(startTime, duration);
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
        
        if (!scrubBarMouseCaptured)
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
        if (playPauseButton)
            playPauseButton.selected = playing;
        
        invalidateSkinState();
        
        // don't dispatch the event here...this is an internal event
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
     */
    private function fullScreenButton_clickHandler(event:MouseEvent):void
    {
        if (!fullScreen)
        {
            // TODO (rfrishbe): What should we do on full screen?
            fullScreen = true;
            invalidateSkinState();
            includeInLayout = false;
            setLayoutBoundsSize(stage.fullScreenWidth, stage.fullScreenHeight);
            videoElement.mx_internal::videoPlayer.smoothing = false;
            videoElement.mx_internal::videoPlayer.deblocking = 0;
            validateNow();
            stage.displayState = StageDisplayState.FULL_SCREEN;
            stage.fullScreenSourceRect = new Rectangle(0, 0, width, height);
            stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenEventHandler);
        }
        else
        {
            stage.displayState = StageDisplayState.NORMAL;
        }
    }
    
    private function fullScreenEventHandler(event:FullScreenEvent):void
    {
        if (event.fullScreen)
            return;
        
        fullScreen = false;
        invalidateSkinState();
        stage.removeEventListener(FullScreenEvent.FULL_SCREEN, fullScreenEventHandler);
        includeInLayout = true;
        invalidateSize();
        invalidateDisplayList();
//        var myParent:IVisualElementContainer = parent as IVisualElementContainer;
//        if (myParent)
//        {
//            var index:int = myParent.getElementIndex(this);
//            myParent.removeElement(this);
//            myParent.addElementAt(this, index);
//        }
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
            seek(scrubBar.value);
        }
    }
}
}