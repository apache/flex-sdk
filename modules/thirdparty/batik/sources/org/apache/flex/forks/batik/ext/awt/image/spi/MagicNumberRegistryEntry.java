/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.ext.awt.image.spi;

import java.io.IOException;
import java.io.InputStream;
import java.io.StreamCorruptedException;

/**
 * This Image tag registry entry is built around the notion of magic
 * numbers.  These are strings of bytes that are at a well known
 * location in the input stream (often the start).
 *
 * This base class can handle the compatiblity check based on a list
 * of Magic Numbers that correspond to your format (Some formats have
 * multiple magic numbers associated with them).
 *
 * @version $Id: MagicNumberRegistryEntry.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public abstract class MagicNumberRegistryEntry
    extends AbstractRegistryEntry
    implements StreamRegistryEntry {

    public static final float PRIORITY = 1000;

    /**
     * Inner class that represents one magic number. Simply consists
     * of an offset in bytes from the start of the file, and a byte
     * array that must match.
     */
    public static class MagicNumber {
        int offset;
        byte [] magicNumber;
        byte [] buffer;

        /**
         *  Constructor.
         * @param offset the location of the magic number in file.
         * @param magicNumber the sequence of bytes that must match.
         */
        public MagicNumber(int offset, byte[]magicNumber) {
            this.offset = offset;
            this.magicNumber = magicNumber.clone();
            buffer = new byte[magicNumber.length];
        }

        /**
         * Returns the maximum number of bytes that will be read for
         * this magic number compairison.
         */
        int getReadlimit() {
            return offset+magicNumber.length;
        }

        /**
         * Performs the check of is.
         */
        boolean isMatch(InputStream is)
            throws StreamCorruptedException {
            int idx = 0;
            is.mark(getReadlimit());
            try {
                // Skip to the offset location.
                while (idx < offset) {
                    int rn = (int)is.skip(offset-idx);
                    if (rn == -1) return false;
                    idx += rn;
                }

                idx = 0;
                while (idx < buffer.length) {
                    int rn = is.read(buffer, idx, buffer.length-idx);
                    if (rn == -1) return false;
                    idx += rn;
                }

                for (int i=0; i<magicNumber.length; i++) {
                    if (magicNumber[i] != buffer[i])
                        return false;
                }
            } catch (IOException ioe) {
                return false;
            } finally {
                try {
                    // Make sure we always put back what we have read.
                    // If this throws an IOException then the current
                    // stream should be closed an reopend by the registry.
                    is.reset();
                } catch (IOException ioe) {
                    throw new StreamCorruptedException(ioe.getMessage());
                }
            }
            return true;
        }
    }

    /** The list of magic numbers associated with this entry */
    MagicNumber [] magicNumbers;

    /**
     * Constructor, simplifies construction of entry when only
     * one extension and one magic number is required.
     * @param name        Format Name
     * @param priority    the priority of the RegistryEntry
     * @param ext         Standard extension
     * @param mimeType    the supported MIME type
     * @param offset      Offset of magic number
     * @param magicNumber byte array to match.
     */
    public MagicNumberRegistryEntry(String name,
                                    float priority,
                                    String ext,
                                    String mimeType,
                                    int offset, byte[]magicNumber) {
        super(name, priority, ext, mimeType);
        magicNumbers    = new MagicNumber[1];
        magicNumbers[0] = new MagicNumber(offset, magicNumber);
    }

    /**
     * Constructor, simplifies construction of entry when only
     * one extension and one magic number is required.
     * @param name        Format Name
     * @param ext         Standard extension
     * @param mimeType    the supported MIME type
     * @param offset      Offset of magic number
     * @param magicNumber byte array to match.
     */
    public MagicNumberRegistryEntry(String name,
                                    String ext,
                                    String mimeType,
                                    int offset, byte[] magicNumber) {
        this(name, PRIORITY, ext, mimeType, offset, magicNumber);
    }

    /**
     * Constructor, simplifies construction of entry when only
     * one extension is required.
     * @param name         Format Name
     * @param priority     the priority of the RegistryEntry
     * @param ext          Standard extension
     * @param mimeType     the supported MIME type
     * @param magicNumbers Array of magic numbers any of which can match.
     */
    public MagicNumberRegistryEntry(String name,
                                    float priority,
                                    String ext,
                                    String mimeType,
                                    MagicNumber[] magicNumbers) {
        super(name, priority, ext, mimeType);
        this.magicNumbers = magicNumbers;
    }

    /**
     * Constructor, simplifies construction of entry when only
     * one extension is required.
     * @param name         Format Name
     * @param ext          Standard extension
     * @param mimeType     the supported MIME type
     * @param magicNumbers Array of magic numbers any of which can match.
     */
    public MagicNumberRegistryEntry(String name,
                                    String ext,
                                    String mimeType,
                                    MagicNumber[] magicNumbers) {
        this(name, PRIORITY, ext, mimeType, magicNumbers);
    }

    /**
     * Constructor, simplifies construction of entry when only
     * one magic number is required.
     * @param name Format Name
     * @param priority the priority of the RegistryEntry
     * @param exts Standard set of extensions
     * @param mimeTypes array of supported MIME types
     * @param offset Offset of magic number
     * @param magicNumber byte array to match.
     */
    public MagicNumberRegistryEntry(String    name,
                                    float     priority,
                                    String [] exts,
                                    String [] mimeTypes,
                                    int offset, byte[]magicNumber) {
        super(name, priority, exts, mimeTypes);
        magicNumbers    = new MagicNumber[1];
        magicNumbers[0] = new MagicNumber(offset, magicNumber);
    }

    /**
     * Constructor, simplifies construction of entry when only
     * one magic number is required.
     * @param name Format Name
     * @param exts Standard set of extensions
     * @param mimeTypes array of supported MIME types
     * @param offset Offset of magic number
     * @param magicNumbers byte array to match.
     */
    public MagicNumberRegistryEntry(String    name,
                                    String [] exts,
                                    String [] mimeTypes,
                                    int offset, byte[] magicNumbers) {
        this(name, PRIORITY, exts, mimeTypes, offset, magicNumbers);
    }

    /**
     * Constructor
     * @param name Format Name
     * @param priority the priority of the RegistryEntry
     * @param exts Standard set of extensions
     * @param mimeTypes array of supported MIME types
     * @param magicNumbers array of magic numbers any of which can match.
     */
    public MagicNumberRegistryEntry(String    name,
                                    float     priority,
                                    String [] exts,
                                    String [] mimeTypes,
                                    MagicNumber [] magicNumbers) {
        super(name, priority, exts, mimeTypes);
        this.magicNumbers = magicNumbers;
    }

    /**
     * Constructor
     * @param name Format Name
     * @param exts Standard set of extensions
     * @param mimeTypes array of supported MIME types
     * @param magicNumbers array of magic numbers any of which can match.
     */
    public MagicNumberRegistryEntry(String    name,
                                    String [] exts,
                                    String [] mimeTypes,
                                    MagicNumber [] magicNumbers) {
        this(name, PRIORITY, exts, mimeTypes, magicNumbers);
    }

    /**
     * Constructor, allows for overriding the default priority of
     * magic number entries.  This should be needed very rarely since
     * magic number checks are fairly relyable and hence aren't usually
     * sensative to order issues.
     * @param name Format Name
     * @param exts Standard set of extensions
     * @param magicNumbers array of magic numbers any of which can match.
     * @param priority     The priority of this entry (1000 is baseline)
     */
    public MagicNumberRegistryEntry(String         name,
                                    String []      exts,
                                    String []      mimeTypes,
                                    MagicNumber [] magicNumbers,
                                    float          priority) {
        super(name, priority, exts, mimeTypes);
        this.magicNumbers = magicNumbers;
    }

    /**
     * Returns the maximume read ahead needed for all magic numbers.
     */
    public int getReadlimit() {
        int maxbuf = 0;
        for (int i=0; i<magicNumbers.length; i++) {
            int req = magicNumbers[i].getReadlimit();
            if (req > maxbuf) maxbuf = req;
        }
        return maxbuf;
    }

    /**
     * Check if the stream contains an image that can be
     * handled by this format handler
     */
    public boolean isCompatibleStream(InputStream is)
        throws StreamCorruptedException {
        for (int i=0; i<magicNumbers.length; i++) {
            if (magicNumbers[i].isMatch(is))
                return true;
        }

        return false;
    }
}
