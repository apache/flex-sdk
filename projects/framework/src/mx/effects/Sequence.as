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

import mx.effects.effectClasses.SequenceInstance;

/**
 *  The Sequence effect plays multiple child effects one after the other, 
 *  in the order in which they are added.
 *  
 *  <p>You can create a Sequence effect in MXML,
 *  as the following example shows:</p>
 *
 *  <pre>
 *  &lt;mx:Sequence id="WipeRightUp"&gt;
 *    &lt;mx:children&gt;
 *      &lt;mx:WipeRight duration="1000"/&gt;
 *      &lt;mx:WipeUp duration="1000"/&gt;
 *    &lt;/mx:children&gt;
 *  &lt;/mx:Sequence&gt;
 *  
 *  &lt;mx:VBox id="myBox" hideEffect="{WipeRightUp}"&gt;
 *    &lt;mx:TextArea id="aTextArea" text="hello"/&gt;
 *  &lt;/mx:VBox&gt;
 *  </pre>
 *
 *  <p>Notice that the <code>&lt;mx:children&gt;</code> tag is optional.</p>
 *  
 *  <p>Starting a composite effect in ActionScript is usually
 *  a five-step process:</p>
 *
 *  <ol>
 *    <li>Create instances of the effect objects to be composited together;
 *    for example: 
 *    <pre>myFadeEffect = new mx.effects.Fade(target);</pre></li>
 *    <li>Set properties, such as <code>duration</code>, on the individual effect objects.</li>
 *    <li>Create an instance of the Sequence effect object; 
 *    for example: 
 *    <pre>mySequenceEffect = new mx.effects.Sequence();</pre></li>
 *    <li>Call the <code>addChild()</code> method for each of the effect objects;
 *    for example: 
 *    <pre>mySequenceEffect.addChild(myFadeEffect);</pre></li>
 *    <li>Invoke the Sequence effect's <code>play()</code> method; 
 *    for example: 
 *    <pre>mySequenceEffect.play();</pre></li>
 *  </ol>
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;mx:Sequence&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;mx:Sequence id="<i>identifier</i>"&gt;
 *    &lt;mx:children&gt;
 *      &lt;!-- Specify child effect tags --&gt; 
 *    &lt;/mx:children&gt;
 *  &lt;/mx:Sequence&gt;
 *  </pre>
 *
 *  @see mx.effects.effectClasses.SequenceInstance
 *  
 *  @includeExample examples/SequenceEffectExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class Sequence extends CompositeEffect
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
	 *  @param target This argument is ignored for Sequence effects.
	 *  It is included only for consistency with other types of effects.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function Sequence(target:Object = null)
	{
		super(target);

		instanceClass = SequenceInstance;
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
	}

    /**
     * @inheritDoc
     * 
     * Sequence calculates this number to be the duration of each
     * child effect, played one after the other.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    override public function get compositeDuration():Number
    {
        var sequenceDuration:Number = 0;
        for (var i:int = 0; i < children.length; ++i)
        {
            var childDuration:Number;
            var child:Effect = Effect(children[i]);
            if (child is CompositeEffect)
                childDuration = CompositeEffect(child).compositeDuration;
            else
                childDuration = child.duration;
            childDuration = 
                childDuration * child.repeatCount +
                (child.repeatDelay * (child.repeatCount - 1)) +
                child.startDelay;
            sequenceDuration += childDuration;
        }
        return sequenceDuration;
    }
}

}
