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
import flash.display.DisplayObjectContainer;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.FlexGlobals;
import mx.core.ILayoutElement;
import mx.core.IVisualElement;
import mx.core.LayoutDirection;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.ResizeEvent;
import mx.managers.SystemManager;
import mx.utils.MatrixUtil;
import mx.utils.PopUpUtil;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  TODO (jasonsj): PARB
 *
 *  The gap style defines a buffer border at the bounds of the screen
 *  where the callout may not be positioned.
 *
 *  @default 0
 *
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */
[Style(name="gap", type="Number", format="Length", inherit="no")]


/**
 *  The Callout class is a SkinnablePopUpContainer that functions as a pop-up
 *  with additional owner-relative positioning options similar to PopUpAnchor.
 *  Callout also adds an optional <code>arrow</code> skin part that visually
 *  displays direction toward the owner.
 *
 *  <p>Callout uses <code>horizontalPosition</code> and
 *  <code>verticalPosition<code> properties to determine the position of the
 *  Callout relative to the owner that is specified via the <code>open()</code>
 *  method. Both properties may be set to CalloutPosition.AUTO which selects a
 *  position based on the aspect ratio of the screen for the Callout to fit
 *  with minimal overlap with the owner and and minimal adjustments at the
 *  screen bounds.
 *
 *  <p>Once positioned, the Callout positions the arrow on the side adjacent
 *  to the owner, centered as close as possible on the horizontal or vertical
 *  center of the owner as appropriate. The arrow is hidden in cases where
 *  the Callout position is not adjacent to any edge.
 *
 *  <p>You do not create a Callout container as part of the normal layout
 *  of its parent container.
 *  Instead, it appears as a pop-up window on top of its parent.
 *  Therefore, you do not create it directly in the MXML code of your application.</p>
 *
 *  <p>Instead, you create is as an MXML component, often in a separate MXML file.
 *  To show the component create an instance of the MXML component, and
 *  then call the <code>open()</code> method.
 *  You can also set the size and position of the component when you open it.</p>
 *
 *  <p>To close the component, call the <code>close()</code> method.
 *  If the pop-up needs to return data to a handler, you can add an event listener for
 *  the <code>PopUp.CLOSE</code> event, and specify the returned data in
 *  the <code>close()</code> method.</p>
 *
 *  <p>The Callout is initially in its <code>closed</code> skin state.
 *  When it opens, it adds itself as a pop-up to the PopUpManager,
 *  and transition to the <code>normal</code> skin state.
 *  To define open and close animations, use a custom skin with transitions between
 *  the <code>closed</code> and <code>normal</code> skin states.</p>
 *
 *  <p>The Callout container has the following default characteristics:</p>
 *     <table class="innertable">
 *     <tr><th>Characteristic</th><th>Description</th></tr>
 *     <tr><td>Default size</td><td>Large enough to display its children</td></tr>
 *     <tr><td>Minimum size</td><td>0 pixels</td></tr>
 *     <tr><td>Maximum size</td><td>10000 pixels wide and 10000 pixels high</td></tr>
 *     <tr><td>Default skin class</td><td>spark.skins.mobile.CalloutSkin</td></tr>
 *     </table>
 *
 *  @mxml <p>The <code>&lt;s:Callout&gt;</code> tag inherits all of the tag
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:Callout
 *    <strong>Properties</strong>
 *    horizontalPosition="auto"
 *    verticalPosition="auto"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.skins.mobile.CalloutSkin
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
    public var arrow:UIComponent;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  horizontalPosition
    //----------------------------------

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

    //----------------------------------
    //  actualHorizontalPosition
    //----------------------------------

    private var _actualHorizontalPosition:String;

    /**
     *  TODO (jasonsj): PARB
     *
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    mx_internal function get actualHorizontalPosition():String
    {
        if (_actualHorizontalPosition)
            return _actualHorizontalPosition;

        return horizontalPosition;
    }

    /**
     *  TODO (jasonsj): PARB
     *
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    mx_internal function set actualHorizontalPosition(value:String):void
    {
        _actualHorizontalPosition = value;
    }

    //----------------------------------
    //  verticalPosition
    //----------------------------------

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

    //----------------------------------
    //  actualVerticalPosition
    //----------------------------------

    private var _actualVerticalPosition:String;

    /**
     *  TODO (jasonsj): PARB
     *
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    mx_internal function get actualVerticalPosition():String
    {
        if (_actualVerticalPosition)
            return _actualVerticalPosition;

        return verticalPosition;
    }

    /**
     *  TODO (jasonsj): PARB
     *
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    mx_internal function set actualVerticalPosition(value:String):void
    {
        _actualVerticalPosition = value;
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

            // invalidate only when the arrow direction changes
            var direction:String = determineArrowPosition(actualHorizontalPosition,
                actualVerticalPosition);

            if (_arrowDirection != direction)
            {
                _arrowDirection = direction;
                
                if (arrow)
                    arrow.visible = (arrowDirection != ArrowDirection.NONE);

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
        var ownerComponent:UIComponent = owner as UIComponent;
        var concatenatedColorTransform:ColorTransform = ownerComponent.$transform.concatenatedColorTransform;

        PopUpUtil.applyPopUpTransform(owner, concatenatedColorTransform,
                                      systemManager, this, popUpPoint);
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
            arrow.addEventListener(ResizeEvent.RESIZE, arrow_resizeHandler);
    }

    /**
     *  @private
     */
    override protected function partRemoved(partName:String, instance:Object):void
    {
        super.partRemoved(partName, instance);

        if (instance == arrow)
            arrow.removeEventListener(ResizeEvent.RESIZE, arrow_resizeHandler);
    }

    /**
     *  @private
     */
    override public function open(owner:DisplayObjectContainer, modal:Boolean=false):void
    {
        if ((horizontalPosition == CalloutPosition.AUTO)
            || (verticalPosition == CalloutPosition.AUTO))
        {
            // invalidate the arrow direction before opening
            invalidateArrowState = true;
            invalidateProperties();
        }

        // add to PopUpManager, calls positionPopUp(), and change state
        super.open(owner, modal);
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        // position the arrow
        updateSkinDisplayList();
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
        var ownerVisualElement:IVisualElement = owner as IVisualElement;

        if (!arrow || (arrowDirection == ArrowDirection.NONE))
            return;

        var isVertical:Boolean = (arrowDirection == ArrowDirection.UP)
            || (arrowDirection == ArrowDirection.DOWN);

        var isStartPosition:Boolean = false;
        var isMiddlePosition:Boolean = false;
        var isEndPosition:Boolean = false;

        var position:String = (isVertical) ? actualHorizontalPosition : actualVerticalPosition;

        isStartPosition = (position == CalloutPosition.START);
        isMiddlePosition = (position == CalloutPosition.MIDDLE);
        isEndPosition = (position == CalloutPosition.END);

        var isEndOfCallout:Boolean = (arrowDirection == ArrowDirection.DOWN)
            || (arrowDirection == ArrowDirection.RIGHT);

        var calloutWidth:Number = getLayoutBoundsWidth();
        var calloutHeight:Number = getLayoutBoundsHeight();
        var arrowWidth:Number = arrow.getLayoutBoundsWidth();
        var arrowHeight:Number = arrow.getLayoutBoundsHeight();

        // arrow X/Y in pop-up coordinates
        var arrowX:Number = 0;
        var arrowY:Number = 0;

        // max arrow positions
        var maxArrowX:Number = calloutWidth - arrowWidth;
        var maxArrowY:Number = calloutHeight - arrowHeight;
        
        // find the registration point of the owner
        var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
        var regPoint:Point = owner.localToGlobal(new Point());
        regPoint = sandboxRoot.globalToLocal(regPoint);

        if (isVertical)
        {
            // vertical arrows need horizontal alignment
            var ownerX:Number = regPoint.x;
            var ownerVisibleWidth:Number = (ownerVisualElement)
                ? ownerVisualElement.getLayoutBoundsWidth() : owner.width;

            // edge cases when start/end of owner is not visible
            if ((ownerX < 0) && (ownerVisibleWidth < screen.width))
                ownerVisibleWidth = Math.max(ownerVisibleWidth + ownerX, 0);
            else if ((ownerX >= 0) && ((ownerX + ownerVisibleWidth) >= screen.width))
                ownerVisibleWidth = Math.max(screen.width - ownerX, 0);

            ownerVisibleWidth = Math.min(ownerVisibleWidth, screen.width);

            if (calloutWidth <= ownerVisibleWidth)
            {
                arrowX = (calloutWidth - arrowWidth) / 2;
            }
            else // if (calloutWidth > ownerWidth)
            {
                // center the arrow on the owner
                arrowX = (ownerVisibleWidth - arrowWidth) / 2;
                
                if (ownerX > 0)
                    arrowX += Math.abs(ownerX - getLayoutBoundsX());

                // arrow should not extend past the callout bounds
                arrowX = Math.max(Math.min(maxArrowX, arrowX), 0);
            }

            // move the arrow to the bottom of the callout
            if (isEndOfCallout)
                arrowY = calloutHeight - arrowHeight;
        }
        else
        {
            // horizontal arrows need vertical alignment
            var ownerY:Number = regPoint.y;
            var ownerVisibleHeight:Number = (ownerVisualElement)
                ? ownerVisualElement.getLayoutBoundsHeight() : owner.height;

            // edge cases when start/end of owner is not visible
            if ((ownerY < 0) && (ownerVisibleHeight < screen.height))
                ownerVisibleHeight = Math.max(ownerVisibleHeight + ownerY, 0);
            else if ((ownerY >= 0) && ((ownerY + ownerVisibleHeight) >= screen.height))
                ownerVisibleHeight = Math.max(screen.height - ownerY, 0);

            ownerVisibleHeight = Math.min(ownerVisibleHeight, screen.height);

            if (calloutHeight <= ownerVisibleHeight)
            {
                arrowY = (calloutHeight - arrowHeight) / 2;
            }
            else // if (calloutHeight > ownerHeight)
            {
                // center the arrow on the owner
                arrowY = (ownerVisibleHeight - arrowHeight) / 2;
                
                if (ownerY > 0)
                    arrowY += Math.abs(ownerY - getLayoutBoundsY());

                // arrow should not extend past the callout bounds
                arrowY = Math.max(Math.min(maxArrowY, arrowY), 0);
            }

            // move the arrow to the end of the callout
            if (isEndOfCallout)
                arrowX = calloutWidth - arrowWidth;
        }

        arrow.setLayoutBoundsPosition(Math.floor(arrowX), Math.floor(arrowY));
        arrow.invalidateDisplayList();
    }
    
    /**
     *  @private
     * 
     *  Flip or clear the adjusted position when the callout bounds are outside
     *  the screen bounds.
     */
    mx_internal function adjustCalloutPosition(position:String, 
                                               calloutStart:Number, calloutEnd:Number,
                                               screenStart:Number, screenEnd:Number,
                                               revert:Boolean=false):String
    {
        // skip all adjustments when using AUTO
        if (!position || (position == CalloutPosition.AUTO))
            return null;
        
        var adjustedPosition:String = null;
        
        // maintain outer/inner positions when flipping to opposite direction
        switch (position)
        {
            case CalloutPosition.BEFORE:
                if (calloutStart < screenStart)
                    adjustedPosition = CalloutPosition.AFTER;
                break;
            case CalloutPosition.AFTER:
                if (calloutEnd > screenEnd)
                    adjustedPosition = CalloutPosition.BEFORE;
                break;
            case CalloutPosition.END:
                if (calloutStart < screenStart)
                    adjustedPosition = CalloutPosition.START;
                break;
            case CalloutPosition.START:
                if (calloutEnd > screenEnd)
                    adjustedPosition = CalloutPosition.END;
                break;
            // case CalloutPosition.MIDDLE:
            // nudge instead of flipping
        }
        
        // return null to revert the adjusted position
        // otherwise, return the incoming position
        if (revert)
            return (adjustedPosition) ? null : position;
        
        // adjusted position or null if the callout already fits
        return adjustedPosition;
    }
    
    /**
     *  @private
     * 
     *  Nudge the callout position to fit on screen. Prefer top/left positions
     *  and allow overflow to get clipped on the bottom/right.
     */
    mx_internal function nudgeToFit(calloutStart:Number, calloutEnd:Number,
                                    screenStart:Number, screenEnd:Number,
                                    scaleFactor:Number):Number
    {
        var position:Number = 0;
        
        if (calloutStart < screenStart)
        {
            position += (screenStart - calloutStart) / scaleFactor;
            invalidateArrowState = true;
        }
        else if (calloutEnd > screenEnd)
        {
            position -= (calloutEnd - screenEnd) / scaleFactor;
            invalidateArrowState = true;
        }
        
        return position;
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

        determinePosition(actualHorizontalPosition, actualVerticalPosition, matrix, regPoint, calloutBounds);

        var adjustedHorizontalPosition:String;
        var adjustedVerticalPosition:String;

        // Position the callout in the opposite direction if it
        // does not fit on the screen.
        if (screen)
        {
            adjustedHorizontalPosition = adjustCalloutPosition(
                horizontalPosition,
                calloutBounds.left, calloutBounds.right,
                screen.left, screen.right);

            adjustedVerticalPosition = adjustCalloutPosition(
                verticalPosition,
                calloutBounds.top, calloutBounds.bottom,
                screen.top, screen.bottom);
        }

        var oldArrowDirection:String = _arrowDirection;
        var adjustedArrowDirection:String;

        // Get the new registration point based on the adjusted position
        if ((adjustedHorizontalPosition != null) || (adjustedVerticalPosition != null))
        {
            var adjustedRegPoint:Point = new Point();
            var adjustedBounds:Rectangle = new Rectangle();

            var tempHorizontalPosition:String = (adjustedHorizontalPosition)
                ? adjustedHorizontalPosition : actualHorizontalPosition;
            var tempVerticalPosition:String = (adjustedVerticalPosition)
                ? adjustedVerticalPosition : actualVerticalPosition;

            // adjust arrow direction after adjusting position
            adjustedArrowDirection = determineArrowPosition(tempHorizontalPosition,
                tempVerticalPosition);

            // invalidate the skin if the arrow direction changed
            if (_arrowDirection != adjustedArrowDirection)
            {
                _arrowDirection = adjustedArrowDirection;

                if (arrow)
                    arrow.visible = (arrowDirection != ArrowDirection.NONE);

                skin.invalidateProperties();
                skin.validateNow();

                // reposition the arrow
                updateSkinDisplayList();
            }

            determinePosition(tempHorizontalPosition, tempVerticalPosition, matrix, adjustedRegPoint, adjustedBounds);

            if (screen)
            {
                // If we adjusted the position but the callout still doesn't fit,
                // then revert to the original position.
                adjustedHorizontalPosition = adjustCalloutPosition(
                    adjustedHorizontalPosition,
                    adjustedBounds.left, adjustedBounds.right,
                    screen.left, screen.right, true);
                
                adjustedVerticalPosition = adjustCalloutPosition(
                    adjustedVerticalPosition,
                    adjustedBounds.top, adjustedBounds.bottom,
                    screen.top, screen.bottom, true);
            }

            if ((adjustedHorizontalPosition != null) || (adjustedVerticalPosition != null))
            {
                regPoint = adjustedRegPoint;
                calloutBounds = adjustedBounds;

                // temporarily set actual positions to reposition the arrow
                if (adjustedHorizontalPosition)
                    actualHorizontalPosition = adjustedHorizontalPosition;

                if (adjustedVerticalPosition)
                    actualVerticalPosition = adjustedVerticalPosition;

                // reposition the arrow with the new actual position
                updateSkinDisplayList();
            }
            else
            {
                // restore previous arrow direction *before* reversing the
                // adjusted positions
                _arrowDirection = oldArrowDirection;

                skin.invalidateProperties();
                skin.validateNow();

                // reposition the arrow to the original position
                updateSkinDisplayList();
            }
        }

        MatrixUtil.decomposeMatrix(decomposition, matrix, 0, 0);
        var concatScaleX:Number = decomposition[3];
        var concatScaleY:Number = decomposition[4];

        // If the callout still doesn't fit, then nudge it
        // so it is completely on the screen. Make sure to include scale.
        var buffer:Number = getStyle("gap");

        regPoint.y += nudgeToFit(calloutBounds.top, calloutBounds.bottom,
            screen.top + buffer, screen.bottom - buffer, concatScaleY);
        
        regPoint.x += nudgeToFit(calloutBounds.left, calloutBounds.right,
            screen.left + buffer, screen.right - buffer, concatScaleX);

        // Compute the stage coordinates of the upper,left corner of the PopUp, taking
        // the postTransformOffsets - which include mirroring - into account.
        // If we're mirroring, then the implicit assumption that x=left will fail,
        // so we compensate here.

        if (layoutDirection == LayoutDirection.RTL)
            regPoint.x += calloutBounds.width;
        return MatrixUtil.getConcatenatedComputedMatrix(owner, sandboxRoot).transformPoint(regPoint);
        
        if (invalidateArrowState)
        {
            updateSkinDisplayList();
            invalidateArrowState = false;
        }
    }

    /**
     *  TODO (jasonsj): PARB
     *
     *  Computes <code>actualHorizontalPosition</code> and/or
     *  <code>actualVerticalPosition</code> values when using
     *  <code>CalloutPosition.AUTO</code>. When implementing subclasses of
     *  Callout, use <code>actualHorizontalPosition</code> and
     *  <code>actualVerticalPosition</code> to compute
     *  <code>arrowDirection</code> and positioning in
     *  <code>positionPopUp()</code> and <code>updateSkinDisplayList()</code>.
     *
     *  <p>The default implementation chooses "outer" positions for the callout
     *  such that the owner is not obscured. Horizontal/Vertical orientation
     *  relative to the owner choosen based on the aspect ratio.</p>
     *
     *  <p>When the aspect ratio is landscape, and the callout can fit to the
     *  left or right of the owner, <code>actualHorizontalPosition</code> is
     *  set to <code>CalloutPosition.BEFORE</code> or
     *  <code>CalloutPosition.AFTER</code> as appropriate.
     *  <code>actualVerticalPosition</code> is set to
     *  <code>CalloutPosition.MIDDLE</code> to have the vertical center of the
     *  callout align to the vertical center of the owner.</p>
     *
     *  <p>When the aspect ratio is portrait, and the callout can fit
     *  above or below the owner, <code>actualVerticalPosition</code> is
     *  set to <code>CalloutPosition.BEFORE</code> or
     *  <code>CalloutPosition.AFTER</code> as appropriate.
     *  <code>actualHorizontalPosition</code> is set to
     *  <code>CalloutPosition.MIDDLE</code> to have the horizontal center of the
     *  callout align to the horizontal center of the owner.</p>
     *
     *  <p>Subclasses may override to modify automatic positioning behavior.</p>
     */
    mx_internal function commitAutoPosition():void
    {
        if (!screen)
            return;

        if ((horizontalPosition != CalloutPosition.AUTO)
            || (verticalPosition != CalloutPosition.AUTO))
        {
            actualHorizontalPosition = null;
            actualVerticalPosition = null;

            return;
        }

        var ownerBounds:Rectangle = owner.getBounds(systemManager.getSandboxRoot());

        // use aspect ratio to determine vertical/horizontal preference
        var isLandscape:Boolean = (screen.width > screen.height);

        var spaceLeft:Number = ownerBounds.left;
        var spaceRight:Number = screen.width - ownerBounds.right;
        var spaceTop:Number = ownerBounds.top;
        var spaceBottom:Number = screen.height - ownerBounds.bottom;

        var calloutWidth:Number = getLayoutBoundsWidth();
        var calloutHeight:Number = getLayoutBoundsHeight();

        // can the popUp fit in each direction?
        spaceLeft -= calloutWidth;
        spaceRight -= calloutWidth;
        spaceTop -= calloutHeight;
        spaceBottom -= calloutHeight;

        var canFitVertical:Boolean = ((spaceTop > 0) || (spaceBottom > 0));
        var canFitHorizontal:Boolean = ((spaceLeft > 0) || (spaceRight > 0));

        if (verticalPosition != CalloutPosition.AUTO)
        {
            // horizontal auto only
            actualHorizontalPosition = (spaceRight > spaceLeft) ? CalloutPosition.AFTER : CalloutPosition.BEFORE;
            actualVerticalPosition = null;
        }
        else if (horizontalPosition != CalloutPosition.AUTO)
        {
            // vertical auto only
            actualHorizontalPosition = null;
            actualVerticalPosition = (spaceBottom > spaceTop) ? CalloutPosition.AFTER : CalloutPosition.BEFORE;
        }
        else // if ((verticalPosition == CalloutPosition.AUTO) && (horizontalPosition == CalloutPosition.AUTO))
        {
            var useVertical:Boolean = true;

            if (!canFitHorizontal && !canFitVertical)
            {
                // edge case where callout doesn't fit in any direction
                var horizontalSpace:Number = (spaceLeft > spaceRight) ? spaceLeft : spaceRight;
                var verticalSpace:Number = (spaceTop > spaceBottom) ? spaceTop : spaceBottom;

                useVertical = (verticalSpace > horizontalSpace);
            }
            else if (isLandscape)
            {
                // favor horizontal before/after in landscape
                useVertical = !canFitHorizontal;
            }
            else
            {
                // favor vertical before/after in portrait
                useVertical = canFitVertical;
            }

            if (useVertical)
            {
                actualHorizontalPosition = CalloutPosition.MIDDLE;
                actualVerticalPosition = (spaceBottom > spaceTop) ? CalloutPosition.AFTER : CalloutPosition.BEFORE;
            }
            else
            {
                actualHorizontalPosition = (spaceRight > spaceLeft) ? CalloutPosition.AFTER : CalloutPosition.BEFORE;
                actualVerticalPosition = CalloutPosition.MIDDLE;
            }
        }
    }

    mx_internal function determineArrowPosition(horizontalPos:String, verticalPos:String):String
    {
        // determine arrow direction, outer positions get priority
        // corner positions and center show no arrow
        var direction:String = ArrowDirection.NONE;

        if (horizontalPos == CalloutPosition.BEFORE)
        {
            if ((verticalPos != CalloutPosition.BEFORE)
                &&  (verticalPos != CalloutPosition.AFTER))
            {
                direction = ArrowDirection.RIGHT;
            }
        }
        else if (horizontalPos == CalloutPosition.AFTER)
        {
            if ((verticalPos != CalloutPosition.BEFORE)
                && (verticalPos != CalloutPosition.AFTER))
            {
                direction = ArrowDirection.LEFT;
            }
        }
        else if (verticalPos == CalloutPosition.BEFORE)
        {
            direction = ArrowDirection.DOWN;
        }
        else if (verticalPos == CalloutPosition.AFTER)
        {
            direction = ArrowDirection.UP;
        }
        else if (horizontalPos == CalloutPosition.START)
        {
            direction = ArrowDirection.LEFT;
        }
        else if (horizontalPos == CalloutPosition.END)
        {
            direction = ArrowDirection.RIGHT;
        }
        else if (verticalPos == CalloutPosition.START)
        {
            direction = ArrowDirection.UP;
        }
        else if (verticalPos == CalloutPosition.END)
        {
            direction = ArrowDirection.DOWN;
        }

        return direction
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