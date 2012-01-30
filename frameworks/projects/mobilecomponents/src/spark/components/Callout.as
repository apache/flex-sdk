////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{
import flash.display.DisplayObject;
import flash.display.Stage;
import flash.display.StageDisplayState;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.ILayoutElement;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.LayoutDirection;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.ResizeEvent;
import mx.utils.MatrixUtil;
import mx.utils.PopUpUtil;

import spark.layouts.VerticalAlign;

use namespace mx_internal;

/**
 *  TODO (jasonsj): write class description
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */
public class Callout extends SkinnablePopUpContainer
{
    
    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    private static var decomposition:Vector.<Number> = new <Number>[0,0,0,0,0];
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor. 
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public function Callout()
    {
        super();
        
        addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        
        // TODO (jasonsj): listen for resize on owner?
    }
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts 
    //
    //--------------------------------------------------------------------------
    
    [Bindable]
    [SkinPart(required="false")]
    
    /**
     *  An optional skin part that visually connects the owner to the
     *  contentGroup.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public var arrow:ILayoutElement;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  horizontalPosition
    //----------------------------------
    
    private var _autoHorizontalPosition:String;
    
    private var _horizontalPosition:String = CalloutPosition.AUTO;
    
    [Inspectable(category="General", enumeration="before,start,middle,end,after,auto", defaultValue="auto")]
    
    /**
     *  Horizontal position of the callout relative to the owner.
     * 
     *  <p>Possible values are <code>"before"</code>, <code>"start"</code>,
     *  <code>"middle"</code>, <code>"end"</code>, <code>"after"</code>,
     *  and <code>"auto"</code> (default).</p>
     *
     *  @default CalloutPosition.AUTO
     *  @see spark.components.CalloutPosition
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public function get horizontalPosition():String
    {
        return _horizontalPosition;
    }
    
    /**
     *  @private
     */
    public function set horizontalPosition(value:String):void
    {
        if (value == _horizontalPosition)
            return;
        
        _horizontalPosition = value;
        
        invalidateArrowState = true;
        invalidateProperties();
    }
    
    mx_internal function get internalHorizontalPosition():String
    {
        if (_autoHorizontalPosition)
            return _autoHorizontalPosition;
        
        return horizontalPosition;
    }
    
    //----------------------------------
    //  verticalPosition
    //----------------------------------
    
    private var _autoVerticalPosition:String;
    
    private var _verticalPosition:String = CalloutPosition.AUTO;
    
    [Inspectable(category="General", enumeration="before,start,middle,end,after,auto", defaultValue="auto")]
    
    /**
     *  Vertical position of the callout relative to the owner.
     * 
     *  <p>Possible values are <code>"before"</code>, <code>"start"</code>,
     *  <code>"middle"</code>, <code>"end"</code>, <code>"after"</code>,
     *  and <code>"auto"</code> (default).</p>
     *
     *  @default CalloutPosition.AUTO
     *  @see spark.components.CalloutPosition
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public function get verticalPosition():String
    {
        return _verticalPosition;
    }
    
    /**
     *  @private
     */
    public function set verticalPosition(value:String):void
    {
        if (value == _verticalPosition)
            return;
        
        _verticalPosition = value;
        
        invalidateArrowState = true;
        invalidateProperties();
    }
    
    mx_internal function get internalVerticalPosition():String
    {
        if (_autoVerticalPosition)
            return _autoVerticalPosition;
        
        return verticalPosition;
    }
    
    //----------------------------------
    //  arrowDirection
    //----------------------------------
    
    private var invalidateArrowState:Boolean = true;
    
    private var _arrowDirection:String = ArrowDirection.NONE;
    
