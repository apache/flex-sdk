////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.controls.olapDataGridClasses
{
import mx.core.mx_internal;
import mx.core.IFactory;
import mx.formatters.Formatter;

use namespace mx_internal;

/**
 *  The OLAPDataGridRendererProvider class defines the base class for 
 *  assigning item renderers used by the OLAPDataGrid control. 
 *  Use properties of the OLAPDataGridRendererProvider class to 
 *  configure where an item renderer is used in an OLAPDataGrid control.
 *
 *  <p>Each cell in an OLAPDataGrid control is a result of an intersection 
 *  between the members along a row and the members along a column of the control. 
 *  However, when you assign an item renderer to an OLAPDataGrid control, 
 *  you only specify the <code>uniqueName</code> and <code>type</code> properties 
 *  for one of the dimensions, either row or column. 
 *  Therefore, you can create a situation where two different item renderers 
 *  are assigned to the same cell of the control.</p>
 *  
 *  <p>In case of a conflict between two or more item renderers, 
 *  the OLAPDataGrid control applies the item renderer based on the following priorities: </p>
 * 
 *  <ol>
 *    <li><code>type</code> = <code>OLAPDataGrid.OLAP_MEMBER</code> </li>
 *    <li><code>type</code> = <code>OLAPDataGrid.OLAP_LEVEL</code> </li>
 *    <li><code>type</code> = <code>OLAPDataGrid.OLAP_HIERARCHY</code></li> 
 *    <li><code>type</code> = <code>OLAPDataGrid.OLAP_DIMENSION</code></li> 
 *  </ol>
 *  
 *  <p>Therefore, if an item renderer with a type value of 
 *  <code>OLAPDataGrid.OLAP_LEVEL</code> and an item renderer 
 *  with a type value of <code>OLAPDataGrid.OLAP_HIERARCHY</code> 
 *  are applied to the same cell, 
 *  the OLAPDataGrid control applies the item renderer with a type value 
 *  of <code>OLAPDataGrid.OLAP_LEVEL</code>.</p>
 * 
 *  <p>If two item renderers have the same value for the type property, 
 *  the OLAPDataGrid control determines which renderer more closely matches 
 *  the item, and uses it.</p>
 *
 *  @see mx.controls.OLAPDataGrid
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class OLAPDataGridRendererProvider
{
	include "../../core/Version.as";
	
	//--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------   
    
    //----------------------------------
    // uniqueName
    //----------------------------------
    
    private var _uniqueName:String;

    /**
     *  The unique name of the IOLAPElement to which the renderer is applied.
     *  For example, "[TimeDim][YearHier][2007]" is a unique name, 
     *  where "2007" is the level belonging to the "YearHier" hierarchy 
     *  of the "TimeDim" dimension.
     *
     *  <p>The <code>uniqueName</code> property and the <code>type</code> property
     *  together specify the target of the item renderer. 
     *  Because the unique name of "[TimeDim][YearHier][2007]" 
     *  specifies a level of an OLAP schema, 
     *  set the <code>type</code> property to <code>OLAPDataGrid.OLAP_LEVEL</code>.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get uniqueName():String
    {
        return _uniqueName;
    }

    /**
     *  @private
     */
    public function set uniqueName(name:String):void
    {
        _uniqueName = name;
    }
    
    //----------------------------------
    // type
    //----------------------------------
    
    private var _type:int;

    /**
     *  Specifies whether the renderer is applied to a 
     *  dimension (<code>OLAPDataGrid.OLAP_DIMENSION</code>), 
     *  hierarchy(<code>OLAPDataGrid.OLAP_HIERARCHY</code>), 
     *  level(<code>OLAPDataGrid.OLAP_LEVEL</code>), 
     *  or member (<code>OLAPDataGrid.OLAP_MEMBER</code>) of an axis.
     *
     *  <p>Set this property based on the setting of the <code>uniqueName</code> property. 
     *  For example, if the <code>uniqueName</code> property references a hierarchy of an OLAP schema,
     *  set this property to <code>OLAPDataGrid.OLAP_HIERARCHY</code>.</p>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get type():int
    {
        return _type;
    }

    /**
     *  @private
     */
    public function set type(name:int):void
    {
        _type = name;
    }
    
    //----------------------------------
    // renderer
    //----------------------------------

    private var _renderer:IFactory;

    /**
     *  The renderer object used for customizing the OLAPDataGrid control.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get renderer():IFactory
    {
        return _renderer;
    }

    /**
     *  @private
     */
    public function set renderer(r:IFactory):void
    {
        _renderer = r;
    }
    
    //----------------------------------
    // styleName
    //----------------------------------

    /**
     *  The name of a CSS style declaration for controlling 
     *  the appearance of the cell.
     *
     *  <p>For example, you define the following style in your application, 
     *  and then use the <code>styleName</code> property to associate it with 
     *  a specific hierarchy in an OLAP schema:</p>
     *
     *  <pre>
     *  &lt;Style&gt;
     *    .monthStyle
     *      {
     *        color:0x755762
     *        fontSize:14
     *      }
     *  &lt;/Style&gt;
     * 
     *  &lt;mx:ODGHeaderRendererProvider 
     *    type="OLAPDataGrid.OLAP_HIERARCHY" 
     *    uniqueName="[Time][Month]" styleName="monthStyle"/&gt; </pre>
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public var styleName:String
}
}
