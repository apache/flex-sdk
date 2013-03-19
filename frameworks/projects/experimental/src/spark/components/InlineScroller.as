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
package spark.components
{
	import spark.components.Scroller;
	import spark.components.supportClasses.Skin;
	
	import spark.layouts.InlineScrollerLayout;
	
	/**
	 *  The InlineScroller component displays a single scrollable component, 
	 *  called a viewport, and horizontal and vertical scroll bars. 
	 *  The viewport must implement the IViewport interface.  Its skin
	 *  must be a derivative of the Group class.
	 *
	 *  <p>The Spark Group, DataGroup, and RichEditableText components implement 
	 *  the IViewport interface and can be used as the children of the InlineScroller control,
	 *  as the following example shows:</p>
	 * 
	 *  <pre>
	 *  &lt;st:InlineScroller width="100" height="100"&gt;
	 *       &lt;s:Group&gt; 
	 *          &lt;mx:Image width="300" height="400" 
	 *               source="&#64;Embed(source='assets/logo.jpg')"/&gt; 
	 *       &lt;/s:Group&gt;        
	 *  &lt;/st:InlineScroller&gt;</pre>     
	 *
	 *  <p>The size of the Image control is set larger than that of its parent Group container. 
	 *  By default, the child extends past the boundaries of the parent container. 
	 *  Rather than allow the child to extend past the boundaries of the parent container, 
	 *  the InlineScroller specifies to clip the child to the boundaries and display scroll bars.</p>
	 *
	 *  <p>Not all Spark containers implement the IViewPort interface. 
	 *  Therefore, those containers, such as the Border and SkinnableContainer containers, 
	 *  cannot be used as the direct child of the InlineScroller component.
	 *  However, all Spark containers can have a InlineScroller component as a child component. 
	 *  For example, to use scroll bars on a child of the Spark Border container, 
	 *  wrap the child in a InlineScroller component. </p>
	 *
	 *  <p>To make the entire Border container scrollable, wrap it in a Group container. 
	 *  Then, make the Group container the child of the InlineScroller component,
	 *  For skinnable Spark containers that do not implement the IViewport interface, 
	 *  you can also create a custom skin for the container that 
	 *  includes the InlineScroller component. </p>
	 * 
	 *  <p>The IViewport interface defines a viewport for the components that implement it.
	 *  A viewport is a rectangular subset of the area of a container that you want to display, 
	 *  rather than displaying the entire container.
	 *  The scroll bars control the viewport's <code>horizontalScrollPosition</code> and
	 *  <code>verticalScrollPosition</code> properties.
	 *  scroll bars make it possible to view the area defined by the viewport's 
	 *  <code>contentWidth</code> and <code>contentHeight</code> properties.</p>
	 *
	 *  <p>You can combine scroll bars with explicit settings for the container's viewport. 
	 *  The viewport settings determine the initial position of the viewport, 
	 *  and then you can use the scroll bars to move it, as the following example shows: </p>
	 *  
	 *  <pre>
	 *  &lt;st:InlineScroller width="100" height="100"&gt;
	 *      &lt;s:Group
	 *          horizontalScrollPosition="50" verticalScrollPosition="50"&gt; 
	 *          &lt;mx:Image width="300" height="400" 
	 *              source="&#64;Embed(source='assets/logo.jpg')"/&gt; 
	 *      &lt;/s:Group&gt;                 
	 *  &lt;/st:InlineScroller&gt;</pre>
	 * 
	 *  <p>The scroll bars are displayed according to the vertical and horizontal scroll bar
	 *  policy, which can be <code>auto</code>, <code>on</code>, or <code>off</code>.
	 *  The <code>auto</code> policy means that the scroll bar will be visible and included
	 *  in the layout when the viewport's content is larger than the viewport itself.</p>
	 * 
	 *  <p>The InlineScroller skin layout cannot be changed. It is unconditionally set to a 
	 *  private layout implementation that handles the scroll policies. InlineScroller skins
	 *  can only provide replacement scroll bars. To gain more control over the layout
	 *  of a viewport and its scroll bars, instead of using InlineScroller, just add them 
	 *  to a <code>Group</code> and use the scroll bar <code>viewport</code> property 
	 *  to link them together.</p>
	 *
	 *  <p>The InlineScroller control has the following default characteristics:</p>
	 *     <table class="innertable">
	 *        <tr>
	 *           <th>Characteristic</th>
	 *           <th>Description</th>
	 *        </tr>
	 *        <tr>
	 *           <td>Default size</td>
	 *           <td>0</td>
	 *        </tr>
	 *        <tr>
	 *           <td>Minimum size</td>
	 *           <td>0</td>
	 *        </tr>
	 *        <tr>
	 *           <td>Maximum size</td>
	 *           <td>10000 pixels wide and 10000 pixels high</td>
	 *        </tr>
	 *        <tr>
	 *           <td>Default skin class</td>
	 *           <td>spark.skins.controls.InlineScrollerSkin</td>
	 *        </tr>
	 *     </table>
	 *
	 *  @mxml
	 *
	 *  <p>The <code>&lt;st:InlineScroller&gt;</code> tag inherits all of the tag 
	 *  attributes of its superclass and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;st:InlineScroller
	 *   <strong>Properties</strong>
	 *    measuredSizeIncludesScrollBars="true"
	 *    minViewportInset="0"
	 *    viewport="null"
	 *  
	 *    <strong>Styles</strong>
	 *    alignmentBaseline="use_dominant_baseline"
	 *    alternatingItemColors=""
	 *    baselineShift="0.0"
	 *    blockProgression="TB"
	 *    breakOpportunity="auto"
	 *    cffHinting="horizontal_stem"
	 *    color="0"
	 *    contentBackgroundAlpha=""
	 *    contentBackgroundColor=""
	 *    digitCase="default"
	 *    digitWidth="default"
	 *    direction="LTR"
	 *    dominantBaseline="auto"
	 *    firstBaselineOffset="auto"
	 *    focusColor=""
	 *    focusedTextSelectionColor=""
	 *    fontFamily="Times New Roman"
	 *    fontLookup="device"
	 *    fontSize="12"
	 *    fontStyle="normal"
	 *    fontWeight="normal"
	 *    horizontalScrollPolicy="auto"
	 *    inactiveTextSelection=""
	 *    justificationRule="auto"
	 *    justificationStyle="auto"
	 *    kerning="auto"
	 *    leadingModel="auto"
	 *    ligatureLevel="common"
	 *    lineHeight="120%"
	 *    lineThrough="false"
	 *    locale="en"
	 *    paragraphEndIndent="0"
	 *    paragraphSpaceAfter="0"
	 *    paragraphSpaceBefore="0"
	 *    paragraphStartIndent="0"
	 *    renderingMode="CFF"
	 *    rollOverColor=""
	 *    symbolColor=""
	 *    tabStops="null"
	 *    textAlign="start"
	 *    textAlignLast="start"
	 *    textAlpha="1"
	 *    textDecoration="none"
	 *    textIndent="0"
	 *    textJustify="inter_word"
	 *    textRotation="auto"
	 *    trackingLeft="0"
	 *    trackingRight="0"
	 *    typographicCase="default"
	 *    unfocusedTextSelectionColor=""
	 *    verticalScrollPolicy="auto"
	 *    whiteSpaceCollapse="collapse"
	 *  /&gt;
	 *  </pre>
	 *  
	 *  @see spark.skins.controls.InlineScrollerSkin
	 * 	@see spark.layouts.InlineScrollerLayout
	 *
	 *  @includeExample examples/InlineScrollerExample.mxml
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	
	public class InlineScroller extends Scroller
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
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function InlineScroller()
		{
			super();
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override protected function attachSkin():void
		{
			super.attachSkin();
			Skin( skin ).layout = new InlineScrollerLayout();
		}
	}
}