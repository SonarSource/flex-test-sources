/*
* Copyright 2007-2011 the original author or authors.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
package org.springextensions.actionscript.context {
	import mx.core.IMXMLObject;

	import org.springextensions.actionscript.context.config.IConfigurationPackage;
	import org.springextensions.actionscript.module.ModulePolicy;

	/**
	 *
	 * @author Roland Zwaga
	 * @productionversion SpringActionscript 2.0
	 */
	public interface IMXMLApplicationContext extends IMXMLObject {

		function get modulePolicy():ModulePolicy;

		function set modulePolicy(value:ModulePolicy):void;

		function get autoAddChildren():Boolean;

		function set autoAddChildren(value:Boolean):void;

		function get autoLoad():Boolean;

		function set autoLoad(value:Boolean):void;

		function get configurationPackage():IConfigurationPackage;

		function set configurationPackage(value:IConfigurationPackage):void;

		function get defaultShareSettings():ContextShareSettings;

		function set defaultShareSettings(value:ContextShareSettings):void;

		function initializeContext():void;

	}
}
