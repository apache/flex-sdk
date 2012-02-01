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

package spark.layouts
{

/**
 *  The VerticalAlign class defines the possible values for the 
 *  <code>verticalAlign</code> property of the HorizontalLayout class.
 * 
 * @see HorizontalLayout#verticalAlign
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public final class VerticalAlign
{   
    /**
     *  Vertically align children to the top of the container.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const TOP:String = "top";

    /**
     *  Vertically align children in the middle of the container.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const MIDDLE:String = "middle";

    /**
     *  Vertically align children to the bottom of the container.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const BOTTOM:String = "bottom";

    /**
     *  Justify the children with respect to the container.  This
     *  uniformly sizes all children to be the same height as the 
     *  container.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const JUSTIFY:String = "justify";

    /**
     *  Content justify the children with respect to the container.  This
     *  uniformly sizes all children to be the content height of the container.
     *  The content height of the container is the size of the largest child.
     *  If all children are smaller than the height of the container, then 
     *  all the children will be sized to the height of the container.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static const CONTENT_JUSTIFY:String = "contentJustify";
    
}

}
