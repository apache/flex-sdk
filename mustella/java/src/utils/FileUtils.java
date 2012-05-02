/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
package utils;

import java.io.*;
import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;
import java.util.StringTokenizer;
import java.util.Vector;

/**
 * User: dschaffer
 * Date: Mar 8, 2005
 * Time: 11:21:03 AM
 */
public class FileUtils {
    public static String normalizeDir(String dir) {
        if (dir==null) dir=".";
        try {
            dir=new File(dir).getCanonicalPath();
        } catch (IOException e) {
        }
        dir=dir.replace('\\','/');
        if (dir.endsWith("/" ) || dir.endsWith("\\")) {
            dir=dir.substring(0,dir.length()-1);
        }
        return dir;
    }

    public static String normalizeDirOS(String dir) {
        if (dir==null) dir=".";
        try {
            dir=new File(dir).getCanonicalPath();
        } catch (IOException e) {
        }
        dir=dir.replace('\\',File.separatorChar);
        dir=dir.replace('/',File.separatorChar);
        if (dir.endsWith("/" ) || dir.endsWith("\\")) {
            dir=dir.substring(0,dir.length()-1);
        }
        return dir;
    }

    public static String get8Dot3Path(String path) {

        path = normalizeDir(path);
        StringTokenizer tokenizer = new StringTokenizer(path, "/");

        String newPath = "";
        while (tokenizer.hasMoreElements()) {
            String currentToken = (String)tokenizer.nextElement();

            int indexOfDot = currentToken.indexOf(".");
            String beforeDot = indexOfDot > 0? currentToken.substring(0, indexOfDot ) : currentToken;
            String afterDot = indexOfDot > 0? currentToken.substring(indexOfDot) : "/";

            if (beforeDot.length() <= 8) {
                newPath += beforeDot + afterDot;
            } else {
                newPath += beforeDot.substring(0, 6) + "~1" + afterDot;
            }
        }

        if (newPath.substring(newPath.length()).equals("/"))
            newPath = newPath.substring(0, newPath.length() - 1);

        return newPath;
    }

    public static String getDirectory(String file) {
        file=file.replace('\\',File.separatorChar);
        file=file.replace('/',File.separatorChar);
        String dir=file.substring(0,file.lastIndexOf(File.separatorChar));
        return dir;
    }
    public static String getFile(String file) {
        file=file.replace('\\',File.separatorChar);
        file=file.replace('/',File.separatorChar);
        String dir=file.substring(file.lastIndexOf(File.separatorChar)+1);
        return dir;
    }
    public static void writeFile(String name,String contents) throws Exception {
        BufferedWriter bw=new BufferedWriter(new FileWriter(name));
        bw.write(contents);
        bw.flush();
        bw.close();
    }

    public static void writeFileUTF(String name,String contents) throws Exception {
        BufferedWriter bw=new BufferedWriter(new OutputStreamWriter(new FileOutputStream(name), "UTF-8"));
        bw.write(contents);
        bw.flush();
        bw.close();
    }

    public static void writeBinaryFile(String name,String fromName) throws Exception {

        byte byteArr[]=new byte[8192];
        String contents="";
        FileInputStream fin=new FileInputStream(fromName);
        FileOutputStream fos=new FileOutputStream(name);
        int len;
        while ((len=fin.read(byteArr, 0, 8192))!=-1) {
            fos.write(byteArr);
        }
        fin.close();
        fos.close();
    }
    public static String readFile(String name) throws Exception {
        char ch[]=new char[8192];
        String contents="";
        BufferedReader br=new BufferedReader(new FileReader(name));
        int len;
        while ((len=br.read(ch,0,8192))!=-1) {
            contents+=new String(ch,0,len);
        }
        br.close();
        return contents;
    }

    public static String readFileUTF(String name) throws Exception {
        char ch[]=new char[8192];
        String contents="";
        BufferedReader br=new BufferedReader(new InputStreamReader(new FileInputStream(name), "UTF-8"));
        int len;
        while ((len=br.read(ch,0,8192))!=-1) {
            contents+=new String(ch,0,len);
        }
        br.close();
        return contents;
    }

    public static List readLines(String name) throws Exception {
        String contents=readFile(name);
        List lines=new Vector();
        while (contents.indexOf("\n")>-1) {
            String line=contents.substring(0,contents.indexOf("\n"));
            contents=contents.substring(contents.indexOf("\n")+1);
            line=line.trim();
            lines.add(line);
        }
        if (contents.length()>0) {
            lines.add(contents);
        }
        return lines;
    }
    public static void copyFile(String fromFile,String toFile) throws Exception {
        if (new File(toFile).exists()==true) {
            new File(toFile).delete();
        }
        writeFile(toFile,readFile(fromFile));
    }
    public static void copyBinaryFile(String fromFile,String toFile) throws Exception {
	        if (new File(toFile).exists()==true) {
	            new File(toFile).delete();
	        }
	        writeBinaryFile(toFile, fromFile);
    }
    public static void copyDir(String dir,String todir) throws Exception {
        if (new File(todir).exists()==false) {
            new File(todir).mkdirs();
        }
        File d = new File(dir);
        if (!d.isDirectory())
        {
            System.err.println("warning: " + dir + " is not a directory");
            return;
        }
        File files[]=d.listFiles();
        if (files != null)
        {
            for (int i=0;i<files.length;i++) {
                if (files[i].isDirectory()) {
                    copyDir(files[i].toString(),todir+"/"+getFile(files[i].toString()));
                } else {
                    copyFile(files[i].toString(),todir+"/"+getFile(files[i].toString()));
                }
            }
        }

    }

