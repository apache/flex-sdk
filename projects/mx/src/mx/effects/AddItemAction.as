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
import mx.effects.effectClasses.AddItemActionInstance;
import mx.controls.listClasses.ListBase;

use namespace mx_internal;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="duration", kind="property")]

/**
 *  The AddItemAction class defines an action effect that determines 
 *  when the item renderer appears in the control for an item being added 
 *  to a list-based control, such as List or TileList, 
 *  or for an item that replaces an existing item in the control.
 *  You can use this class as part of defining custom data effect for the 
 *  list-based classes.
 *   
 *  @mxml
 *
 *  <p>The <code>&lt;mx:AddItemAction&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds no new tag attributes:</p>
 *
 *  <pre>
 *  &lt;mx:AddItemAction
 *  /&gt;
 *  </pre>
 *
 *  @see mx.effects.effectClasses.AddItemActionInstance
 *
 *  @includeExample examples/AddItemActionEffectExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class AddItemAction extends Effect
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
    private static var AFFECTED_PROPERTIES:Array = [ "parent"];

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

//  public var effectHost:ListBase = null
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
    public function AddItemAction(target:Object = null)
    {
        super(target);
        duration = 0;
        instanceClass = AddItemActionInstance;
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
        
        var actionInstance:AddItemActionInstance  =
            AddItemActionInstance(instance);

//      actionInstance.effectHost = effectTargetHost;
    }

    // might be other methods we need to override here, but it's not at
    // all clear that they will be applicable.  
}

}
