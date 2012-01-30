////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.preloaders
{
import mx.core.IMXMLObject;
import mx.core.mx_internal;
    
use namespace mx_internal;

[DefaultProperty("mxmlContent")]
    
/**
 *  Use the SplashScreenImage class to specify different splash screen 
 *  images based on characteristics of a mobile device.
 *  For example, you can use different images for a splashscreen based on the 
 *  DPI, orientation, or resolution of the device.
 * 
 *  <p>You typically define a SplashScreenImage class
 *  in an MXML file.  
 *  Use the SplahsScreenImageSource class to define the different 
 *  image choices and corresponding device configurations.  
 *  You then set the application's <code>splashScreenImage</code>
 *  property to the name of the <code>SplashScreenImage</code> MXML component.</p> 
 * 
 *  <p>The procedure for determining the best match of an SplahsScreenImageSource 
 *  definition to a mobile device is as follows:</p>
 *  
 *  <ol>
 *    <li>Determine all of the SplashScreenImageSource definitions 
 *      that match the settings of the mobile device. 
 *      A match occurs when: 
 *        <ul>
 *          <li>The SplashScreenImageSource definition does not have that setting explicitly defined. 
 *              For example, no setting for the <code>dpi</code> property matches any device's DPI.</li>
 *          <li>For the <code>dpi</code> or <code>aspectRatio</code> property, the property must exactly match 
 *              the corresponding setting of the mobile device. </li>
 *          <li>For the <code>minResolution</code> property, the property matches a setting on 
 *              the device when the larger of the <code>Stage.stageWidth</code> and 
 *              <code>Stage.stageHeight</code> properties is equal to or greater than <code>minResolution</code>.</li>
 *        </ul>
 *    </li>
 *    <li>If there's more than one SplashScreenImageSource definition that matches the device then: 
 *          <ul>
 *            <li>Choose the one with largest number of explicit settings. 
 *              For example, a SplashScreenImageSource definition that specifies both the 
 *              <code>dpi</code> and <code>aspectRatio</code> properties is a better match 
 *              than one that only species the <code>dpi</code> property.</li>
 *            <li>If there is still more than one match, choose the one with highest 
 *              <code>minResolution</code> value.</li>
 *            <li>If there is still more than one match, choose the first one defined in the component.</li>
 *          </ul>
 *    </li>
 *  </ol>
 *
 *  <p><b>Note</b>: This class cannot be set inline in the MXML of the application.
 *  You must define it in a separate MXML file and reference it by using the 
 *  application's <code>splashScreenImage</code> property.</p>
 *
 *  @mxml
 *  
 *  <p>The <code>&lt;s:SplashScreenImage&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds no new tag attributes:</p>
 *  
 *  <pre>
 *  &lt;s:SplashScreenImage xmlns:fx="http://ns.adobe.com/mxml/2009" 
 *      xmlns:s="library://ns.adobe.com/flex/spark"&gt;
 *  
 *      &lt;!-- Define one or more SplashScreenImageSource. --&gt;
 *      &lt;s:SplashScreenImageSource 
 *          source="&#64;Embed('assets/logoDefault.jpg')"/&gt;
 *          
 *      &lt;s:SplashScreenImageSource 
 *          source="&#64;Embed('assets/logo240Portrait.jpg')"
 *          dpi="240" 
 *          aspectRatio="portrait"/&gt;
 *   
 *  &lt;/s:SplashScreenImage&gt;
 *  </pre>
 *
 *  @includeExample examples/DynamicSplashScreenExample1.mxml -noswf
 *  @includeExample examples/DynamicSplashScreenExample1HomeView.mxml -noswf
 *  @includeExample examples/SplashScreenImage1.mxml -noswf
 * 
 *  @see spark.preloaders.SplashScreenImageSource
 *  @see spark.components.Application#splashScreenImage
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */    
public class SplashScreenImage implements IMXMLObject
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
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function SplashScreenImage()
    {
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  mxmlContent
    //----------------------------------

    /**
     *  @private
     *  Storage for the mxmlContent property 
     */
    private var _mxmlContent:Array;

    [ArrayElementType("spark.preloaders.SplashScreenImageSource")]

    /**
     *  The SplashScreenImageSource sources for this 
     *  <code>SplashScreenImage</code>.
     * 
     *  Typically you do not call this method directly.
     *  Instead, you add SplashScreenImageSource definitions 
     *  inline in the MXML file of the SplashScreenImage component.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function get mxmlContent():Array
    {
        return _mxmlContent;
    }

    /**
     *  @private
     */
    public function set mxmlContent(value:Array):void
    {
        _mxmlContent = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Returns the Class of the SplashScreenImageSource that best matches 
     *  the specified device parameters.
     * 
     *  <p>You do not call this method directly; it is called internally by Flex.</p>
     * 
     *  <p>Override this method in a SplashScreenImage component if you want to override
     *  the default Flex logic of picking the best matching SplashScreenImageSource instance.</p>
     * 
     *  @param aspectRatio Either <code>flash.display.StageAspectRatio.PORTRAIT</code> or 
     *  <code>flash.display.StageAspectRatio.LANDSCAPE</code>, whichever is greater.
     * 
     *  @param dpi The DPI of the mobile device.
     * 
     *  @param resolution The resolution of the mobile device's bigger dimension, in pixels.
     * 
     *  @return The Class for the image to be displayed as a splash screen image.
     *
     *  @see flash.display.StageAspectRatio
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function getImageClass(aspectRatio:String, dpi:Number, resolution:Number):Class
    {
        if (!_mxmlContent)
            return null;

        // Find best matching source
        var bestMatch:SplashScreenImageSource;
        const length:int = _mxmlContent.length;
        for (var i:int = 0; i < length; i++)
        {
            var source:SplashScreenImageSource = _mxmlContent[i] as SplashScreenImageSource; 
            if (source && source.matches(aspectRatio, dpi, resolution) && (!bestMatch || source.betterThan(bestMatch)))
                bestMatch = source;
        }

        return bestMatch ? bestMatch.source : null;
    }

    /**
     *  Called after the implementing object has been created and all
     *  component properties specified on the MXML tag have been initialized.
     *
     *  @param document The MXML document that created this object.
     *
     *  @param id The identifier used by <code>document</code> to refer
     *  to this object.
     *  If the object is a deep property on <code>document</code>,
     *  <code>id</code> is null.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function initialized(document:Object, id:String):void
    {
    }
}
}