    public static void copyBinaryDir(String dir,String todir) throws Exception {
        if (new File(todir).exists()==false) {
            new File(todir).mkdirs();
        }
        File d = new File(dir);
        if (!d.isDirectory())
        {
            System.err.println("warning: " + dir + " is not a directory");
            return;
        }
        File files[]=d.listFiles();
        if (files != null)
        {
            for (int i=0;i<files.length;i++) {
                if (files[i].isDirectory()) {
                    copyBinaryDir(files[i].toString(),todir+"/"+getFile(files[i].toString()));
                } else {
                    copyBinaryFile(files[i].toString(),todir+"/"+getFile(files[i].toString()));
                }
            }
        }

    }

    public static void deleteFile(String name){
        if (new File(name).exists())
            new File(name).delete();
    }

	/**
	* Deletes a file or directory and all of its contents.
	**/
    public static void recursivelyDelete(String name){
        File curFile = new File(name);
		File subFile = null;
		int i = 0;

		try{
			if (curFile.exists()){
				if(curFile.isDirectory()){
					String[] arrFiles = curFile.list();

					for(i = 0; i < Array.getLength(arrFiles); ++i){
						subFile = new File(curFile + File.separator + arrFiles[i]);
						recursivelyDelete(subFile.getCanonicalPath());
					}
				}

				// Now we have a file or an empty dir we can delete.
				if( !curFile.delete() ){
					//System.out.println("Could not delete " + curFile.getCanonicalPath() + ".");
				}
			}
		}catch(Exception e){
			e.printStackTrace();
		}
    }

    public static String convertCygwinPath(String file) {
        if (file.startsWith("\"")) file=file.substring(1);
        if (file.endsWith("\"")) file=file.substring(0,file.length()-1);
        if (new File(file).exists())
            return file;
        if (file.startsWith("/cygdrive"))
            file=file.substring(9);
        if (file.startsWith("/") && file.substring(2,3).equals("/")) {
            file=file.substring(1,2)+":"+file.substring(2);
        }
        return file;
    }
    public static boolean getResult(String file) {
        boolean result=true;
        try {
            String s=readFile(file);
            if (s.indexOf("false")>-1) {
                result=false;
            }
        } catch (Exception e) {
        }
        return result;
    }
    public static boolean getResult() {
        return getResult(System.getProperty("basedir","."));
    }
    public static void updateResult(boolean bool) {
        updateResult(System.getProperty("basedir",".")+"/testresults.properties",bool);
    }
    public static void updateResult(String file,boolean bool) {
        System.out.println("testresults "+(bool? "PASSED":"FAILED")+" writing to "+file);
        boolean result=getResult(file);
        try {
            writeFile(file,"result="+(result&bool));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static String removeCommentsFromFile(String content) {
        content = Pattern.compile("/\\*.*?\\*/", Pattern.DOTALL).matcher(content).replaceAll("");
        content = content.replaceAll("//.*", "");
        return content;
    }


    public static void main(String[] args) {
        get8Dot3Path("c:\\program files\\internet explorer\\iexplore.exe");
    }

	/**
	 * Returns all files (no directories) found in and below rootDir, with the given
	 * filter.
	 **/
	public static ArrayList listFilesRecursively( File rootDir, FilenameFilter filter ){
		ArrayList list = new ArrayList();
		File[] files = rootDir.listFiles( filter );

		for( int i = 0; i < Array.getLength( files ); ++i ){
			if( files[i].isFile() ){
				list.add( files[i] );
			}else if( files[i].isDirectory() ){
				list.addAll( listFilesRecursively( files[i], filter ) );
			}
		}

		return list;
	}
	
	/**
	 * Returns all top level directories and files (no sub directories) found in and below rootDir and 
	 * swfdir, with the given filter. Note that filter does not work in sub directories.
	 **/
	public static ArrayList listTopLevelDirectoriesAndFiles( File rootDir, FilenameFilter filter ){
		ArrayList list = new ArrayList();
		File[] files = rootDir.listFiles( filter );

		for( int i = 0; i < Array.getLength( files ); ++i ){
			try {
				String filePath = files[i].getCanonicalPath().toLowerCase();
				if (filePath.endsWith(File.separator + "swfs") == false) {
					list.add( files[i] );
				}
				else 
				{
					list.addAll(listTopLevelDirectoriesAndFiles(files[i], filter));
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		return list;
	}
}
