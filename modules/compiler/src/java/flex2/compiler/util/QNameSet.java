
package flex2.compiler.util;

import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

/**
 * This class represents a set of QNames.  It includes handy methods,
 * like contains(String, String), which allow performing collection
 * operations without having to create a new QName.
 *
 * @author Clement Wong
 */
public class QNameSet extends HashSet<QName>
{
	private static final long serialVersionUID = 7880415481059845329L;

    public QNameSet()
	{
		super();
		key = new QName();
	}

	public QNameSet(int size)
	{
		super(size);
		key = new QName();
	}

	public QNameSet(Collection<? extends QName> c)
	{
		super(c);
		key = new QName();
	}

	private QName key;

	public boolean contains(String ns, String name)
	{
		key.setNamespace(ns);
		key.setLocalPart(name);
		return contains(key);
	}

	public boolean add(String ns, String name)
	{
		if (!contains(ns, name))
		{
			return add(new QName(ns, name));
		}
		else
		{
			return false;
		}
	}

	public QName first()
	{
		Iterator i = iterator();
		return (i.hasNext()) ? (QName) i.next() : null;
	}

    public Set<String> getStringSet()
    {
        HashSet<String> set = new HashSet<String>();
        for (Iterator<QName> it = this.iterator(); it.hasNext();)
            set.add( it.next().toString() );

        assert set.size() == this.size();
        return set;
    }

    public String toString()
    {
        StringBuilder sb = new StringBuilder();
        for (Iterator<QName> it = this.iterator(); it.hasNext();)
        {
            sb.append( it.next().toString() );
            if (it.hasNext())
                sb.append(";");
        }
        return sb.toString();
    }
}
