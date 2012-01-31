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
import mx.controls.listClasses.ListBase;
import mx.effects.effectClasses.UnconstrainItemActionInstance;

use namespace mx_internal;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="duration", kind="property")]

/**
 *  The UnconstrainItemAction class defines an action effect that
 *  is used in a data-effect definition
 *  to temporarily stop item renderers from being positioned by the
 *  layout algorithm of the parent control. This effect can be used
 *  to allow item renderers in a TileList control to move freely
 *  rather than being constrained to lay in the normal grid defined by the control.
 *  The default data effect class for the TileList control, DefaultTileListEffect, 
 *  uses this effect.
 *
 *  <p>You typically add this effect when your custom data effect moves item renderers.</p>
 *   
 *  @mxml
 *
 *  <p>The <code>&lt;mx:UnconstrainItemAction&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds no new tag attributes:</p>
 *
 *  <pre>
 *  &lt;mx:UnconstrainItemAction
 *  /&gt;
 *  </pre>
 *
 *  @see mx.effects.effectClasses.UnconstrainItemActionInstance
 *  @see mx.effects.DefaultTileListEffect
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class UnconstrainItemAction extends Effect
{
    include "../core/Version.as";

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
    public function UnconstrainItemAction(target:Object = null)
    {
        super(target);
        duration = 0;
        instanceClass = UnconstrainItemActionInstance;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);
        
        var actionInstance:UnconstrainItemActionInstance  =
            UnconstrainItemActionInstance(instance);

    }
}

}
