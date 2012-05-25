
package org.w3c.flex.forks.dom.svg;

import org.w3c.dom.DOMException;
public interface SVGAnimatedNumber {
  public float getBaseVal( );
  public void           setBaseVal( float baseVal )
                       throws DOMException;
  public float getAnimVal( );
}
