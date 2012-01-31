////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.primitives.supportClasses
{

import flash.display.BlendMode;
import flash.display.Graphics;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.ui.Keyboard;

import flashx.textLayout.container.TextContainerManager;
import flashx.textLayout.edit.EditingMode;
import flashx.textLayout.edit.ISelectionManager;
import flashx.textLayout.edit.SelectionFormat;
import flashx.textLayout.elements.IConfiguration;
import flashx.undo.IUndoManager;
import flashx.undo.UndoManager;

import mx.styles.IStyleClient;
import mx.core.mx_internal;

import spark.primitives.RichEditableText;
import spark.components.TextSelectionVisibility;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 *  A subclass of TextContainerManager that manages the text in
 *  a RichEditableText component.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class RichEditableTextContainerManager extends TextContainerManager
{
    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function RichEditableTextContainerManager(
                        container:RichEditableText, configuration:IConfiguration)
    {
        super(container, configuration);

        textView = container;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var hasScrollRect:Boolean = false;

    /**
     *  @private
     */
    private var textView:RichEditableText;

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
        
    /**
     *  @private
     */
    override public function drawBackgroundAndSetScrollRect(
                                    scrollX:Number, scrollY:Number):Boolean
    {
        var width:Number = compositionWidth;
        var height:Number = compositionHeight;
        
        if (!textView.actuallyAutoSizing && (isNaN(width) || isNaN(height)))
            return false;  // just measuring!
        
        var contentBounds:Rectangle = getContentBounds();
        
        // If autoSize, use the content values rather than the composition
        // values. The composition values allow room for growth 
        // (width=maxWidth, height=NaN).
        if (textView.actuallyAutoSizing)
        {
            width = contentBounds.width;
            height = contentBounds.height;
        }
            
        if (scrollX == 0 &&
            scrollY == 0 &&
            contentBounds.width <= width &&
            contentBounds.height <= height)
        {
            // skip the scrollRect
            if (hasScrollRect)
            {
                container.scrollRect = null;
                hasScrollRect = false;                  
            }
        }
        else
        {
            container.scrollRect = new Rectangle(scrollX, scrollY, width, height);
            hasScrollRect = true;
        }
        
        // Client must draw a background to get mouse events,
        // even it if is 100% transparent.
    	// If backgroundColor is defined, fill the bounds of the component
    	// with backgroundColor drawn with alpha level backgroundAlpha.
    	// Otherwise, fill with transparent black.
    	// (The color in this case is irrelevant.)
    	var color:uint = 0x000000;
    	var alpha:Number = 0.0;
    	var styleableContainer:IStyleClient = container as IStyleClient;
    	if (styleableContainer)
    	{
    		var backgroundColor:* =
    			styleableContainer.getStyle("backgroundColor");
    		if (backgroundColor !== undefined)
    		{
    			color = uint(backgroundColor);
    			alpha = styleableContainer.getStyle("backgroundAlpha");
    		}
    	}
        var g:Graphics = container.graphics;
        g.clear();
        g.lineStyle();
        g.beginFill(color, alpha);
        g.drawRect(scrollX, scrollY, width, height);
        g.endFill();
        
        return hasScrollRect;
    }
        
    /**
     *  @private
     */
    override protected function getUndoManager():IUndoManager
    {
        if (!textView.undoManager)
        {
            textView.undoManager = new UndoManager();
            textView.undoManager.undoAndRedoItemLimit = int.MAX_VALUE;
        }
            
        return textView.undoManager;
    }
    
    /**
     *  @private
     */
    override protected function getFocusedSelectionFormat():SelectionFormat
    {
        var selectionColor:* = textView.getStyle("selectionColor");

        var focusedPointAlpha:Number =
            editingMode == EditingMode.READ_WRITE ?
            1.0 :
            0.0;

        // If editable, the insertion point is black, inverted, which makes it
        // the inverse color of the background, for maximum readability.         
        // If not editable, then no insertion point.        
        return new SelectionFormat(
            selectionColor, 1.0, BlendMode.NORMAL, 
            0x000000, focusedPointAlpha, BlendMode.INVERT);
    }
    
    /**
     *  @private
     */
    override protected function getUnfocusedSelectionFormat():SelectionFormat
    {
        var unfocusedSelectionColor:* = textView.getStyle(
                                            "unfocusedSelectionColor");

        var unfocusedAlpha:Number =
            textView.selectionVisibility != TextSelectionVisibility.WHEN_FOCUSED ?
            1.0 :
            0.0;

        // No insertion point when no focus.
        return new SelectionFormat(
            unfocusedSelectionColor, unfocusedAlpha, BlendMode.NORMAL,
            unfocusedSelectionColor, 0.0);
    }
    
    /**
     *  @private
     */
    override protected function getInactiveSelectionFormat():SelectionFormat
    {
        var inactiveSelectionColor:* = textView.getStyle(
                                            "inactiveSelectionColor"); 

        var inactiveAlpha:Number =
            textView.selectionVisibility == TextSelectionVisibility.ALWAYS ?
            1.0 :
            0.0;

        // No insertion point when not active.
        return new SelectionFormat(
            inactiveSelectionColor, inactiveAlpha, BlendMode.NORMAL,
            inactiveSelectionColor, 0.0);
    }   
    
    /**
     *  @private
     */
    override public function focusInHandler(event:FocusEvent):void
    {
        textView.focusInHandler(event);

        super.focusInHandler(event);
    }    

    /**
     *  @private
     */
    override public function keyDownHandler(event:KeyboardEvent):void
    {
        //trace("TCM: keyDown cancelable ", event.cancelable.toString());

        super.keyDownHandler(event);
        
        // ToDo: remove this when TLF starts doing this.  Note that our
        // SystemManager.keyDownHandler redispatches keyDown events for the 
        // following keyCodes as cancelable events for the player.  In AIR, 
        // all keyboard events are cancelable.
        //
        // We need to tell the scroller, if there is one, to ignore the 
        // navigation keys that TLF processes.
        if (event.cancelable && textView.clipAndEnableScrolling)
        {
            // Copied from TLF SelectionManager.keyDownHandler.
            if (event.charCode == 0)
            {   
                switch(event.keyCode)
                {
                    case Keyboard.LEFT:
                    case Keyboard.UP:
                    case Keyboard.RIGHT:
                    case Keyboard.DOWN:
                    case Keyboard.HOME:
                    case Keyboard.END:
                    case Keyboard.PAGE_DOWN:
                    case Keyboard.PAGE_UP:
                        event.preventDefault();
                        break;
                }
            }                        
        }        
    }    
    
//    override public function textInputHandler(event:TextEvent):void
//    {
//        trace("textInputHandler", event);
//        super.textInputHandler(event);
//    }
}

}