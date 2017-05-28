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

package flex2.compiler.as3;

import macromedia.asc.embedding.ConfigVar;
import macromedia.asc.util.ObjectList;

/**
 * This interface is used to restrict consumers of
 * CompilerConfiguration to as3 compiler specific options.
 *
 * @see flex2.compiler.common.CompilerConfiguration
 */
public interface As3Configuration
{
	/**
	 * Omit method arg names.
	 */
	boolean optimize();

	/**
	 * Emit system paths with debug info.
	 */
	boolean verboseStacktraces();

	/**
	 * Generate SWFs for debugging
	 */
	boolean debug();

	int dialect();
	boolean adjustOpDebugLine();

	/**
	 * Run the AS3 compiler in strict mode
	 */
	boolean strict();

	/**
	 * Enable asc -warnings
	 */
	boolean warnings();

	/**
	 * Generate asdoc
	 */
	boolean doc();

	/**
	 * user-defined AS3 file encoding
	 */
	String getEncoding();
    
    /**
     * Configuration settings (ConfigVars) from <code>--compiler.define</code>
     * are retrieved using this getter.
     *  
     * @return ObjectList<macromedia.asc.embedding.ConfigVar>
     */
    ObjectList<ConfigVar> getDefine();

    boolean getGenerateAbstractSyntaxTree();

	/**
	 * Whether to export metadata into ABCs
	 */
	boolean metadataExport();

    boolean showDeprecationWarnings();

	// coach warnings

	boolean warn_array_tostring_changes();

	boolean warn_assignment_within_conditional();

	boolean warn_bad_array_cast();

	boolean warn_bad_bool_assignment();

	boolean warn_bad_date_cast();

	boolean warn_bad_es3_type_method();

	boolean warn_bad_es3_type_prop();

	boolean warn_bad_nan_comparison();

	boolean warn_bad_null_assignment();

	boolean warn_bad_null_comparison();

	boolean warn_bad_undefined_comparison();

	boolean warn_boolean_constructor_with_no_args();

	boolean warn_changes_in_resolve();

	boolean warn_class_is_sealed();

	boolean warn_const_not_initialized();

	boolean warn_constructor_returns_value();

	boolean warn_deprecated_event_handler_error();

	boolean warn_deprecated_function_error();

	boolean warn_deprecated_property_error();

	boolean warn_duplicate_argument_names();

	boolean warn_duplicate_variable_def();

	boolean warn_for_var_in_changes();

	boolean warn_import_hides_class();

	boolean warn_instance_of_changes();

	boolean warn_internal_error();

	boolean warn_level_not_supported();

	boolean warn_missing_namespace_decl();

	boolean warn_negative_uint_literal();

	boolean warn_no_constructor();

	boolean warn_no_explicit_super_call_in_constructor();

	boolean warn_no_type_decl();

	boolean warn_number_from_string_changes();

	boolean warn_scoping_change_in_this();

	boolean warn_slow_text_field_addition();

	boolean warn_unlikely_function_value();

	boolean warn_xml_class_has_changed();

	boolean keepEmbedMetadata();
	
	boolean getAdvancedTelemetry();
}
