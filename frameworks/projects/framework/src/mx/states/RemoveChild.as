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

package mx.states
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import mx.core.UIComponent;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 *
 *  The RemoveChild class removes a child display object, such as a component, 
 *  from a container as part of a view state.
 *  The child is only removed from the display list, it is not deleted.
 *  You use this class in the <code>overrides</code> property of the State class.
 *
 *  @mxml
 *
 *  <p>The <code>&lt;mx:RemoveChild&gt;</code> tag
 *  has the following attributes:</p>
 *  
 *  <pre>
 *  &lt;mx:RemoveChild
 *  <b>Properties</b>
 *  target="null"
 *  /&gt;
 *  </pre>
 *
 *  @see mx.states.State
 *  @see mx.states.AddChild
 *  @see mx.states.Transition
 *  @see mx.effects.RemoveChildAction
 *
 *  @includeExample examples/StatesExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class RemoveChild extends OverrideBase implements IOverride
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
     *  @param target The child to remove from the view.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function RemoveChild(target:DisplayObject = null)
    {
        super();

        this.target = target;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Parent of the removed child.
     */
    private var oldParent:DisplayObjectContainer;

    /**
     *  @private
     *  Index of the removed child.
     */
    private var oldIndex:int;
    
    /**
     *  @private
     */
    private var removed:Boolean;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  target
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  The child to remove from the view.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var target:Object;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  IOverride interface method; this class implements it as an empty method.
     * 
     *  @copy IOverride#initialize()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function initialize():void
    {
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function apply(parent:UIComponent):void
    {
        removed = false;
        
        var obj:* = getOverrideContext(target, parent);
        
        if ((obj is DisplayObject) && obj.parent)
        {
            oldParent = obj.parent;
            oldIndex = oldParent.getChildIndex(obj);
            oldParent.removeChild(obj);
            removed = true;
        }
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function remove(parent:UIComponent):void
    {
        var obj:* = getOverrideContext(target, parent);
        
        if (removed && (obj is DisplayObject))
        {
            oldParent.addChildAt(obj, oldIndex);

            // Make sure any changes made while the child was removed are reflected
            // properly.
            if (obj is UIComponent)
                UIComponent(target).updateCallbacks();

            removed = false;
        }
    }
}

}
