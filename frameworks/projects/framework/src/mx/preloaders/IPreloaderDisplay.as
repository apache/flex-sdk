////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.preloaders
{

import flash.display.Sprite;
import flash.events.IEventDispatcher;

/**
 *  Defines the interface that 
 *  a class must implement to be used as a download progress bar.
 *  The IPreloaderDisplay receives events from the Preloader class
 *  and is responsible for visualizing that information to the user.
 *
 *  @see mx.preloaders.DownloadProgressBar
 *  @see mx.preloaders.Preloader
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IPreloaderDisplay extends IEventDispatcher
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  backgroundAlpha
    //----------------------------------

    /**
     *  @copy mx.preloaders.DownloadProgressBar#backgroundAlpha
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get backgroundAlpha():Number;
    
    /**
     *  @private
     */
    function set backgroundAlpha(value:Number):void;
    
    //----------------------------------
    //  backgroundColor
    //----------------------------------

    /**
     *  @copy mx.preloaders.DownloadProgressBar#backgroundColor
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    function get backgroundColor():uint;
    
    /**
     *  @private
     */
    function set backgroundColor(value:uint):void;
    
    //----------------------------------
    //  backgroundImage
    //----------------------------------

    /**
     *  @copy mx.preloaders.DownloadProgressBar#backgroundImage
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get backgroundImage():Object;
    
    /**
     *  @private
     */
    function set backgroundImage(value:Object):void;

    //----------------------------------
    //  backgroundSize
    //----------------------------------

    /**
     *  @copy mx.preloaders.DownloadProgressBar#backgroundSize
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get backgroundSize():String;
    
    /**
     *  @private
     */
    function set backgroundSize(value:String):void;

    //----------------------------------
    //  preloader
    //----------------------------------

    /**
     *  @copy mx.preloaders.DownloadProgressBar#preloader
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function set preloader(obj:Sprite):void;
    
    //----------------------------------
    //  stageHeight
    //----------------------------------

    /**
     *  @copy mx.preloaders.DownloadProgressBar#stageHeight
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get stageHeight():Number;
    
    /**
     *  @private
     */
    function set stageHeight(value:Number):void;
    
    //----------------------------------
    //  stageWidth
    //----------------------------------

    /**
     *  @copy mx.preloaders.DownloadProgressBar#stageWidth
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get stageWidth():Number;
    
    /**
     *  @private
     */
    function set stageWidth(value:Number):void;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @copy mx.preloaders.DownloadProgressBar#initialize()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function initialize():void;
}

}
