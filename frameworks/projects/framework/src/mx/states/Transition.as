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

package mx.states
{

import mx.effects.IEffect;

[DefaultProperty("effect")]

/**
 *  The Transition class defines a set of effects that play in response
 *  to a change of view state. While a view state definition
 *  defines how to change states, a transition defines the order in which
 *  visual changes occur during the state change.
 *
 *  <p>To define a transition, you set the <code>transitions</code> property of an Application
 *  to an Array of Transition objects. </p>
 *
 *  <p>You use the <code>toState</code> and <code>fromState</code> properties of
 *  the Transition class to specify the state changes that trigger the transition.
 *  By default, both the <code>fromState</code> and <code>toState</code> properties
 *  are set to "&#42;", meaning apply the transition to any changes to the view state.</p>
 *
 *  <p>You can use the <code>fromState</code> property to explicitly specify a
 *  view state that your are changing from, and the <code>toState</code> property
 *  to explicitly specify a view state that you are changing to.
 *  If a state change matches two transitions, the <code>toState</code> property
 *  takes precedence over the <code>fromState</code> property. If more than one
 *  transition match, Flex uses the first definition in the transition array. </p>
 *
 *  <p>You use the <code>effect</code> property to specify the Effect object to play
 *  when you apply the transition. Typically, this is a composite effect object,
 *  such as the Parallel or Sequence effect, that contains multiple effects,
 *  as the following example shows:</p><pre>
 *
 *  &lt;mx:Transition id="myTransition" fromState="&#42;" toState="&#42;"&gt;
 *    &lt;mx:Parallel&gt;
 *        ...
 *    &lt;/mx:Parallel&gt;
 *  &lt;/mx:Transition&gt;
 *  </pre>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;mx:Transition&gt;</code> tag
 *  defines the following attributes:</p>
 *  
 *  <pre>
 *  &lt;mx:Transition
 *    <b>Properties</b>
 *    id="ID"
 *    effect=""
 *    fromState="&#42;"
 *    toState="&#42;"
 *    autoReverse="false"
 *  /&gt;
 *  </pre>
 *
 *  @see mx.effects.AddChildAction
 *  @see mx.effects.RemoveChildAction
 *  @see mx.effects.SetPropertyAction
 *  @see mx.effects.SetStyleAction
 *
 *  @includeExample examples/TransitionExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class Transition
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
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public function Transition()
	{
		super();
	}

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
	//  effect
    //----------------------------------

	/**
	 *  The IEffect object to play when you apply the transition. Typically,
	 *  this is a composite effect object, such as the Parallel or Sequence effect,
	 *  that contains multiple effects.
	 *
	 *  <p>The <code>effect</code> property is the default property of the
	 *  Transition class. You can omit the <code>&lt;mx:effect&gt;</code> tag 
	 *  if you use MXML tag syntax.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var effect:IEffect;

    //----------------------------------
	//  fromState
    //----------------------------------

	[Inspectable(category="General")]

    /**
     *  A String specifying the view state that your are changing from when
     *  you apply the transition. The default value is "&#42;", meaning any view state.
     *
     *  <p>You can set this property to an empty string, "",
     *  which corresponds to the base view state.</p>
     *
     *  @default "&#42;"
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public var fromState:String = "*";

    //----------------------------------
	//  toState
    //----------------------------------

	[Inspectable(category="General")]

	/**
	 *  A String specifying the view state that you are changing to when
	 *  you apply the transition. The default value is "&#42;", meaning any view state.
     *
     *  <p>You can set this property to an empty string, "",
     *  which corresponds to the base view state.</p>
     *
     *  @default "&#42;"
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public var toState:String = "*";
	
    /**
     *  Whether the transition should automatically reverse itself 
     *  when the opposite state transition begins playing.
     *
     *  <p>Flex does not currently play multiple transitions simultaneously.
     *  This means that when a new state transition occurs, if there
     *  is already one playing it is stopped by calling <code>end()</code>
     *  on it, which snaps it to its end values. The new transition
     *  then starts playing from that state.</p>
     * 
     *  <p>The <code>autoReverse</code> flag allows the developer to
     *  control whether the default snap-to-end behavior occurs, or whether,
     *  instead, the previous effect is stopped in place and the new
     *  effect is played from that intermediate state instead. Internally,
     *  the transition code calculates how much of the previous effect
     *  has been played and then plays the next effect for the inverse of that
     *  time.</p>
     * 
     *  <p>This flag is only checked when the new transition is going in the
     *  exact opposite direction of the currently playing one. That is, if
     *  a transition is playing between states A and B and then a transition
     *  to return to A is started, this flag will be checked. But if the
     *  application is going from state A to B and a transition to state C is
     *  started, then the default behavior of snapping to the end of the A->B
     *  transition, then playing the B->C transition will occur.</p>
     * 
     *  @default false 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	public var autoReverse:Boolean = false;
}

}
