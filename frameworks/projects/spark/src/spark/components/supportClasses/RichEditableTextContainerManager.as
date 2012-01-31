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
import flash.geom.Rectangle;

import flashx.textLayout.container.TextContainerManager;
import flashx.textLayout.edit.ISelectionManager;
import flashx.textLayout.edit.SelectionFormat;
import flashx.textLayout.elements.IConfiguration;
import flashx.undo.IUndoManager;
import flashx.undo.UndoManager;

import mx.core.mx_internal;

import spark.primitives.RichEditableText;
import spark.components.TextSelectionVisibility;

/**
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
    //private var hasScrollRect:Boolean = false;

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
        
        if (isNaN(width) || isNaN(height))
            return false;  // just measuring!
        
        var contentBounds:Rectangle = getContentBounds();
        
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
        
        // Client must draw a background, even it if is 100% transparent.
        var g:Graphics = container.graphics;
        g.clear();
        g.lineStyle();
        var bc:Object = RichEditableText.mx_internal::backgroundColor;
        if (bc != null)
            g.beginFill(uint(bc)); 
        else
            g.beginFill(0x000000, 0);
        g.drawRect(scrollX, scrollY, width, height);
        g.endFill();
        
        return hasScrollRect;
    }
        
    /**
     *  @private
     */
    override protected function getUndoManager():IUndoManager
    {
        if (!textView.mx_internal::undoManager)
        {
            textView.mx_internal::undoManager = new UndoManager();
            textView.mx_internal::undoManager.undoAndRedoItemLimit = int.MAX_VALUE;
        }
            
        return textView.mx_internal::undoManager;
    }
    
    /**
     *  @private
     */
    override protected function getFocusedSelectionFormat():SelectionFormat
    {
        var selectionColor:* = textView.getStyle("selectionColor");

        // The insertion point is black, inverted, which makes it
        // the inverse color of the background, for maximum readability.         
        return new SelectionFormat(
            selectionColor, 1.0, BlendMode.NORMAL, 
            0x000000, 1.0, BlendMode.INVERT);
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
     *  ToDo: there is currently an issue with event handlers.  As soon as
     *  there is a controller attached all the event handling is done by the
     *  controller and this no longer gets called.
     */
    override public function focusInHandler(event:FocusEvent):void
    {
        textView.mx_internal::focusInHandler(event);

        super.focusInHandler(event);
    }    

}

}