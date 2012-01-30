////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.graphics
{

/**
 *  An enum of the scale modes that determine how a BitmapImage
 *  scales image content when fillMode is set to BitmapImage.SCALE.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
public final class BitmapScaleMode
{
    /**
     *  The bitmap fill stretches to fill the region.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public static const STRETCH:String = "stretch";

    /**
     *  The bitmap fill is scaled while maintaining the aspect
     *  ratio of the original content.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public static const LETTERBOX:String = "letterbox";
    
    /**
     *  The bitmap fill is scaled and cropped such that the aspect
     *  ratio of the original content is maintained and no letterbox
     *  or pillar box is displayed.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 11
     *  @playerversion AIR 3
     *  @productversion Flex 4.5.2
     */
    public static const ZOOM:String = "zoom";
}

}
