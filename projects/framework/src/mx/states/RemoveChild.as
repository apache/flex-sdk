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
public class RemoveChild extends OverrideBase 
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
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function apply(parent:UIComponent):void
    {
        parentContext = parent;
        removed = false;
        
        var obj:* = getOverrideContext(target, parent);
        if ((obj is DisplayObject) && obj.parent)
        {
            oldParent = obj.parent;
            oldIndex = oldParent.getChildIndex(obj);
            oldParent.removeChild(obj);
            removed = true;
        }
        else if (obj == null && !applied)
        {
            // Our target context is unavailable so we attempt to register
            // a listener on our parent document to detect when/if it becomes
            // valid.
            addContextListener(target); 
        }
        
        // Save state in case our value or target is changed while applied. This
        // can occur when our value property is databound or when a target is 
        // deferred instantiated.
        applied = true;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function remove(parent:UIComponent):void
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
        else if (obj == null)
        {
            // It seems our override is no longer active, but we were never
            // able to successfully apply ourselves, so remove our context
            // listener if applicable.
            removeContextListener();
        }
        
        // Clear our flags and override context.
        applied = false;
        parentContext = null;
    }
}

}