    /**
     *  A read-only property that indicates the direction from the callout
     *  towards the owner.
     * 
     *  <p>This value is computed based on the callout position given by 
     *  <code>horizontalPosition</code> and <code>verticalPosition</code>.
     *  Exterior and interior positions will point from the callout towards
     *  the edge of the owner. Corner and absolute center positions are not
     *  supported and will return a value of <code>"none".</code></p>
     *
     *  @see spark.components.ArrowDirection
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public function get arrowDirection():String
    {
        return _arrowDirection;
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
        
        if (arrow && invalidateArrowState)
        {
            commitAutoPosition();
            
            // determine arrow direction, outer positions get priority
            // corner positions and center show no arrow
            var direction:String = ArrowDirection.NONE;
            
            if (internalHorizontalPosition == CalloutPosition.BEFORE)
            {
                if ((internalVerticalPosition != CalloutPosition.BEFORE)
                    &&  (internalVerticalPosition != CalloutPosition.AFTER))
                {
                    direction = ArrowDirection.RIGHT;
                }
            }
            else if (internalHorizontalPosition == CalloutPosition.AFTER)
            {
                if ((internalVerticalPosition != CalloutPosition.BEFORE)
                    && (internalVerticalPosition != CalloutPosition.AFTER))
                {
                    direction = ArrowDirection.LEFT;
                }
            }
            else if (internalVerticalPosition == CalloutPosition.BEFORE)
            {
                direction = ArrowDirection.DOWN;
            }
            else if (internalVerticalPosition == CalloutPosition.AFTER)
            {
                direction = ArrowDirection.UP;
            }
            else if (internalHorizontalPosition == CalloutPosition.START)
            {
                direction = ArrowDirection.LEFT;
            }
            else if (internalHorizontalPosition == CalloutPosition.END)
            {
                direction = ArrowDirection.RIGHT;
            }
            else if (internalVerticalPosition == CalloutPosition.START)
            {
                direction = ArrowDirection.UP;
            }
            else if (internalVerticalPosition == CalloutPosition.END)
            {
                direction = ArrowDirection.DOWN;
            }
            
            // invalidate only when the arrow direction changes
            if (_arrowDirection != direction)
            {
                _arrowDirection = direction;
                
                var arrowDisplayObject:DisplayObject = (arrow as DisplayObject);
                
                if (arrowDisplayObject)
                    arrowDisplayObject.visible = (arrowDirection != ArrowDirection.NONE);
                
                skin.invalidateProperties();
            }
            
            // Always reposition when horizontalPosition or verticalPosition
            // changes. This will reposition the callout.
            invalidateDisplayList();
            
            invalidateArrowState = false;
        }
    }
    
    /**
     * @private
     */
    override protected function positionPopUp():void
    {
        var popUpPoint:Point = calculatePopUpPosition();
        PopUpUtil.applyPopUpTransform(owner, systemManager, this, popUpPoint);
    }
    
