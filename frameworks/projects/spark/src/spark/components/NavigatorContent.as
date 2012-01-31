////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{
import flash.events.Event;

import mx.core.ContainerCreationPolicy;
import mx.core.IDeferredContentOwner;
import mx.core.INavigatorContent

/**
 *  The NavigatorChild class is used in ViewStack, TabNavigator and Accordion
 *  to allow Spark components to be managed by these navigators.
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:NavigatorChild&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:NavigatorChild
 *    <strong>Properties</strong>
 *    icon="null"
 *    label=""
 *  
 *  /&gt;
 *  </pre>
 *
 *  @see SkinnableContainer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class NavigatorContent extends SkinnableContainer 
       implements INavigatorContent
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
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function NavigatorContent()
    {
        super();
        creationPolicy = null;
    }
    
    
    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  icon
    //----------------------------------

    /**
     *  @private
     *  Storage for the icon property.
     */
    private var _icon:Class = null;

    [Bindable("iconChanged")]
    [Inspectable(category="General", defaultValue="", format="EmbeddedFile")]

    /**
     *  The Class of the icon displayed by some navigator
     *  containers to represent this Container.
     *
     *  <p>For example, if this Container is a child of a TabNavigator,
     *  this icon appears in the corresponding tab.
     *  If this Container is a child of an Accordion,
     *  this icon appears in the corresponding header.</p>
     *
     *  <p>To embed the icon in the SWF file, use the &#64;Embed()
     *  MXML compiler directive:</p>
     *
     *  <pre>
     *    icon="&#64;Embed('filepath')"
     *  </pre>
     *
     *  <p>The image can be a JPEG, GIF, PNG, SVG, or SWF file.</p>
     *
     *  @default null
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get icon():Class
    {
        return _icon;
    }

    /**
     *  @private
     */
    public function set icon(value:Class):void
    {
        _icon = value;

        dispatchEvent(new Event("iconChanged"));
    }

    //----------------------------------
    //  label
    //----------------------------------

    /**
     *  @private
     *  Storage for the label property.
     */
    private var _label:String = "";

    [Bindable("labelChanged")]
    [Inspectable(category="General", defaultValue="")]

    /**
     *  The text displayed by some navigator containers to represent
     *  this Container.
     *
     *  <p>For example, if this Container is a child of a TabNavigator,
     *  this string appears in the corresponding tab.
     *  If this Container is a child of an Accordion,
     *  this string appears in the corresponding header.</p>
     *
     *  @default ""
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get label():String
    {
        return _label;
    }

    /**
     *  @private
     */
    public function set label(value:String):void
    {
        _label = value;

        dispatchEvent(new Event("labelChanged"));
    }

    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Create components that are children of this Container.
     */
    override protected function createChildren():void
    {
        // if nobody has overridden creationPolicy, get it from the
        // navigator parent
        if (creationPolicy == null)
        {
            if (parent is IDeferredContentOwner)
            {
                var parentCreationPolicy:String = IDeferredContentOwner(parent).creationPolicy;
                creationPolicy = parentCreationPolicy == 
                        ContainerCreationPolicy.ALL ? ContainerCreationPolicy.ALL : 
                                                        ContainerCreationPolicy.NONE;

            }
        }

        super.createChildren();
    }

}

}
