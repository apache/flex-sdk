////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
package spark.collections
{
import flash.events.Event;

import mx.collections.IList;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;
import mx.utils.OnDemandEventDispatcher;

/**
 *  This IList class generates items that are a sequential series of numbers.
 *  The numbers range between the <code>minimum</code> and <code>maximum</code>
 *  properties. The <code>stepSize</code> property defines the difference between
 *  an item and the next item.
 * 
 * <p>This class is used primarily as a data provider for the SpinnerList control; for example:</p>
 * <pre>
 * &lt;s:SpinnerList&gt;
 *   &lt;s:dataProvider&gt;
 *     &lt;s:NumericDataProvider minimum="0" maximum="23" stepSize="1"/&gt;
 *   &lt;/s:dataProvider&gt;
 * &lt;/s:SpinnerList&gt; 
 * </pre>
 * 
 *  <p>The advantage of this class is that the item values are calculated on demand,
 *  instead of stored.</p>
 * 
 *  <p>Because the values are calculated instead of stored, the <code>addItem()</code>, <code>addItemAt()</code>, 
 *  <code>removeAll()</code>, <code>removeItemAt()</code>, <code>itemUpdated()</code> and <code>setItemAt()</code> IList methods are not
 *  supported.</p>
 *    
 *  @see spark.components.SpinnerList
 *  @see mx.collections.IList
 *
 *  @langversion 3.0
 *  @playerversion Flash 11
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
public class NumericDataProvider extends OnDemandEventDispatcher implements IList
{
    //----------------------------------------------------------------------------------------------
    //
    //  Constructor
    //
    //----------------------------------------------------------------------------------------------
    
    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function NumericDataProvider()
    {
        super();
    }
    
    
    //----------------------------------------------------------------------------------------------
    //
    //  Variables
    //
    //----------------------------------------------------------------------------------------------
    
    /**
     *  @private
     *  Used for accessing localized Error messages.
     */
    private var resourceManager:IResourceManager =
        ResourceManager.getInstance();
    
    //----------------------------------------------------------------------------------------------
    //
    //  Properties
    //
    //----------------------------------------------------------------------------------------------
    
    //----------------------------------
    //  length
    //----------------------------------
    /**
     *  @inheritDoc 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public function get length():int
    {
        normalizeMinMax();
        return (_maximum - _minimum) / Math.abs(stepSize) + 1;
    }
    
    //----------------------------------
    //  maximum
    //----------------------------------
    
    private var _maximum:Number = 100;
    
    /**
     *  The value of the last item. This value must be
     *  larger than the minimum value. 
     * 
     *  @default 100
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function get maximum():Number
    {
        normalizeMinMax();
        return _maximum;
    }
    
    /**
     *  @private
     */
    public function set maximum(value:Number):void
    {
        if (_maximum == value)
            return;
        
        _maximum = value;
        
        reset();
    }
    
    //----------------------------------
    //  minimum
    //----------------------------------
    
    private var _minimum:Number = 0;
    
    /**
     *  The value of the first item. This value must be
     *  smaller than the minimum value. 
     * 
     *  @default 0
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function get minimum():Number
    {
        normalizeMinMax();
        return _minimum;
    }
    
    public function set minimum(value:Number):void
    {
        if (_minimum == value)
            return;
        
        _minimum = value;
        
        reset();
    }
    
    //----------------------------------
    //  stepSize
    //----------------------------------
    
    private var _stepSize:Number = 1;
    
    /**
     *  The stepSize property controls the values of items between the first and last items.
     * 
     *  For each item, the value is calculated as the sum of the <code>minimum</code> 
     *  and the item's index multiplied by this property. 
     * 
     *  <p>For example, if <code>minimum</code> is 10, <code>maximum</code> is 20, and this property is 3, then the
     *  item values of this data provider are 10, 13, 16, 19, and 20.</p>
     * 
     *  @default 1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function get stepSize():Number
    {
        return _stepSize;
    }
    
    public function set stepSize(value:Number):void
    {
        if (_stepSize == value)
            return;
        
        if (value == 0)
        {
            var message:String = resourceManager.getString(
                "collections", "stepSizeError");
            throw new Error(message);
        }
        
        _stepSize = value;
        
        reset();
    }
    
    //----------------------------------------------------------------------------------------------
    //
    //  Interface Methods
    //
    //----------------------------------------------------------------------------------------------
    
    /**
     *  This function is not supported.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public function addItem(item:Object):void
    {
        var message:String = resourceManager.getString(
            "collections", "addItemError");
        throw new Error(message);
    }
    
    /**
     *  This function is not supported.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public function addItemAt(item:Object, index:int):void
    {
        var message:String = resourceManager.getString(
            "collections", "addItemAtError");
        throw new Error(message);
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public function getItemAt(index:int, prefetch:int=0):Object
    {
        if (index < 0 || index >= length)
        {
            var message:String = resourceManager.getString(
                "collections", "outOfBounds", [ index ]);
            throw new RangeError(message);
        }
        
        var scale:Number = 1;
        var value:Number;
        var scaledStepSize:Number = stepSize;
        var baseValue:Number = stepSize > 0 ? minimum : maximum;
        
        // If stepSize isn't an integer, there's a possibility that the floating point 
        // approximation of value will be slightly larger or smaller 
        // than the real value.  This can lead to errors in calculations like 
        // index * stepSize. To avoid problems, we scale by the implicit precision 
        // of the stepSize and then round. For example if stepSize=0.01, then 
        // we scale by 100.   
        // TODO (jszeto) Refactor into a util class?
        if (stepSize != Math.round(stepSize)) 
        { 
            const parts:Array = (new String(1 + stepSize)).split("."); 
            scale = Math.pow(10, parts[1].length);
            scaledStepSize = Math.round(stepSize * scale);
            
            value = Math.round(index * scaledStepSize) / scale; 
        }   
        else
        {
            value = index * stepSize;
        }        
            
        return Math.min(Math.max(value + baseValue, minimum), maximum);
    }
    
    /**
     *  @inheritDoc 
     */ 
    public function getItemIndex(item:Object):int
    {
        // Calculate the index by subtracting the item from the minimum and
        // dividing by the stepSize. Make sure the index is between
        // 0 and length - 1.
        var baseValue:Number = stepSize > 0 ? minimum : maximum;
        
        return Math.max(Math.min((Number(item) - baseValue) / stepSize, length - 1), 0);
    }
    
    /**
     *  This function is not supported.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public function itemUpdated(item:Object, property:Object=null, oldValue:Object=null, newValue:Object=null):void
    {
        var message:String = resourceManager.getString(
            "collections", "itemUpdatedError");
        throw new Error(message);
    }
    
    /**
     *  This function is not supported.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public function removeAll():void
    {
        var message:String = resourceManager.getString(
            "collections", "removeAllError");
        throw new Error(message);
    }
    
    /**
     *  This function is not supported.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public function removeItemAt(index:int):Object
    {
        var message:String = resourceManager.getString(
            "collections", "removeItemAtError");
        throw new Error(message);
        return null;
    }
    
    /**
     *  This function is not supported.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public function setItemAt(item:Object, index:int):Object
    {
        var message:String = resourceManager.getString(
            "collections", "setItemAtError");
        throw new Error(message);
        return null;
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public function toArray():Array
    {
        var result:Array = [];
        var numItems:int = length;
        var baseValue:Number = stepSize > 0 ? minimum : maximum;
        
        // TODO (jszeto) Add in floating point error logic
        for (var i:int = 0; i < numItems; i++)
            result.push(Math.min(Math.max(baseValue + (i * stepSize), minimum), maximum));
        return result;
    }
    
    //----------------------------------------------------------------------------------------------
    //
    //  Functions
    //
    //----------------------------------------------------------------------------------------------
    
    private function normalizeMinMax():void
    {
        if (_minimum > _maximum)
            _maximum = _minimum;
    }
    
    private function reset():void
    {
        // Easier to just reset the collection instead of 
        // calculating the delta of which items have been
        // added, removed or updated
        var event:CollectionEvent =
            new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
        event.kind = CollectionEventKind.RESET;
        dispatchEvent(event);
    }
}
    
}