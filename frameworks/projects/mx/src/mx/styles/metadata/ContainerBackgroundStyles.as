
[Style(name="backgroundAlpha", type="Number", inherit="no", theme="halo, spark")]

/**
 *  Background color of a component.
 *  You can have both a <code>backgroundColor</code> and a
 *  <code>backgroundImage</code> set.
 *  Some components do not have a background.
 *  The DataGrid control ignores this style.
 *  The default value is <code>undefined</code>, which means it is not set.
 *  If both this style and the <code>backgroundImage</code> style
 *  are <code>undefined</code>, the component has a transparent background.
 *
 *  <p>For the Application container, this style specifies the background color
 *  while the application loads, and a background gradient while it is running. 
 *  Flex calculates the gradient pattern between a color slightly darker than 
 *  the specified color, and a color slightly lighter than the specified color.</p>
 * 
 *  <p>The default skins of most Flex controls are partially transparent. As a result, the background color of 
 *  a container partially "bleeds through" to controls that are in that container. You can avoid this by setting the 
 *  alpha values of the control's <code>fillAlphas</code> property to 1, as the following example shows:
 *  <pre>
 *  &lt;mx:<i>Container</i> backgroundColor="0x66CC66"/&gt;
 *      &lt;mx:<i>ControlName</i> ... fillAlphas="[1,1]"/&gt;
 *  &lt;/mx:<i>Container</i>&gt;</pre>
 *  </p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
[Style(name="backgroundColor", type="uint", format="Color", inherit="no", theme="halo, spark")]