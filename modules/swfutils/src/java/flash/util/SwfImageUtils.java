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

import java.io.OutputStream;
import java.io.IOException;

/**
 * A variety of utilities for dealing with the image formats that are
 * part of the SWF spec.
 *
 * @author Roger Gonzalez
 */
public class SwfImageUtils
{
    private static class JPEGIterator
    {
        private byte[] jpeg = null;
        private int offset = 0;
        private int length = 0;
        private int nextOffset = -1;
        private boolean valid = false;
        private byte code;

        public JPEGIterator( byte[] jpeg )
        {
            this.jpeg = jpeg;
            reset();
        }

        public boolean valid()
        {
            return this.valid;
        }

        public byte code()
        {
            return this.code;
        }

        public int length()
        {
            return this.length;
        }

        public int size()
        {
            if ( !valid )
                return -1;

            if ( nextOffset == -1 )
                return jpeg.length - offset;
            else
                return nextOffset - offset;
        }


        public int offset()
        {
            return this.offset;
        }

        public boolean reset()
        {
            valid = ((jpeg.length >= 4)
                  && (jpeg[0] == (byte)0xff)
                  && (jpeg[1] == (byte)0xd8)
                  && (jpeg[jpeg.length-2] == (byte)0xff)
                  && (jpeg[jpeg.length-1] == (byte)0xd9));
            offset = 0;
            nextOffset = offsetOfNextBlock();
            code = jpeg[1];
            length = 0;
            return valid;
        }

        public int offsetOfNextBlock()
        {
            int i = offset + 2 + length;

            while (i < jpeg.length)
            {
                if ((code == (byte)0xda) && (jpeg[i] != (byte) 0xff))
                    ++i;
                else if (i+1 >= jpeg.length)
                    return -1;
                else if ( jpeg[i+1] == (byte) 0xff ) // padding
                    ++i;
                else if ((code == (byte)0xda) && (jpeg[i+1] == (byte) 0x00))
                    i += 2;
                else
                    break;
            }

            return i;
        }

        public boolean next()
        {
            if (!valid)
                return false;

            // entry state assumes that we are on the
            // start of a valid record, i.e. that
            // offset points at 0xff and that offset+1
            // is a code.  if the current record has
            // a length, it is assumed to be set.

            offset = nextOffset;
            if ((offset >= jpeg.length) || (offset == -1))
            {
                valid = false;
                offset = jpeg.length;
                return false;
            }

            code = jpeg[offset+1];

            if ((code == (byte) 0x00) || (code == (byte) 0x01)
                || ((code >= (byte)0xd0) && (code <= (byte)0xd9)))
            {
                length = 0;
            }
            else if (offset + 3 >= jpeg.length)
                valid = false;
            else
            {
                length = ((jpeg[offset+2]&0xff)<<8)
                       +  (jpeg[offset+3]&0xff);
            }
            nextOffset = offsetOfNextBlock();
            return valid;
        }
    }

    public static class JPEG
    {
        public byte[] table;
        public byte[] data;

        private int width;
        private int height;

        public JPEG( byte[] table, byte[] data )
        {
            this.table = table;
            this.data = data;

            validate();
        }

        public JPEG( byte[] jpeg, boolean doSplit )
        {
            if (doSplit)
                split( jpeg );
            else
                data = jpeg;

            validate();
        }

        public int getWidth()
        {
            return width;
        }

        public int getHeight()
        {
            return height;
        }

        static public boolean markerIsSOF( byte code )
        {
            return ((code >= (byte)0xc0)
                    && (code <= (byte)0xcf)
                    && (code != (byte)0xc4)
                    && (code != (byte)0xcc));
        }

        public boolean validate()
        {
            if (table != null)
            {
                // Confirm that there are only db and c4 markers...

                JPEGIterator it = new JPEGIterator( table );

                if ( !it.valid() )  // constructor does an SOI/EOI check...
                    return false;
                it.next();

                while (it.valid() && (it.code() != (byte)0xd9))
                {
                    if ((it.code() != (byte)0xc4) && (it.code() != (byte)0xdb))
                        return false;
                    it.next();
                }

                if (it.offset() != table.length-2)
                    return false;
            }

            if (data == null)
                return false;

            JPEGIterator it = new JPEGIterator( data );

            if ( !it.valid() )
                return false;

            boolean foundSOS = false;
            boolean foundSOF = false;

            while (it.valid())
            {
                if (it.code() == (byte)0xda)
                    foundSOS = true;

                if (!foundSOF && markerIsSOF(it.code()))
                {
                    foundSOF = true;
                    height = (((data[it.offset()+5]&0xff)<<8)
                              |(data[it.offset()+6]&0xff));

                    width = (((data[it.offset()+7]&0xff)<<8)
                             |(data[it.offset()+8]&0xff));

                    if ((width == 0) || (height == 0))
                        return false;
                }
                it.next();
            }
            return ( foundSOS && foundSOF && (it.offset() == data.length));
        }

