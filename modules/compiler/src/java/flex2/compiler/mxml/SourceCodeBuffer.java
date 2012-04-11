
package flex2.compiler.mxml;

import java.io.StringWriter;

/**
 * This class is used to track and report the line number during code
 * generation.
 *
 * @author Clement Wong
 */
public final class SourceCodeBuffer extends StringWriter
{
	public SourceCodeBuffer(int initialSize)
	{
		super(initialSize);
	}

	public SourceCodeBuffer()
	{
		this(1024);
	}

	private int currentLine = 1;

	public void write(int c)
	{
		super.write(c);
		if (c == '\n')
		{
			currentLine++;
		}
	}

	public void write(char cbuf[], int off, int len)
	{
		super.write(cbuf, off, len);
		for (int i = off; i < off + len; i++)
		{
			if (cbuf[i] == '\n')
			{
				currentLine++;
			}
		}
	}

	public void write(String str)
	{
		super.write(str);
		for (int i = 0, len = str.length(); i < len; i++)
		{
			if (str.charAt(i) == '\n')
			{
				currentLine++;
			}
		}
	}

	public void write(String str, int off, int len)
	{
		super.write(str, off, len);
		for (int i = off; i < off + len; i++)
		{
			if (str.charAt(i) == '\n')
			{
				currentLine++;
			}
		}
	}

	public int getLineNumber()
	{
		return currentLine;
	}
}
