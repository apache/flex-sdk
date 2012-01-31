////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.effects
{
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.mx_internal;
import mx.effects.Effect;
import mx.effects.effectClasses.PropertyChanges;
import spark.effects.supportClasses.RemoveActionInstance;

use namespace mx_internal;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="duration", kind="property")]

/**
 *  The RemoveAction class defines an action effect that corresponds
 *  to the RemoveChild property of a view state definition.
 *  You use a RemoveAction effect within a transition definition
 *  to control when the view state change defined by a RemoveChild property
 *  occurs during the transition.
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;s:RemoveAction&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>

 *  <pre>
 *  &lt;s:RemoveAction
 *    <b>Properties</b>
 *    id="ID"
 *  /&gt;
 *  </pre>
 *  
 *  @see spark.effects.supportClasses.RemoveActionInstance
 *  @see mx.states.RemoveChild
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class RemoveAction extends Effect
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
    private static var AFFECTED_PROPERTIES:Array = [ "parent", "index" ];

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
    public function RemoveAction(target:Object = null)
    {
        super(target);
        duration = 0;
        instanceClass = RemoveActionInstance;
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
    private function propChangesSortHandler(
                    first:PropertyChanges, 
                    second:PropertyChanges):Number
    {
        if (first.start.index > second.start.index)
            return 1;
        else if (first.start.index < second.start.index)
            return -1;
        
        return 0;
    }
    
    /**
     *  @private
     */
    override mx_internal function applyStartValues(propChanges:Array,
                                              targets:Array):void
    {
        if (propChanges)
            propChanges.sort(propChangesSortHandler);
        
        super.applyStartValues(propChanges, targets);
    }
    
    /**
     *  @private
     */
    override protected function getValueFromTarget(target:Object,
                                                   property:String):*
    {
        var container:* = target.parent;
        if (property == "index")
            return container ? 
                    ((container is IVisualElementContainer) ? 
                    IVisualElementContainer(container).getElementIndex(target as IVisualElement) : container.getChildIndex(target))
                : 0;
        
        return super.getValueFromTarget(target, property);
    }
    
    /**
     *  @private
     */ 
    override protected function applyValueToTarget(target:Object,
                                                   property:String, 
                                                   value:*,
                                                   props:Object):void
    {
        if (property == "parent" && value)
        {
            if (target.parent == null)
            {
                // FIXME (chaase): workaround for current situation of mis-match between
                // Group having 'item's and Flex3 components having 'parent's
                if (value is IVisualElementContainer)
                    IVisualElementContainer(value).addElementAt(target as IVisualElement, Math.min(props.index, 
                        IVisualElementContainer(value).numElements));
                else
                    value.addChildAt(target, Math.min(props.index, 
                        value.numChildren));
            }
        }
        
        // Ignore index - it's applied along with parent
    }
}

}
