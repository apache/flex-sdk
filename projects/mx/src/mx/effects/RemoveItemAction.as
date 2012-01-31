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

package mx.effects
{

import mx.core.mx_internal;
import mx.effects.effectClasses.PropertyChanges;
import mx.effects.effectClasses.RemoveItemActionInstance;
import mx.controls.listClasses.ListBase;

use namespace mx_internal;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="duration", kind="property")]

/**
 *  The RemoveItemAction class defines an action effect that determines 
 *  when the item renderer disappears from the control for the item renderer 
 *  of an item being removed from a list-based control, such as List or TileList, 
 *  or for an item that is replaced by a new item added to the control. 
 *  You can use this class as part of defining custom data effect for the 
 *  list-based classes.
 *   
 *  @mxml
 *
 *  <p>The <code>&lt;mx:RemoveItemAction&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds no new tag attributes:</p>
 *
 *  <pre>
 *  &lt;mx:RemoveItemAction
 *  /&gt;
 *  </pre>
 *
 *  @see mx.effects.effectClasses.RemoveItemActionInstance
 *
 *  @includeExample examples/AddItemActionEffectExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class RemoveItemAction extends Effect
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
    private static var AFFECTED_PROPERTIES:Array = ["parent"];

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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function RemoveItemAction(target:Object = null)
    {
        super(target);
        duration = 0;
        instanceClass = RemoveItemActionInstance;
    }
    
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
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);
        
        var actionInstance:RemoveItemActionInstance  =
            RemoveItemActionInstance(instance);

    }
}

}
