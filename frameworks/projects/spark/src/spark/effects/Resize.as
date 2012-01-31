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
package spark.effects
{
import mx.core.mx_internal;
import mx.effects.IEffectInstance;

import spark.effects.supportClasses.ResizeInstance;

use namespace mx_internal;

/**
 *  The Resize effect changes the width, height, or both dimensions
 *  of a component over a specified time interval. 
 *  
 *  <p>If you specify only two of the three values of the
 *  <code>widthFrom</code>, <code>widthTo</code>, and
 *  <code>widthBy</code> properties, Flex calculates the third.
 *  If you specify all three, Flex ignores the <code>widthBy</code> value.
 *  If you specify only the <code>widthBy</code> or the
 *  <code>widthTo</code> value, the <code>widthFrom</code> property
 *  is set to be the object's current width.
 *  The same is true for <code>heightFrom</code>, <code>heightTo</code>,
 *  and <code>heightBy</code> property values.</p>
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;s:Resize&gt;</code> tag
 *  inherits all of the tag attributes of its superclass, 
 *  and adds the following tab attributes:</p>
 *  
 *  <pre>
 *  &lt;s:Resize
 *    id="ID"
 *    widthFrom="val"
 *    heightFrom="val"
 *    widthTo="val"
 *    heightTo="val"
 *    widthBy="val"
 *    heightBy="val"
 *  /&gt;
 *  </pre>
 *
 *  @see spark.effects.supportClasses.ResizeInstance
 *
 *  @includeExample examples/ResizeEffectExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Resize extends Animate
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static var AFFECTED_PROPERTIES:Array =
    [
        "width", "height",
        "explicitWidth", "explicitHeight",
        "percentWidth", "percentHeight",
        "left", "right", "top", "bottom"
    ];
    private static var RELEVANT_STYLES:Array = 
        ["left", "right", "top", "bottom", "percentWidth", "percentHeight"];

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param target The Object to animate with this effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function Resize(target:Object=null)
    {
        super(target);

        instanceClass = ResizeInstance;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  heightBy
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Number of pixels by which to modify the height of the component.
     *  Values may be negative.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var heightBy:Number;
    
    //----------------------------------
    //  heightFrom
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Initial height, in pixels.
     *  If omitted, Flex uses the current height of the target.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var heightFrom:Number;

    //----------------------------------
    //  heightTo
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Final height of the target, in pixels.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var heightTo:Number;
            
    //----------------------------------
    //  widthBy
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Number of pixels by which to modify the width of the target.
     *  Values may be negative.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var widthBy:Number;

    //----------------------------------
    //  widthFrom
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Initial width of the target, in pixels.
     *  If omitted, Flex uses the current width.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var widthFrom:Number;
    
    //----------------------------------
    //  widthTo
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Final width of the target, in pixels.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var widthTo:Number;

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function getAffectedProperties():Array /* of String */
    {
        return AFFECTED_PROPERTIES;
    }

    /**
     *  @private
     */
    override public function get relevantStyles():Array /* of String */
    {
        return RELEVANT_STYLES;
    }   

    /**
     *  @private
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);
        
        var resizeInstance:ResizeInstance = ResizeInstance(instance);

        if (!isNaN(widthFrom))
            resizeInstance.widthFrom = widthFrom;
        if (!isNaN(widthTo))
            resizeInstance.widthTo = widthTo;
        if (!isNaN(widthBy))
            resizeInstance.widthBy = widthBy;
        if (!isNaN(heightFrom))
            resizeInstance.heightFrom = heightFrom;
        if (!isNaN(heightTo))
            resizeInstance.heightTo = heightTo;
        if (!isNaN(heightBy))
            resizeInstance.heightBy = heightBy;
    }
    
    /**
     * @private
     * Tell the propertyChanges array to keep all values, unchanged or not.
     * This enables us to check later, when the effect is finished, whether
     * we need to restore explicit height/width values.
     */
    override mx_internal function captureValues(propChanges:Array,
        setStartValues:Boolean, targetsToCapture:Array = null):Array
    {
        var propertyChanges:Array = super.captureValues(propChanges, setStartValues);
        
        if (setStartValues)
        {
            var n:int = propertyChanges.length;
            for (var i:int = 0; i < n; i++)
            {
                if (targetsToCapture == null || targetsToCapture.length == 0 ||
                    targetsToCapture.indexOf(propertyChanges[i].target) >= 0)
                {
                    propertyChanges[i].stripUnchangedValues = false;
                }
            }
        }
        return propertyChanges;
    }
    
    /**
     * @private
     * When we're done, check to see whether explicitWidth/Height values
     * for the target were NaN in the start state. If so, we should restore
     * them to that value. This ensures that the target will be sized by
     * its layout manager instead of by the width/height that we set during
     * the Resize.
     */
    override mx_internal function applyEndValues(propChanges:Array,
        targets:Array):void
    {
        super.applyEndValues(propChanges, targets);
        // Special case for Resize - since we use width/height during the effect,
        // we may have clobbered the explicitWidth/Height values which otherwise 
        // would not have been set. We need to restore these values plus any
        // associated layout constraint values (percentWidth/Height)
        // Note that this approach assumes that stripUnchangedValues on propChanges
        // is false (which should be the case for Resize targets), otherwise
        // unchanging explicit values would not be in propChanges and we would
        // not restore them correctly.
        if (propChanges)
        {
            var n:int = propChanges.length;
            for (var i:int = 0; i < n; i++)
            {
                var target:Object = propChanges[i].target;
                if (propChanges[i].end["explicitWidth"] !== undefined)
                {
                    if (isNaN(propChanges[i].end["explicitWidth"]) && 
                        "explicitWidth" in target)
                    {
                        target.explicitWidth = NaN;
                        if (propChanges[i].end["percentWidth"] !== undefined && 
                            "percentWidth" in target)
                        {
                            target.percentWidth = propChanges[i].end["percentWidth"];
                        }
                    }
                }
                if (propChanges[i].end["explicitHeight"] !== undefined)
                {
                    if (isNaN(propChanges[i].end["explicitHeight"]) && 
                        "explicitHeight" in target)
                    {
                        target.explicitHeight = NaN;
                        if (propChanges[i].end["percentHeight"] !== undefined && 
                            "percentHeight" in target)
                        {
                            target.percentHeight = propChanges[i].end["percentHeight"];
                        }
                    }
                }
            }
        }
    }
                                                     
}
}
