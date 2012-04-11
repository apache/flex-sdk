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

package macromedia.asc.embedding;

import macromedia.asc.util.ByteList;

import java.util.StringTokenizer;

public class SwfMaker
{
	public static final int stagShowFrame       = 1;
	public static final int stagEnableDebugger2 = 64;   // this movie may be debugged
	public static final int stagDebugID			= 63;   // unique ID to match up swf with swd
	public static final int stagFileAttributes	= 69;
	public static final int stagDoABC           = 72;
	public static final int stagSymbolClass     = 76;


	// Flags for stagFileAttributes
	public static final int swfFlagsUseNetwork          = 0x00000001;  // when this SWF is local, give it network access instead of local access
	public static final int swfFlagsSwfRelativeUrls     = 0x00000002;  // relative URL paths in this SWF are relative to SWF location rather than browser location
	public static final int swfFlagsNoCrossdomainCache  = 0x00000004;  // do not add this SWF to the Asset Cache
	public static final int swfFlagsAS3                 = 0x00000008;  // this SWF contains AVM+ bytecodes
	public static final int swfFlagsHasMetadata         = 0x00000010;  // this SWF contains stagMetadata somewhere
	// (this is not relevant to the player, but is relevant to search engines)
	public static final int kDefaultSwfFlags            = 0x00000000;   // these flags are assumed when no stagFileAttributes is present

	private int CoreAbs(int x) { return (x<0) ? (-x) : x; }

	class SRECT
	{
		public int xmin;
		public int xmax;
		public int ymin;
		public int ymax;
	};
	
    int bitPos;
    int bitBuf;
    ByteList buffer = new ByteList();

	int     pos;
	int		tagCode;
	int		tagPos;
	int		tagLen;
	boolean	tagIsBig;
    int     swf_version;

    SwfMaker()
    {
		pos             = 0;
	    tagCode			= 0;
	    tagPos			= 0;
	    tagLen			= 0;
	    tagIsBig		= false;
        swf_version     = 9;
    }

	void SetPos(int pos)
	{
		this.pos = pos;
	}
	
	void CheckSpace(int count)
	{
		buffer.resize(pos+count);
	}

    void PutData(byte data[])
    {
		CheckSpace(data.length);
		for (int i=0; i<data.length; i++) {
			buffer.set(pos++, data[i]);
		}
    }

    void PutByte(byte b)
    {
		CheckSpace(1);
		buffer.set(pos++, b);
    }
	
	void PutString(String str)
	{
        PutData(str.getBytes());
		PutByte((byte)0);
	}

    void PutWord(int d)
    {
		CheckSpace(2);
		buffer.set(pos++, (byte)d);
        buffer.set(pos++, (byte)(d>>8));
    }

    void PutDWord(int d)
    {
		CheckSpace(4);
        buffer.set(pos++, (byte)d);
        buffer.set(pos++, (byte)(d>>8));
        buffer.set(pos++, (byte)(d>>16));
        buffer.set(pos++, (byte)(d>>24));
    }

    void StartTag(int code, boolean isBig)
    {
	    //assert(tagCode==0);
	    
	    tagCode = code;
	    tagPos = pos;
	    tagIsBig = isBig;
	    
	    PutWord(0);
	    if ( isBig )
		    PutDWord(0);
    }
    
    void FinishTag()
    {
	    int savePos = pos;
	    int tagLen = pos - tagPos - (tagIsBig ? 6 : 2);
	    pos = tagPos;
    
	    if (tagIsBig) {
		    PutWord((short)((tagCode<<6) | 0x3f));
		    PutDWord(tagLen);
	    } else {
		    //assert(tagLen < 0x3f);
		    PutWord((short)((tagCode<<6) | tagLen));
	    }
	    pos = savePos;
	    tagCode = 0;
    }

    int CountBits(int v)
    {
	    int n = 0;
	    while ( (v & ~0xF) != 0 ) {
		    v >>= 4;
	 	    n += 4;
	    }
	    while ( v != 0 ) {
		    v >>= 1;
		    n++;
	    }
	    return n;
    }

    int CheckMag(int v, int mag)
    {
	    if ( v < 0 ) v = -v;
	    return v > mag ? v : mag;
    }

    void InitBits()
    {
	    bitPos = 8;
	    bitBuf = 0;
    }

    void FlushBits()
    {
	    if ( bitPos < 8 )
		    PutByte((byte)bitBuf);
    }

