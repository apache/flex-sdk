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

import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.LineScaleMode;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Transform;
import flash.geom.Vector3D;
import flash.utils.Timer;

import mx.core.DesignLayer;
import mx.core.DPIClassification;
import mx.core.FlexGlobals;
import mx.core.IUIComponent;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;
import mx.geom.TransformOffsets;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

/**
 *  The interval to delay, in milliseconds, between rotations of this
 *  component. Controls the speed at which this component spins. 
 * 
 *  @default 50
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 *   
 */ 
[Style(name="rotationInterval", type="Number", format="Time", inherit="no")]

/**
 *  Color of the spokes of the spinner.
 *   
 *  @default 0x000000
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark,mobile")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("BusyIndicator.png")]

/**
 *  The BusyIndicator defines a component to display when a long-running 
 *  operation is in progress. This component creates a spinner with twelve spokes.
 *  The color of the spokes is controlled by the value of the <code>symbolColor</code> style.
 *  The transparency of this component can be modified using the <code>alpha</code> property,
 *  but the alpha value of each spoke cannot be modified.
 *
 *  <p>The following image shows the BusyIndicator at the bottom of the screen next 
 *  to the Submit button:</p>
 *
 * <p>
 *  <img src="../../images/bi_busy_indicator_bi.png" alt="Busy indicator" />
 * </p>
 * 
 *  <p>The speed at which this component spins is controlled by the <code>rotationInterval</code>
 *  style. The <code>rotationInterval</code> style sets the delay, in milliseconds, between
 *  rotations. Decrease the <code>rotationInterval</code> value to increase the speed of the spin.</p>
 * 
 *  <p>The BusyIndicator has the following default characteristics:</p>
 *  <table class="innertable">
 *     <tr><th>Characteristic</th><th>Description</th></tr>
 *     <tr><td>Default size</td><td>160 DPI: 26x26 pixels<br>
 *                                  240 DPI: 40x40 pixels<br>
 *                                  320 DPI: 52x52 pixels</td></tr>
 *     <tr><td>Minimum size</td><td>20x20 pixels</td></tr>
 *     <tr><td>Maximum size</td><td>No limit</td></tr>
 *  </table>
 *  
 *  <p>The diameter of the BusyIndicator's spinner is the minimum of the width and
 *  height of the component. The diameter must be an even number, and is
 *  reduced by one if it is set to an odd number.</p>
 * 
 *  @mxml
 *  
 *  <p>The <code>&lt;s:BusyIndicator&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;s:BusyIndicator
 *    <strong>Common Styles</strong>
 *    rotationInterval=50
 * 
 *    <strong>Spark Styles</strong>
 *    symbolColor="0x000000"
 *  
 *    <strong>Mobile Styles</strong>
 *    symbolColor="0x000000"
 *  &gt;
 *  </pre>
 *
 *  @includeExample examples/BusyIndicatorExample.mxml -noswf
 *  @includeExample examples/views/BusyIndicatorExampleHomeView.mxml -noswf
 * 
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class BusyIndicator extends UIComponent
{

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */ 
    static private const DEFAULT_ROTATION_INTERVAL:Number = 50;

    /**
     *  @private
     */ 
    static private const DEFAULT_MINIMUM_SIZE:Number = 20;

    /**
     *  @private
     */ 
    static private const RADIANS_PER_DEGREE:Number = Math.PI / 180;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function BusyIndicator()
    {
        super();
        
        alpha = 0.60;       // default alpha
        
        // Listen to added to stage and removed from stage.
        // Start rotating when we are on the stage and stop
        // when we are removed from the stage.
        addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private var effectiveVisibility:Boolean = false;
    
    /**
     *  @private
     */
    private var effectiveVisibilityChanged:Boolean = true;
    
    /**
     *  @private
     */   
    private var oldUnscaledHeight:Number;

    /**
     *  @private
     */   
    private var oldUnscaledWidth:Number;
    
    /**
     *  @private
     */   
    private var rotationTimer:Timer;

    /**
     *  @private
     * 
     *  Current rotation of this component in degrees.
     */   
    private var currentRotation:Number = 0;
    
    /**
     *  @private
     * 
     *  Diameter of the spinner for this component.
     */ 
    private var spinnerDiameter:int;

    /**
     *  @private
     * 
     *  Cached value of the spoke color.
     */ 
    private var spokeColor:uint;

    //--------------------------------------------------------------------------
    //
    //  Private Properties 
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Cache the last value of applicationDPI.
     */ 
    private var _applicationDPI:Number;
    
    /**
     *  @private
     * 
     *  Get the applicationDPI in use.
     */ 
    private function get applicationDPI():Number
    {
        if (_applicationDPI)
            return _applicationDPI;
        
        var application:Object = FlexGlobals.topLevelApplication;
        
        if ("applicationDPI" in application)
            _applicationDPI = application["applicationDPI"];

        return _applicationDPI; 
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override public function set designLayer(value:DesignLayer):void
    {
        super.designLayer = value;

        effectiveVisibilityChanged = true;
        invalidateProperties();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (effectiveVisibilityChanged)
        {
            // if visibility changed, re-compute them here
            computeEffectiveVisibility();
            
            if (canRotate())
                startRotation();
            else
                stopRotation();
            
            effectiveVisibilityChanged = false;
        }
    }

    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        // Set the default measured size depending on the
        // applicationDPI
        if (applicationDPI == DPIClassification.DPI_320)
        {
            measuredWidth = 52;
            measuredHeight = 52;
        }
        else if (applicationDPI == DPIClassification.DPI_240)
        {
            measuredWidth = 40;
            measuredHeight = 40;
        }
        else if (applicationDPI == DPIClassification.DPI_160)
        {
            measuredWidth = 26;
            measuredHeight = 26;
        }
        else
        {
            measuredWidth = DEFAULT_MINIMUM_SIZE;
            measuredHeight = DEFAULT_MINIMUM_SIZE;
        }

        measuredMinWidth = DEFAULT_MINIMUM_SIZE;
        measuredMinHeight = DEFAULT_MINIMUM_SIZE;
    }
    
    /**
     *  @private
     *  Override so we know when visibility is set. The initialized
     *  property calls setVisible() with noEvent == true
     *  so we wouldn't get a visibility event if we just listened
     *  for events.
     */
    override public function setVisible(value:Boolean,
                               noEvent:Boolean = false):void
    {
        super.setVisible(value, noEvent);
        
        effectiveVisibilityChanged = true;
        invalidateProperties();
    }
    
    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);
        
        var allStyles:Boolean = !styleName || styleName == "styleName";

        // Check for skin/icon changes here.
        // We could only throw out any skins that change,
        // but since dynamic re-skinning is uncommon, we'll take
        // the simpler approach of throwing out all skins.
        if (allStyles || styleName == "rotationInterval")
        {
            // Update the timer if the rotation interval has changed.
            if (isRotating())
            {
                stopRotation();
                startRotation();
            }
        }
        
        if (allStyles || styleName == "symbolColor")
        {
            updateSpinner(spinnerDiameter);
        }
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        // If the size changed, then create a new spinner.
        if (oldUnscaledWidth != unscaledWidth ||
            oldUnscaledHeight != unscaledHeight)
        {
            var newDiameter:Number;
            
            newDiameter = calculateSpinnerDiameter(unscaledWidth, unscaledHeight);
            updateSpinner(newDiameter);

            oldUnscaledWidth = unscaledWidth;
            oldUnscaledHeight = unscaledHeight;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *   @private
     *
     *   Apply the rules to calculate the spinner diameter from the width
     *   and height.
     *  
     *   @param width new width of this component
     *   @param height new height of this component
     *    
     *   @return true if the spinner's diameter changes, false otherwise.
     */
    private function calculateSpinnerDiameter(width:Number, height:Number):Number
    {
        var diameter:Number = Math.min(width, height);
        diameter = Math.max(DEFAULT_MINIMUM_SIZE, diameter);
        if (diameter % 2 != 0)
            diameter--;
        
        return diameter;
    }
    
   /**
    *   @private
    * 
    *   Update the spinner properties and redraw.
    */
    private function updateSpinner(diameter:Number):void
    {
        var isRotating:Boolean = isRotating();
        
        if (isRotating)
            stopRotation();
       
        spinnerDiameter = diameter;
        spokeColor = getStyle("symbolColor");
        
        drawSpinner();
        
        if (isRotating)
            startRotation();
    }

    /**
     *  @private
     * 
     *  Draw the spinner using the graphics property of this component.
     */ 
    mx_internal function drawSpinner():void 
    {
        var g:Graphics = graphics;
        var spinnerRadius:int = spinnerDiameter / 2;
        var spinnerWidth:int = spinnerDiameter;
        var spokeHeight:Number = spinnerDiameter / 3.7;
        var insideDiameter:Number = spinnerDiameter - (spokeHeight * 2); 
        var spokeWidth:Number = insideDiameter / 5;
        var eHeight:Number = spokeWidth / 2;
        var spinnerPadding:Number = 0;

        // Undocumented styles to modified the spokeWidth
        // and spokeHeight.
//        if (getStyle("spokeWidth") !== undefined)
//        {
//            spokeWidth = getStyle("spokeWidth");
//            eHeight = spokeWidth / 2;
//        }
//        
//        if (getStyle("spokeHeight") !== undefined)
//            spokeHeight = getStyle("spokeHeight");
//        
//        // spinnerPadding is the padding between the outside
//        // edge of the circle and the edge of a spoke. 
//        if (getStyle("spinnerPadding") !== undefined)
//            spinnerPadding = getStyle("spinnerPadding");
//
//        trace("spoke height = " + spokeHeight);
//        trace("spoke width = " + spokeWidth);
//        trace("center = " + center);
        
        g.clear();
        
        // 1
        drawSpoke(0.20, currentRotation + 300, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
        
        // 2
        drawSpoke(0.25, currentRotation + 330, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
        
        // 3
        drawSpoke(0.30, currentRotation, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
        
        // 4
        drawSpoke(0.35, currentRotation + 30, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
        
        // 5
        drawSpoke(0.40, currentRotation + 60, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
        
        // 6
        drawSpoke(0.45, currentRotation + 90, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
        
        // 7
        drawSpoke(0.50, currentRotation + 120, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);

        // 8
        drawSpoke(0.60, currentRotation + 150, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);

        // 9
        drawSpoke(0.70, currentRotation + 180, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
        
        // 10
        drawSpoke(0.80, currentRotation + 210, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
        
        // 11
        drawSpoke(0.90, currentRotation + 240, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
        
        // 12
        drawSpoke(1.0, currentRotation + 270, spokeWidth, spokeHeight, spokeColor, spinnerRadius, eHeight, spinnerPadding);
    }
    
    
    /**
     *  @private
     * 
     *  @param spokeAlpha: alpha value of the spoke.
     *  @param spokeWidth: width of the spoke in points.
     *  @param spokeHeight: the lenght of the spoke in pixels.
     *  @param spokeColor: the color of the spoke.
     *  @param spinnerRadius: radius of the spinner.
     *  @param eHeight: estimated height of the rounded end of the spinner.
     *  @param spinnerPadding: number of pixels between the outside
     *  radius of the spinner and the spokes. This is used to make 
     *  spinners with skinny spokes look better by moving them
     *  closer to the center of the spinner.
     */ 
    private function drawSpoke(spokeAlpha:Number, degrees:int,
                               spokeWidth:Number, 
                               spokeHeight:Number, 
                               spokeColor:uint, 
                               spinnerRadius:Number, 
                               eHeight:Number,
                               spinnerPadding:Number):void
    {
        var g:Graphics = graphics;
        var outsidePoint:Point = new Point();
        var insidePoint:Point = new Point();
        
        g.lineStyle(spokeWidth, spokeColor, spokeAlpha, false, LineScaleMode.NORMAL, CapsStyle.ROUND);
        outsidePoint = calculatePointOnCircle(spinnerRadius, spinnerRadius - eHeight - spinnerPadding, degrees);
        insidePoint = calculatePointOnCircle(spinnerRadius, spinnerRadius - spokeHeight + eHeight - spinnerPadding, degrees);
        g.moveTo(outsidePoint.x, outsidePoint.y);
        g.lineTo(insidePoint.x,  insidePoint.y);
            
    }
    
    /**
     *  @private
     */ 
    private function calculatePointOnCircle(center:Number, radius:Number, degrees:Number):Point
    {
        var point:Point = new Point();
        var radians:Number = degrees * RADIANS_PER_DEGREE;
        point.x = center + radius * Math.cos(radians);
        point.y = center + radius * Math.sin(radians);
        
        return point;
    }
    
    /**
     *  @private
     */
    private function startRotation():void
    {
        if (!rotationTimer)
        {
            var rotationInterval:Number = getStyle("rotationInterval");
            if (isNaN(rotationInterval))
                rotationInterval = DEFAULT_ROTATION_INTERVAL;
            
            if (rotationInterval < 16.6)
                rotationInterval = 16.6;
            
            rotationTimer = new Timer(rotationInterval);
        }
        
        if (!rotationTimer.hasEventListener(TimerEvent.TIMER))
        {
            rotationTimer.addEventListener(TimerEvent.TIMER, timerHandler);
            rotationTimer.start();
        }
        
    }
    
    /**
     *  @private
     */
    private function stopRotation():void
    {
        if (rotationTimer)
        {
            rotationTimer.removeEventListener(TimerEvent.TIMER, timerHandler);
            rotationTimer.stop();
            rotationTimer = null;
        }
    }
 
    /**
     *  @private
     */
    private function isRotating():Boolean
    {
        return rotationTimer != null;
    }
    
    /**
     *  The BusyIndicator can be rotated if it is both on the display list and 
     *  visible.
     * 
     *  @returns true if the BusyIndicator can be rotated, false otherwise.
     */ 
    private function canRotate():Boolean
    {
        if (effectiveVisibility && stage != null)
            return true;
        
        return false;
    }
    
    /**
     *  @private
     */
    private function computeEffectiveVisibility():void
    {
        
        // Check our design layer first.
        if (designLayer && !designLayer.effectiveVisibility)
        {
            effectiveVisibility = false;
            return;
        }
        
        // Start out with true visibility and enablement
        // then loop up parent-chain to see if any of them are false.
        effectiveVisibility = true;
        var current:IVisualElement = this;
        
        while (current)
        {
            if (!current.visible)
            {
                if (!(current is IUIComponent) || !IUIComponent(current).isPopUp)
                {
                    // Treat all pop ups as if they were visible. This is to 
                    // fix a bug where the BusyIndicator does not spin when it 
                    // is inside modal popup. The problem is in we do not get 
                    // an event when the modal window is made visible in 
                    // PopUpManagerImpl.fadeInEffectEndHandler(). When the modal
                    // window is made visible, setVisible() is passed "true" so 
                    // as to not send an event. When do get events when the 
                    // non-modal windows are popped up. Only modal windows are
                    // a problem.
                    // The downside of this fix is BusyIndicator components that are
                    // inside of hidden, non-modal, popup windows will paint themselves
                    // on a timer.
                    effectiveVisibility = false;
                    break;                  
                }
            }
            
            current = current.parent as IVisualElement;
        }
    }
    
    /**
     *  @private
     *  Add event listeners for SHOW and HIDE on all the ancestors up the parent chain.
     *  Adding weak event listeners just to be safe.
     */
    private function addVisibilityListeners():void
    {
        var current:IVisualElement = this.parent as IVisualElement;
        while (current)
        {
            // add visibility listeners to the parent
            current.addEventListener(FlexEvent.HIDE, visibilityChangedHandler, false, 0, true);
            current.addEventListener(FlexEvent.SHOW, visibilityChangedHandler, false, 0, true);
            
            current = current.parent as IVisualElement;
        }
    }

    /**
     *  @private
     *  Remove event listeners for SHOW and HIDE on all the ancestors up the parent chain.
     */
    private function removeVisibilityListeners():void
    {
        var current:IVisualElement = this;
        while (current)
        {
            current.removeEventListener(FlexEvent.HIDE, visibilityChangedHandler, false);
            current.removeEventListener(FlexEvent.SHOW, visibilityChangedHandler, false);
            
            current = current.parent as IVisualElement;
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers: UIComponent
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function layer_PropertyChange(event:PropertyChangeEvent):void
    {
        super.layer_PropertyChange(event);
        
        if (event.property == "effectiveVisibility")
        {
            effectiveVisibilityChanged = true;
            invalidateProperties();
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event Handlers
    //
    //--------------------------------------------------------------------------
 
    /**
     *  @private
     */
    private function addedToStageHandler(event:Event):void
    {
        // Check our visibility here since we haven't added
        // visibility listeners yet.
        computeEffectiveVisibility();
        
        if (canRotate())
            startRotation();
        
        addVisibilityListeners();
    }
   
    /**
     *  @private
     */
    private function removedFromStageHandler(event:Event):void
    {
        stopRotation();
        
        removeVisibilityListeners();
    }
    
    /**
     *  @private
     *  Event call back whenever the visibility of us or one of our ancestors 
     *  changes
     */
    private function visibilityChangedHandler(event:FlexEvent):void
    {
        effectiveVisibilityChanged = true;
        invalidateProperties();
    }
    
    /**
     *  @private
     * 
     *  Rotate the spinner once for each timer event.
     */
    private function timerHandler(event:TimerEvent):void
    {
        currentRotation += 30;
        if (currentRotation >= 360)
            currentRotation = 0;
        
        drawSpinner();
        event.updateAfterEvent();
    }
  
}
}