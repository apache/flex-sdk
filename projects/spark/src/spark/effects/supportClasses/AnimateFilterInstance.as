////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package spark.effects.supportClasses
{
    
import mx.filters.IBitmapFilter;
import spark.effects.AnimateFilter;

/**
 * The AnimateFilterInstance class implements the instance class for the
 * AnimateFilter effect. Flex creates an instance of this class when
 * it plays a AnimateFilter effect; you do not create one yourself.
 *
 *  @see spark.effects.AnimateFilter
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class AnimateFilterInstance extends AnimateInstance
{
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
    public function AnimateFilterInstance(target:Object)
    {
        super(target);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  bitmapFilter
    //----------------------------------
    
    /**
     *  @copy spark.effects.AnimateFilter#bitmapFilter
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */  
    public var bitmapFilter:IBitmapFilter;
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     */
    override public function play():void
    {
        // Apply our filter instance.
        var filters:Array = target.filters;
        filters.push(bitmapFilter);
        target.filters = filters;
        super.play();
    }
    
    
    /**
     * @private
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override public function finishEffect():void
    {   
        // Locate and remove our filter instance
        var filters:Array = target.filters;
        for (var i:int = 0; i < filters.length; i++)
        {
            if (filters[i] == bitmapFilter)
            {
                filters.splice(i, 1);
                break;
            }
        }
        
        // Refresh filter stack.
        target.filters = filters;
        
        super.finishEffect();
    }       
        
    /**
     * Unlike Animate's setValue we assign the new value to the filter
     * associated with our effect instance rather than the target of 
     * the effect. 
     *  
     * @private
     */
    override protected function setValue(property:String, value:Object):void
    {
        bitmapFilter[property] = value;
    }

    /**
     * Unlike Animate's getValue we return the value of the property requested
     * from the filter associated with our effect instance rather than 
     * the effect target.
     *  
     * @private
     */
    override protected function getCurrentValue(property:String):*
    {
        return bitmapFilter[property];
    }
    
    /**
     * Override FXAnimate's setupStyleMapEntry to avoid the need to 
     * validate our properties against the 'target' (since we actually
     * set properties on our associated filter instance).
     *  
     * @private
     */
    override protected function setupStyleMapEntry(property:String):void
    {
    }
}

}