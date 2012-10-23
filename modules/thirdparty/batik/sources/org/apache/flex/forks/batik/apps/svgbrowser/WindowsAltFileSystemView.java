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
package org.apache.flex.forks.batik.apps.svgbrowser;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;

import javax.swing.filechooser.FileSystemView;

/**
 * Work around FileSystemView implementation bug on the Windows
 * platform. See:
 *
 * <a href="http://forums.java.sun.com/thread.jsp?forum=38&thread=71491">
 * Using JFileChooser in WebStart-deployed application</a>
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: WindowsAltFileSystemView.java 479616 2006-11-27 13:41:44Z dvholten $
 */

// This class is necessary due to an annoying bug on Windows NT where
// instantiating a JFileChooser with the default FileSystemView will
// cause a "drive A: not ready" error every time. I grabbed the
// Windows FileSystemView impl from the 1.3 SDK and modified it so
// as to not use java.io.File.listRoots() to get fileSystem roots.
// java.io.File.listRoots() does a SecurityManager.checkRead() which
// causes the OS to try to access drive A: even when there is no disk,
// causing an annoying "abort, retry, ignore" popup message every time
// we instantiate a JFileChooser!
//
// Instead of calling listRoots() we use a straightforward alternate
// method of getting file system roots.

class WindowsAltFileSystemView extends FileSystemView {
    public static final String EXCEPTION_CONTAINING_DIR_NULL
        = "AltFileSystemView.exception.containing.dir.null";

    public static final String EXCEPTION_DIRECTORY_ALREADY_EXISTS
        = "AltFileSystemView.exception.directory.already.exists";

    public static final String NEW_FOLDER_NAME =
        " AltFileSystemView.new.folder.name";

    public static final String FLOPPY_DRIVE =
        "AltFileSystemView.floppy.drive";

    /**
     * Returns true if the given file is a root.
     */
    public boolean isRoot(File f) {
        if(!f.isAbsolute()) {
            return false;
        }

        String parentPath = f.getParent();
        if(parentPath == null) {
            return true;
        } else {
            File parent = new File(parentPath);
            return parent.equals(f);
        }
    }

    /**
     * creates a new folder with a default folder name.
     */
    public File createNewFolder(File containingDir) throws
        IOException {
        if(containingDir == null) {
            throw new IOException(Resources.getString(EXCEPTION_CONTAINING_DIR_NULL));
        }
        File newFolder = null;
        // Using NT's default folder name
        newFolder = createFileObject(containingDir,
                                     Resources.getString(NEW_FOLDER_NAME));
        int i = 2;
        while (newFolder.exists() && (i < 100)) {
            newFolder = createFileObject
                (containingDir, Resources.getString(NEW_FOLDER_NAME) + " (" + i + ')' );
            i++;
        }

        if(newFolder.exists()) {
            throw new IOException
                (Resources.formatMessage(EXCEPTION_DIRECTORY_ALREADY_EXISTS,
                                         new Object[]{newFolder.getAbsolutePath()}));
        } else {
            newFolder.mkdirs();
        }

        return newFolder;
    }

    /**
     * Returns whether a file is hidden or not. On Windows
     * there is currently no way to get this information from
     * io.File, therefore always return false.
     */
    public boolean isHiddenFile(File f) {
        return false;
    }

    /**
     * Returns all root partitians on this system. On Windows, this
     * will be the A: through Z: drives.
     */
    public File[] getRoots() {

        List rootsVector = new ArrayList();

        // Create the A: drive whether it is mounted or not
        FileSystemRoot floppy = new FileSystemRoot(Resources.getString(FLOPPY_DRIVE)
                                                   + "\\");
        rootsVector.add(floppy);

        // Run through all possible mount points and check
        // for their existance.
        for (char c = 'C'; c <= 'Z'; c++) {
            char[] device = {c, ':', '\\'};
            String deviceName = new String(device);
            File deviceFile = new FileSystemRoot(deviceName);
            if (deviceFile != null && deviceFile.exists()) {
                rootsVector.add(deviceFile);
            }
        }
        File[] roots = new File[rootsVector.size()];
        rootsVector.toArray(roots);
        return roots;
    }

    class FileSystemRoot extends File {
        public FileSystemRoot(File f) {
            super(f, "");
        }

        public FileSystemRoot(String s) {
            super(s);
        }

        public boolean isDirectory() {
            return true;
        }
    }

}

