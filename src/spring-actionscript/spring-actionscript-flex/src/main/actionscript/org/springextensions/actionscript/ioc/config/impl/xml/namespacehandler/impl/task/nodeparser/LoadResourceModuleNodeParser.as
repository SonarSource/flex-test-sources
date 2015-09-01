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
package org.springextensions.actionscript.ioc.config.impl.xml.namespacehandler.impl.task.nodeparser {
	import org.as3commons.async.operation.impl.LoadResourceModuleOperation;
	import org.springextensions.actionscript.ioc.config.impl.xml.parser.IXMLObjectDefinitionsParser;
	import org.springextensions.actionscript.ioc.objectdefinition.IObjectDefinition;


	/**
	 *
	 * @author Roland Zwaga
	 * @productionversion SpringActionscript 2.0
	 */
	public class LoadResourceModuleNodeParser extends LoadStyleModuleNodeParser {

		public function LoadResourceModuleNodeParser() {
			super();
		}

		override protected function parseInternal(node:XML, context:IXMLObjectDefinitionsParser):IObjectDefinition {
			super.parseInternal(node, context);
			builder.objectDefinition.constructorArguments[0] = LoadResourceModuleOperation;
			builder.objectDefinition.constructorArguments.pop();
			return builder.objectDefinition;
		}

	}
}
