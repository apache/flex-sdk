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

package spark.components
{

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Transform;
import flash.geom.Vector3D;
import flash.utils.Timer;

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
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 *   
 */ 
[Style(name="rotationInterval", type="Number", format="Time", inherit="no")]

/**
 *  Color of any symbol of a component. 
 *  This is used by the BusyIndicator to color the spokes of the spinner.
 *   
 *  @default 0x000000
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10.1
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark,mobile")]

/**
 *  The BusyIndicator defines a component to display a when a long-running 
 *  operation is in progress. This component is a spinner with twelve spokes.
 *  The color of the spokes is controled by the value of the symbolColor style.
 *  The transparency of this component can be modified using the alpha property
 *  but the alpha value of each spoke cannot be modified.
 * 
 *  <p>
 *  The speed at which this component spins is controled by the rotationInterval
 *  style. The rotationInterval style is the delay in milliseconds between
 *  rotates. Decrease the rotationInterval to increase the speed of the spin
 *  and increase the rotationInterval to slow the spin.
 *  </p>
 * 
 *  <p>The BusyIndicator has the following default characteristics:</p>
 *  <table class="innertable">
 *     <tr><th>Characteristic</th><th>Description</th></tr>
 *     <tr><td>Default size</td><td>160 DPI: 22x22 pixels<br>
 *                                  240 DPI: 34x34 pixels<br>
 *                                  320 DPI: 44x44 pixels</td></tr>
 *     <tr><td>Minimum size</td><td>20x20 pixels</td></tr>
 *     <tr><td>Maximum size</td><td>No limit</td></tr>
 *  </table>
 *  
 *  The diameter of the BusyIndicator's spinner is the minimum of the width and
 *  height of the component. The diameter must be an even number so will be
 *  reduced by one if it is odd.
 * 
 *  @mxml
 *  
*  <p>The <code>&lt;s:BusyCursor&gt;</code> tag inherits the symbolColor style
 *  and adds the rotationInterval style.</p>
 *  
 *  <pre>
 *  &lt;s:BusyIndicator
 *     
 *    <strong>Styles</strong>
 *    rotationInterval=50
 * 
 *    <strong>Spark Styles</strong>
 *    symbolColor="0x000000"
 *  
 *  &gt;
 *  </pre>
 *
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.1
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

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.1
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function BusyIndicator()
    {
        super();
        
        alpha = 0.65;       // default alpha
        
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
    
    //--------------------------------------------------------------------------
    //
    //  Public Properties 
    //
    //--------------------------------------------------------------------------
    
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
        var applicationDPI:int = 0;
        var application:Object = FlexGlobals.topLevelApplication;
        
        if ("applicationDPI" in application)
            applicationDPI = application["applicationDPI"];
        
        if (applicationDPI == 320)
        {
            measuredWidth = 44;
            measuredHeight = 44;
        }
        else if (applicationDPI == 240)
        {
            measuredWidth = 34;
            measuredHeight = 34;
        }
        else if (applicationDPI == 160)
        {
            measuredWidth = 22;
            measuredHeight = 22;
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
            updateSpinnerChildren(spinnerDiameter);
        }
    }

    /**
     *  @private
     */
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        // If the size or color changed, then create a new spinner.
        if (oldUnscaledWidth != unscaledWidth ||
            oldUnscaledHeight != unscaledHeight)
        {
            var newDiameter:Number;
            
            newDiameter = calculateSpinnerDiameter(unscaledWidth, unscaledHeight);
            updateSpinnerChildren(newDiameter);

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
        {
            diameter--;
        }
        
        return diameter;
    }
    
   /**
    *   @private
    * 
    *   Removes the old spinner children, if any, and adds
    *   new ones.
    */
    private function updateSpinnerChildren(diameter:Number):void
    {
        var isRotating:Boolean = isRotating();
        
        if (isRotating)
            stopRotation();
       
        var n:int = numChildren;
        for (var i:int = 0; i < n; i++)
        {
            removeChildAt(0);
        }

        // FIXME (dloverin): need to reset the accumulated 
        // transform matrix information. Current attempts
        // have not worked.

        //setLayoutMatrix3D(new Matrix3D(), false);
        //postLayoutTransformOffsets = new TransformOffsets();
        
        // Add the spinner children that when combined create the 
        // spinner.
        spinnerDiameter = diameter;
        
        var spinnerChildren:Array = createSpinnerChildren();
        n = spinnerChildren.length;
        
        for (i = 0; i < n; i++)
            addChild(spinnerChildren[i]);
        
        if (isRotating)
            startRotation();
    }

    
    /**
     *   @private
     * 
     *   Create the three spinner chilren and returns them in 
     *   an array.
     * 
     *   The spinner children are created based on the current
     *   value of the symbolColor style and the spinnerDiameter.
     * 
     *   The spinner has twelve spokes in the position of a clock
     *   face. Each spoke has a differnt alpha. Three children
     *   are used for different parts of the clockface. Each
     *   child contains four spokes. The first child contains
     *   the spokes for 12, 3, 6, and 9 o'clock. 
     *   
     *   The second child
     *   is drawn the same as the first child (but with different
     *   alphas) but is roatated 30 degrees. The second child
     *   represents 1, 4, 7, and 10 o'clock.
     * 
     *   The third child is drawn the same with differnt alpha
     *   but it is rotated 60 degrees. The third child represents
     *   2, 5, 8, and 11 o'clock.
     *
     */
    private function createSpinnerChildren():Array 
    {
        
        var spokeColor:uint = getStyle("symbolColor");
        var g:Graphics;
        var spinner12:Shape = new Shape();
        var spinner1:Shape = new Shape();
        var spinner2:Shape = new Shape();
        var localSpinnerDiameter:int = spinnerDiameter;
        var halfSpinnerDiameter:int = spinnerDiameter / 2;
        var spinnerWidth:int = spinnerDiameter;
        var halfSpinnerWidth:int = spinnerWidth / 2;
        var halfSpinnerHeight:int = spinnerDiameter / 2;
        var spokeWidth:int = spinnerDiameter / 10;
        var spokeHeight:int = spinnerDiameter / 4;
        var halfSpokeWidth:int = spokeWidth / 2;
        var halfSpokeHeight:int = spokeHeight / 2;
        var eWidth:int = spokeWidth;
        var eHeight:int = spokeWidth / 2;
        var m:Matrix;
       
        // First child
        g = spinner12.graphics;
        
        // 12
        g.beginFill(spokeColor, 1);
        g.drawRoundRect(halfSpinnerDiameter - halfSpokeWidth, 1, spokeWidth, spokeHeight, eWidth, eHeight);
        
        // 9
        g.beginFill(spokeColor, 0.89);
        g.drawRoundRect(1, halfSpinnerDiameter - halfSpokeWidth, spokeHeight, spokeWidth,  eWidth, eHeight);
        
        // 6
        g.beginFill(spokeColor, 0.73);
        g.drawRoundRect(halfSpinnerDiameter - halfSpokeWidth, localSpinnerDiameter - spokeHeight - 1, spokeWidth, spokeHeight,  eWidth, eHeight);
        
        // 3
        g.beginFill(spokeColor, 0.53);
        g.drawRoundRect(localSpinnerDiameter - spokeHeight - 1, halfSpinnerDiameter - halfSpokeWidth, spokeHeight, spokeWidth, eWidth, eHeight);
        
        // Second child
        g = spinner1.graphics;
        
        // 1
        g.beginFill(spokeColor, 0.45);
        g.drawRoundRect(halfSpinnerDiameter - halfSpokeWidth, 1, spokeWidth, spokeHeight, eWidth, eHeight);
        
        // 10
        g.beginFill(spokeColor, 0.93);
        g.drawRoundRect(1, halfSpinnerDiameter - halfSpokeWidth, spokeHeight, spokeWidth,  eWidth, eHeight);
        
        // 7
        g.beginFill(spokeColor, 0.80);
        g.drawRoundRect(halfSpinnerDiameter - halfSpokeWidth, localSpinnerDiameter - spokeHeight - 1, spokeWidth, spokeHeight,  eWidth, eHeight);
        
        // 4
        g.beginFill(spokeColor, 0.55);
        g.drawRoundRect(localSpinnerDiameter - spokeHeight - 1, halfSpinnerDiameter - halfSpokeWidth, spokeHeight, spokeWidth, eWidth, eHeight);
        
        m = new Matrix();
        m.translate(-halfSpinnerDiameter,-halfSpinnerDiameter);
        m.rotate( (30 * Math.PI) / 180);
        m.translate(halfSpinnerDiameter, halfSpinnerDiameter);
        spinner1.transform.matrix = m;
        
        // Third child
        g = spinner2.graphics;
        
        // 2
        g.beginFill(spokeColor, 0.49);
        g.drawRoundRect(halfSpinnerDiameter - halfSpokeWidth, 1, spokeWidth, spokeHeight, eWidth, eHeight);
        
        // 11
        g.beginFill(spokeColor, 0.95);
        g.drawRoundRect(1, halfSpinnerDiameter - halfSpokeWidth, spokeHeight, spokeWidth,  eWidth, eHeight);
        
        // 8
        g.beginFill(spokeColor, 0.82);
        g.drawRoundRect(halfSpinnerDiameter - halfSpokeWidth, localSpinnerDiameter - spokeHeight - 1, spokeWidth, spokeHeight,  eWidth, eHeight);
        
        // 5
        g.beginFill(spokeColor, 0.65);
        g.drawRoundRect(localSpinnerDiameter - spokeHeight - 1, halfSpinnerDiameter - halfSpokeWidth, spokeHeight, spokeWidth, eWidth, eHeight);
        
        m = new Matrix();
        m.translate(-halfSpinnerDiameter,-halfSpinnerDiameter);
        m.rotate( (60 * Math.PI) / 180);
        m.translate(halfSpinnerDiameter, halfSpinnerDiameter);
        spinner2.transform.matrix = m;
        
        return [spinner12, spinner1, spinner2];
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
        // start out with true visibility and enablement
        // then loop up parent-chain to see if any of them are false
        effectiveVisibility = true;
        var current:IVisualElement = this;
        
        while (current)
        {
            if (!current.visible || 
                (current.designLayer && !current.designLayer.effectiveVisibility))
            {
                effectiveVisibility = false;
                break;
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
        var current:IVisualElement = this;
        while (current)
        {
            // add visibility listeners to the parent
            current.addEventListener(FlexEvent.HIDE, visibilityChangedHandler, false, 0, true);
            current.addEventListener(FlexEvent.SHOW, visibilityChangedHandler, false, 0, true);
            
            // add listeners to the design layer too
            if (current.designLayer)
            {
                current.designLayer.addEventListener("layerPropertyChange", 
                    designLayer_layerPropertyChangeHandler, false, 0, true);
            }
            
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
            
            if (current.designLayer)
            {
                current.designLayer.removeEventListener("layerPropertyChange", 
                    designLayer_layerPropertyChangeHandler, false);
            }
            
            current = current.parent as IVisualElement;
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
     *  Event call back whenever the visibility of our designLayer or one of our parent's
     *  designLayers change.
     */
    private function designLayer_layerPropertyChangeHandler(event:PropertyChangeEvent):void
    {
        if (event.property == "effectiveVisibility")
        {
            effectiveVisibilityChanged = true;
            invalidateProperties();
        }
    }
    
    /**
     *  @private
     * 
     *  Rotate the spinner once for each timer event.
     */
    private function timerHandler(event:TimerEvent):void
    {
        
        var spinnerRadius:int = (spinnerDiameter / 2);
        var transformCenter:Vector3D = new Vector3D(spinnerRadius, spinnerRadius);
        currentRotation += 30;
        var rotation3D:Vector3D = new Vector3D(0, 0, currentRotation);
        transformAround(transformCenter, null, rotation3D, null, null, null, null, false);
        
        event.updateAfterEvent();
    }
  
}
}