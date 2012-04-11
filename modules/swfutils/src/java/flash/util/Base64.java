/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flash.util;

/**
 * Code to read and write Base64-encoded text.  Fairly
 * special-purpose, not quite ready for general streaming as they
 * don't let you drain less than everything that is currently
 * available.
 */
public class Base64
{
    private final static char alphabet[] =
    {
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
        'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
        'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
        'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
        'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
        'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
        'w', 'x', 'y', 'z', '0', '1', '2', '3',
        '4', '5', '6', '7', '8', '9', '+', '/'
    };

    private final static int inverse[] =
    {
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 62, 64, 64, 64, 63,
        52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 64, 64, 64, 64, 64, 64,
        64,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 64, 64, 64, 64, 64,
        64, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 64, 64, 64, 64, 64,
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64
    };

    public static class Decoder
    {
        private int filled = 0;
        private byte data[];
        private int count = 0;
        private int work[] = { 0, 0, 0, 0 };

        public Decoder()
        {
            data = new byte[256];
        }

        public void decode( String encoded )
        {
            int estimate = 1 + encoded.length() * 3 / 4;

            if ( filled + estimate > data.length )
            {
                int length = data.length * 2;
                while ( length < filled + estimate )
                    length *= 2;
                byte[] newdata = new byte[length];

                System.arraycopy( data, 0, newdata, 0, filled );
                data = newdata;
            }

            for (int i = 0; i < encoded.length(); ++i )
            {
                char c = encoded.charAt(i);

                if ( c == '=' )
                    work[count++] = -1;
                else if ( inverse[c] != 64 )
                    work[count++] = inverse[c];
                else
                    continue;

                if ( count == 4 )
                {
                    count = 0;
                    data[filled++] = (byte)((work[0] << 2) | ((work[1]&0xff) >> 4));

                    if ( work[2] == -1 )
                        break;

                    data[filled++] = (byte)((work[1] << 4) | ((work[2]&0xff) >> 2));

                    if ( work[3] == -1 )
                        break;

                    data[filled++] = (byte)((work[2] << 6) | work[3]);
                }

            }
        }
        public byte[] drain()
        {
            byte[] r = new byte[filled];
            System.arraycopy( data, 0, r, 0, filled );
            filled = 0;
            return r;
        }

        public byte[] flush() throws IllegalStateException
        {
            if ( count > 0 )
                throw new IllegalStateException( "a partial block (" + count + " of 4 bytes) was dropped, decoded data is probably truncated!");
           return drain();
        }

        public void reset()
        {
            count = 0;
            filled = 0;
        }

    }


    public static class Encoder
    {
        private int work[] = { 0, 0, 0 };
        private int count = 0;
        private int line = 0;
        private StringBuilder output;
        private int wrap = 76;

        public Encoder( int size )
        {
            output = new StringBuilder( size );
        }

        public Encoder( int size, int wrap )
        {
            output = new StringBuilder( size );
            this.wrap = wrap;
        }

        private void encodeBlock()
        {
            output.append( alphabet[(work[0] & 0xFF) >> 2] );
            output.append( alphabet[((work[0] & 0x03) << 4) | ((work[1] & 0xF0) >> 4)] );
            if ( count > 1 )
                output.append( alphabet[((work[1] & 0x0F) << 2) | ((work[2] & 0xC0) >> 6) ] );
            else
                output.append( '=' );

            if ( count > 2 )
                output.append( alphabet[work[2] & 0x3F] );
            else
                output.append( '=' );

            if ( (wrap != -1) && (( line += 4 ) == wrap ))
            {
                output.append( '\n' );
                line = 0;
            }
        }

        public void encode( byte[] data )
        {
            encode( data, 0, data.length );
        }
        public void encode( byte[] data, int offset, int length )
        {
            int plainIndex = offset;

            while ( plainIndex < (offset + length) )
            {
                work[count] = data[plainIndex];
                count++;

                if ( count == work.length || ((offset + length) - plainIndex) == 1 )
                {
                    encodeBlock();
                    count = 0;
                    work[0] = 0;
                    work[1] = 0;
                    work[2] = 0;
                }
                plainIndex++;
            }
        }

        public String drain()
        {
            String r = output.toString();
            output.setLength(0);
            return r;
        }

        public String flush()
        {
            if ( count > 0 )
                encodeBlock();

            String r = drain();
            count = 0;
            line = 0;
            work[0] = 0;
            work[1] = 0;
            work[2] = 0;
            return r;
        }


    }

    public static void main(String[] args)
	{
        boolean printData = false;
        int randomLimit = 500;

        byte raw [] = new byte[(int)(Math.random() * randomLimit)];

        for ( int i = 0; i < raw.length; ++i )
        {
            if (( i % 1024 ) < 256 )
                raw[i] = (byte)(i % 1024);
            else
                raw[i] = (byte)((int)(Math.random() * 255) - 128);
        }
        Base64.Encoder encoder = new Base64.Encoder(100);
        encoder.encode( raw  );

        String encoded = encoder.drain();

        Base64.Decoder decoder = new Base64.Decoder();
        decoder.decode( encoded );
        byte check[] = decoder.flush();

        String mesg = "Success!";
        if ( check.length != raw.length )
        {
            mesg =  "***** length mismatch!";
        }
        else
        {
            for ( int i = 0; i < check.length; ++i )
            {
                if ( check[i] != raw[i] )
                {
                    mesg =  "***** data mismatch!";
                    break;
                }
            }
        }
        System.out.println(mesg);

        if (printData)
        {
            System.out.println("Decoded: " + new String(raw));
            System.out.println("Encoded: " + encoded);
            System.out.println("Decoded: " + new String(check));
        }

        /*
        if (args.length==0)
        {
            System.err.println("Usage: java util.Base64 filename");
            System.exit(1);
        }

        File f = new File( args[0] );
        URL url = FileUtils.toURL(f);

        InputStream in = url.openStream();
        Base64.Encoder enc = new Base64.Encoder(1024 * 4 / 3 + 2*1024/76);

        byte data [] = new byte[1024];
        while ( true )
        {
            int len = in.read( data );
            if ( len == -1 )
                break;
            enc.encode( data, 0, len );
            System.out.print( enc.drain() );

        }
        System.out.print( enc.flush() );
        */

    }
}
