package org.springextensions.actionscript.samples.cafetownsend.presentation {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import org.as3commons.eventbus.IEventBus;
	import org.as3commons.eventbus.IEventBusAware;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getClassLogger;
	import org.springextensions.actionscript.samples.cafetownsend.application.ApplicationEvents;

	/**
	 * Presentation model for the main view.
	 *
	 * @author Christophe Herreman
	 */
	public class MainViewPresentationModel extends EventDispatcher implements IEventBusAware {
		private static const EMPLOYEE_LIST_VIEW_INDEX:int = 1;
		private static const LOGIN_VIEW_INDEX:int = 0;

		private static var logger:ILogger = getClassLogger(MainViewPresentationModel);

		public function MainViewPresentationModel() {
			super();
		}

		private var _eventBus:IEventBus;

		private var m_selectedViewIndex:uint = 0;

		public function get eventBus():IEventBus {
			return _eventBus;
		}

		public function set eventBus(value:IEventBus):void {
			_eventBus = value;
		}

		[Bindable(event="selectedViewIndexChange")]
		public function get selectedViewIndex():uint {
			return m_selectedViewIndex;
		}

		private function set selectedViewIndex(value:uint):void {
			if (value !== m_selectedViewIndex) {
				m_selectedViewIndex = value;
				dispatchEvent(new Event("selectedViewIndexChange"));
			}
		}

		public function init():void {
			_eventBus.addEventListener(ApplicationEvents.LOGGED_IN, eventBus_loggedInHandler);
			_eventBus.addEventListener(ApplicationEvents.LOGGED_OUT, eventBus_loggedOutHandler);
		}

		private function eventBus_loggedInHandler(event:Event):void {
			logger.debug("Received loggedIn event from EventBus");
			private::selectedViewIndex = EMPLOYEE_LIST_VIEW_INDEX;
		}

		private function eventBus_loggedOutHandler(event:Event):void {
			logger.debug("Received loggedOut event from EventBus");
			private::selectedViewIndex = LOGIN_VIEW_INDEX;
		}
	}
}
