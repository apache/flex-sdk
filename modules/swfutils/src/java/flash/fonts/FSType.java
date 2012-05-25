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

package flash.fonts;

import org.apache.flex.forks.batik.svggen.font.Font;
import org.apache.flex.forks.batik.svggen.font.table.Os2Table;

/**
 * Returns information on the fsType of the font.  More information on
 * this can be found here:
 * <p>
 * http://partners.adobe.com/public/developer/en/acrobat/sdk/FontPolicies.pdf
 * <p>
 * http://www.microsoft.com/typography/tt/ttf_spec/ttch02.doc
 * <p>
 * And if we start using OpenType, we should follow this:
 * <p>
 * http://www.microsoft.com/typography/otspec/os2.htm
 *
 * @author Brian Deitte
 */
public class FSType
{
	public int fsType;
	public String description;
	public boolean installable, editable, previewAndPrint, noEmbedding, usableByFlex;

	public FSType(int fsType, String description, boolean installable, boolean editable, boolean previewAndPrint, boolean noEmbedding)
	{
		this.fsType = fsType;
		this.description = description;
		this.installable = installable;
		this.editable = editable;
		this.previewAndPrint = previewAndPrint;
		this.noEmbedding = noEmbedding;
		this.usableByFlex = true; //installable || editable;
	}

	public static FSType getFSType(Font font)
	{
		Os2Table table = font.getOS2Table();
		return getFSType(table.getLicenseType());
	}

	public static FSType getFSType(int lt)
	{
		String description;
        boolean installable = false, editable = false, previewAndPrint = false, noEmbedding = false;
		boolean noEmbeddingBit = (lt & 0x0002) == 0x0002;
		boolean previewAndPrintBit = (lt & 0x0004) == 0x0004;
		boolean editableBit = (lt & 0x0008) == 0x0008;
		// the most permissible bit wins
		if (editableBit)
		{
			editable = true;
			description = "Editable embedding";
		}
		else if (previewAndPrintBit)
		{
			previewAndPrint = true;
			description = "Preview and Print embedding";
		}
		else if (noEmbeddingBit)
		{
			noEmbedding = true;
			description = "No embedding allowed";
		}
		else
		{
			installable = true;
			description = "Installable embedding";
		}

		return new FSType(lt, description, installable, editable, previewAndPrint, noEmbedding);
	}
}
