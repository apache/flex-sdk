
package org.w3c.flex.forks.dom.svg;

public interface SVGFEGaussianBlurElement extends 
               SVGElement,
               SVGFilterPrimitiveStandardAttributes {
  public SVGAnimatedString getIn1( );
  public SVGAnimatedNumber getStdDeviationX( );
  public SVGAnimatedNumber getStdDeviationY( );

  public void setStdDeviation ( float stdDeviationX, float stdDeviationY );
}
