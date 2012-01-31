////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.effects
{

import flash.display.DisplayObjectContainer;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.mx_internal;
import spark.effects.supportClasses.AddActionInstance;
import mx.effects.IEffectInstance;
import mx.effects.Effect;
import mx.effects.effectClasses.PropertyChanges;

use namespace mx_internal;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="duration", kind="property")]

/**
 *  The AddAction class defines an action effect that corresponds
 *  to the <code>AddChild</code> property of a view state definition.
 *  You use an AddAction effect within a transition definition
 *  to control when the view state change defined by an AddChild property
 *  occurs during the transition.
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;s:AddAction&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:AddAction
 *    <b>Properties</b>
 *    id="ID"
 *    index="-1"
 *    position="index"
 *    relativeTo=""
 *  /&gt;
 *  </pre>
 *  
 *  @see spark.effects.supportClasses.AddActionInstance
 *  @see mx.states.AddChild
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class AddAction extends Effect
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
    
    /**
     * Constant used to specify the position to add the item relative to the
     * object specified by the <code>relativeTo</code> property.
     * 
     * @see #position
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public static const BEFORE:String = "before"; 
    /**
     * Constant used to specify the position to add the item relative to the
     * object specified by the <code>relativeTo</code> property.
     * 
     * @see #position
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public static const AFTER:String = "after"; 
    /**
     * Constant used to specify the position to add the item relative to the
     * object specified by the <code>relativeTo</code> property.
     * 
     * @see #position
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public static const FIRST_CHILD:String = "firstChild"; 
    /**
     * Constant used to specify the position to add the item relative to the
     * object specified by the <code>relativeTo</code> property.
     * 
     * @see #position
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public static const LAST_CHILD:String = "lastChild"; 
    /**
     * Constant used to specify the position to add the item relative to the
     * object specified by the <code>relativeTo</code> property.
     * 
     * @see #position
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public static const INDEX:String = "index";

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
    public function AddAction(target:Object = null)
    {
        super(target);
        duration = 0;
        instanceClass = AddActionInstance;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var localPropertyChanges:Array;
    
    //----------------------------------
    //  index
    //----------------------------------

    [Inspectable(category="General")]
    
    /** 
     *  The index of the child within the parent.
     *  A value of -1 means add the child as the last child of the parent.
     *
     *  @default -1
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var index:int = -1;
        
    //----------------------------------
    //  relativeTo
    //----------------------------------

    [Inspectable(category="General")]
    
    /** 
     *  The location where the child component is added.
     *  By default, Flex determines this value from the <code>AddChild</code>
     *  property definition in the view state definition.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var relativeTo:DisplayObjectContainer;
        
    //----------------------------------
    //  position
    //----------------------------------

    [Inspectable(category="General")]
    
    /** 
     *  The position of the child in the display list, relative to the
     *  object specified by the <code>relativeTo</code> property.
     *  Valid values are <code>AddAction.BEFORE</code>, <code>AddAction.AFTER</code>, 
     *  <code>AddAction.FIRST_CHILD</code>, <code>AddAction.LAST_CHILD</code>, 
     *  and <code>AddAction.INDEX</code>, where <code>AddAction.INDEX</code> 
     *  specifies the use of the <code>index</code> property 
     *  to determine the position of the child.
     *
     *  @default AddAction.INDEX
     *  @see #BEFORE
     *  @see #AFTER
     *  @see #FIRST_CHILD
     *  @see #LAST_CHILD
     *  @see #INDEX
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var position:String = INDEX;
    
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
    private function getPropertyChanges(target:Object):PropertyChanges
    {
        for (var i:int = 0; i < localPropertyChanges.length; i++)
        {
            if (localPropertyChanges[i].target == target)
                return localPropertyChanges[i];
        }
        
        return null;
    }
    
    /**
     *  @private
     */
    private function targetSortHandler(first:Object, second:Object):Number
    {
        var p1:PropertyChanges = getPropertyChanges(first);
        var p2:PropertyChanges = getPropertyChanges(second);
        
        if (p1 && p2)
        {
            if (p1.start.index > p2.start.index)
                return 1;
            else if (p1.start.index < p2.start.index)
                return -1;
        }
        
        return 0;
    }

    /**
     *  @private
     */
    override public function createInstances(targets:Array = null):Array /* of EffectInstance */
    {
        if (!targets)
            targets = this.targets;
            
        if (targets && propertyChangesArray)
        {
            localPropertyChanges = propertyChangesArray;
            targets.sort(targetSortHandler);
        }
        
        return super.createInstances(targets);
    }

    /**
     *  @private
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);
        
        var actionInstance:AddActionInstance =
            AddActionInstance(instance);

        actionInstance.relativeTo = relativeTo;
        actionInstance.index = index;
        actionInstance.position = position;
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
                    IVisualElementContainer(container).getElementIndex(target as IVisualElement) : 
                    container.getChildIndex(target)) 
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
        if (property == "parent" && value == undefined)
        {
            if (target.parent)
            {
                // FIXME (chaase): workaround for current situation of mis-match between
                // Group having 'item's and Flex3 components having 'parent's
                if (target.parent is IVisualElementContainer)
                    IVisualElementContainer(target.parent).removeElement(target as IVisualElement);
                else
                    target.parent.removeChild(target);
            }
        }
        // Ignore index - it's applied along with parent
    }
}

}
