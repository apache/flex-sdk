/*
 * Copyright  2001-2002,2004 The Apache Software Foundation
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
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

package flex2.compiler.swc.zip;

import flex2.compiler.swc.SwcException;

import java.util.zip.CRC32;

/**
 * Adds Unix file permission and UID/GID fields as well as symbolic
 * link handling.
 *
 * <p>This class uses the ASi extra field in the format:
 * <pre>
 *         Value         Size            Description
 *         -----         ----            -----------
 * (Unix3) 0x756e        Short           tag for this extra block type
 *         TSize         Short           total data size for this block
 *         CRC           Long            CRC-32 of the remaining data
 *         Mode          Short           file permissions
 *         SizDev        Long            symlink'd size OR major/minor dev num
 *         UID           Short           user ID
 *         GID           Short           group ID
 *         (var.)        variable        symbolic link filename
 * </pre>
 * taken from appnote.iz (Info-ZIP note, 981119) found at <a
 * href="ftp://ftp.uu.net/pub/archiving/zip/doc/">ftp://ftp.uu.net/pub/archiving/zip/doc/</a></p>

 *
 * <p>Short is two bytes and Long is four bytes in big endian byte and
 * word order, device numbers are currently not supported.</p>
 *
 * @version $Revision: 1.1 $
 */
public class AsiExtraField implements ZipExtraField, UnixStat, Cloneable {

    private static final ZipShort HEADER_ID = new ZipShort(0x756E);

    /**
     * Standard Unix stat(2) file mode.
     *
     * @since 1.1
     */
    private int mode = 0;
    /**
     * User ID.
     *
     * @since 1.1
     */
    private int uid = 0;
    /**
     * Group ID.
     *
     * @since 1.1
     */
    private int gid = 0;
    /**
     * File this entry points to, if it is a symbolic link.
     *
     * <p>empty string - if entry is not a symbolic link.</p>
     *
     * @since 1.1
     */
    private String link = "";
    /**
     * Is this an entry for a directory?
     *
     * @since 1.1
     */
    private boolean dirFlag = false;

    /**
     * Instance used to calculate checksums.
     *
     * @since 1.1
     */
    private CRC32 crc = new CRC32();

    public AsiExtraField() {
    }

    /**
     * The Header-ID.
     *
     * @since 1.1
     */
    public ZipShort getHeaderId() {
        return HEADER_ID;
    }

    /**
     * Length of the extra field in the local file data - without
     * Header-ID or length specifier.
     *
     * @since 1.1
     */
    public ZipShort getLocalFileDataLength() {
        return new ZipShort(4         // CRC
                          + 2         // Mode
                          + 4         // SizDev
                          + 2         // UID
                          + 2         // GID
                          + getLinkedFile().getBytes().length);
    }

    /**
     * Delegate to local file data.
     *
     * @since 1.1
     */
    public ZipShort getCentralDirectoryLength() {
        return getLocalFileDataLength();
    }

    /**
     * The actual data to put into local file data - without Header-ID
     * or length specifier.
     *
     * @since 1.1
     */
    public byte[] getLocalFileDataData() {
        // CRC will be added later
        byte[] data = new byte[getLocalFileDataLength().getValue() - 4];
        System.arraycopy((new ZipShort(getMode())).getBytes(), 0, data, 0, 2);

        byte[] linkArray = getLinkedFile().getBytes();
        System.arraycopy((new ZipLong(linkArray.length)).getBytes(),
                         0, data, 2, 4);

        System.arraycopy((new ZipShort(getUserId())).getBytes(),
                         0, data, 6, 2);
        System.arraycopy((new ZipShort(getGroupId())).getBytes(),
                         0, data, 8, 2);

        System.arraycopy(linkArray, 0, data, 10, linkArray.length);

        crc.reset();
        crc.update(data);
        long checksum = crc.getValue();

        byte[] result = new byte[data.length + 4];
        System.arraycopy((new ZipLong(checksum)).getBytes(), 0, result, 0, 4);
        System.arraycopy(data, 0, result, 4, data.length);
        return result;
    }

    /**
     * Delegate to local file data.
     *
     * @since 1.1
     */
    public byte[] getCentralDirectoryData() {
        return getLocalFileDataData();
    }

    /**
     * Set the user id.
     *
     * @since 1.1
     */
    public void setUserId(int uid) {
        this.uid = uid;
    }

    /**
     * Get the user id.
     *
     * @since 1.1
     */
    public int getUserId() {
        return uid;
    }

    /**
     * Set the group id.
     *
     * @since 1.1
     */
    public void setGroupId(int gid) {
        this.gid = gid;
    }

    /**
     * Get the group id.
     *
     * @since 1.1
     */
    public int getGroupId() {
        return gid;
    }

    /**
     * Indicate that this entry is a symbolic link to the given filename.
     *
     * @param name Name of the file this entry links to, empty String
     *             if it is not a symbolic link.
     *
     * @since 1.1
     */
    public void setLinkedFile(String name) {
        link = name;
        mode = getMode(mode);
    }

    /**
     * Name of linked file
     *
     * @return name of the file this entry links to if it is a
     *         symbolic link, the empty string otherwise.
     *
     * @since 1.1
     */
    public String getLinkedFile() {
        return link;
    }

    /**
     * Is this entry a symbolic link?
     *
     * @since 1.1
     */
    public boolean isLink() {
        return getLinkedFile().length() != 0;
    }

    /**
     * File mode of this file.
     *
     * @since 1.1
     */
    public void setMode(int mode) {
        this.mode = getMode(mode);
    }

    /**
     * File mode of this file.
     *
     * @since 1.1
     */
    public int getMode() {
        return mode;
    }

    /**
     * Indicate whether this entry is a directory.
     *
     * @since 1.1
     */
    public void setDirectory(boolean dirFlag) {
        this.dirFlag = dirFlag;
        mode = getMode(mode);
    }

    /**
     * Is this entry a directory?
     *
     * @since 1.1
     */
    public boolean isDirectory() {
        return dirFlag && !isLink();
    }

    /**
     * Populate data from this array as if it was in local file data.
     *
     * @since 1.1
     */
    public void parseFromLocalFileData(byte[] data, int offset, int length)
        throws SwcException {

        long givenChecksum = (new ZipLong(data, offset)).getValue();
        byte[] tmp = new byte[length - 4];
        System.arraycopy(data, offset + 4, tmp, 0, length - 4);
        crc.reset();
        crc.update(tmp);
        long realChecksum = crc.getValue();
        if (givenChecksum != realChecksum) {
            throw new SwcException.BadCRC(Long.toHexString(givenChecksum),
		            Long.toHexString(realChecksum));
        }

        int newMode = (new ZipShort(tmp, 0)).getValue();
        byte[] linkArray = new byte[(int) (new ZipLong(tmp, 2)).getValue()];
        uid = (new ZipShort(tmp, 6)).getValue();
        gid = (new ZipShort(tmp, 8)).getValue();

        if (linkArray.length == 0) {
            link = "";
        } else {
            System.arraycopy(tmp, 10, linkArray, 0, linkArray.length);
            link = new String(linkArray);
        }
        setDirectory((newMode & DIR_FLAG) != 0);
        setMode(newMode);
    }

    /**
     * Get the file mode for given permissions with the correct file type.
     *
     * @since 1.1
     */
    protected int getMode(int mode) {
        int type = FILE_FLAG;
        if (isLink()) {
            type = LINK_FLAG;
        } else if (isDirectory()) {
            type = DIR_FLAG;
        }
        return type | (mode & PERM_MASK);
    }

}