        private void split( byte[] jpeg ) throws IllegalStateException
        {
            JPEGIterator it = new JPEGIterator( jpeg );
            int tablesize = 4;

            while (it.valid())
            {
                if ((it.code() == (byte)0xdb) || (it.code() == (byte)0xc4))
                    tablesize += it.length() + 2;
                it.next();
            }

            table = new byte[tablesize];
            int tableoffset = 0;
            table[tableoffset++] = (byte) 0xff;
            table[tableoffset++] = (byte) 0xd8;

            int datasize = 4 + (jpeg.length - tablesize);
            int dataoffset = 0;
            data = new byte[datasize];

            it.reset();
            while (it.valid())
            {
                if ((it.code() == (byte)0xdb) || (it.code() == (byte)0xc4))
                {
                    java.lang.System.arraycopy( jpeg,
                                                it.offset(),
                                                table,
                                                tableoffset,
                                                it.size() );
                    tableoffset += it.size();
                }
                else
                {
                    java.lang.System.arraycopy( jpeg,
                                                it.offset(),
                                                data,
                                                dataoffset,
                                                it.size() );
                    dataoffset += it.size();
                }
                it.next();
            }
            table[tableoffset++] = (byte) 0xff;
            table[tableoffset++] = (byte) 0xd9;

            if ( (tableoffset < table.length) || (dataoffset < data.length) )
                throw new IllegalStateException( "JPEG data is corrupt!" );
        }

        public void write( OutputStream out ) throws IOException
        {
            // Simple case: non-split JPEG
            if (table == null)
            {
                out.write( data );
                return;
            }

            // Harder case... emit the tables just before the SOS marker.
            int i = 0;
            while (i < data.length)
            {
                if ( data[i] != (byte) 0xff )
                {
                    ++i;
                    continue;
                }
                if (i + 1 >= data.length)
                    return;


                byte marker = data[i+1];

                if (marker == (byte) 0xff)
                {
                    ++i;
                    continue;
                }

                if ((marker == (byte) 0x00)
                    || (marker == (byte) 0x01)
                    || ((marker >= (byte) 0xd0) && (marker <= (byte) 0xd9 )))
                {
                    i += 2;
                    continue;
                }
                if (marker == (byte) 0xda)    // Start of Scan, aka SOS
                {
                    out.write( data, 0, i );
                    out.write( table, 2, table.length - 4 );
                    out.write( data, i, data.length - i );
                    return;
                }
                else
                {
                    if (i + 3 >= data.length)
                        return;

                    int length =  ((data[i+2]&0xff)<<8) + (data[i+3]&0xff);
                    i += length;
                }
            }
        }

    }

