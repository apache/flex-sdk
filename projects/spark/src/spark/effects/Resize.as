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
package mx.effects
{
import mx.effects.effectClasses.FxResizeInstance;

import mx.effects.IEffectInstance;
    
public class FxResize extends FxAnimate
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
        ["left", "right", "top", "bottom"];

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param target The Object to animate with this effect.
     */
    public function FxResize(target:Object=null)
    {
        super(target);

        instanceClass = FxResizeInstance;
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
     */
    public var heightBy:Number;
    
    //----------------------------------
    //  heightFrom
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Initial height, in pixels.
     *  If omitted, Flex uses the current height.
     */
    public var heightFrom:Number;

    //----------------------------------
    //  heightTo
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Final height, in pixels.
     */
    public var heightTo:Number;
            
    //----------------------------------
    //  widthBy
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Number of pixels by which to modify the width of the component.
     *  Values may be negative.
     */
    public var widthBy:Number;

    //----------------------------------
    //  widthFrom
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Initial width, in pixels.
     *  If omitted, Flex uses the current width.
     */
    public var widthFrom:Number;
    
    //----------------------------------
    //  widthTo
    //----------------------------------

    [Inspectable(category="General", defaultValue="NaN")]

    /** 
     *  Final width, in pixels.
     */
    public var widthTo:Number;

    //----------------------------------
    //  hideChildrenTargets
    //----------------------------------

    // TODO: We should axe this from Resize and enable the
    // functionality in a different manner, such as setting hiding
    // effects manually on the children themselves
    /**
     *  An Array of Panel containers.
     *  The children of these Panel containers are hidden while the Resize
     *  effect plays.
     *
     *  <p>You use data binding syntax to set this property in MXML, 
     *  as the following example shows, where panelOne and panelTwo 
     *  are the names of two Panel containers in your application:</p>
     *
     *  <pre>&lt;mx:Resize id="e" heightFrom="100" heightTo="400"
     *  hideChildrenTargets="{[panelOne, panelTwo]}" /&gt;</pre>        
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
        
        var resizeInstance:FxResizeInstance = FxResizeInstance(instance);

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
        resizeInstance.hideChildrenTargets = hideChildrenTargets;
    }
}
}