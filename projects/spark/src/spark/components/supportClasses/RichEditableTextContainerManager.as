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
import spark.components.TextSelectionHighlighting;

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

        textDisplay = container;
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
    private var textDisplay:RichEditableText;

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
        
        if (!textDisplay.autoSize && (isNaN(width) || isNaN(height)))
            return false;  // just measuring!
        
        var contentBounds:Rectangle = getContentBounds();
        
        // If autoSize, use the content values rather than the composition
        // values. The composition values allow room for growth 
        // (width=maxWidth, height=NaN).
        if (textDisplay.autoSize)
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
        if (!textDisplay.undoManager)
        {
            textDisplay.undoManager = new UndoManager();
            textDisplay.undoManager.undoAndRedoItemLimit = int.MAX_VALUE;
        }
            
        return textDisplay.undoManager;
    }
    
    /**
     *  @private
     */
    override protected function getFocusedSelectionFormat():SelectionFormat
    {
        var selectionColor:* = textDisplay.getStyle("focusedTextSelectionColor");

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
        var unfocusedSelectionColor:* = textDisplay.getStyle(
                                            "unfocusedTextSelectionColor");

        var unfocusedAlpha:Number =
            textDisplay.selectionHighlighting != 
            TextSelectionHighlighting.WHEN_FOCUSED ?
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
        var inactiveSelectionColor:* = textDisplay.getStyle(
                                            "inactiveTextSelectionColor"); 

        var inactiveAlpha:Number =
            textDisplay.selectionHighlighting == 
            TextSelectionHighlighting.ALWAYS ?
            1.0 :
            0.0;

        // No insertion point when not active.
        return new SelectionFormat(
            inactiveSelectionColor, inactiveAlpha, BlendMode.NORMAL,
            inactiveSelectionColor, 0.0);
    }   
    
    override public function setText(text:String):void
    {
        textDisplay.ignoreDamageEvent = true;
        
        super.setText(text);
        
        textDisplay.ignoreDamageEvent = false;
    }
    
    /**
     *  @private
     */
    override public function focusInHandler(event:FocusEvent):void
    {
        textDisplay.focusInHandler(event);

        super.focusInHandler(event);
    }    

    /**
     *  @private
     */
    override public function focusOutHandler(event:FocusEvent):void
    {
        textDisplay.focusOutHandler(event);

        super.focusOutHandler(event);
    }    

    /**
     *  @private
     */
    override public function keyDownHandler(event:KeyboardEvent):void
    {
        textDisplay.keyDownHandler(event);

        if (!event.isDefaultPrevented())
            super.keyDownHandler(event);
    }    

    /**
     *  @private
     */
    override public function keyUpHandler(event:KeyboardEvent):void
    {
        if (!event.isDefaultPrevented())
            super.keyUpHandler(event);
    }    

}

}