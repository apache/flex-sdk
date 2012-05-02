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

import java.util.*;
import java.net.InetAddress;

/**
 * User: dschaffer
 * Date: Mar 8, 2005
 * Time: 11:22:03 AM
 */
public class StringUtils {
    public static String arrayToString(String[] arr) {
        String str = "";
        for (int i = 0; i < arr.length; i++) {
            str += arr[i] + " ";
        }
        if (arr.length>0)
            str += str.substring(str.length() - 1);
        return str;
    }

    public static String formatTime(long t) {
        String out = "";
        int days = (int) (t / (24 * 60 * 60 * 1000));
        t = t % (24 * 60 * 60 * 1000);
        int hours = (int) (t / (60 * 60 * 1000));
        t = t % (60 * 60 * 1000);
        int mins = (int) (t / (60 * 1000));
        t = t % (60 * 1000);
        if (days > 0) out += "" + days + "d ";
        if (hours > 0) out += "" + hours + "h ";
        if (mins > 0) out += "" + mins + "m ";
        out += ((t + 50) / 100) / 10.0 + "s";
        return out;
    }

    public static String getDate() {
        return getDate(System.currentTimeMillis());
    }

    public static String getSqlDate() {
        GregorianCalendar gc = new GregorianCalendar();
        gc.setTimeInMillis(System.currentTimeMillis());
        String ret = "" + gc.get(Calendar.YEAR) + "-" + (gc.get(Calendar.MONTH)+1) + "-" + gc.get(Calendar.DAY_OF_MONTH) +  " " + gc.get(Calendar.HOUR_OF_DAY) + ":";
        if (gc.get(Calendar.MINUTE) > 9)
            ret += gc.get(Calendar.MINUTE);
        else
            ret += "0" + gc.get(Calendar.MINUTE);
        return ret;
    }

    public static String getDate(long time) {
        String months[] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
        GregorianCalendar gc = new GregorianCalendar();
        gc.setTimeInMillis(time);
        String ret = "" + months[gc.get(Calendar.MONTH)] + " " + gc.get(Calendar.DAY_OF_MONTH) + ", " + gc.get(Calendar.YEAR) + " " + gc.get(Calendar.HOUR_OF_DAY) + ":";
        if (gc.get(Calendar.MINUTE) > 9)
            ret += gc.get(Calendar.MINUTE);
        else
            ret += "0" + gc.get(Calendar.MINUTE);
        return ret;
    }

	private static String hostname = null;
    public static String getHostName() {
		if(hostname == null) {
	        hostname = "localhost";
			try {
				hostname = InetAddress.getLocalHost().getHostName();
				String ip=InetAddress.getLocalHost().getHostAddress();
				hostname+="/"+ip;
			} catch (Exception e) {
			}
		}
        return hostname;
    }
    public static String replaceString(String line, String search, String replace) {
        int ctr = 0;
        while (line.indexOf(search, ctr) > -1) {
            int newctr=line.indexOf(search,ctr)+replace.length();
            line = line.substring(0, line.indexOf(search,ctr)) + replace + line.substring(line.indexOf(search,ctr) + search.length());
            ctr=newctr;
        }
        return line;
    }
    public static String[] StringToArray(String contents) {
        if (contents.startsWith("\"")) contents=contents.substring(1);
        if (contents.endsWith("\"")) contents=contents.substring(0,contents.length()-1);
        StringTokenizer stok=new StringTokenizer(contents);
        String ret[]=new String[stok.countTokens()];
        int n=0;
        while (stok.hasMoreTokens()) {
            ret[n++]=stok.nextToken();
        }
        return ret;
    }
    public static String[] StringToArray(String contents,String linematch) throws Exception {
        List matches=new Vector();
        while (true) {
            if (contents.indexOf("\n")>-1) {
                String line=contents.substring(0,contents.indexOf("\n")).trim();
                contents=contents.substring(contents.indexOf("\n")).trim();
                if (line.equals("") || line.indexOf(linematch)>-1) {
                    matches.add(line);
                }
            } else {
                contents=contents.trim();
                if (contents.indexOf(linematch)>-1) {
                    matches.add(contents);
                }
                break;
            }
        }
        String ret[]=new String[matches.size()];
        matches.toArray(ret);
        return ret;
    }
    
    public static String[] StringToArrayIgnoreLineForSomeFiles(String contents,String linematch, String ignoreLineForFile) throws Exception {
        List matches=new Vector();
        while (true) {
            if (contents.indexOf("\n")>-1) {
                String line=contents.substring(0,contents.indexOf("\n")).trim();
                contents=contents.substring(contents.indexOf("\n")).trim();
                if (line.equals("") || (line.indexOf(linematch)>-1 && 
                		(line.indexOf(ignoreLineForFile) == -1 || line.indexOf(ignoreLineForFile) > line.indexOf(linematch)) ) ) 
                {
                    matches.add(line);
                }
            } else {
                contents=contents.trim();
                if (contents.indexOf(linematch)>-1 && 
                		(contents.indexOf(ignoreLineForFile) == -1 || contents.indexOf(ignoreLineForFile) > contents.indexOf(linematch)) ) 
                {
                    matches.add(contents);
                }
                break;
            }
        }
        String ret[]=new String[matches.size()];
        matches.toArray(ret);
        return ret;
    }
    
    public static String compareArrays(String expectedArray[],String[] actualArray) {
        String diffs="";
        List expected=new Vector();
        for (int i=0;i<expectedArray.length;i++) expected.add(expectedArray[i]);
        List actual=new Vector();
        for (int i=0;i<actualArray.length;i++) actual.add(actualArray[i]);
        Iterator it=expected.iterator();
        boolean found;
        while (it.hasNext()) {
            found=false;
            String exp=(String)it.next();
            Iterator it2=actual.iterator();
            while (it2.hasNext()) {
                String act=(String)it2.next();
                if (act.indexOf(exp)>-1) {
                    actual.remove(act);
                    found=true;
                    break;
                }
            }
            if (found==false) {
                diffs+="expected string not match: '"+exp+"'\n";
            }
        }
        if (actual.size()>0) {
            it=actual.iterator();
            while (it.hasNext()) {
                diffs+="actual string not matched: '"+it.next()+"'\n";
            }
        }
        return diffs;
    }

    // fix double characters in string where they should be in UTF-8 representation.
    public static String fixString(String str) {
    	StringBuffer result = new StringBuffer();
	for (int i=0; i<str.length(); i++)
          {
	      char c = str.charAt(i);
	      if (c < 127)
	      {
	      	// in ascii range
	      	result.append(c);
	      }
	      else
	      {
	      	// multibyte char. output in XML escape code to work around JUnit bug.
 	        String digits = Integer.toHexString(c);
	      	result.append("&#x" + digits + ";");
	      }
	  }
	 return result.toString();
    }
}
