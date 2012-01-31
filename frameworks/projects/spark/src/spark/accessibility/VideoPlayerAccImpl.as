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

package spark.accessibility
{

import flash.accessibility.Accessibility;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.MouseEvent;

import mx.accessibility.AccConst;
import mx.accessibility.AccImpl;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

import org.osmf.events.TimeEvent;

import spark.components.Button;
import spark.components.VideoPlayer;
import spark.components.mediaClasses.ScrubBar;
import spark.components.mediaClasses.VolumeBar;
import spark.components.supportClasses.ButtonBase;
import spark.components.supportClasses.ToggleButtonBase;
import spark.events.SkinPartEvent;
import spark.events.VideoEvent;

use namespace mx_internal;

[ResourceBundle("components")]

/**
 *  VideoPlayerAccImpl is the accessibility implementation class
 *  for spark.components.VideoPlayer.
 *
 *  <p>When a Spark VideoPlayer is created, 
 *  its <code>accessibilityImplementation</code> property
 *  is set to an instance of this class.
 *  The Flash Player then uses this class to allow MSAA clients
 *  such as screen readers to see and manipulate the VideoPlayer.
 *  See the mx.accessibility.AccImpl and
 *  flash.accessibility.AccessibilityImplementation classes
 *  for background information about accessibility implementation
 *  classes and MSAA.</p>
 *
 *  <p><b>Children</b></p>
 *
 *  <p>The VideoPlayer has six MSAA children:
 *  <ol>
 *    <li>Play/Pause control</li>
 *    <li>Scrub control</li>
 *    <li>Play time indicator</li>
 *    <li>Mute control</li>
 *    <li>Volume control</li>
 *    <li>Full Screen control</li>
 *  </ol></p>
 *
 *  <p>The controls will always appear in the same order for accessibility
 *  regardless of the order of controls in the skin.</p>
 *
 *  <p><b>Role</b></p>
 *
 *  <p>The MSAA Role of a VideoPlayer is ROLE_SYSTEM_PANE.</p>
 *
 *  <p>The Role of each child control is:
 *  <ol>
 *    <li>Play/Pause control: ROLE_SYSTEM_BUTTON</li>
 *    <li>Scrub control: ROLE_SYSTEM_SLIDER</li>
 *    <li>Play time indicator: ROLE_SYSTEM_STATICTEXT</li>
 *    <li>Mute control: ROLE_SYSTEM_BUTTON</li>
 *    <li>Volume control: ROLE_SYSTEM_SLIDER</li>
 *    <li>Full Screen control: ROLE_SYSTEM_BUTTON</li>
 *  </ol></p>
 *
 *  <p><b>Name</b></p>
 *
 *  <p>The MSAA Name of a VideoPlayer is, by default,
 *  specified by a locale-dependent resource.
 *  For the en_US locale, the name is "VideoPlayer".
 *  When wrapped in a FormItem element,
 *  this name is combined with the FormItem's label.
 *  To override this behavior,
 *  set the VideoPlayer's's <code>accessibilityName</code> property.</p>
 *
 *  <p>The Name of each child control is similarly specified by a resource.
 *  The en_US names are:
 *  <ol>
 *    <li>Play/Pause control: "Play" or "Pause"</li>
 *    <li>Scrub control: "Scrub Bar"</li>
 *    <li>Play time indicator: the displayed text</li>
 *    <li>Mute control: "Muted" or "Not muted"</li>
 *    <li>Volume control: "Volume Bar"</li>
 *    <li>Full Screen control: "Full Screen"</li>
 *  </ol></p>
 *
 *  <p>To override the names of these child controls, reskin the VideoPlayer
 *  and set the <code>accessibilityName</code> of the controls.</p>
 *
 *  <p>Note that the Play/Pause control and the Mute control
 *  have MSAA Names which change as you interact with them.
 *  To specify them, set <code>accessibilityName</code>
 *  to a comma-separated list of MSAA Names,
 *  such as "Play,Pause" or "Not Muted,Muted".</p>
 *
 *  <p>When the Name of the VideoPlayer or one of its child controls changes,
 *  a VideoPlayer dispatches the MSAA event EVENT_OBJECT_NAMECHANGE
 *  with the proper childID for the control or 0 for itself.</p>
 *
 *  <p><b>Description</b></p>
 *
 *  <p>The MSAA Description of a VideoPlayer is, by default, the empty string,
 *  but you can set the VideoPlayer's <code>accessibilityDescription</code>
 *  property.</p>
 *
 *  <p>The Description of each child control is the empty string.</p>
 *
 *  <p><b>State</b></p>
 *
 *  <p>The MSAA State of a VideoPlayer is STATE_SYSTEM_NORMAL.</p>
 *
 *  <p>The State of each child control is:
 *  <ol>
 *    <li>Play/Pause control:
 *      <ul>
 *        <li>STATE_SYSTEM_UNAVAILABLE</li>
 *        <li>STATE_SYSTEM_FOCUSABLE</li>
 *        <li>STATE_SYSTEM_FOCUSED</li>
 *      </ul></li>
 *    <li>Scrub control:
 *      <ul>
 *        <li>STATE_SYSTEM_UNAVAILABLE</li>
 *        <li>STATE_SYSTEM_FOCUSABLE</li>
 *        <li>STATE_SYSTEM_FOCUSED</li>
 *      </ul></li>
 *    <li>Play time indicator:
 *      <ul>
 *        <li>STATE_SYSTEM_UNAVAILABLE</li>
 *        <li>STATE_SYSTEM_READONLY</li>
 *      </ul></li>
 *    <li>Mute control:
 *      <ul>
 *        <li>STATE_SYSTEM_UNAVAILABLE</li>
 *        <li>STATE_SYSTEM_FOCUSABLE</li>
 *        <li>STATE_SYSTEM_FOCUSED</li>
 *      </ul></li>
 *    <li>Volume control:
 *      <ul>
 *        <li>STATE_SYSTEM_UNAVAILABLE</li>
 *        <li>STATE_SYSTEM_FOCUSABLE</li>
 *        <li>STATE_SYSTEM_FOCUSED</li>
 *      </ul></li>
 *    <li>Full Screen control:
 *      <ul>
 *        <li>STATE_SYSTEM_UNAVAILABLE</li>
 *        <li>STATE_SYSTEM_FOCUSABLE</li>
 *        <li>STATE_SYSTEM_FOCUSED</li>
 *      </ul></li>
 *   </ol></p>
 *
 *   <p>When the State of the VideoPlayer or one of its child controls changes,
 *  a VideoPlayer dispatches the MSAA event EVENT_OBJECT_STATECHANGE
 *  with the proper childID for the control or 0 for itself.</p>
 *
 *  <p><b>Value</b></p>
 *
 *  <p>A VideoPlayer does not have an MSAA Value.</p>
 *
 *  <p>THe Value of each child control is:
 *  <ol>
 *    <li>Play/Pause control: no Value</li>
 *    <li>Scrub control: Value of slider as an amount of time</li>
 *    <li>Play time indicator: no Value</li>
 *    <li>Mute control: no Value</li>
 *    <li>Volume control: Value of slider</li>
 *    <li>Full Screen control: no Value</li>
 *  </ol></p>
 *
 *  <p>When the Value of a child control changes,
 *  a VideoPlayer dispatches the MSAA event EVENT_OBJECT_VALUECHANGE
 *  with the proper childID for the control.</p>
 *
 *  <p><b>Location</b></p>
 *
 *  <p>The MSAA Location of a VideoPlayer, or one of its child controls,
 *  is its bounding rectangle.</p>
 *
 *  <p><b>Default Action</b></p>
 *
 *  <p>A VideoPlayer does not have an MSAA DefaultAction.</p>
 *
 *  <p>The DefaultAction of each child control is:
 *  <ol>
 *    <li>Play/Pause control: "Press"</li>
 *    <li>Scrub control: none</li>
 *    <li>Play time indicator: none</li>
 *    <li>Mute control: "Press"</li>
 *    <li>Volume control: none</li>
 *    <li>Full Screen control: "Press"</li>
 *  </ol></p>
 *
 *  <p>Performing the default action of one of the child controls
 *  will have the following effect:
 *  <ol>
 *    <li>Play/Pause control: toggle between Play and Pause</li>
 *    <li>Scrub control: none</li>
 *    <li>Play time indicator: none</li>
 *    <li>Mute control: toggle between Mute and Not Muted</li>
 *    <li>Volume control: none</li>
 *    <li>Full Screen control: toogle Full Screen on and off</li>
 *  </ol></p>
 *
 *  <p><b>Focus</b></p>
 *
 *  <p>A VideoPlayer accepts focus.
 *  When it does so, it dispatches the MSAA event EVENT_OBJECT_FOCUS event.</p>
 *
 *  <p>Some of its child controls also accept focus:
 *  <ol>
 *    <li>Play/Pause control: accepts focus</li>
 *    <li>Scrub control: accepts focus</li>
 *    <li>Play time indicator: does not accept focus</li>
 *    <li>Mute control: transfers focus to Volume Bar</li>
 *    <li>Volume control: accepts focus</li>
 *    <li>Full Screen control: accepts focus</li>
 *  </ol></p>
 *
 *  <p>When reporting focus, the VideoPlayer reports itself
 *  if it is focused and none of its child controls is focused.
 *  Otherwise, the focus may be reported as being on
 *  the Play/Pause control, the Scrub control,
 *  the Volume control, or the Full Screen control.</p>
 *
 *  <p><b>Selection</b></p>
 *
 *  <p>A VideoPlayer does not support selection in the MSAA sense.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.0
 *  @productversion Flex 4
 */
public class VideoPlayerAccImpl extends AccImpl
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static const VIDEOPLAYER_PLAYPAUSEBUTTON:uint = 1;

    /**
     *  @private
     */
    private static const VIDEOPLAYER_SCRUBBAR:uint = 2

    /**
     *  @private
     */
    private static const VIDEOPLAYER_CURRENTTIMEDISPLAY:uint = 3;
    
    /**
     *  @private
     */
    private static const VIDEOPLAYER_MUTEBUTTON:uint = 4;
    
    /**
     *  @private
     */
    private static const VIDEOPLAYER_VOLUMEBAR:uint = 5;
    
    /**
     *  @private
     */
    private static const VIDEOPLAYER_FULLSCREENBUTTON:uint = 6;

    /**
     *  @private
     */
    private static const VIDEOPLAYER_NUM_ACCESSIBLE_COMPONENTS:uint = 6;
    
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Enables accessibility in the VideoPlayer class.
	 * 
	 *  <p>This method is called by application startup code
	 *  that is autogenerated by the MXML compiler.
	 *  Afterwards, when instances of VideoPlayer are initialized,
	 *  their <code>accessibilityImplementation</code> property
	 *  will be set to an instance of this class.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.0
	 *  @productversion Flex 4
	 */
	 
	public static function enableAccessibility():void
	{
		VideoPlayer.createAccessibilityImplementation =
			createAccessibilityImplementation;
	}

	/**
	 *  @private
	 *  Creates a VideoPlayer's AccessibilityImplementation object.
	 *  This method is called from UIComponent's
	 *  initializeAccessibility() method.
	 */
	mx_internal static function createAccessibilityImplementation(
								component:UIComponent):void
	{
		component.accessibilityImplementation =
			new VideoPlayerAccImpl(component);
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 *
	 *  @param master The UIComponent instance that this AccImpl instance
	 *  is making accessible.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 2.0
	 *  @productversion Flex 4
	 */
	public function VideoPlayerAccImpl(master:UIComponent)
	{
	    super(master);

	    role = AccConst.ROLE_SYSTEM_PANE; 
        
		// VideoPlayer has a playPauseButton and a volumeBar as skin parts,
		// and we need to listen to some of their events.
		// They may or may not be present when this constructor is called.
		// If they come or go later, we are notified via
		// "partAdded" and "partRemoved" events.

		var playPauseButton:ToggleButtonBase =
			VideoPlayer(master).playPauseButton;
		if (playPauseButton)
        {
			playPauseButton.addEventListener(Event.CHANGE, eventHandler);
            if (VideoPlayer(master).tabIndex > 0 &&
               playPauseButton.tabIndex == -1)
               playPauseButton.tabIndex = VideoPlayer(master).tabIndex;
            
        }

		var volumeBar:VolumeBar = VideoPlayer(master).volumeBar;
        if (volumeBar)
		{
			volumeBar.addEventListener(Event.CHANGE, eventHandler);
			volumeBar.addEventListener(FlexEvent.MUTED_CHANGE, eventHandler);
            if (VideoPlayer(master).tabIndex > 0 &&
                volumeBar.tabIndex == -1)
                volumeBar.tabIndex = VideoPlayer(master).tabIndex;
		}
        
        if (VideoPlayer(master).scrubBar)    
            if (VideoPlayer(master).tabIndex > 0 &&
                VideoPlayer(master).scrubBar.tabIndex == -1)
                VideoPlayer(master).scrubBar.tabIndex = VideoPlayer(master).tabIndex;

        if (VideoPlayer(master).fullScreenButton)
            if (VideoPlayer(master).tabIndex > 0 &&
                VideoPlayer(master).fullScreenButton.tabIndex == -1)
                VideoPlayer(master).fullScreenButton.tabIndex = VideoPlayer(master).tabIndex;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden properties: AccImpl
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  eventsToHandle
	//----------------------------------

	/**
	 *  @private
	 *	Array of events that we should listen for from the master component.
	 */
	override protected function get eventsToHandle():Array
	{
        return super.eventsToHandle.concat([ MouseEvent.CLICK,
        									 FocusEvent.FOCUS_IN,
											 TimeEvent.CURRENT_TIME_CHANGE,
											 SkinPartEvent.PART_ADDED,
											 SkinPartEvent.PART_REMOVED ])
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: AccessibilityImplementation
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Method to return the location of the child display object
 	 *  This function should never be called for parent (childID 0)
	 *
	 *  @return any
	 */
	override public function accLocation(childID:uint):*
	{
	    var videoPlayer:VideoPlayer = VideoPlayer(master);
		
	    switch (childID)
        {
            case VIDEOPLAYER_PLAYPAUSEBUTTON:
            {
                return videoPlayer.playPauseButton ? 
                       videoPlayer.playPauseButton : null;
            }
				
            case VIDEOPLAYER_SCRUBBAR: 
            {
                return videoPlayer.scrubBar ?
                       videoPlayer.scrubBar : null;
            }
				
            case VIDEOPLAYER_CURRENTTIMEDISPLAY:
            {
                return videoPlayer.currentTimeDisplay ?
                       videoPlayer.currentTimeDisplay : null;
            }
				
            case VIDEOPLAYER_MUTEBUTTON:
            {
                return videoPlayer.volumeBar ?
                       videoPlayer.volumeBar : null;
            }
				
            case VIDEOPLAYER_VOLUMEBAR:
            {
                return (videoPlayer.volumeBar && videoPlayer.volumeBar.dropDown) ?
                       videoPlayer.volumeBar.dropDown : null;
            }
				
            case VIDEOPLAYER_FULLSCREENBUTTON:
            {
                return videoPlayer.fullScreenButton ?
                       videoPlayer.fullScreenButton : null;
            }
        } 
	}
	
	/**
	 *  @private
	 *  Method to return an array of childIDs.
	 *  Currently there are six (6) child objects that render accessibility
     *
	 *  @return Array
	 */
	override public function getChildIDArray():Array
	{
        return createChildIDArray(VIDEOPLAYER_NUM_ACCESSIBLE_COMPONENTS); 
	}
	
	/**
	 *  @private
	 *  IAccessible method for returning the role of the VideoPlayer components.
	 *  Roles are predefined for all the components in MSAA.
	 *  Roles are assigned to each component.
	 *  Depending upon the video player's focused control
	 *
	 *  @param childID uint
	 *
	 *  @return Role uint
	 */
	override public function get_accRole(childID:uint):uint
	{
	    var accRole:uint = AccConst.ROLE_SYSTEM_GRAPHIC;

		switch (childID) 
        {
		    case 0:
            {
		        accRole = role; // PANE
		        break;
		    }
				
		    case VIDEOPLAYER_PLAYPAUSEBUTTON:
            {
                if (!VideoPlayer(master).playPauseButton)
                    break;
			    accRole = AccConst.ROLE_SYSTEM_PUSHBUTTON;  // playPauseButton
			    break;
    		}
				
    		case VIDEOPLAYER_SCRUBBAR:
            {
                if (!VideoPlayer(master).scrubBar)
                    break;
			    accRole = AccConst.ROLE_SYSTEM_SLIDER;  // scrubBar
			    break;
		    }
				
		    case VIDEOPLAYER_CURRENTTIMEDISPLAY:
            {
                if (!VideoPlayer(master).currentTimeDisplay)
                    break;
			    accRole = AccConst.ROLE_SYSTEM_STATICTEXT; // currentTime
			    break;
       		}
				
    		case VIDEOPLAYER_MUTEBUTTON:
            {
                if (!VideoPlayer(master).volumeBar)
                    break;
			    accRole = AccConst.ROLE_SYSTEM_PUSHBUTTON;  // volumeBar
			    break;
		    }
				
		    case VIDEOPLAYER_VOLUMEBAR:
            {
                if (!VideoPlayer(master).volumeBar)
                    break;
			    accRole = AccConst.ROLE_SYSTEM_SLIDER;  // volumeBar
			    break;
		    }
				
		    case VIDEOPLAYER_FULLSCREENBUTTON:
            {
                if (!VideoPlayer(master).fullScreenButton)
                    break;
			    accRole = AccConst.ROLE_SYSTEM_PUSHBUTTON; // fullScreenButton
			    break;
		    }
		}
        
		return accRole;
	}
	
	/**
	 *  @private
	 *  IAccessible method for returning the state of the VideoPlayer.
	 *  States are predefined for all the components in MSAA.
	 *  Values are assigned to each state.
	 *  Depending upon the video player controls being pressed or released,
	 *  a value is returned.
	 *
	 *  @param childID uint
	 *
	 *  @return State uint
	 */
	override public function get_accState(childID:uint):uint
	{
	    var accState:uint;
	    var index:uint = get_accFocus();
	    var videoPlayer:VideoPlayer = VideoPlayer(master);

        // pull from the default accessibility implementation
	    accState |= getState(childID);  
	
        if (!videoPlayer.enabled)
        {
            accState |= AccConst.STATE_SYSTEM_UNAVAILABLE;
            return accState;
        }

        if ((!videoPlayer.volumeBar) || (childID == VIDEOPLAYER_VOLUMEBAR && 
        	!videoPlayer.volumeBar.isDropDownOpen))
        {
            accState |= AccConst.STATE_SYSTEM_UNAVAILABLE;
            return accState;
        }

        if (((childID == VIDEOPLAYER_PLAYPAUSEBUTTON 
           && !videoPlayer.playPauseButton) || 
           (childID == VIDEOPLAYER_PLAYPAUSEBUTTON && 
           !videoPlayer.playPauseButton.enabled)) ||
           ((childID == VIDEOPLAYER_SCRUBBAR && !videoPlayer.scrubBar) || (childID == VIDEOPLAYER_SCRUBBAR && 
           !videoPlayer.scrubBar.enabled)) ||
           ((childID == VIDEOPLAYER_CURRENTTIMEDISPLAY && !videoPlayer.currentTimeDisplay) || 
           (childID == VIDEOPLAYER_CURRENTTIMEDISPLAY && 
           !(videoPlayer.currentTimeDisplay is UIComponent && UIComponent(videoPlayer.currentTimeDisplay).enabled))) ||
           ((childID == VIDEOPLAYER_MUTEBUTTON && !videoPlayer.volumeBar) || (childID == VIDEOPLAYER_MUTEBUTTON && 
           !videoPlayer.volumeBar.enabled)) ||
           ((childID == VIDEOPLAYER_VOLUMEBAR && !videoPlayer.volumeBar) || (childID == VIDEOPLAYER_VOLUMEBAR && 
           !videoPlayer.volumeBar.enabled)) ||
           ((childID == VIDEOPLAYER_FULLSCREENBUTTON && !videoPlayer.fullScreenButton) ||
           (childID == VIDEOPLAYER_FULLSCREENBUTTON &&
           !videoPlayer.fullScreenButton.enabled)))
        {
           accState |= AccConst.STATE_SYSTEM_UNAVAILABLE;
           return accState;
        }

        // eveything except for the currentTimeDisplay should be focusable
        if (childID != VIDEOPLAYER_CURRENTTIMEDISPLAY) 
            accState |=	AccConst.STATE_SYSTEM_FOCUSABLE;

        if (childID == index)
            accState |= AccConst.STATE_SYSTEM_FOCUSED;

        // invisible for slider when not visible
        return accState;
	}

	/**
	 *  @private
	 *  IAccessible method for returning the default action
	 *  of the VideoPlayer, which is Press.
	 *
	 *  @param childID uint
	 *
	 *  @return DefaultAction String
	 */
	override public function get_accDefaultAction(childID:uint):String
	{
		var action:String = "";
		
		switch (childID)
        {
		    case VIDEOPLAYER_PLAYPAUSEBUTTON: 
            {
                if (!VideoPlayer(master).playPauseButton)
                    break;
                action = "Toggle";
                break;
            }
            
			case VIDEOPLAYER_MUTEBUTTON:
            {
               if (!VideoPlayer(master).volumeBar)
                    break;
                action = "Press";
                break;
            }            
            case VIDEOPLAYER_FULLSCREENBUTTON:
            {
               if (!VideoPlayer(master).fullScreenButton)
                    break;
		        action = "Press";
		        break;
		    }
		}

		return action;
	}

	/**
	 *  @private
	 *  IAccessible method for returning the childFocus of the VideoPlayer.
	 *
	 *  @param childID uint
	 *
	 *  @return focused childID
	 */
	override public function get_accFocus():uint
	{
		var videoPlayer:VideoPlayer = VideoPlayer(master);
	
		var index:Number = 0;
		
		index = elementToChildID(videoPlayer.getFocus());

		return index;
	}

	/**
	 *  @private
	 *  IAccessible method for performing the default action
	 *  associated with VideoPlayer, which is Press.
	 *
	 *  @param childID uint
	 */
	override public function accDoDefaultAction(childID:uint):void
	{
		var videoPlayer:VideoPlayer = VideoPlayer(master);
		
		var clickEvent:MouseEvent; 		
	                
		if (master.enabled)
		{
            if (childID == VIDEOPLAYER_PLAYPAUSEBUTTON && 
                videoPlayer.playPauseButton)
			{
				clickEvent = new MouseEvent(MouseEvent.CLICK);
                videoPlayer.playPauseButton.dispatchEvent(clickEvent);
			}
			
            else if (childID == VIDEOPLAYER_MUTEBUTTON && 
                     videoPlayer.volumeBar)
            {
				videoPlayer.volumeBar.muted = !videoPlayer.volumeBar.muted;
				
				var mutedChangeEvent:FlexEvent =
					new FlexEvent(FlexEvent.MUTED_CHANGE);	
				videoPlayer.volumeBar.dispatchEvent(mutedChangeEvent);
			}
			
            else if (childID == VIDEOPLAYER_FULLSCREENBUTTON && 
                     videoPlayer.fullScreenButton)
			{
				clickEvent = new MouseEvent(MouseEvent.CLICK);
				videoPlayer.fullScreenButton.dispatchEvent(clickEvent);
			}
		}
	}
	
	/**
	 *  @private
	 *  IAccessible method for returning the value of sliders
	 *  which is spoken out by the screen reader
	 *  @param childID uint
	 *
	 *  @return Value String
	 */
	override public function get_accValue(childID:uint):String
	{
		var videoPlayer:VideoPlayer = VideoPlayer(master);
		
		var accValue:String = "";
		
        if (childID == VIDEOPLAYER_SCRUBBAR && 
            videoPlayer.currentTimeDisplay) 
  	   	    accValue = videoPlayer.currentTimeDisplay.text; 
		
        else if (childID == VIDEOPLAYER_VOLUMEBAR && videoPlayer.volumeBar) 
            accValue = String(Math.floor(videoPlayer.volumeBar.value * 100));
		
		return accValue;
	}

    /**
     *  @private
     *  IAccessible method for setting focus or selecting a child element
     *  @param selFlag uint
     *  @param childID uint
	 */
	override public function accSelect(selFlag:uint, childID:uint):void
	{   
        var videoPlayer:VideoPlayer = VideoPlayer(master);

	    if (selFlag == AccConst.SELFLAG_TAKEFOCUS) 
        {
	       	switch (childID) 
            {
	            case VIDEOPLAYER_PLAYPAUSEBUTTON: 
                {
                    if (videoPlayer.playPauseButton) 
    			        videoPlayer.playPauseButton.setFocus();
			 	    break;
			    }
					
			    case VIDEOPLAYER_SCRUBBAR:
                {
                    if (videoPlayer.scrubBar)
    			     	videoPlayer.scrubBar.setFocus();
			     	break;
			    }
					
			    case VIDEOPLAYER_MUTEBUTTON:
                {
                     if (videoPlayer.volumeBar)
			     	     videoPlayer.volumeBar.setFocus();
			     	 break;
			    }
					
			    case VIDEOPLAYER_VOLUMEBAR:
                {
                     if (videoPlayer.volumeBar)
    			    	 videoPlayer.volumeBar.setFocus();
			    	 break;
			    }
					
			    case VIDEOPLAYER_FULLSCREENBUTTON:
                {
                     if (videoPlayer.fullScreenButton)
    			    	 videoPlayer.fullScreenButton.setFocus();
			         break;
			    }
		    } 
	    }
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: AccImpl
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  method for returning the name of the VideoPlayer
	 *  which is spoken out by the screen reader
	 *  The VideoPlayer parent object will return the accessible name set on the 
     *  VideoPlayer or if one does not exist the one set in the resource file
	 *  Child elements will use the accessible name that is set on those child 
     *  components in the VideoPlayerSkin.mxml or associated skin file if they 
     *  exist otherwise the name will be retrieved from the resource file
	 *  
	 *  @param childID uint
	 *
	 *  @return Name String
	 */
	override protected function getName(childID:uint):String
	{
		var videoPlayer:VideoPlayer = VideoPlayer(master);
		
		var resourceManager:IResourceManager = ResourceManager.getInstance();

		var label:String;
        var name1:String = "";
        var name2:String = "";

		switch (childID)
        {
		    case 0: 
            {
                label = videoPlayer.accessibilityName ?
						videoPlayer.accessibilityName : 
                		resourceManager.getString(
							"components", "videoPlayerVideoDisplayAccName");
		    	break;
		    }
				
		    case VIDEOPLAYER_PLAYPAUSEBUTTON:
            {
                if (!videoPlayer.playPauseButton)
                    break;
                    
                label = videoPlayer.playPauseButton.accessibilityProperties ?
						videoPlayer.playPauseButton.accessibilityName :
						"";
                if (!label)
                {
                    label = resourceManager.getString(
						"components", "videoPlayerPlayButtonAccName")
                }
                
                if (label.indexOf(",") >= 0) 
                {
                    name1 = label.split(",",2)[0];
                    name2 = label.split(",",2)[1] 
                }
                else 
                {
                   name1 = name2 = label;
                }

		        label = videoPlayer.playing ? name2 : name1;
                
		    	break;
		    }
		    case VIDEOPLAYER_SCRUBBAR:
            {
                if (!videoPlayer.scrubBar)
                    break;
                    
                label = videoPlayer.scrubBar.accessibilityName ?
						videoPlayer.scrubBar.accessibilityName : 
                		resourceManager.getString(
							"components","videoPlayerScrubBarAccName")
                break;
	        }
				
		    case VIDEOPLAYER_CURRENTTIMEDISPLAY:
            {
                if (!videoPlayer.currentTimeDisplay ||
                    !videoPlayer.durationDisplay)
                    break;
                    
		        label = videoPlayer.currentTimeDisplay.text + "/" +
                		videoPlayer.durationDisplay.text;
		        break;
		    }
				
            case VIDEOPLAYER_MUTEBUTTON:
            {
                if (!videoPlayer.volumeBar || !videoPlayer.volumeBar.muteButton)
                    break;
                    
                label =
					videoPlayer.volumeBar.muteButton.accessibilityProperties ?
					videoPlayer.volumeBar.muteButton.accessibilityName :
					"";
                if (!label)
                {
                    label = resourceManager.getString(
						"components", "videoPlayerMuteButtonAccName")
                }
                
                if (label.indexOf(",") >= 0) 
                {
                    name1 = label.split(",",2)[0];
                    name2 = label.split(",",2)[1] 
                }
                else 
                {
                   name1 = name2 = label;
                }

                label = videoPlayer.volumeBar.muted ? name2 : name1;
                
                break;
            }
				
            case VIDEOPLAYER_VOLUMEBAR:
            {
                if (!videoPlayer.volumeBar)
                    break;
                    
                label = videoPlayer.volumeBar.accessibilityName ?
						videoPlayer.volumeBar.accessibilityName : 
                		resourceManager.getString(
							"components", "videoPlayerVolumeBarAccName")
                break;
            }
				
            case VIDEOPLAYER_FULLSCREENBUTTON:
            {
                if (!videoPlayer.fullScreenButton)
                    break;
                label = videoPlayer.fullScreenButton.accessibilityName ?
						videoPlayer.fullScreenButton.accessibilityName : 
                		resourceManager.getString(
							"components", "videoPlayerFullScreenButtonAccName")
                break;
            }
		}
        
		return label;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     *  Returns a child id based on a sub component that is passed in. 
     */
	private function elementToChildID(obj:Object):Number 
	{
		var index:Number = 0;

		var str:String = String(obj);
		
        if (str.search("playPauseButton") > 0) 
            index = VIDEOPLAYER_PLAYPAUSEBUTTON;
		
        else if (str.search("scrubBar") > 0)
            index = VIDEOPLAYER_SCRUBBAR;
		
        else if (str.search("durationDisplay") > 0) 
            index = VIDEOPLAYER_CURRENTTIMEDISPLAY;
		
        else if (str.search("volumeBar") > 0)
            index = VIDEOPLAYER_VOLUMEBAR;
		
        else if (str.search("fullScreenButton") > 0)
            index = VIDEOPLAYER_FULLSCREENBUTTON;
          
		return index;
		
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden event handlers: AccImpl
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Override the generic event handler.
	 *  All AccImpl must implement this
	 *  to listen for events from its master component. 
	 */
	override protected function eventHandler(event:Event):void
	{
		// Let AccImpl class handle the events
		// that all accessible UIComponents understand.
		$eventHandler(event);
		
		var childID:Number = elementToChildID(event.target);
		
		var playPauseButton:ToggleButtonBase;
		var volumeBar:VolumeBar;
        var scrubBar:ScrubBar;
        var fullScreenButton:ButtonBase;
		
		switch (event.type)
		{
			case MouseEvent.CLICK:
			{
				Accessibility.sendEvent(master, 0,
										AccConst.EVENT_OBJECT_STATECHANGE);
				Accessibility.updateProperties();
				break;
			}
				
			case FocusEvent.FOCUS_IN:
			{
				Accessibility.sendEvent(master, get_accFocus(), 
                						AccConst.EVENT_OBJECT_FOCUS);
				Accessibility.updateProperties();
				break;
			}
				
			case Event.CHANGE:
			{
				var msaaEvt:uint = 0;

				if (childID == VIDEOPLAYER_PLAYPAUSEBUTTON ||
					childID == VIDEOPLAYER_MUTEBUTTON || 
                	childID == VIDEOPLAYER_FULLSCREENBUTTON)
				{
					msaaEvt = AccConst.EVENT_OBJECT_NAMECHANGE;
				}
				else if (childID == VIDEOPLAYER_SCRUBBAR ||
						 childID == VIDEOPLAYER_VOLUMEBAR)
				{
					msaaEvt = AccConst.EVENT_OBJECT_VALUECHANGE;
				}
                if (childID != VIDEOPLAYER_CURRENTTIMEDISPLAY && childID != 0)
                {
				    Accessibility.sendEvent(master, childID, msaaEvt);
				    Accessibility.updateProperties();
				    break;
                }
			}
				
			case FlexEvent.MUTED_CHANGE:
			{
				Accessibility.sendEvent(master, VIDEOPLAYER_MUTEBUTTON, 
                						AccConst.EVENT_OBJECT_NAMECHANGE);
				Accessibility.updateProperties();
				break;
			}
				
            case TimeEvent.CURRENT_TIME_CHANGE:
			{
				Accessibility.sendEvent(master, VIDEOPLAYER_SCRUBBAR, 
                						AccConst.EVENT_OBJECT_VALUECHANGE);
				Accessibility.sendEvent(master, VIDEOPLAYER_CURRENTTIMEDISPLAY, 
                						AccConst.EVENT_OBJECT_NAMECHANGE);
				Accessibility.updateProperties();
				break;
			}
				
			case SkinPartEvent.PART_ADDED:
			{
				playPauseButton = VideoPlayer(master).playPauseButton;
				if (SkinPartEvent(event).instance == playPauseButton)
                {
					playPauseButton.addEventListener(Event.CHANGE, eventHandler);
                    if (VideoPlayer(master).tabIndex > 0 &&
                        playPauseButton.tabIndex == -1)
                        playPauseButton.tabIndex = VideoPlayer(master).tabIndex;

                }
				
				volumeBar = VideoPlayer(master).volumeBar;
				if (SkinPartEvent(event).instance == volumeBar)
				{
					volumeBar.addEventListener(Event.CHANGE, eventHandler);
					volumeBar.addEventListener(FlexEvent.MUTED_CHANGE, eventHandler);
                    if (VideoPlayer(master).tabIndex > 0 &&
                        volumeBar.tabIndex == -1)
                        volumeBar.tabIndex = VideoPlayer(master).tabIndex;
				}

                scrubBar = VideoPlayer(master).scrubBar;
                if (SkinPartEvent(event).instance == scrubBar)
                {
                    if (VideoPlayer(master).tabIndex > 0 &&
                        scrubBar.tabIndex == -1)
                        scrubBar.tabIndex = VideoPlayer(master).tabIndex;
                }

                fullScreenButton = VideoPlayer(master).fullScreenButton;
                if (SkinPartEvent(event).instance == fullScreenButton)
                {
                    if (VideoPlayer(master).tabIndex > 0 &&
                        fullScreenButton.tabIndex == -1)
                        fullScreenButton.tabIndex = VideoPlayer(master).tabIndex;
                }

				break;
			}
				
			case SkinPartEvent.PART_REMOVED:
			{
				playPauseButton = VideoPlayer(master).playPauseButton;
				if (SkinPartEvent(event).instance == playPauseButton)
					playPauseButton.removeEventListener(Event.CHANGE, eventHandler);
				
				volumeBar = VideoPlayer(master).volumeBar;
				if (SkinPartEvent(event).instance == volumeBar)
				{
					volumeBar.removeEventListener(Event.CHANGE, eventHandler);
					volumeBar.removeEventListener(FlexEvent.MUTED_CHANGE, eventHandler);
				}
				
				break;
			}
		}
	}
}

}
