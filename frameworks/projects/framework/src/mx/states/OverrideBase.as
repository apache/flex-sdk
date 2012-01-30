////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.states
{
    
import mx.core.UIComponent;
import mx.events.PropertyChangeEvent;
import mx.utils.OnDemandEventDispatcher;

/**
 *  The OverrideBase class is the base class for the 
 *  override classes used by view states. 
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OverrideBase extends OnDemandEventDispatcher implements IOverride
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function OverrideBase() {}

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Flag which tracks if we're actively overriding a property.
     */
    protected var applied:Boolean = false;
    
    /**
     *  @private
     *  Our most recent parent context.
     */
    protected var parentContext:UIComponent;
    
    /**
     *  @private
     */  
    private var targetProperty:String;
    
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
    public function initialize():void {}
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function apply(parent:UIComponent):void {}
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function remove(parent:UIComponent):void {}
    
    /**
     * @private 
     * Initialize this object from a descriptor.
     */
    public function initializeFromObject(properties:Object):Object
    {
        for (var p:String in properties)
        {
            this[p] = properties[p];
        }
        
        return Object(this);
    }
    
    /**
     * @private
     * @param parent The document level context for this override.
     * @param target The component level context for this override.
     */
    protected function getOverrideContext(target:Object, parent:UIComponent):Object
    {
        if (target == null)
            return parent;
    
        if (target is String)
            return parent[target];
    
        return target;
    }
 
    /**
     * @private
     * If the target of our override is a String (representing a property), 
     * we register a PROPERTY_CHANGE listener to determine when/if our target 
     * context becomes available or changes.  
     */ 
    protected function addContextListener(target:Object):void
    {
        if (target is String && parentContext != null)
        {
            targetProperty = target as String;
            parentContext.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,
                context_propertyChangeHandler);
        }
    }
    
    /**
     * @private
     * Unregister our PROPERTY_CHANGE listener.
     */ 
    protected function removeContextListener():void
    {
        if (parentContext != null)
        {
            parentContext.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,
                context_propertyChangeHandler);
        }
    }
    
    /**
     * @private
     * Called when our target context is set.  We re-apply our override
     * if appropriate.
     */
    protected function context_propertyChangeHandler(event:PropertyChangeEvent):void
    {
        if (event.property == targetProperty && event.newValue != null)
        {
            apply(parentContext);
            removeContextListener();
        }
    }
}

}