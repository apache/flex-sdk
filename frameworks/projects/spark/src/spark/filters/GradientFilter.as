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

package spark.filters
{
    
import flash.events.Event;  
import flash.events.EventDispatcher;
import flash.filters.BitmapFilter;
import flash.filters.BitmapFilterType;
import flash.filters.GradientBevelFilter;

import mx.core.mx_internal;
import mx.events.PropertyChangeEvent;
import mx.filters.BaseDimensionFilter;
import mx.graphics.GradientEntry;

use namespace mx_internal;

[DefaultProperty("entries")]

/**
 * The base class for filters that provide gradient visual effects.
 * 
 *  @mxml 
 *  <p>The <code>&lt;s:GradientFilter&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:GradientFilter
 *    <strong>Properties</strong>
 *    angle="45"
 *    disatance="4.0"
 *    entries="[]"
 *    type="inner"
 *  /&gt;
 *  </pre>
 *
 * @langversion 3.0
 * @playerversion Flash 10
 * @playerversion AIR 1.5
 * @productversion Flex 4
 *
 */
public class GradientFilter extends BaseDimensionFilter
{
    /**
     * Constructor.
     *
     * @param colors An array of RGB hexadecimal color values to use in the gradient.
     * For example, red is 0xFF0000, blue is 0x0000FF, and so on.
     * @param alphas An array of alpha transparency values for the corresponding colors in
     * the <code>colors</code> array. Valid values for each element in the array are 0 to 1.
     * For example, .25 sets a transparency value of 25%.
     * @param ratios An array of color distribution ratios; valid values are
     * 0 to 255.
     *
     * @langversion 3.0
     * @playerversion Flash 10
     * @playerversion AIR 1.5
     * @productversion Flex 4
     *
     */
    public function GradientFilter(colors:Array = null, 
                                   alphas:Array = null,
                                   ratios:Array = null)
    {
        super();
        
        var newEntries:Array = [];
        var colorsLen:int = colors ? colors.length : 0;
        var alphasLen:int = alphas ? alphas.length : 0;
        var ratiosLen:int = ratios ? ratios.length : 0;
        var maxLen:int = Math.max(colorsLen, alphasLen, ratiosLen);
        
        for (var i:int = 0; i < maxLen; i++)
        {
            var newEntry:GradientEntry = new GradientEntry();
            if (colorsLen > i)
                newEntry.color = colors[i];
            if (alphasLen > i)
                newEntry.alpha = alphas[i];
            if (ratiosLen > i)
                newEntry.ratio = ratios[i];
            
            newEntries.push(newEntry);
        }
        
        entries = newEntries;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    mx_internal var colors:Array /* of uint */ = [];

    /**
     *  @private
     */
    mx_internal var ratios:Array /* of Number */ = [];

    /**
     *  @private
     */
    mx_internal var alphas:Array /* of Number */ = [];
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  angle
    //----------------------------------
    
    private var _angle:Number = 45;
    
    [Inspectable(minValue="0.0", maxValue="360.0")]    
    
    /**
     *  The angle, in degrees. Valid values are 0 to 360. 
     *  The angle value represents the angle of the theoretical light source
     *  falling on the object and determines the placement of the effect 
     *  relative to the object. If distance is set to 0, the effect is not 
     *  offset from the object, and therefore the angle property has no effect.
     *
     *  @default 45
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get angle():Number
    {
        return _angle;
    }
    
    public function set angle(value:Number):void
    {
        if (value != _angle)
        {
            _angle = value;
            notifyFilterChanged();
        }
    }
    
    //----------------------------------
    //  distance
    //----------------------------------
    
    private var _distance:Number = 4.0;
    
    /**
     *  The offset distance of the glow. 
     *
     *  @default 4.0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get distance():Number
    {
        return _distance;
    }
    
    public function set distance(value:Number):void
    {
        if (value != _distance)
        {
            _distance = value;
            notifyFilterChanged();
        }
    }
    
    //----------------------------------
    //  entries
    //----------------------------------

    /**
     *  @private
     *  Storage for the entries property.
     */
    private var _entries:Array = [];
    
    [Bindable("propertyChange")]
    [Inspectable(category="General", arrayType="mx.graphics.GradientEntry")]

    /**
     *  An Array of GradientEntry objects
     *  defining the fill patterns for the gradient fill.
     *
     *  @default []
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get entries():Array
    {
        return _entries;
    }

    /**
     *  @private
     */
    public function set entries(value:Array):void
    {
        var oldValue:Array = _entries;
        _entries = value;
        
        processEntries();
        notifyFilterChanged();
        //dispatchGradientChangedEvent("entries", oldValue, value);
    }
        
    //----------------------------------
    //  type
    //----------------------------------
    
    private var _type:String = BitmapFilterType.INNER;
    
    /**
     *  The placement of the filter effect. Possible values are 
     *  flash.filters.BitmapFilterType constants:
     *  <ul>
     *    <li><code>BitmapFilterType.OUTER</code> - Glow on the outer edge of the object.</li>
     *    <li><code>BitmapFilterType.INNER</code> - Glow on the inner edge of the object.</li>
     *    <li><code>BitmapFilterType.FULL</code> - Glow on top of the object.</li>
     *  </ul>
     *
     *  @default BitmapFilterType.INNER
     *
     *  @see flash.filters.BitmapFilterType
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get type():String
    {
        return _type;
    }
    
    public function set type(value:String):void
    {
        if (value != _type)
        {
            _type = value;
            notifyFilterChanged();
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Extract the gradient information in the public <code>entries</code>
     *  Array into the internal <code>colors</code>, <code>ratios</code>,
     *  and <code>alphas</code> arrays.
     */
    private function processEntries():void
    {
        colors = [];
        ratios = [];
        alphas = [];

        if (!_entries || _entries.length == 0)
            return;

        var ratioConvert:Number = 255;

        var i:int;
        
        var n:int = _entries.length;
        for (i = 0; i < n; i++)
        {
            var e:GradientEntry = _entries[i];
            e.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, 
                               entry_propertyChangeHandler, false, 0, true);
            colors.push(e.color);
            alphas.push(e.alpha);
            ratios.push(e.ratio * ratioConvert);
        }
        
        if (isNaN(ratios[0]))
            ratios[0] = 0;
            
        if (isNaN(ratios[n - 1]))
            ratios[n - 1] = 255;
        
        i = 1;

        while (true)
        {
            while (i < n && !isNaN(ratios[i]))
            {
                i++;
            }

            if (i == n)
                break;
                
            var start:int = i - 1;
            
            while (i < n && isNaN(ratios[i]))
            {
                i++;
            }
            
            var br:Number = ratios[start];
            var tr:Number = ratios[i];
            
            for (var j:int = 1; j < i - start; j++)
            {
                ratios[j] = br + j * (tr - br) / (i - start);
            }
        }
    }
        
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function entry_propertyChangeHandler(event:Event):void
    {
        processEntries();

        //dispatchGradientChangedEvent("entries", entries, entries);
    }
}
}