    /**
     *  @private
     *  
     *  Cooperative layout
     *  @see spark.components.supportClasses.TrackBase#partAdded
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == arrow)
        {
            arrow.addEventListener(ResizeEvent.RESIZE, arrow_resizeHandler);
            arrow.addEventListener(FlexEvent.UPDATE_COMPLETE, arrow_updateCompleteHandler);
        }
    }
    
    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);
        
        if (instance == arrow)
        {
            arrow.removeEventListener(ResizeEvent.RESIZE, arrow_resizeHandler);            
            arrow.removeEventListener(FlexEvent.UPDATE_COMPLETE, arrow_updateCompleteHandler);            
        }
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(w:Number, h:Number):void
    {
        super.updateDisplayList(w, h);
        
        updateSkinDisplayList();
        positionPopUp();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Sets the bounds of arrow, whose geometry isn't fully
     *  specified by the skin's layout.
     * 
     *  <p>Subclasses may override this method to update the arrow's size,
     *  position, and visibility, based on the computed
     *  <code>arrowDirection</code></p>
     * 
     *  <p>By default, this method aligns the arrow on the shorter of either
     *  the <code>arrow</code> bounds or the <code>owner</code> bounds.</p> 
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected function updateSkinDisplayList():void
    {
        var anchor:IVisualElement = owner as IVisualElement;
        
        if (!arrow || !owner || (arrowDirection == ArrowDirection.NONE))
            return;
        
        var isVertical:Boolean = (arrowDirection == ArrowDirection.UP)
            || (arrowDirection == ArrowDirection.DOWN);
        
        var isStartPosition:Boolean = false;
        var isMiddlePosition:Boolean = false;
        var isEndPosition:Boolean = false;
        
        var position:String = (isVertical) ? internalHorizontalPosition : internalVerticalPosition;
        
        isStartPosition = (position == CalloutPosition.START);
        isMiddlePosition = (position == CalloutPosition.MIDDLE);
        isEndPosition = (position == CalloutPosition.END);
        
        var isEndOfCallout:Boolean = (arrowDirection == ArrowDirection.DOWN)
            || (arrowDirection == ArrowDirection.RIGHT);
        
        // arrow X/Y in pop-up coordinates
        var arrowX:Number = 0;
        var arrowY:Number = 0;
        
        var calloutWidth:Number = getLayoutBoundsWidth();;
        var calloutHeight:Number = getLayoutBoundsHeight();;
        var arrowWidth:Number = arrow.getLayoutBoundsWidth();
        var arrowHeight:Number = arrow.getLayoutBoundsHeight();
        
        if (isVertical)
        {
            // vertical arrows need horizontal alignment
            var ownerWidth:Number = anchor.getLayoutBoundsWidth();
            var ownerX:Number = anchor.getLayoutBoundsX();
            
            if (calloutWidth <= ownerWidth)
            {
                arrowX = (calloutWidth - arrowWidth) / 2;
            }
            else // if (calloutWidth > ownerWidth)
            {
                if ((arrowWidth >= ownerWidth) && !isMiddlePosition)
                {
                    arrowX = (isStartPosition) ? 0 : calloutWidth - arrowWidth;
                }
                else
                {
                    if (isMiddlePosition)
                    {
                        // center on the callout
                        arrowX = (calloutWidth - arrowWidth) / 2;
                    }
                    else
                    {
                        arrowX = (ownerWidth - arrowWidth) / 2;
                        
                        if (isEndPosition)
                            arrowX += (calloutWidth - ownerWidth);
                    }
                }
            }
            
            // move the arrow to the end of the callout
            if (isEndOfCallout)
                arrowY = calloutHeight - arrowHeight;
        }
        else
        {
            // horizontal arrows need vertical alignment
            var ownerHeight:Number = anchor.getLayoutBoundsHeight();
            
            if (calloutHeight <= ownerHeight)
            {
                arrowY = (calloutHeight - arrowHeight) / 2;
            }
            else
            {
                // isStartPosition
                arrowY = Math.max(0, (ownerHeight - arrowHeight) / 2);
                
                if (isEndPosition)
                {
                    arrowY += (calloutHeight - ownerHeight);
                }
                else if (isMiddlePosition)
                {
                    arrowY += (calloutHeight - ownerHeight) / 2;
                }
            }
            
            // move the arrow to the end of the callout
            if (isEndOfCallout)
                arrowX = calloutWidth - arrowWidth;
        }
        
        arrow.setLayoutBoundsPosition(Math.floor(arrowX), Math.floor(arrowY));
    }
    
    /**
     *  @private
     * 
     *  Basically the same as PopUpAnchor, but with more position options
     *  including exterior, interior and corner positions.
     * 
     *  @see spark.components.PopUpAnchor#calculatePopUpPosition
     */
    mx_internal function calculatePopUpPosition():Point
    {
        // This implementation doesn't handle rotation
        var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
        var matrix:Matrix = MatrixUtil.getConcatenatedMatrix(owner, sandboxRoot);
        
        var regPoint:Point = new Point();
        
        if (!matrix)
            return regPoint;
        
        var calloutBounds:Rectangle = new Rectangle(); 
        
        determinePosition(internalHorizontalPosition, internalVerticalPosition, matrix, regPoint, calloutBounds);
        
        var adjustedPosition:String;
        
        // Position the callout in the opposite direction if it 
        // does not fit on the screen. 
        // TODO (jasonsj): adjust for horizontalPosition/verticalPosition
        /*
        if (screen)
        {
        switch(popUpPosition)
        {
        case PopUpPosition.BELOW :
        if (popUpBounds.bottom > screen.bottom)
        adjustedPosition = PopUpPosition.ABOVE; 
        break;
        case PopUpPosition.ABOVE :
        if (popUpBounds.top < screen.top)
        adjustedPosition = PopUpPosition.BELOW; 
        break;
        case PopUpPosition.LEFT :
        if (popUpBounds.left < screen.left)
        adjustedPosition = PopUpPosition.RIGHT; 
        break;
        case PopUpPosition.RIGHT :
        if (popUpBounds.right > screen.right)
        adjustedPosition = PopUpPosition.LEFT; 
        break;
        }
        }
        */
        
        // Get the new registration point based on the adjusted position
        if (adjustedPosition != null)
        {
            var adjustedRegPoint:Point = new Point();
            var adjustedBounds:Rectangle = new Rectangle(); 
            determinePosition(internalHorizontalPosition, internalVerticalPosition, matrix, adjustedRegPoint, adjustedBounds);
            
            // TODO (jasonsj): adjust for horizontalPosition/verticalPosition
            /*
            if (screen)
            {
            // If we adjusted the position but the popUp still doesn't fit, 
            // then revert to the original position. 
            switch(adjustedPosition)
            {
            case PopUpPosition.BELOW :
            if (adjustedBounds.bottom > screen.bottom)
            adjustedPosition = null; 
            break;
            case PopUpPosition.ABOVE :
            if (adjustedBounds.top < screen.top)
            adjustedPosition = null; 
            break;
            case PopUpPosition.LEFT :
            if (adjustedBounds.left < screen.left)
            adjustedPosition = null; 
            break;
            case PopUpPosition.RIGHT :
            if (adjustedBounds.right > screen.right)
            adjustedPosition = null;  
            break;
            }    
            }
            */
            
            if (adjustedPosition != null)
            {
                regPoint = adjustedRegPoint;
                calloutBounds = adjustedBounds;
            }
        }
        
        MatrixUtil.decomposeMatrix(decomposition, matrix, 0, 0);
        var concatScaleX:Number = decomposition[3];
        var concatScaleY:Number = decomposition[4]; 
        
        // If the popUp still doesn't fit, then nudge it
        // so it is completely on the screen. Make sure to include scale.
        
        if (calloutBounds.top < screen.top)
            regPoint.y += (screen.top - calloutBounds.top) / concatScaleY;
        else if (calloutBounds.bottom > screen.bottom)
            regPoint.y -= (calloutBounds.bottom - screen.bottom) / concatScaleY;
        
        if (calloutBounds.left < screen.left)
            regPoint.x += (screen.left - calloutBounds.left) / concatScaleX;    
        else if (calloutBounds.right > screen.right)
            regPoint.x -= (calloutBounds.right - screen.right) / concatScaleX;
        
        // Compute the stage coordinates of the upper,left corner of the PopUp, taking
        // the postTransformOffsets - which include mirroring - into account.
        // If we're mirroring, then the implicit assumption that x=left will fail,
        // so we compensate here.
        
        if (layoutDirection == LayoutDirection.RTL)
            regPoint.x += calloutBounds.width;
        return MatrixUtil.getConcatenatedComputedMatrix(owner, sandboxRoot).transformPoint(regPoint);
    }
    