    // You don't care about this.  Move along.
    public static void jpegDebugSegments( byte[] data )
    {
        JPEGIterator it = new JPEGIterator( data );

        while (it.valid())
        {
            System.out.print( "offset " + it.offset() + ": " );

            System.out.print( Integer.toHexString(it.code() & 0xff) + " (");

            switch( it.code() )
            {
                case (byte)0xc0: System.out.print( "SOF0"); break;
                case (byte)0xc1: System.out.print( "SOF1"); break;
                case (byte)0xc2: System.out.print( "SOF2"); break;
                case (byte)0xc3: System.out.print( "SOF3"); break;
                case (byte)0xc4: System.out.print( "DHT"); break;
                case (byte)0xc5: System.out.print( "SOF5"); break;
                case (byte)0xc6: System.out.print( "SOF6"); break;
                case (byte)0xc7: System.out.print( "SOF7"); break;
                case (byte)0xc8: System.out.print( "JPGext"); break;
                case (byte)0xc9: System.out.print( "SOF9"); break;
                case (byte)0xca: System.out.print( "SOF10"); break;
                case (byte)0xcb: System.out.print( "SOF11"); break;
                case (byte)0xcc: System.out.print( "DAC"); break;
                case (byte)0xcd: System.out.print( "SOF13"); break;
                case (byte)0xce: System.out.print( "SOF14"); break;
                case (byte)0xcf: System.out.print( "SOF15"); break;

                case (byte)0xd0: System.out.print( "RST0"); break;
                case (byte)0xd1: System.out.print( "RST1"); break;
                case (byte)0xd2: System.out.print( "RST2"); break;
                case (byte)0xd3: System.out.print( "RST3"); break;
                case (byte)0xd4: System.out.print( "RST4"); break;
                case (byte)0xd5: System.out.print( "RST5"); break;
                case (byte)0xd6: System.out.print( "RST6"); break;
                case (byte)0xd7: System.out.print( "RST7"); break;

                case (byte)0xd8: System.out.print( "SOI"); break;
                case (byte)0xd9: System.out.print( "EOI"); break;

                case (byte)0xda: System.out.print( "SOS"); break;
                case (byte)0xdb: System.out.print( "DQT"); break;
                case (byte)0xdc: System.out.print( "DNL"); break;
                case (byte)0xdd: System.out.print( "DRI"); break;
                case (byte)0xde: System.out.print( "DHP"); break;
                case (byte)0xdf: System.out.print( "EXP"); break;

                case (byte)0xe0: System.out.print( "APP0"); break;
                case (byte)0xe1: System.out.print( "APP1"); break;
                case (byte)0xe2: System.out.print( "APP2"); break;
                case (byte)0xe3: System.out.print( "APP3"); break;
                case (byte)0xe4: System.out.print( "APP4"); break;
                case (byte)0xe5: System.out.print( "APP5"); break;
                case (byte)0xe6: System.out.print( "APP6"); break;
                case (byte)0xe7: System.out.print( "APP7"); break;
                case (byte)0xe8: System.out.print( "APP8"); break;
                case (byte)0xe9: System.out.print( "APP9"); break;
                case (byte)0xea: System.out.print( "APP10"); break;
                case (byte)0xeb: System.out.print( "APP11"); break;
                case (byte)0xec: System.out.print( "APP12"); break;
                case (byte)0xed: System.out.print( "APP13"); break;
                case (byte)0xee: System.out.print( "APP14"); break;
                case (byte)0xef: System.out.print( "APP15"); break;

                case (byte)0xf0: System.out.print( "JPG0"); break;
                case (byte)0xf1: System.out.print( "JPG1"); break;
                case (byte)0xf2: System.out.print( "JPG2"); break;
                case (byte)0xf3: System.out.print( "JPG3"); break;
                case (byte)0xf4: System.out.print( "JPG4"); break;
                case (byte)0xf5: System.out.print( "JPG5"); break;
                case (byte)0xf6: System.out.print( "JPG6"); break;
                case (byte)0xf7: System.out.print( "JPG7"); break;
                case (byte)0xf8: System.out.print( "JPG8"); break;
                case (byte)0xf9: System.out.print( "JPG9"); break;
                case (byte)0xfa: System.out.print( "JPG10"); break;
                case (byte)0xfb: System.out.print( "JPG11"); break;
                case (byte)0xfc: System.out.print( "JPG12"); break;
                case (byte)0xfd: System.out.print( "JPG13"); break;
                case (byte)0xfe: System.out.print( "COM"); break;

                case (byte)0x00: System.out.print( "00?"); break;
                case (byte)0x01: System.out.print( "TEM"); break;
                    default: System.out.print("???"); break;
            }
            System.out.print( ") ");

            if ((it.code() == (byte) 0x00)
                || (it.code() == (byte) 0x01)
                || ((it.code() >= (byte) 0xd0) && (it.code() <= (byte) 0xd9 )))
                System.out.print( "len=0");
            else
                System.out.print( "len=" + it.length() );

            System.out.print( " size=" + it.size() );

            int i = it.offset();

            if ( it.code() == (byte)0xfe)
            {
                byte[] comment = new byte[it.length() + 1];
                for ( int c = 0; c < it.length(); ++c )
                    comment[c] = data[i+2+c];

                System.out.print( " COMMENT='" + comment + "'");
            }

            if ( it.code() == (byte)0xe0)
            {
                if (( data[i+4] == 'J')
                    && (data[i+5] == 'F')
                    && (data[i+6] == 'I')
                    && (data[i+7] == 'F')
                    && (data[i+8] == 0))
                    System.out.print(" JFIF");
            }

            if ( (it.code() == (byte)0xc0)
                 || (it.code() == (byte)0xc1)
                 || (it.code() == (byte)0xc2)
                 || (it.code() == (byte)0xc3)
                 || (it.code() == (byte)0xc5)
                 || (it.code() == (byte)0xc6)
                 || (it.code() == (byte)0xc7)
                 || (it.code() == (byte)0xc8)
                 || (it.code() == (byte)0xc9)
                 || (it.code() == (byte)0xca)
                 || (it.code() == (byte)0xcb)
                 || (it.code() == (byte)0xcd)
                 || (it.code() == (byte)0xce)
                 || (it.code() == (byte)0xcf))
            {
                System.out.print( " precision = " + data[i+4]);
                int y = ((data[i+5]&0xff)<<8) | (data[i+6]&0xff);
                int x = ((data[i+7]&0xff)<<8) | (data[i+8]&0xff);
                System.out.print( " dimensions = " + x + "," + y );
            }


            System.out.println(".");
            it.next();
        }
    }
}
