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
 *  An enum of the smoothing quality modes that determine how a BitmapImage
 *  scales image content when fillMode is set to BitmapFillMode.SCALE and
 *  <code>smooth</code> is true.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4.5
 */
public final class BitmapSmoothingQuality
{
    /**
     *  Default smoothing algorithm is used when scaling,
     *  consistent with quality of the stage (stage.quality).
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public static const DEFAULT:String = "default";

    /**
     *  High quality smoothing algorithm is used when scaling. Used
     *  when a higher quality (down-sampled) scale is preferred. This option 
     *  yields the best results when the image is scaled to a size equal to the 
     *  aspect ratio of the original image and is useful for generating high 
     *  quality thumbnails. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4.5
     */
    public static const HIGH:String = "high";
}

}