    /**
     *  @private
     *  Computes horizontalPosition and verticalPosition values when using
     *  CalloutPosition.AUTO.
     */
    mx_internal function commitAutoPosition():void
    {
        if ((horizontalPosition != CalloutPosition.AUTO) 
            && (verticalPosition != CalloutPosition.AUTO))
            return;
        
        var sbRoot:DisplayObject = systemManager.getSandboxRoot();
        var ownerBounds:Rectangle = owner.getBounds(sbRoot);
        
        var spaceLeft:Number = ownerBounds.left - width;
        var spaceRight:Number = sbRoot.width - ownerBounds.right;
        var spaceTop:Number = ownerBounds.top;
        var spaceBottom:Number = sbRoot.height - ownerBounds.bottom;
        
        spaceLeft -= width;
        spaceRight -= width;
        spaceTop -= height;
        spaceBottom -= height;
        
        if (verticalPosition != CalloutPosition.AUTO)
        {
            // horizontal auto only
            _autoHorizontalPosition = CalloutPosition.MIDDLE;
            _autoVerticalPosition = null;
        }
        else if (horizontalPosition != CalloutPosition.AUTO) 
        {
            // vertical auto only
            _autoHorizontalPosition = null;
            _autoVerticalPosition = CalloutPosition.MIDDLE;
        }
        else
        {
            // no room above or below
            var canFitVertical:Boolean = ((spaceTop > 0) || (spaceBottom > 0));
            var canFitHorizontal:Boolean = ((spaceLeft > 0) || (spaceRight > 0));
            
            if (canFitVertical && !canFitHorizontal)
            {
                // place vertically before or after the owner
                // allow the callout to span the horizontal screen space
                _autoHorizontalPosition = CalloutPosition.MIDDLE;
                _autoVerticalPosition = (spaceTop > spaceBottom) ? CalloutPosition.BEFORE : CalloutPosition.AFTER;
            }
            else
            {
                // place horizontally before or after the owner
                // allow the callout to span the vertical screen space
                _autoHorizontalPosition = CalloutPosition.MIDDLE;
                _autoVerticalPosition = (spaceTop > spaceBottom) ? CalloutPosition.BEFORE : CalloutPosition.AFTER;
            }
        }
    }
    
