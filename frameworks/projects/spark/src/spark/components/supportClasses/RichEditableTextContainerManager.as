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

package spark.components.supportClasses
{

import flash.display.BlendMode;
import flash.display.Graphics;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.ui.Keyboard;

import flashx.textLayout.container.ContainerController;
import flashx.textLayout.container.TextContainerManager;
import flashx.textLayout.edit.EditingMode;
import flashx.textLayout.edit.ElementRange;
import flashx.textLayout.edit.IEditManager;
import flashx.textLayout.edit.ISelectionManager;
import flashx.textLayout.edit.SelectionFormat;
import flashx.textLayout.edit.SelectionManager;
import flashx.textLayout.edit.SelectionState;
import flashx.textLayout.elements.FlowLeafElement;
import flashx.textLayout.elements.IConfiguration;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.SelectionEvent;
import flashx.textLayout.formats.Category;
import flashx.textLayout.formats.ITextLayoutFormat;
import flashx.textLayout.formats.TextLayoutFormat;
import flashx.textLayout.operations.ApplyFormatOperation;
import flashx.textLayout.operations.InsertTextOperation;
import flashx.textLayout.property.Property;
import flashx.textLayout.tlf_internal;
import flashx.undo.IUndoManager;
import flashx.undo.UndoManager;

import mx.core.mx_internal;
import mx.events.SandboxMouseEvent;
import mx.styles.IStyleClient;

import spark.components.RichEditableText;
import spark.components.TextSelectionHighlighting;

use namespace mx_internal;
use namespace tlf_internal;

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
        // If not auto-sizing these are the same as the compositionWidth/Height.
        // If auto-sizing, the compositionWidth/Height may be NaN.  If no
        // constraints this will reflect the actual size of the text.
        var width:Number = textDisplay.width;
        var height:Number = textDisplay.height;
        
        // (FIXME) cframpto: is this still really needed?
        if (!textDisplay.autoSize && (isNaN(width) || isNaN(height)))
            return false;  // just measuring!
        
        var contentBounds:Rectangle = getContentBounds();
        
        // If autoSize, and lineBreak="toFit there should never be 
        // a scroll rect but if lineBreak="explicit" the text may need
        // to be clipped.
        if (scrollX == 0 && scrollY == 0 &&
            contentBounds.right <= width &&
            contentBounds.bottom <= height)
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
        // TODO (cframpto):  Adjust for RL text.  See 
        // ContainerController.attachTransparentBackgroundForHit().
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
    
    /**
     *  @private
     */
    override protected function createEditManager(
                        undoManager:flashx.undo.IUndoManager):IEditManager
    {
        return new RichEditableTextEditManager(textDisplay, undoManager);
    }

    /**
     *  @private
     */
    override public function setText(text:String):void
    {
        super.setText(text);
        
        // If we have focus, need to make sure we can still input text.
        initForInputIfHaveFocus();
    }

    /**
     *  @private
     */
    override public function setTextFlow(textFlow:TextFlow):void
    {
        super.setTextFlow(textFlow);
        
        // If we have focus, need to make sure we can still input text.
        initForInputIfHaveFocus();
    }

    /**
     *  @private
     */
    private function initForInputIfHaveFocus():void
    {
        // If we have focus, need to make sure there is a composer in place,
        // the new controller knows it has focus, and there is an insertion
        // point so input works without a mouse over or mouse click.  Normally 
        // this is done in our focusIn handler by making sure there is a 
        // selection.  Test this by clicking an arrow in the NumericStepper 
        // and then entering a number without clicking on the input field first. 
        if (editingMode != EditingMode.READ_ONLY &&
            textDisplay.getFocus() == textDisplay)
        {
            // this will ensure a text flow with a comopser
            var im:ISelectionManager = beginInteraction();
            
            var controller:ContainerController = 
                getTextFlow().flowComposer.getControllerAt(0);
            
            controller.requiredFocusInHandler(null);
            
            im.selectRange(0, 0);
            
            endInteraction();
        }
    }
    
    /**
     *  @private
     *  To apply a format to a selection in a textFlow without using the
     *  selection manager.
     */
    mx_internal function applyFormatOperation(
                            leafFormat:ITextLayoutFormat, 
                            paragraphFormat:ITextLayoutFormat, 
                            containerFormat:ITextLayoutFormat,
                            anchorPosition:int, 
                            activePosition:int):Boolean
    {
        // Nothing to do.
        if (anchorPosition == -1 || activePosition == -1)
            return true;
        
        var textFlow:TextFlow = getTextFlowWithComposer();
        
        var operationState:SelectionState =
            new SelectionState(textFlow, anchorPosition, activePosition); 
        
        var op:ApplyFormatOperation = 
            new ApplyFormatOperation(
                operationState, leafFormat, paragraphFormat, containerFormat);
        
        //ToDo: remove generations if not needed
        
        //var beforeGeneration:uint = textFlow.generation;
        //op.setGenerations(beforeGeneration, 0);
        
        var success:Boolean = op.doOperation();
        if (success)
        {
            textFlow.normalize(); 
            
            // This has to be done after the normalize, because normalize 
            // increments the generation number.
            //op.setGenerations(beforeGeneration, textFlow.generation);					
            
            textFlow.flowComposer.updateAllControllers(); 
        } 
        
        return success;
    }

    /**
     *  @private
     *  To get the format of a character without using a SelectionManager.
     *  The method should be kept in sync with the version in the 
     *  SelectionManager.
     */
    mx_internal function getCommonCharacterFormat(
                                        anchorPosition:int, 
                                        activePosition:int):ITextLayoutFormat
    {
        if (anchorPosition == -1 || activePosition == -1)
            return null;
        
        var textFlow:TextFlow = getTextFlowWithComposer();
        
        var absoluteStart:int = getAbsoluteStart(anchorPosition, activePosition);
        var absoluteEnd:int = getAbsoluteEnd(anchorPosition, activePosition);
        
        var selRange:ElementRange = 
            ElementRange.createElementRange(textFlow, absoluteStart, absoluteEnd); 
        
        var leaf:FlowLeafElement = selRange.firstLeaf;
        var attr:TextLayoutFormat = new TextLayoutFormat(leaf.computedFormat);
        
        // If there is a insertion point, see if there is an interaction
        // manager with a pending point format.
        if (anchorPosition != -1 && anchorPosition == activePosition)
        {
            if (textFlow.interactionManager)
            {
                var selectionState:SelectionState = 
                    textFlow.interactionManager.getSelectionState();                
                if (selectionState.pointFormat)
                    attr.apply(selectionState.pointFormat);
            }
        }
        else
        {
            for (;;)
            {
                if (leaf == selRange.lastLeaf)
                    break;
                leaf = leaf.getNextLeaf();
                attr.removeClashing(leaf.computedFormat);
            }
        }
        
        return Property.extractInCategory(
                    TextLayoutFormat, 
                    TextLayoutFormat.description, 
                    attr, Category.CHARACTER) as ITextLayoutFormat;
    }
    
    /**
     *  @private
     *  To get the format of the container without using a SelectionManager.
     *  The method should be kept in sync with the version in the 
     *  SelectionManager.
     */
    mx_internal function getCommonContainerFormat():ITextLayoutFormat
    {
        var textFlow:TextFlow = getTextFlowWithComposer();
        
        var controller:ContainerController = 
            textFlow.flowComposer.getControllerAt(0);
            
        return Property.extractInCategory(
                    TextLayoutFormat, TextLayoutFormat.description, 
                    controller.computedFormat,
                    Category.CONTAINER) as ITextLayoutFormat;
    }
    
    /**
     *  @private
     *  To get the format of a paragraph without using a SelectionManager.
     *  The method should be kept in sync with the version in the 
     *  SelectionManager.
     */
    mx_internal function getCommonParagraphFormat(
                                        anchorPosition:int, 
                                        activePosition:int):ITextLayoutFormat
    {
        if (anchorPosition == -1 || activePosition == -1)
            return null;
                
        var textFlow:TextFlow = getTextFlowWithComposer();

        var absoluteStart:int = getAbsoluteStart(anchorPosition, activePosition);
        var absoluteEnd:int = getAbsoluteEnd(anchorPosition, activePosition);

        var selRange:ElementRange = 
            ElementRange.createElementRange(textFlow, absoluteStart, absoluteEnd); 
        
        var para:ParagraphElement = selRange.firstParagraph;
        var attr:TextLayoutFormat = new TextLayoutFormat(para.computedFormat);
        for (;;)
        {
            if (para == selRange.lastParagraph)
                break;
            
            para = textFlow.findAbsoluteParagraph(
                            para.getAbsoluteStart() + para.textLength);
            attr.removeClashing(para.computedFormat);
        }
        
        return Property.extractInCategory(TextLayoutFormat,
                    TextLayoutFormat.description,
                    attr, Category.PARAGRAPH) as ITextLayoutFormat;
    }
    
    /**
     *  @private
     *  Insert or append text to the textFlow without using an EditManager.
     *  If there is a SelectionManager or EditManager its selection will be
     *  updated at the end of the operation to keep it in sync.
     */
    mx_internal function insertTextOperation(insertText:String, 
                                             anchorPosition:int, 
                                             activePosition:int):Boolean
    {
        // No insertion point.
        if (anchorPosition == -1 || activePosition == -1)
            return false;
        
        var textFlow:TextFlow = getTextFlowWithComposer();
        
        var absoluteStart:int = getAbsoluteStart(anchorPosition, activePosition);
        var absoluteEnd:int = getAbsoluteEnd(anchorPosition, activePosition);
        
        var operationState:SelectionState = 
            new SelectionState(textFlow, absoluteStart, absoluteEnd);
        
        var op:InsertTextOperation = 
            new InsertTextOperation(operationState, insertText);
        
        // Generations don't seem to be used in this code path since we
        // aren't doing composite, merge or undo operations so they were
        // optimized out.
        
        var success:Boolean = op.doOperation();
        if (success)
        {
            textFlow.normalize(); 
            
            textFlow.flowComposer.updateAllControllers(); 

            var insertPt:int = absoluteEnd - (absoluteEnd - absoluteStart) +
                                    + insertText.length;            
            
            // No point format.
            var selectionState:SelectionState =
                new SelectionState(textFlow, insertPt, insertPt);
            
            // If there is a selection manager, keep the selection in
            // sync and clear the point format as the EditManager insertText
            // operation does.
            if (textFlow.interactionManager)
            {
                var selectionManager:SelectionManager = 
                    SelectionManager(textFlow.interactionManager);
                
                selectionManager.setSelectionState(selectionState);
            }
            
            var selectionEvent:SelectionEvent = 
                new SelectionEvent(SelectionEvent.SELECTION_CHANGE, 
                                   false, false, selectionState);

            textFlow.dispatchEvent(selectionEvent);
            
            scrollToRange(insertPt, insertPt);            
        } 

        return success;
    }

    mx_internal function getTextFlowWithComposer():TextFlow
    {
        var textFlow:TextFlow = getTextFlow();
        
        // Make sure there is a text flow with a flow composer.  There will
        // not be an interaction manager if editingMode is read-only.  If
        // there is an interaction manager flush any pending inserts into the
        // text flow.
        if (composeState != TextContainerManager.COMPOSE_COMPOSER)
            convertToTextFlowWithComposer();
        else if (textFlow.interactionManager)
            textFlow.interactionManager.flushPendingOperations();
        
        return textFlow;
    }
        
    /**
     *  @private
     */
    private function getAbsoluteStart(anchorPosition:int, activePosition:int):int
    {
        return (anchorPosition < activePosition) ? 
                    anchorPosition : activePosition;
    }
    
    /**
     *  @private
     */
    private function getAbsoluteEnd(anchorPosition:int, activePosition:int):int
    {
        return (anchorPosition > activePosition) ? 
                    anchorPosition : activePosition;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers
    //
    //--------------------------------------------------------------------------
        
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
    
    /**
     *  @private
     */
    override public function mouseDownHandler(event:MouseEvent):void
    {
        textDisplay.mouseDownHandler(event);
        
        super.mouseDownHandler(event);
    }
        
    /**
     *  @private
     *  This handler gets called for ACTIVATE events from the player
     *  and FLEX_WINDOW_ACTIVATE events from Flex.  Because of the
     *  way AIR handles activation of AIR Windows, and because Flex
     *  has its own concept of popups or pseudo-windows, we
     *  ignore ACTIVATE and respond to FLEX_WINDOW_ACTIVATE instead
     */
    override public function activateHandler(event:Event):void
    {
        // block ACTIVATE events
        if (event.type == Event.ACTIVATE)
            return;

        super.activateHandler(event);
    }

    /**
     *  @private
     *  This handler gets called for DEACTIVATE events from the player
     *  and FLEX_WINDOW_DEACTIVATE events from Flex.  Because of the
     *  way AIR handles activation of AIR Windows, and because Flex
     *  has its own concept of popups or pseudo-windows, we
     *  ignore DEACTIVATE and respond to FLEX_WINDOW_DEACTIVATE instead
     */
    override public function deactivateHandler(event:Event):void
    {
        // block DEACTIVATE events
        if (event.type == Event.DEACTIVATE)
            return;

        super.deactivateHandler(event);
    }

    /**
     *  @private
     *  sandbox support
     */
    override public function beginMouseCapture():void
    {
        super.beginMouseCapture();
        textDisplay.systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpSomewhereHandler);
        textDisplay.systemManager.getSandboxRoot().addEventListener(SandboxMouseEvent.MOUSE_MOVE_SOMEWHERE, mouseMoveSomewhereHandler);
    }

    /**
     *  @private
     *  sandbox support
     */
    override public function endMouseCapture():void
    {
        super.endMouseCapture();
        textDisplay.systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpSomewhereHandler);
        textDisplay.systemManager.getSandboxRoot().removeEventListener(SandboxMouseEvent.MOUSE_MOVE_SOMEWHERE, mouseMoveSomewhereHandler);
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    private function mouseUpSomewhereHandler(event:Event):void
    {
        mouseUpSomewhere(event);
    }

    private function mouseMoveSomewhereHandler(event:Event):void
    {
        mouseMoveSomewhere(event);
    }
}

}
