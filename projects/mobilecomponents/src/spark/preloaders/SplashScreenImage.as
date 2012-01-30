package spark.preloaders
{
import mx.core.mx_internal;
    
use namespace mx_internal;

[DefaultProperty("mxmlContent")]
    
/**
 *  Use the SplashScreenImage class to specify different splash screen 
 *  images per device configurations like DPI, orientation, resolution.
 * 
 *  <p>Developers typically define a <code>SplashScreenImage</code> class
 *  in a separate MXML file.  The different image choices and corresponding
 *  device configutaions are defined in that MXML file as <code>SplahsScreenImageSource</code>
 *  children.  The Developers set the Application's <code>splashScreenImage</code>
 *  property to the name of the <code>SplashScreenImage</code> definition.</p> 
 *
 *  <p>Note, this class can't be set inline in the Application MXML, it needs
 *  to be defined in a separate MXML file and referenced from the Application's
 *  <code>splashScreenImage</code> property.</p>
 *
 *  @see spark.preloaders.SplashScreenImageSource
 *  @see spark.components.Application#splashScreenImage
 */    
public class SplashScreenImage
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
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
     *  The <code>SplashScreenImageSource</code> sources for this 
     *  <code>SplashScreenImage</code>.
     * 
     *  Typically developers don't use this method directly, instead they
     *  define the <code>SplashScreenImageSource</code> inline in MXML.
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
     *  Returns the Class of the SplashScreenImageSource that matches best
     *  the specified device parameters.
     * 
     *  Developers don't call this method directly, it is called internally by Flex.
     * 
     *  Developers may override this method in a subclass if they want to override
     *  the default Flex logic of picking the best matching SplashScreenImageSource.
     * 
     *  @param aspectRatio One of StageAspectRatio.PORTRAIT StageAspectRatio.LANDSCAPE.
     *  @param dpi The dpi of the device.
     *  @param resolution The resolution of the device's bigger dimension, in pixels.
     *  @return The Class for the image to be displayed as a splash screen image.
     */
    public function getImageClass(aspectRatio:String, dpi:Number, resolution:Number):Class
    {
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
}
}