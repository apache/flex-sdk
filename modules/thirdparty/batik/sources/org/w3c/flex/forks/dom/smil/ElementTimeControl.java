package org.w3c.flex.forks.dom.smil;

import org.w3c.dom.DOMException;

public interface ElementTimeControl {
    public boolean beginElement()
	throws DOMException;
    
    public boolean beginElementAt(float offset)
	throws DOMException;
    
    public boolean endElement()
	throws DOMException;
    
    public boolean endElementAt(float offset)
	throws DOMException;
    
}
