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
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.DPIClassification;
import mx.core.FlexGlobals;
import mx.core.ILayoutElement;
import mx.core.IVisualElement;
import mx.core.LayoutDirection;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.ResizeEvent;
import mx.managers.SystemManager;
import mx.styles.StyleProtoChain;
import mx.utils.MatrixUtil;
import mx.utils.PopUpUtil;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  Appearance of the <code>contentGroup</code>. 
 *  Valid MXML values are <code>inset</code>, 
 *  <code>flat</code>, and <code>none</code>.
 *
 *  <p>In ActionScript, you can use the following constants
 *  to set this property:
 *  <code>ContentBackgroundAppearance.INSET</code>,
 *  <code>ContentBackgroundAppearance.FLAT</code> and
 *  <code>ContentBackgroundAppearance.NONE</code>.</p>
 *
 *  @default ContentBackgroundAppearance.INSET
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.5.2
 */ 
[Style(name="contentBackgroundAppearance", type="String", enumeration="inset,flat,none", inherit="no")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("Callout.png")]

/**
 *  The Callout container is a SkinnablePopUpContainer that functions as a pop-up
 *  with additional owner-relative positioning options similar to PopUpAnchor.
 *  Callout also adds an optional <code>arrow</code> skin part that visually
 *  displays the direction toward the owner.
 *
 *  <p>You can also use the CalloutButton control to open a callout container. 
 *  The CalloutButton control encapsulates in a single control the callout container 
 *  and all of the logic necessary to open and close the callout. 
 *  The CalloutButton control is then said to the be the owner, or host, 
 *  of the callout.</p>
 *
 *  <p>Callout uses the <code>horizontalPosition</code> and
 *  <code>verticalPosition</code> properties to determine the position of the
 *  Callout relative to the owner that is specified by the <code>open()</code>
 *  method. 
 *  Both properties can be set to <code>CalloutPosition.AUTO</code> which selects a
 *  position based on the aspect ratio of the screen for the Callout to fit
 *  with minimal overlap with the owner and and minimal adjustments at the
 *  screen bounds.</p>
 *
 *  <p>Once positioned, the Callout positions the arrow on the side adjacent
 *  to the owner, centered as close as possible on the horizontal or vertical
 *  center of the owner as appropriate. The arrow is hidden in cases where
 *  the Callout position is not adjacent to any edge.</p>
 *
 *  <p>You do not create a Callout container as part of the normal layout
 *  of its parent container.
 *  Instead, it appears as a pop-up container on top of its parent.
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
 *  <p>Callout changes the default inheritance behavior seen in Flex components 
 *  and instead, inherits styles from the top-level application. This prevents
 *  Callout's contents from unintentionally inheriting styles from an owner
 *  (i.e. Button or TextInput) where the default appearance was desired and
 *  expected.</p>
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
 *
 *    <strong>Styles</strong>
 *    contentBackgroundAppearance="inset"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.components.CalloutButton
 *  @see spark.skins.mobile.CalloutSkin
 *  @see spark.components.ContentBackgroundAppearance
 *  @see spark.components.CalloutPosition
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
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    private var invalidatePositionFlag:Boolean = false;

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

        invalidatePosition();
    }

    //----------------------------------
    //  actualHorizontalPosition
    //----------------------------------

    private var _actualHorizontalPosition:String;

    /**
     *  Fully resolved horizontal position after evaluating CalloutPosition.AUTO.
     * 
     *  <p>Update this property in <code>commitProperties()</code> when the
     *  explicit <code>horizontalPosition</code> is CalloutPosition.AUTO. 
     *  This property must be updated in <code>updatePopUpPosition()</code>
     *  when attempting to reposition the Callout.</p> 
     *  
     *  <p>Subclasses should read this property when computing the <code>arrowDirection</code>,
     *  the arrow position in <code>updateSkinDisplayList()</code>.</p>
     *
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected function get actualHorizontalPosition():String
    {
        if (_actualHorizontalPosition)
            return _actualHorizontalPosition;

        return horizontalPosition;
    }

    /**
     *  @private
     */
    protected function set actualHorizontalPosition(value:String):void
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

        invalidatePosition();
    }

    //----------------------------------
    //  actualVerticalPosition
    //----------------------------------

    private var _actualVerticalPosition:String;
    
    /**
     *  Fully resolved vertical position after evaluating CalloutPosition.AUTO.
     * 
     *  <p>Update this property in <code>commitProperties()</code> when the
     *  explicit <code>verticalPosition</code> is CalloutPosition.AUTO. 
     *  This property must be updated in <code>updatePopUpPosition()</code>
     *  when attempting to reposition the Callout.</p> 
     *  
     *  <p>Subclasses should read this property when computing the <code>arrowDirection</code>,
     *  the arrow position in <code>updateSkinDisplayList()</code>.</p>
     *
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    protected function get actualVerticalPosition():String
    {
        if (_actualVerticalPosition)
            return _actualVerticalPosition;

        return verticalPosition;
    }

    /**
     *  @private
     */
    protected function set actualVerticalPosition(value:String):void
    {
        _actualVerticalPosition = value;
    }

    //----------------------------------
    //  arrowDirection
    //----------------------------------

    private var _arrowDirection:String = ArrowDirection.NONE;
    
    /**
     *  @private
     *  
     */
    private var arrowDirectionAdjusted:Boolean = false;

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
     *  @default none
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
    
    /**
     *  @private
     *  Invalidate skin when the arrowDirection changes. Dispatches an 
     *  "arrowDirectionChanged" event when the property is set.
     */
    mx_internal function setArrowDirection(value:String):void
    {
        if (_arrowDirection == value)
            return;
        
        _arrowDirection = value;
        
        // Instead of using skin states for each arrowDirection, the
        // skin must override commitProperties() and account for
        // arrowDirection on it's own.
        skin.invalidateProperties();
        
        // adjust margins based on arrow direction
        switch (arrowDirection)
        {
            case ArrowDirection.DOWN:
            {
                // Set the marginBottom to zero to place the arrow adjacent to the keyboard
                softKeyboardEffectMarginBottom = 0;
                softKeyboardEffectMarginTop = margin;
                break;
            }
            case ArrowDirection.UP:
            {
                // Arrow should already be adjacent to the owner or the top of
                // the screen.
                softKeyboardEffectMarginTop = 0;
                softKeyboardEffectMarginBottom = margin;
                break;
            }
            default:
            {
                softKeyboardEffectMarginBottom = margin;
                softKeyboardEffectMarginTop = margin;
                break;
            }
        }
        
        if (hasEventListener("arrowDirectionChanged"))
            dispatchEvent(new Event("arrowDirectionChanged"));
    }
    
    //----------------------------------
    //  margin
    //----------------------------------
    
    private var _margin:Number = NaN;
    
    /**
     *  @private
     *  Defines a margin around the Callout to nudge it's position away from the
     *  edge of the screen.
     */
    mx_internal function get margin():Number
    {
        if (isNaN(_margin))
        {
            var dpi:Number = FlexGlobals.topLevelApplication["applicationDPI"];
            
            if (dpi)
            {
                switch (dpi)
                {
                    case DPIClassification.DPI_320:
                    {
                        _margin = 16;
                        break;
                    }
                    case DPIClassification.DPI_240:
                    {
                        _margin = 12;
                        break;
                    }
                    default:
                    {
                        // default DPI_160
                        _margin = 8;
                        break;
                    }
                }
            }
            else
            {
                _margin = 8;
            }
        }
        
        return _margin;
    }
    
    private var _explicitMoveForSoftKeyboard:Boolean = false;
    
    /**
     *  @private
     */
    override public function get moveForSoftKeyboard():Boolean
    {
        // If no explicit setting, then automatically disable move when
        // pointing up towards the owner.
        if (!_explicitMoveForSoftKeyboard && 
            (arrowDirection == ArrowDirection.UP))
        {
            return false;
        }
        
        return super.moveForSoftKeyboard;
    }
    
    /**
     *  @private
     */
    override public function set moveForSoftKeyboard(value:Boolean):void
    {
        super.moveForSoftKeyboard = value;
        
        _explicitMoveForSoftKeyboard = true;
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
        
        commitAutoPosition();

        if (arrow)
        {
            // arrowDirection can be set in 2 ways: (1) horizontalPostion/verticalPosition
            // changes and (2) flipping the axis to fit on screen. 
            if (!arrowDirectionAdjusted)
            {
                // Invalidate only when the arrow direction changes
                var direction:String = determineArrowPosition(actualHorizontalPosition,
                    actualVerticalPosition);
                
                if (arrowDirection != direction)
                {
                    setArrowDirection(direction);
                    
                    if (arrow)
                        arrow.visible = (arrowDirection != ArrowDirection.NONE);
                }
            }
            
            // Always reset the arrow position
            invalidateDisplayList();
        }
    }

    /**
     *  @private
     *  Re-position the pop-up using actualHorizontalPosition and
     *  actualVerticalPosition. 
     */
    override public function updatePopUpPosition():void
    {
        if (!owner)
            return;
        
        var popUpPoint:Point = calculatePopUpPosition();
        var ownerComponent:UIComponent = owner as UIComponent;
        var concatenatedColorTransform:ColorTransform = 
            (ownerComponent) ? ownerComponent.$transform.concatenatedColorTransform : null;
        
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
        if (isOpen)
            return;

        // Add to PopUpManager, calls updatePopUpPosition(), and change state
        super.open(owner, modal);
        
        // Reposition the callout when the screen changes
        var systemManagerParent:SystemManager = this.parent as SystemManager;
        
        if (systemManagerParent)
            systemManagerParent.addEventListener(Event.RESIZE, systemManager_resizeHandler);
    }
    
    /**
     *  @private
     */
    override public function close(commit:Boolean=false, data:*=null):void
    {
        if (!isOpen)
            return;
        
        var systemManagerParent:SystemManager = this.parent as SystemManager;
        
        if (systemManagerParent)
            systemManagerParent.removeEventListener(Event.RESIZE, systemManager_resizeHandler);
        
        super.close(commit, data);
    }
    
    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        // Callout can be respositioned while open via SystemManager resize or
        // explicit changes to horizontalPostion and verticalPosition.
        if (isOpen && invalidatePositionFlag)
        {
            updatePopUpPosition();
            invalidatePositionFlag = false;
        }

        // Position the arrow
        updateSkinDisplayList();
    }
    
    /**
     *  @private
     *  Force callout inheritance chain to start at the style root.
     */
    override mx_internal function initProtoChain():void
    {
        StyleProtoChain.initProtoChain(this, false);
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function invalidatePosition():void
    {
        arrowDirectionAdjusted = false;
        
        invalidateProperties();
        
        if (isOpen)
            invalidatePositionFlag = true;
    }

    /**
     *  Sets the bounds of <code>arrow</code>, whose geometry isn't fully
     *  specified by the skin's layout.
     *
     *  <p>Subclasses can override this method to update the arrow's size,
     *  position, and visibility, based on the computed
     *  <code>arrowDirection</code>.</p>
     *
     *  <p>By default, this method aligns the arrow on the shorter of either
     *  the <code>arrow</code> bounds or the <code>owner</code> bounds. This
     *  implementation assumes that the <code>arrow</code> and the Callout skin
     *  share the same coordinate space.</p>
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

        var isStartPosition:Boolean = false;
        var isMiddlePosition:Boolean = false;
        var isEndPosition:Boolean = false;

        var position:String = (isArrowVertical) ? actualHorizontalPosition : actualVerticalPosition;

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

        // Max arrow positions
        var maxArrowX:Number = calloutWidth - arrowWidth;
        var maxArrowY:Number = calloutHeight - arrowHeight;
        
        // Find the registration point of the owner
        var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
        var regPoint:Point = owner.localToGlobal(new Point());
        regPoint = sandboxRoot.globalToLocal(regPoint);

        if (isArrowVertical)
        {
            // Vertical arrows need horizontal alignment
            var ownerX:Number = regPoint.x;
            var ownerVisibleWidth:Number = (ownerVisualElement)
                ? ownerVisualElement.getLayoutBoundsWidth() : owner.width;

            // Edge cases when start/end of owner is not visible
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
                // Center the arrow on the owner
                arrowX = (ownerVisibleWidth - arrowWidth) / 2;
                
                // Add owner offset
                if (ownerX > 0)
                    arrowX += Math.abs(ownerX - getLayoutBoundsX());
            }
            
            // arrow should not extend past the callout bounds
            arrowX = Math.max(Math.min(maxArrowX, arrowX), 0);

            // Move the arrow to the bottom of the callout
            if (isEndOfCallout)
                arrowY = calloutHeight - arrowHeight;
        }
        else
        {
            // Horizontal arrows need vertical alignment
            var ownerY:Number = regPoint.y;
            var ownerVisibleHeight:Number = (ownerVisualElement)
                ? ownerVisualElement.getLayoutBoundsHeight() : owner.height;

            // Edge cases when start/end of owner is not visible
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
                // Center the arrow on the owner
                arrowY = (ownerVisibleHeight - arrowHeight) / 2;
                
                // Add owner offset
                if (ownerY > 0)
                    arrowY += Math.abs(ownerY - getLayoutBoundsY());
            }
            
            // arrow should not extend past the callout bounds
            arrowY = Math.max(Math.min(maxArrowY, arrowY), 0);

            // Move the arrow to the end of the callout
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
        // Skip all adjustments when using AUTO
        if (!position || (position == CalloutPosition.AUTO))
            return null;
        
        var adjustedPosition:String = null;
        
        // Maintain outer/inner positions when flipping to opposite direction
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
            // Nudge instead of flipping
        }
        
        // Return null to revert the adjusted position
        // Otherwise, return the incoming position
        if (revert)
            return (adjustedPosition) ? null : position;
        
        // Adjusted position or null if the callout already fits
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
            position += (screenStart - calloutStart) / scaleFactor;
        else if (calloutEnd > screenEnd)
            position -= (calloutEnd - screenEnd) / scaleFactor;
        
        return position;
    }

    /**
     *  @private
     *
     *  Basically the same as PopUpAnchor, but with more position options
     *  including exterior, interior and corner positions.
     * 
     *  Nudging to fit the screen accounts for <code>margin</code> so that
     *  the Callout is not positioned in the margin.
     * 
     *  <code>arrowDirection</code> will change if required for the callout
     *  to fit.
     *
     *  @see #margin
     */
    mx_internal function calculatePopUpPosition():Point
    {
        // This implementation doesn't handle rotation
        var sandboxRoot:DisplayObject = systemManager.getSandboxRoot();
        var matrix:Matrix = MatrixUtil.getConcatenatedMatrix(owner, sandboxRoot);

        var regPoint:Point = new Point();

        if (!matrix)
            return regPoint;
        
        var adjustedHorizontalPosition:String;
        var adjustedVerticalPosition:String;
        var calloutBounds:Rectangle = determinePosition(actualHorizontalPosition,
            actualVerticalPosition, matrix, regPoint);

        // Position the callout in the opposite direction if it
        // does not fit on the screen.
        if (screen)
        {
            adjustedHorizontalPosition = adjustCalloutPosition(
                actualHorizontalPosition,
                calloutBounds.left, calloutBounds.right,
                screen.left, screen.right);

            adjustedVerticalPosition = adjustCalloutPosition(
                actualVerticalPosition,
                calloutBounds.top, calloutBounds.bottom,
                screen.top, screen.bottom);
        }

        var oldArrowDirection:String = arrowDirection;
        var actualArrowDirection:String = null;
        
        // Reset arrowDirectionAdjusted
        arrowDirectionAdjusted = false;

        // Get the new registration point based on the adjusted position
        if ((adjustedHorizontalPosition != null) || (adjustedVerticalPosition != null))
        {
            var adjustedRegPoint:Point = new Point();
            var tempHorizontalPosition:String = (adjustedHorizontalPosition)
                ? adjustedHorizontalPosition : actualHorizontalPosition;
            var tempVerticalPosition:String = (adjustedVerticalPosition)
                ? adjustedVerticalPosition : actualVerticalPosition;

            // Adjust arrow direction after adjusting position
            actualArrowDirection = determineArrowPosition(tempHorizontalPosition,
                tempVerticalPosition);

            // All position flips gaurantee an arrowDirection change
            setArrowDirection(actualArrowDirection);
            arrowDirectionAdjusted = true;

            if (arrow)
                arrow.visible = (arrowDirection != ArrowDirection.NONE);

            // Reposition the arrow
            updateSkinDisplayList();

            var adjustedBounds:Rectangle = determinePosition(tempHorizontalPosition,
                tempVerticalPosition, matrix, adjustedRegPoint);

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

                // Temporarily set actual positions to reposition the arrow
                if (adjustedHorizontalPosition)
                    actualHorizontalPosition = adjustedHorizontalPosition;

                if (adjustedVerticalPosition)
                    actualVerticalPosition = adjustedVerticalPosition;

                // Reposition the arrow with the new actual position
                updateSkinDisplayList();
            }
            else
            {
                // Restore previous arrow direction *before* reversing the
                // adjusted positions
                setArrowDirection(oldArrowDirection);
                arrowDirectionAdjusted = false;

                // Reposition the arrow to the original position
                updateSkinDisplayList();
            }
        }

        MatrixUtil.decomposeMatrix(decomposition, matrix, 0, 0);
        var concatScaleX:Number = decomposition[3];
        var concatScaleY:Number = decomposition[4];

        // If the callout still doesn't fit, then nudge it
        // so it is completely on the screen. Make sure to include scale.
        var screenTop:Number = screen.top;
        var screenBottom:Number = screen.bottom;
        var screenLeft:Number = screen.left;
        var screenRight:Number = screen.right;
        
        // Allow zero margin on the the side with the arrow
        switch (arrowDirection)
        {
            case ArrowDirection.UP:
            {
                screenBottom -= margin;
                screenLeft += margin;
                screenRight -= margin
                break;
            }
            case ArrowDirection.DOWN:
            {
                screenTop += margin;
                screenLeft += margin;
                screenRight -= margin
                break;
            }
            case ArrowDirection.LEFT:
            {
                screenTop += margin;
                screenBottom -= margin;
                screenRight -= margin
                break;
            }
            case ArrowDirection.RIGHT:
            {
                screenTop += margin;
                screenBottom -= margin;
                screenLeft += margin;
                break;
            }
            default:
            {
                screenTop += margin;
                screenBottom -= margin;
                screenLeft += margin;
                screenRight -= margin
                break;
            }
        }
        
        regPoint.y += nudgeToFit(calloutBounds.top, calloutBounds.bottom,
            screenTop, screenBottom, concatScaleY);
        
        regPoint.x += nudgeToFit(calloutBounds.left, calloutBounds.right,
            screenLeft, screenRight, concatScaleX);

        // Compute the stage coordinates of the upper,left corner of the PopUp, taking
        // the postTransformOffsets - which include mirroring - into account.
        // If we're mirroring, then the implicit assumption that x=left will fail,
        // so we compensate here.

        if (layoutDirection == LayoutDirection.RTL)
            regPoint.x += calloutBounds.width;
        return MatrixUtil.getConcatenatedComputedMatrix(owner, sandboxRoot).transformPoint(regPoint);
    }

    /**
     *  Computes <code>actualHorizontalPosition</code> and/or
     *  <code>actualVerticalPosition</code> values when using
     *  <code>CalloutPosition.AUTO</code>. When implementing subclasses of
     *  Callout, use <code>actualHorizontalPosition</code> and
     *  <code>actualVerticalPosition</code> to compute
     *  <code>arrowDirection</code> and positioning in
     *  <code>updatePopUpPosition()</code> and <code>updateSkinDisplayList()</code>.
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
        if (!screen || ((horizontalPosition != CalloutPosition.AUTO) &&
            (verticalPosition != CalloutPosition.AUTO)))
        {
            // Use explicit positions instead of AUTO
            actualHorizontalPosition = null;
            actualVerticalPosition = null;
            
            return;
        }

        var ownerBounds:Rectangle = owner.getBounds(systemManager.getSandboxRoot());

        // Use aspect ratio to determine vertical/horizontal preference
        var isLandscape:Boolean = (screen.width > screen.height);

        var spaceLeft:Number = ownerBounds.left;
        var spaceRight:Number = screen.width - ownerBounds.right;
        var spaceTop:Number = ownerBounds.top;
        var spaceBottom:Number = screen.height - ownerBounds.bottom;

        var canFitVertical:Boolean = ((spaceTop > 0) || (spaceBottom > 0));
        var canFitHorizontal:Boolean = ((spaceLeft > 0) || (spaceRight > 0));

        if (verticalPosition != CalloutPosition.AUTO)
        {
            // Horizontal auto only
            switch (verticalPosition)
            {
                case CalloutPosition.START:
                case CalloutPosition.MIDDLE:
                case CalloutPosition.END:
                {
                    actualHorizontalPosition = (spaceRight > spaceLeft) ? CalloutPosition.AFTER : CalloutPosition.BEFORE;
                    break;
                }
                default:
                {
                    actualHorizontalPosition = CalloutPosition.MIDDLE;
                    break;
                }
            }
            
            actualVerticalPosition = null;
        }
        else if (horizontalPosition != CalloutPosition.AUTO)
        {
            // Vertical auto only
            switch (horizontalPosition)
            {
                case CalloutPosition.START:
                case CalloutPosition.MIDDLE:
                case CalloutPosition.END:
                {
                    actualVerticalPosition = (spaceBottom > spaceTop) ? CalloutPosition.AFTER : CalloutPosition.BEFORE;
                    break;
                }
                default:
                {
                    actualVerticalPosition = CalloutPosition.MIDDLE;
                    break;
                }
            }
            
            actualHorizontalPosition = null;
        }
        else // if ((verticalPosition == CalloutPosition.AUTO) && (horizontalPosition == CalloutPosition.AUTO))
        {
            var useVertical:Boolean = true;
            var useInterior:Boolean = false;

            if (!canFitHorizontal && !canFitVertical)
            {
                // Edge case where callout doesn't fit in any direction.
                // Choose position based on aspect ratio
                useVertical = !isLandscape;
                
                // Only use interior positions when no space is available
                useInterior = (spaceTop <= 0) && (spaceBottom <= 0) &&
                              (spaceLeft <= 0) && (spaceRight <= 0);
            }
            else if (isLandscape)
            {
                // Favor horizontal before/after in landscape
                useVertical = !canFitHorizontal;
            }
            else
            {
                // Favor vertical before/after in portrait
                useVertical = canFitVertical;
            }
            
            var startPos:String = (useInterior) ? CalloutPosition.START : CalloutPosition.BEFORE;
            var endPos:String = (useInterior) ? CalloutPosition.END : CalloutPosition.AFTER;

            if (useVertical)
            {
                actualHorizontalPosition = CalloutPosition.MIDDLE;
                actualVerticalPosition = (spaceBottom > spaceTop) ? endPos : startPos;
            }
            else
            {
                actualHorizontalPosition = (spaceRight > spaceLeft) ? endPos : startPos;
                actualVerticalPosition = CalloutPosition.MIDDLE;
            }
        }
    }

    /**
     *  @private
     */
    mx_internal function determineArrowPosition(horizontalPos:String, verticalPos:String):String
    {
        // Determine arrow direction, outer positions get priority.
        // Corner positions and center show no arrow
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
     * 
     *  Uses horizontalPosition and verticalPosition to determine the bounds of
     *  the callout.
     */
    mx_internal function determinePosition(horizontalPos:String, verticalPos:String,
                                           matrix:Matrix, registrationPoint:Point):Rectangle
    {
        var ownerVisualElement:ILayoutElement = owner as ILayoutElement;
        var ownerWidth:Number = (ownerVisualElement) ? ownerVisualElement.getLayoutBoundsWidth() : owner.width;
        var ownerHeight:Number = (ownerVisualElement) ? ownerVisualElement.getLayoutBoundsHeight() : owner.height;

        switch (horizontalPos)
        {
            case CalloutPosition.BEFORE:
            {
                // The full width of the callout is before the owner
                // All arrow directions are ArrowDirection.RIGHT x=(width - arrow.width)
                registrationPoint.x = -width;
                break;
            }
            case CalloutPosition.START:
            {
                // ArrowDirection.LEFT is at x=0
                registrationPoint.x = 0;
                break;
            }
            case CalloutPosition.END:
            {
                // The ends of the owner and callout are aligned
                registrationPoint.x = (ownerWidth - width);
                break;
            }
            case CalloutPosition.AFTER:
            {
                // The full width of the callout is after the owner
                // All arrow directions are ArrowDirection.LEFT (x=0)
                registrationPoint.x = ownerWidth;
                break;
            }
            default: // case CalloutPosition.MIDDLE:
            {
                registrationPoint.x = Math.floor((ownerWidth - width) / 2);
                break;
            }
        }

        switch (verticalPos)
        {
            case CalloutPosition.BEFORE:
            {
                // The full height of the callout is before the owner
                // All arrow directions are ArrowDirection.DOWN y=(height - arrow.height)
                registrationPoint.y = -height;
                break;
            }
            case CalloutPosition.START:
            {
                // ArrowDirection.UP is at y=0
                registrationPoint.y = 0;
                break;
            }
            case CalloutPosition.MIDDLE:
            {
                registrationPoint.y = Math.floor((ownerHeight - height) / 2);
                break;
            }
            case CalloutPosition.END:
            {
                // The ends of the owner and callout are aligned
                registrationPoint.y = (ownerHeight - height);
                break;
            }
            default: //case CalloutPosition.AFTER:
            {
                // The full height of the callout is after the owner
                // All arrow directions are ArrowDirection.UP (y=0)
                registrationPoint.y = ownerHeight;
                break;
            }
        }

        var topLeft:Point = registrationPoint.clone();
        var size:Point = MatrixUtil.transformBounds(width, height, matrix, topLeft);
        var bounds:Rectangle = new Rectangle();
        
        bounds.left = topLeft.x;
        bounds.top = topLeft.y;
        bounds.width = size.x;
        bounds.height = size.y;
        
        return bounds;
    }
    
    /**
     * @private
     */
    mx_internal function get isArrowVertical():Boolean
    {
        return (arrowDirection == ArrowDirection.UP ||
                arrowDirection == ArrowDirection.DOWN);
    }

    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

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
    private function systemManager_resizeHandler(event:Event):void
    {
        // Screen resize might require a new arrow direction and callout position
        invalidatePosition();
    }
}
}