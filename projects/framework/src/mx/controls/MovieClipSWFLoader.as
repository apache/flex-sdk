////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.controls
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;

import mx.core.MovieClipLoaderAsset;
import mx.managers.ISystemManager;

/**
 *  The MovieClipSWFLoader control extends SWFLoader to provide convenience
 *  methods for manipulating a SWF which has a MovieClip as its root content,
 *  provided that the MovieClip is not a Flex application.
 * 
 *  Note that for all other SWF content types, this class will return null
 *  for the movieClip getter and will result in a no-op for function calls.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class MovieClipSWFLoader extends SWFLoader
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */        
    public function MovieClipSWFLoader()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  When the content of the SWF is a MovieClip, if autoStop is true then
     *  the MovieClip is stopped immediately after loading.
     * 
     *  @default true
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */        
    public var autoStop:Boolean = true;
    
    
    /**
     *  Handle to the underlying MovieClip of the loaded SWF. If the SWF is not
     *  rooted in a MovieClip, this property will be null.
     * 
     *  @return MovieClip if the content is of type MovieClip; otherwise,
     *          return null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */        
    public function get movieClip():MovieClip
    {
        var content:DisplayObject = this.content;
        
        if (content is MovieClipLoaderAsset)
        {
            // Obtain child MovieClip 
            if (DisplayObjectContainer(content).numChildren > 0)
                content = 
                    Loader(DisplayObjectContainer(content).getChildAt(0)).content;
        }
        
        if (content is MovieClip && !(content is ISystemManager))
            return MovieClip(content);
        
        return null;
    }
    
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Begins playing the SWF content. If the content is not a MovieClip,
     *  this results in a no-op. 
     * 
     *  @see flash.display.MovieClip#play
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function play():void
    {
        var movieClip:MovieClip = this.movieClip;
        if (movieClip)
            movieClip.play();
    }
    
    /**
     *  Stops the SWF content. If the content is not a MovieClip,
     *  this results in a no-op.
     * 
     *  @see flash.display.MovieClip#stop
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */        
    public function stop():void
    {
        var movieClip:MovieClip = this.movieClip;
        if (movieClip)
            movieClip.stop(); // stop at current frame
    }
    
    /**
     *  Starts playing the SWF file at the specified frame. If the
     *  content is not a MovieClip, this results in a no-op.
     * 
     *  @see flash.display.MovieClip#gotoAndPlay
     * 
     *  @param frame A number representing the frame number, 
     *  or a string representing the label of the frame, 
     *  to which the playhead is sent. 
     *  If you specify a number, it is relative to the scene you specify. 
     *  If you do not specify a scene, the current scene determines the 
     *  global frame number to play. 
     *  If you do specify a scene, the playhead jumps to the frame number in the specified scene. 
     *
     *  @param scene The name of the scene to play.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */        
    
    public function gotoAndPlay(frame:Object, scene:String = null):void
    {
        var movieClip:MovieClip = this.movieClip;
        if (movieClip)
            movieClip.gotoAndPlay(frame, scene);
    }
    
    /**
     *  Resets the playhead to the first frame of the first scene and stops the MovieClip.
     *  If the content is not a MovieClip, this results in a no-op.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */        
    public function gotoFirstFrameAndStop():void
    {
        var movieClip:MovieClip = this.movieClip;
        if (movieClip)
        {
            var scenes:Array = movieClip.scenes;
            var sceneHasName:Boolean = (scenes &&
                                        scenes.length > 0 &&
                                        scenes[0].name != "");

            var scene:String = (sceneHasName ? scenes[0].name : null);
            
            movieClip.gotoAndStop(0, scene); // go to first frame and stop
        }
    }
    
    /**
     *  Stops playing the SWF and resets the playhead to the specified frame.
     *  If the content is not a MovieClip, this results in a no-op.
     * 
     *  @see flash.display.MovieClip#gotoAndStop
     *
     *  @param frame A number representing the frame number, 
     *  or a string representing the label of the frame, 
     *  to which the playhead is sent. 
     *  If you specify a number, it is relative to the scene you specify. 
     *  If you do not specify a scene, the current scene determines the 
     *  global frame number to play. 
     *  If you do specify a scene, the playhead jumps to the frame number in the specified scene. 
     *
     *  @param scene The name of the scene to play.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */        
    public function gotoAndStop(frame:Object, scene:String = null):void
    {
        var movieClip:MovieClip = this.movieClip;
        if (movieClip)
            movieClip.gotoAndStop(frame, scene);
    }
    
    /**
     *  Go to the next frame. No-op if content is not a MovieClip.
     * 
     *  @see flash.display.MovieClip#nextFrame 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */        
    public function nextFrame():void
    {
        var movieClip:MovieClip = this.movieClip;
        if (movieClip)
            movieClip.nextFrame();
    }
    
    /**
     *  Go to the next scene. No-op if content is not a MovieClip.
     * 
     *  @see flash.display.MovieClip#nextScene 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */        
    public function nextScene():void
    {
        var movieClip:MovieClip = this.movieClip;
        if (movieClip)
            movieClip.nextScene();
    }
    
    /**
     *  Go to the previous frame. No-op if content is not a MovieClip.
     * 
     *  @see flash.display.MovieClip#prevFrame 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */        
    public function prevFrame():void
    {
        var movieClip:MovieClip = this.movieClip;
        if (movieClip)
            movieClip.prevFrame();
    }
    
    /**
     *  Go to the previous scene. No-op if content is not a MovieClip.
     * 
     *  @see flash.display.MovieClip#prevScene 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */        
    public function prevScene():void
    {
        var movieClip:MovieClip = this.movieClip;
        if (movieClip)
            movieClip.prevScene();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     *  On completion of SWF loading, explicitly stop the SWF
     *  (i.e. prevent auto-play) if autoStop is true.
     */            
    override protected function contentLoaded():void
    {
        super.contentLoaded();
        if (autoStop)
            stop();
        
        // Special case for embeds where our embed class loader
        // may not be complete just yet.
        if (content is MovieClipLoaderAsset)
        {
            if (DisplayObjectContainer(content).numChildren > 0)
            {
                var childContent:DisplayObject = DisplayObjectContainer(content).getChildAt(0);
                if (childContent is Loader && Loader(childContent).content == null)
                    content.addEventListener(Event.ADDED, content_addedHandler, false, 0, true);
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Helper method used to auto-stop embedded SWF content that may not
     *  have been fully loaded at the time contentLoaded() was invoked.
     */
    private function content_addedHandler(event:Event):void
    {
        if (autoStop)
            stop();
        
        content.removeEventListener(Event.ADDED, content_addedHandler);
    }
}
}