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
package mx.effects.effectClasses
{
import flash.events.Event;

import mx.effects.Animation;
import mx.effects.PropertyValuesHolder;
import mx.events.AnimationEvent;

import mx.components.FxApplication;
import mx.core.Container;
import mx.core.IUIComponent;
import mx.events.EffectEvent;
import mx.events.TweenEvent;
import mx.styles.IStyleClient;
    
public class FxResizeInstance extends FxAnimateInstance
{
    include "../../core/Version.as";

    public function FxResizeInstance(target:Object)
    {
        super(target);
        
        roundValues = true;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var restoreVisibleArray:Array;
    
    /**
     *  @private
     */
    private var restoreAutoLayoutArray:Array;
    
    /**
     *  @private
     */
    private var numHideEffectsPlaying:Number = 0;

    /**
     *  @private
     */
    private var heightSet:Boolean;
    
    /**
     *  @private
     */
    private var widthSet:Boolean;
    
    /**
     *  @private
     */
    private var explicitWidthSet:Boolean;
    
    /**
     *  @private
     */
    private var explicitHeightSet:Boolean;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  heightBy
    //----------------------------------

    /**
     *  @private
     *  Storage for the heightBy property.
     */
    private var _heightBy:Number;
    
    /** 
     *  Number of pixels by which to modify the height of the component.
     *  Values may be negative.
     */
    public function get heightBy():Number
    {
        return _heightBy;
    }   
    
    /**
     *  @private
     */
    public function set heightBy(value:Number):void
    {
        _heightBy = value;
        heightSet = !isNaN(value);
    }
    
    //----------------------------------
    //  heightFrom
    //----------------------------------

    /** 
     *  Initial height. If omitted, Flex uses the current size.
     */
    public var heightFrom:Number;

    //----------------------------------
    //  heightTo
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the heightTo property.
     */
    private var _heightTo:Number;
    
    /** 
     *  Final height, in pixels.
     */
    public function get heightTo():Number
    {
        return _heightTo;
    }   
    
    /**
     *  @private
     */
    public function set heightTo(value:Number):void
    {
        _heightTo = value;
        heightSet = !isNaN(value);
    }
    
    //----------------------------------
    //  widthBy
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the widthBy property.
     */
    private var _widthBy:Number;

    /** 
     *  Number of pixels by which to modify the width of the component.
     *  Values may be negative.
     */ 
    public function get widthBy():Number
    {
        return _widthBy;
    }   
    
    /**
     *  @private
     */
    public function set widthBy(value:Number):void
    {
        _widthBy = value;
        widthSet = !isNaN(value);
    }

    //----------------------------------
    //  widthFrom
    //----------------------------------

    /** 
     *  Initial width. If omitted, Flex uses the current size.
     */
    public var widthFrom:Number;

    //----------------------------------
    //  widthTo
    //----------------------------------

    /**
     *  @private
     *  Storage for the widthTo property.
     */
    private var _widthTo:Number;
    
    /** 
     *  Final width, in pixels.
     */
    public function get widthTo():Number
    {
        return _widthTo;
    }   
    
    /**
     *  @private
     */
    public function set widthTo(value:Number):void
    {
        _widthTo = value;
        widthSet = !isNaN(value);
    }

    //----------------------------------
    //  hideChildrenTargets
    //----------------------------------

    /**
     *  An Array of Panels.
     *  The children of these Panels are hidden while the Resize effect plays.
     */
    public var hideChildrenTargets:Array /* of Panel */;

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function play():void
    {
        calculateDimensionChanges();
        
        // If the target is a Panel, then find all Panel objects that will
        // be affected by the animation.  Deliver a "resizeStart" event to 
        // each affected Panel, and then wait until the Panel finishes
        // hiding its children.
        // TODO: We should axe this from Resize and enable the
        // functionality in a different manner, such as setting hiding
        // effects manually on the children themselves
        var childrenHiding:Boolean = false; // hidePanelChildren();

        propertyValuesList = 
            [new PropertyValuesHolder("width", [widthFrom, widthTo]),
             new PropertyValuesHolder("height", [heightFrom, heightTo])];
                
        super.play();

        if (childrenHiding)
            animation.pause();
        
    }

    /**
     * Handles the end event from the tween. The value here is an Array of
     * values, one for each 'property' in our propertyValuesList.
     */
    override protected function endHandler(event:AnimationEvent):void
    {
        super.endHandler(event);

        restorePanelChildren();
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    private function calculateDimensionChanges():void
    {
        var explicitWidth:* = propertyChanges ? propertyChanges.end["explicitWidth"] : undefined;
        var explicitHeight:* = propertyChanges ? propertyChanges.end["explicitHeight"] : undefined;
        var percentWidth:* = propertyChanges ? propertyChanges.end["percentWidth"] : undefined;
        var percentHeight:* = propertyChanges ? propertyChanges.end["percentHeight"] : undefined;

        // The user may have supplied some combination of widthFrom,
        // widthTo, and widthBy. If either widthFrom or widthTo is
        // not explicitly defined, calculate its value based on the
        // other two values.
        if (isNaN(widthFrom))
        {
            if (!isNaN(widthTo) && !isNaN(widthBy))
                widthFrom = widthTo - widthBy;
            else if (propertyChanges && propertyChanges.start["width"] !== undefined)
                widthFrom = propertyChanges.start["width"];
            else
                widthFrom = getCurrentValue("width");
        }
        if (isNaN(widthTo))
        {       
            if (isNaN(widthBy) &&
                propertyChanges &&
                (propertyChanges.end["width"] !== undefined ||
                 explicitWidth !== undefined ))
            {
                if (explicitWidth !== undefined && !isNaN(explicitWidth))
                {
                    explicitWidthSet = true;
                    _widthTo = explicitWidth;
                }
                else
                {
                    _widthTo = propertyChanges.end["width"];
                }
            }
            else
            {
                _widthTo = (!isNaN(widthBy)) ?
                          widthFrom + widthBy :
                          getCurrentValue("width");
            }
        }

        // Ditto for heightFrom, heightTo, and heightBy.
        if (isNaN(heightFrom))
        {
            if (!isNaN(heightTo) && !isNaN(heightBy))
                heightFrom = heightTo - heightBy;
            else if (propertyChanges && propertyChanges.start["height"] != undefined)
                heightFrom = propertyChanges.start["height"];
            else
                heightFrom = getCurrentValue("height");
        }
        if (isNaN(heightTo))
        {       
            if (isNaN(heightBy) &&
                propertyChanges &&
                (propertyChanges.end["height"] !== undefined ||
                 explicitHeight !== undefined))
            {
                if (explicitHeight !== undefined && !isNaN(explicitHeight))
                {
                    explicitHeightSet = true;
                    _heightTo = explicitHeight;
                }
                else
                {
                    _heightTo = propertyChanges.end["height"];
                }
            }
            else
            {
                _heightTo = (!isNaN(heightBy))?
                           heightFrom + heightBy :
                           getCurrentValue("height");
            }
        }
    }

    /**
     *  @private
     *  Hides children of Panels while the effect is playing.
     */
    /*
    private function hidePanelChildren():Boolean
    {
        if (!hideChildrenTargets)
            return false;
            
        // Initialize a couple arrays that will be needed later
        restoreVisibleArray = [];
        restoreAutoLayoutArray = [];
        
        // Send each panel a "resizeStart" event, which will trigger
        // the resizeStartEffect (if any)
        var n:int = hideChildrenTargets.length;
        for (var i:int = 0; i < n; i++)
        {
            var p:Object = hideChildrenTargets[i];
            
            if (p is Panel)
            {
                var prevNumHideEffectsPlaying:Number = numHideEffectsPlaying;

                p.addEventListener(EffectEvent.EFFECT_START, panelChildrenEventHandler);             
                p.dispatchEvent(new Event("resizeStart"));
                p.removeEventListener(EffectEvent.EFFECT_START, panelChildrenEventHandler);

                // If no effect started playing, then make children invisible
                // immediately instead of waiting for the end of the effect
                if (numHideEffectsPlaying == prevNumHideEffectsPlaying)
                    makePanelChildrenInvisible(Panel(p), i);
            }
        }

        return numHideEffectsPlaying > 0;
    }
    */
    
    /**
     *  @private
     */
    /*
    private function makePanelChildrenInvisible(panel:Panel,
                                                panelIndex:Number):void
    {
        var childArray:Array = [];
        
        var child:IUIComponent;
        
        // Hide the Panel's children while the Resize is occurring.
        var n:int = panel.numItems;
        for (var i:int = 0; i < n; i++)
        {
            child = IUIComponent(panel.getItemAt(i));
            if (child.visible)
            {
                childArray.push(child);
                child.setVisible(false, true);
            }
        }
        
        // Hide the Panel's scrollbars while the Resize is occurring.
        //child = panel.horizontalScrollBar;
        if (child && child.visible)
        {
            childArray.push(child);
            child.setVisible(false, true);
        }
        //child = panel.verticalScrollBar;
        if (child && child.visible)
        {
            childArray.push(child);
            child.setVisible(false, true);
        }
        
        restoreVisibleArray[panelIndex] = childArray;

        // Set autoLayout = false, which prevents the Panel's updateDisplayList()
        // method from executing while the Panel is resizing.  
        //if (panel.autoLayout)
        //{
        //    panel.autoLayout = false;
        //    restoreAutoLayoutArray[panelIndex] = true;
        //}
    }    
    */
    
    /**
     *  @private
     */
    private function restorePanelChildren():void
    {
        if (hideChildrenTargets)
        {       
            var n:int = hideChildrenTargets.length;
            for (var i:int = 0; i < n; i++)
            {
                var p:IUIComponent = hideChildrenTargets[i];
                                
                var childArray:Array = restoreVisibleArray[i];
                if (childArray)
                {
                    var m:int = childArray.length;
                    for (var j:int = 0; j < m; j++)
                    {
                        childArray[j].setVisible(true, true);
                    }
                }
                
                //if (restoreAutoLayoutArray[i])
                    //Panel(p).autoLayout = true;
                    
                // Trigger the resizeEndEffect (if any) 
                p.dispatchEvent(new Event("resizeEnd")); 
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  This function is called when one of the Panels finishes
     *  its "hide children" animation. 
     */
    /*
    private function panelChildrenEventHandler(event:Event):void
    {
        var panel:Panel = event.target as Panel;

        if (event.type == EffectEvent.EFFECT_START)
        {
            // Call my eventHandler() method when the effect finishes playing.
            panel.addEventListener(EffectEvent.EFFECT_END, panelChildrenEventHandler);

            // Remember how many effects we're waiting for
            numHideEffectsPlaying++;                
        }

        else if (event.type == EffectEvent.EFFECT_END)
        {       
            // Remove the event listener that triggered this callback.
            panel.removeEventListener(EffectEvent.EFFECT_END, panelChildrenEventHandler);
            
            // Get the array index of the panel
            var n:int = hideChildrenTargets.length;
            for (var i:int = 0; i < n; i++)
            {
                if (hideChildrenTargets[i] == panel)
                    break;
            }
            
            makePanelChildrenInvisible(panel, i);

            // If all panels have finished their "hide children" effect,
            // then it's time to start our Resize effect.
            if (--numHideEffectsPlaying == 0)
                animation.resume();     
        } 
    }
    */
}
}
