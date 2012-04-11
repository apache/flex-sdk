
package macromedia.asc.util;

import macromedia.asc.semantics.*;

import java.util.TreeMap;
import java.util.Comparator;

/**
 * @author Jeff Dyer
 */
public final class Qualifiers extends TreeMap<ObjectValue, Integer>
{
	private static Comparator c = new ObjectValue.ObjectValueCompare();

	public Qualifiers()
	{            
		super(c);
	}

}
