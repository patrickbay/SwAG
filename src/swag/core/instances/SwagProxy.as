package swag.core.instances {
	
	import swag.events.SwagErrorEvent;
	
	/**
	 * @private 
	 * 
	 * Provides method proxy functionality for ActionScript 3 methods.
	 * <p>By proxying a method, a developer effectively intercepts the call to it before and after it is invoked. In this way,
	 * a method's parameters may be dynamically inspected or updated, the method can be timed for performance purposes, or any
	 * other number of functions or analysis may be applied without altering the original method.</p>
	 * 
	 * @author Patrick Bay
	 */
	public class SwagProxy	{
		
		/**
		 * @private 
		 */
		private var _proxyMethod:Function=null;
		/**
		 * @private 
		 */
		private var _replaceMethod:Function=null;
		/**
		 * @private 
		 */
		private var _proxyContainer:Function=null;
		
		/**
		 * Instantiates the ProxyMethod intercept and optionally creates the proxy re-direct.
		 *  
		 * @param proxyMethod The method to be proxied (i.e. the method to temporarily replace with <code>replaceMehod</code>).
		 * May not be <em>null</em>.
		 * @param replaceMehod The method that will act as a proxy for <code>proxy</code> method. Ensure that the replacement
		 * method accepts the correct parameters otherwise it may generate a runtime error. May not be <em>null</em>.
		 * @param proxyContainer The containing object in which the <code>proxyMethod</code> may be found. May not be <em>null</em>.
		 * @param autoInit If <em>true</em>, the proxy is created right away, otherwise the <code>create</code> method must be called
		 * manually.
		 * 
		 */
		public function SwagProxy(proxyMethod:Function, proxyContainer:*, replaceMehod:Function, autoInit:Boolean=true)	{
			this._proxyMethod=proxyMethod;
			this._replaceMethod=replaceMethod;
			this._proxyContainer=proxyContainer;
			if (autoInit==true) {
				this.create();
			}//if
		}//constructor
		
		/**
		 * Creates the proxy method by swapping references between it and the replacing method.
		 *  
		 * @return <em>True</em> is returned if the method was successfully proxied, <em>false</em> otherwise.
		 * A <code>SwagErrorEvent</code> event is also broadcast with specific information about the failure.
		 * 
		 * @eventType swag.events.SwagErrorEvent
		 * 
		 */
		public function create():Boolean {
			if ((this._proxyMethod==null) || (this._replaceMethod==null) || (this._proxyContainer==null)) {
				return (false);
			}//if
			if ((this._proxyContainer[this._proxyMethod] is Function)==false) {
				return (false);
			}//if
			this._proxyContainer[this._proxyMethod]=this._replaceMethod;
			return (true);
		}//create		
		
	}//SwagProxy class
	
}//package