    void PutBits(int v, int n)
    {
        if ( n <= 0 ) 
            return;
        for (;;) {
            v &= 0xFFFFFFFF >> (32-n);	// mask off any extra bits, note this does not work for n == 0, hence check for zero above
            int s = n - bitPos;	// The number of bits more than the buffer will hold
            if ( s <= 0 ) {
                // This fits in the buffer, add it and finish
                bitBuf |= v << -s;
                bitPos -= n;	// we used x bits in the buffer
                return;
            } else {
                // This fills the buffer, fill the remaining space and try again
                bitBuf |= v >> s;
                n -= bitPos;	// we places x bits in the buffer
                PutByte((byte)bitBuf);
                bitBuf = 0;
                bitPos = 8;
            }
        }
    }

    void PutRect(SRECT r)
    {
	    InitBits();
    
	    int mag = CheckMag(r.xmin, CheckMag(r.xmax, CheckMag(r.ymin, CoreAbs(r.ymax))));
	    int nBits = CountBits(mag)+1;	// include a sign bit
        
        if (nBits<15) nBits = 15;

	    PutBits(nBits, 5);
	    PutBits(r.xmin, nBits);
	    PutBits(r.xmax, nBits);
	    PutBits(r.ymin, nBits);
	    PutBits(r.ymax, nBits);

	    FlushBits();
    }

	public boolean EncodeABC(ByteList abcData,
						     String options)
	{
		String className = null;
		int width, height, fps = 12;
        int useNetwork=0;

        boolean debug = false;
		int dAt = options.indexOf(",-g");
		if (dAt > -1)
		{
			// strip it and enable debugger tag
			debug = true;
			options = options.substring(0, dAt) + options.substring(dAt+3);
		}
        dAt = options.indexOf(",-usenetwork");
        if (dAt>-1) {
            useNetwork=swfFlagsUseNetwork;
            options = options.substring(0, dAt) + options.substring(dAt+12);
        }

        StringTokenizer tokenizer = new StringTokenizer(options, ",");
		switch (tokenizer.countTokens())
		{
		case 2:
			width = Integer.parseInt(tokenizer.nextToken());
			height = Integer.parseInt(tokenizer.nextToken());
			break;
		case 3:
			className = tokenizer.nextToken();
			width = Integer.parseInt(tokenizer.nextToken());
			height = Integer.parseInt(tokenizer.nextToken());
			break;
		case 4:
			className = tokenizer.nextToken();
			width = Integer.parseInt(tokenizer.nextToken());
			height = Integer.parseInt(tokenizer.nextToken());
			fps = Integer.parseInt(tokenizer.nextToken());
			break;
		default:
			return false;
		}

        PutByte((byte)'F');
        PutByte((byte)'W');
        PutByte((byte)'S');
        PutByte((byte)swf_version);
        PutDWord(0);

		SRECT bounds = new SRECT();
		bounds.xmin = 0;
		bounds.ymin = 0;
		bounds.xmax = width*20;
		bounds.ymax = height*20;
		PutRect(bounds);
		PutWord(fps<<8);   // frame rate
		PutWord(1);       // # of frames  SDD ### Change to sensicle number

		StartTag(stagFileAttributes, false);
		PutDWord(swfFlagsAS3|useNetwork);
		FinishTag();

		if (debug)
		{
			StartTag(stagEnableDebugger2, false);
			PutWord(0x1975);
			PutString("");
			FinishTag();
			
			StartTag(stagDebugID, false);
			PutData( new byte[] { (byte)0xCA, (byte)0x49, (byte)0x96, (byte)0xC7, 
								  (byte)0x57, (byte)0x8E, (byte)0x20, (byte)0x02, 
								  (byte)0xDD, (byte)0x92, (byte)0xA6, (byte)0x3F, 
								  (byte)0x18, (byte)0x78, (byte)0xC5, (byte)0xBC } );
			FinishTag();
		}

		StartTag(stagDoABC, true);
		PutData(abcData.toByteArray());
		FinishTag();

		if (className != null)
		{
			StartTag(stagSymbolClass, false);
			PutWord(1);
			PutWord(0);
			PutString(className);
			FinishTag();
		}

        // Show Frame
        StartTag(stagShowFrame, false);
        FinishTag();

		// Set the length
		int size = pos;
		SetPos(4);
		PutDWord(size);
	
		return true;
	}	
};

