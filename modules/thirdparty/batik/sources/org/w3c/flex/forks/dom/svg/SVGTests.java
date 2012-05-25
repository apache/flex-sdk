
package org.w3c.flex.forks.dom.svg;

public interface SVGTests {
  public SVGStringList getRequiredFeatures( );
  public SVGStringList getRequiredExtensions( );
  public SVGStringList getSystemLanguage( );

  public boolean hasExtension ( String extension );
}
