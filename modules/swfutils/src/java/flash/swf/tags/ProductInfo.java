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

package flash.swf.tags;

import flash.swf.Tag;
import flash.swf.TagHandler;

/**
 * This represents a ProductInfo SWF tag.  It is used to embed
 * information about the product, which was used to construct the SWF,
 * including it's edition, major version, minor version, and build
 * number, and the date the SWF was constructed.
 *
 * @author Paul Reilly
 */
public class ProductInfo extends Tag
{
    private long build;
    private int product;
    private byte majorVersion;
    private byte minorVersion;
    private int edition;
    private long compileDate;

    public static final int UNKNOWN = 0;
    public static final int J2EE_PRODUCT = 1;
    public static final int NET_PRODUCT = 2;
    public static final int ABOBE_FLEX_PRODUCT = 3;

    protected static final String[] products =
    {
        "unknown", // 0
        "Macromedia Flex for J2EE",
        "Macromedia Flex for .NET",    
        "Adobe Flex",
    };

    protected static final int DEVELOPER_EDITION = 0;
    protected static final int FULL_COMMERCIAL_EDITION = 1;
    protected static final int NON_COMMERCIAL_EDITION = 2;
    protected static final int EDUCATIONAL_EDITION = 3;
    protected static final int NFR_EDITION = 4;
    protected static final int TRIAL_EDITION = 5;
    protected static final int NO_EDITION = 6;      // not part of any edition scheme      

    public static final String[] editions =
    {
        "Developer Edition", // 0       
        "Full Commercial Edition", // 1 
        "Non-Commercial Edition", // 2
        "Educational Edition", // 3
        "NFR Edition", // 4
        "Trial Edition", // 5
        ""      // 6 no edition
    };

    public ProductInfo(int product, int edition, byte majorVersion, byte minorVersion, long build, long compileDate)
    {
        super(stagProductInfo);
        this.product = product;
        this.edition = edition;
        this.majorVersion = majorVersion;
        this.minorVersion = minorVersion;
        this.build = build;
        this.compileDate = compileDate;
    }

    public ProductInfo(int product, byte majorVersion, byte minorVersion, long build, long compileDate)
    {
        super(stagProductInfo);
        this.product = product;
        this.majorVersion = majorVersion;
        this.minorVersion = minorVersion;
        this.build = build;
        this.compileDate = compileDate;
    }

    public ProductInfo(long compileDate)
    {
        super(stagProductInfo);
        this.compileDate = compileDate;
    }

    public long getBuild()
    {
        return build;
    }

    public long getCompileDate()
    {
        return compileDate;
    }

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof ProductInfo))
        {
            ProductInfo productInfo = (ProductInfo) object;

            if (product == productInfo.product &&
                edition == productInfo.edition &&
                majorVersion == productInfo.majorVersion &&
                minorVersion == productInfo.minorVersion &&
                build == productInfo.build &&
                compileDate == productInfo.compileDate)
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

    public int getEdition()
    {
        return edition;
    }

    public void setEdition(int edition)
    {
        this.edition = edition;
    }

    public String getEditionString()
    {
        return editions[edition];
    }

    public int getProduct()
    {
        return product;
    }

    public String getProductString()
    {
        return products[product];
    }

    public byte getMajorVersion()
    {
        return majorVersion;
    }

    public byte getMinorVersion()
    {
        return minorVersion;
    }

    public void visit(TagHandler tagHandler)
	{
        tagHandler.productInfo(this);
	}
}
