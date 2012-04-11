
package flash.util;

import java.io.*;

public final class URLEncoder
{
	public static final String charset = "UTF8"; //$NON-NLS-1$

	private URLEncoder()
	{
	}

	public static final String encode(String s)
	{
		try
		{
			return encode(s, charset);
		}
		catch (UnsupportedEncodingException ex)
		{
			throw new IllegalArgumentException(charset);
		}
	}

	public static final String encode(String s, String enc) throws UnsupportedEncodingException
	{
		if (!needsEncoding(s))
		{
			return s;
		}

		int length = s.length();

		StringBuilder out = new StringBuilder(length);

		ByteArrayOutputStream buf = new ByteArrayOutputStream(10); // why 10? w3c says so.

		BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(buf, enc));

		for (int i = 0; i < length; i++)
		{
			int c = s.charAt(i);
			if (c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' || c >= '0' && c <= '9' || c == ' ')
			{
				if (c == ' ')
				{
					c = '+';
				}

				toHex(out, buf.toByteArray());
				buf.reset();

				out.append((char) c);
			}
			else
			{
				try
				{
					writer.write(c);

					if (c >= 0xD800 && c <= 0xDBFF && i < length - 1)
					{
						int d = s.charAt(i + 1);
						if (d >= 0xDC00 && d <= 0xDFFF)
						{
							writer.write(d);
							i++;
						}
					}

					writer.flush();
				}
				catch (IOException ex)
				{
					throw new IllegalArgumentException(s);
				}
			}
		}

		toHex(out, buf.toByteArray());

		return out.toString();
	}

	private static final void toHex(StringBuilder buffer, byte[] b)
	{
		for (int i = 0; i < b.length; i++)
		{
			buffer.append('%');

			char ch = Character.forDigit((b[i] >> 4) & 0xF, 16);
			if (Character.isLetter(ch))
			{
				ch -= 32;
			}
			buffer.append(ch);

			ch = Character.forDigit(b[i] & 0xF, 16);
			if (Character.isLetter(ch))
			{
				ch -= 32;
			}
			buffer.append(ch);
		}
	}

	private static final boolean needsEncoding(String s)
	{
		if (s == null)
		{
			return false;
		}

		int length = s.length();

		for (int i = 0; i < length; i++)
		{
			int c = s.charAt(i);
			if (c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' || c >= '0' && c <= '9')
			{
				// keep going
			}
			else
			{
				return true;
			}
		}

		return false;
	}
}
