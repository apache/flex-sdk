////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.effects
{

import mx.core.mx_internal;
import mx.effects.effectClasses.CompositeEffectInstance;
import mx.effects.effectClasses.PropertyChanges;

use namespace mx_internal;

[DefaultProperty("children")]

/**
 *  The CompositeEffect class is the parent class for the Parallel
 *  and Sequence classes, which define the <code>&lt;mx:Parallel&gt;</code>
 *  and <code>&lt;mx:Sequence&gt;</code> MXML tags.  
 *  Flex supports two methods to combine, or composite, effects:
 *  parallel and sequence.
 *  When you combine multiple effects in parallel,
 *  the effects play at the same time.
 *  When you combine multiple effects in sequence, 
 *  one effect must complete before the next effect starts.
 *
 *  <p>You can create a composite effect in MXML,
 *  as the following example shows:</p>
 *
 *  <pre>
 *  &lt;mx:Parallel id="WipeRightUp"&gt;
 *    &lt;mx:children&gt;
 *      &lt;mx:WipeRight duration="1000"/&gt;
 *      &lt;mx:WipeUp duration="1000"/&gt;
 *    &lt;/mx:children&gt;
 *  &lt;/mx:Parallel&gt;
 *   
 *  &lt;mx:VBox id="myBox" hideEffect="WipeRightUp"&gt;
 *    &lt;mx:TextArea id="aTextArea" text="hello"/&gt;
 *  &lt;/mx:VBox&gt;
 *  </pre>
 *
 *  <p>The <code>&lt;mx:children&gt;</code> tag is optional.</p>
 *  
 *  <p>Starting a composite effect in ActionScript is usually
 *  a five-step process:</p>
 *
 *  <ol>
 *    <li>Create instances of the effect objects to be composited together; 
 *    for example: 
 *    <pre>myFadeEffect = new mx.effects.Fade(target);</pre></li>
 *    <li>Set properties, such as <code>duration</code>,
 *    on the individual effect objects.</li>
 *    <li>Create an instance of the Parallel or Sequence effect object; 
 *    for example: 
 *    <pre>mySequenceEffect = new mx.effects.Sequence();</pre></li>
 *    <li>Call the <code>addChild()</code> method for each
 *    of the effect objects; for example: 
 *    <pre>mySequenceEffect.addChild(myFadeEffect);</pre></li>
 *    <li>Invoke the composite effect's <code>play()</code> method; 
 *    for example: 
 *    <pre>mySequenceEffect.play();</pre></li>
 *  </ol>
 *  
 *  @mxml
 *
 *  <p>The CompositeEffect class adds the following tag attributes,
 *  and all the subclasses of the CompositeEffect class
 *  inherit these tag attributes:</p>
 *  
 *  <pre>
 *  &lt;mx:<i>tagname</i>&gt;
 *    &lt;mx:children&gt;
 *      &lt;!-- Specify child effect tags --&gt; 
 *    &lt;/mx:children&gt;
 *  &lt;/mx:<i>tagname</i>&gt;
 *  </pre>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class CompositeEffect extends Effect
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
     *  @param target This argument is ignored for composite effects.
     *  It is included only for consistency with other types of effects.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function CompositeEffect(target:Object = null)
    {
        super(target);
        
        instanceClass = CompositeEffectInstance;
    }   
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var childTargets:Array;
    
    /**
     *  @private
     */
    private var _affectedProperties:Array /* of String */;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  children
    //----------------------------------

    [Inspectable(category="General", arrayType="mx.effects.Effect")]
    
    private var _children:Array = [];
    
    /**
     *  An Array containing the child effects of this CompositeEffect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get children():Array
    {
        return _children;
    }
    public function set children(value:Array):void
    {
        var i:int;
        // array may contain null/uninitialized children, so only set/unset
        // parent property for non-null child values
        if (_children)
            // Remove this effect as the parent of the old child effects
            for (i = 0; i < _children.length; ++i)
                if (_children[i])
                    Effect(_children[i]).parentCompositeEffect = null;
        _children = value;
        if (_children)
            for (i = 0; i < _children.length; ++i)
                if (_children[i])
                    Effect(_children[i]).parentCompositeEffect = this;
    }
    
    /**
     * Returns the duration of this effect as defined by the duration of
     * all child effects. This takes into account the startDelay and repetition
     * info for all child effects, along with their durations, and returns the
     * appropriate result.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get compositeDuration():Number
    {
        return duration;
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
        if (!_affectedProperties)
        {
            var arr:Array = [];

            var n:int = children.length;
            for (var i:int = 0; i < n; i++)
            {
                arr = arr.concat(children[i].getAffectedProperties());
            }
                
            _affectedProperties = arr;  
        }
        
        return _affectedProperties;
    }
    
    /**
     *  @private
     */
    override public function createInstance(target:Object = null):IEffectInstance
    {
        if (!childTargets)
            childTargets = [ target ];
        
        var newInstance:IEffectInstance = super.createInstance(target);
        
        childTargets = null;
        
        return newInstance;
    }

    /**
     *  @private
     */
    override public function createInstances(targets:Array = null):Array
    {
        if (!targets)
            targets = this.targets;

        childTargets = targets;
        
        var newInstance:IEffectInstance = createInstance();
        
        childTargets = null;
        
        return newInstance ? [ newInstance ] : [];
    }
    
    /**
     *  @private
     */
    override protected function filterInstance(propChanges:Array,
                                               targ:Object):Boolean
    {
        if (filterObject)
        {
            // If we don't have any targets, then that means
            // we are nested inside of another CompositeEffect.
            // Use the childTargets property instead. 
            var targs:Array = targets;
            if (targs.length == 0)
                targs = childTargets;

            // Perform the check for all targets
            var n:int = targs.length;
            for (var i:int = 0; i < n; i++)
            {
                if (filterObject.filterInstance(propChanges, effectTargetHost, targs[i]))
                    return true;
            }
            
            return false;
        }
        
        return true;
    }
    
    /**
     *  @private
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);
        
        var compInst:CompositeEffectInstance = CompositeEffectInstance(instance);

        var targets:Object = childTargets;
        if (!(targets is Array))
            targets = [ targets ];
            
        if (children)
        {
            var n:int = children.length;
            for (var i:int = 0; i < n; i++)
            {
                var childEffect:Effect = children[i];
                
                // Pass the propertyChangesArray to each child
                if (propertyChangesArray != null)
                {
                    childEffect.propertyChangesArray = propertyChangesArray;
                }
                
                // Pass the filterObject down to the child
                // if it doesn't have a filterObject.
                if (childEffect.filterObject == null &&
                    filterObject)
                {
                    childEffect.filterObject = filterObject;
                }

                // TODO (chaase): This doesn't seem good enough...
                // possibly redundant, but otherwise we'll be using the
                // old semantics. Might be a better way (e.g., reuse
                // the same semantics provider). Note that it's been 
                // working since Flex 3.
                if (effectTargetHost) // && !childEffect.targetSemantics)
                    childEffect.effectTargetHost = effectTargetHost;
                
                if (childEffect.targets.length == 0)
                {
                    compInst.addChildSet(
                        children[i].createInstances(targets));  
                }
                else
                {
                    compInst.addChildSet(
                        children[i].createInstances(childEffect.targets));
                }   
            }
        }       
    }   

    /**
     *  @private
     */
    override public function captureStartValues():void
    {
        // Get all targets of children
        var childTargets:Array = getChildrenTargets();
        
        // Generate the PropertyChanges array
        propertyChangesArray = [];
        
        var n:int = childTargets.length;
        for (var i:int = 0; i < n; i++)
        {
            propertyChangesArray.push(
                new PropertyChanges(childTargets[i]));
        }
        
        // call captureValues
        propertyChangesArray = 
            captureValues(propertyChangesArray, true);
            
        endValuesCaptured = false;
    }

    /**
     *  @private
     */
    override mx_internal function captureValues(propChanges:Array,
                                           setStartValues:Boolean,
                                           targetsToCapture:Array = null):Array
    {
        // Iterate through the list of children
        // and run captureValues() on each of them.
        var n:int = children.length;
        for (var i:int = 0; i < n; i++)
        {
            var child:Effect = children[i];
            propChanges = child.captureValues(propChanges, setStartValues,
                (child.targets && child.targets.length > 0) ? child.targets : targetsToCapture);
        }
        
        return propChanges;
    }
    
    /**
     *  @private
     */
    override mx_internal function applyStartValues(propChanges:Array,
                                              targets:Array):void
    {
        var n:int = children.length;
        for (var i:int = 0; i < n; i++)
        {
            var child:Effect = children[i];
            
            var childTargets:Array = child.targets.length > 0 ?
                                     child.targets :
                                     targets;
            
            if (child.filterObject == null && filterObject)
            {
                child.filterObject = filterObject;
            }
            
            child.applyStartValues(propChanges, childTargets);
        }
    }

    /**
     *  @private
     */
    override mx_internal function applyEndValues(propChanges:Array,
                                              targets:Array):void
    {
        var n:int = children.length;
        for (var i:int = 0; i < n; i++)
        {
            var child:Effect = children[i];
            
            var childTargets:Array = child.targets.length > 0 ?
                                     child.targets :
                                     targets;
            
            if (child.filterObject == null && filterObject)
            {
                child.filterObject = filterObject;
            }
            
            child.applyEndValues(propChanges, childTargets);
        }
    }

    /**
     * @private
     * Override this property so that we can set it on all child effects
     */
    override mx_internal function set transitionInterruption(value:Boolean):void
    {
        super.transitionInterruption = value;

        var n:int = children.length;
        for (var i:int = 0; i < n; i++)
        {
            var child:Effect = children[i];            
            child.transitionInterruption = value;
        }
    }
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    // TODO (chaase): Shouldn't there be a removeChild() method 
    // since there's an addChild() method?
    
    /**
     *  Adds a new child effect to this composite effect.
     *  A Sequence effect plays each child effect one at a time,
     *  in the order that they were added. 
     *  A Parallel effect plays all child effects simultaneously;
     *  the order in which they are added does not matter.
     *
     *  @param childEffect Child effect to be added
     *  to the composite effect.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function addChild(childEffect:IEffect):void
    {
        children.push(childEffect);

        // Null out the list of affected properties,
        // so that it gets recalculated to include the new child.
        _affectedProperties = null;
        Effect(childEffect).parentCompositeEffect = this;
    }
    
    /**
     *  @private
     *  Figure out the targets of the children
     */
    private function getChildrenTargets():Array
    {       
        var resultsArray:Array = [];
        var results:Object = {};
        var childTargets:Array;
        var child:Effect;
        
        var n:int;
        var i:int;
        var m:int;
        var j:int;
        
        n = children.length;
        for (i = 0; i < n; i++)
        {
            child = children[i];
            if (child is CompositeEffect)
            {
                childTargets = CompositeEffect(child).getChildrenTargets();
                m = childTargets.length;
                for (j = 0; j < m; j++)
                {
                    // Don't include null or duplicate targets
                    if (childTargets[j] != null && 
                        resultsArray.indexOf(childTargets[j]) < 0)
                    {
                        resultsArray.push(childTargets[j]);
                    }
                }
            }   
            else if (child.targets != null)
            {
                m = child.targets.length;
                for (j = 0; j < m; j++)
                {
                    // Don't include null or duplicate targets
                    if (child.targets[j] != null && 
                        resultsArray.indexOf(child.targets[j]) < 0)
                    {
                        resultsArray.push(child.targets[j]);
                    }
                }
            }
        }
        
        // Now add in our targets.
        n = targets.length;
        for (i = 0; i < n; i++)
        {
            // Don't include null or duplicate targets
            if (targets[i] != null && 
                resultsArray.indexOf(targets[i]) < 0)
            {
                resultsArray.push(targets[i]);
            }
        }
        
        return resultsArray;
    }
}

}