    /**
     *  @private 
     */
    mx_internal function determinePosition(horizontalPos:String, verticalPos:String,
                                           matrix:Matrix, registrationPoint:Point, bounds:Rectangle):void
    {
        var ownerVisualElement:ILayoutElement = owner as ILayoutElement;
        var ownerWidth:Number = (ownerVisualElement) ? ownerVisualElement.getLayoutBoundsWidth() : owner.width;
        var ownerHeight:Number = (ownerVisualElement) ? ownerVisualElement.getLayoutBoundsHeight() : owner.height;
        
        switch (horizontalPos)
        {
            case CalloutPosition.BEFORE:
                registrationPoint.x = -width;
                break;
            case CalloutPosition.START:
                registrationPoint.x = 0;
                break;
            case CalloutPosition.END:
                registrationPoint.x = ownerWidth - width;
                break;
            case CalloutPosition.AFTER:
                registrationPoint.x = ownerWidth;
                break;
            default: // case CalloutPosition.MIDDLE:
                registrationPoint.x = Math.floor((ownerWidth - width) / 2);
                break;
        }
        
        switch (verticalPos)
        {
            case CalloutPosition.BEFORE:
                registrationPoint.y = -height;
                break;
            case CalloutPosition.START:
                registrationPoint.y = 0;
                break;
            case CalloutPosition.MIDDLE:
                registrationPoint.y = Math.floor((ownerHeight - height) / 2);
                break;
            case CalloutPosition.END:
                registrationPoint.y = ownerHeight - height;
                break;
            default: //case CalloutPosition.AFTER:
                registrationPoint.y = ownerHeight;
                break;
        }
        
        var topLeft:Point = registrationPoint.clone();
        var size:Point = MatrixUtil.transformBounds(width, height, matrix, topLeft);
        bounds.left = topLeft.x;
        bounds.top = topLeft.y;
        bounds.width = size.x;
        bounds.height = size.y;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Redraw whenever added to the stage to ensure the calculations
     *  in updateSkinDisplayList() are correct.
     */
    private function addedToStageHandler(event:Event):void
    {
        updateSkinDisplayList();
    }
    
    /**
     *  @private
     */
    private function arrow_resizeHandler(event:Event):void
    {
        updateSkinDisplayList();
    }
    
    /**
     *  @private
     */
    private function arrow_updateCompleteHandler(event:Event):void
    {
        updateSkinDisplayList();
    }
}
}