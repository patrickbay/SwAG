package swag.core.instances {
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import swag.core.SwagDataTools;
	import swag.core.SwagDispatcher;
	import swag.events.SwagSequenceEvent;
	import swag.interfaces.core.instances.ISwagSequence;
	import swag.interfaces.events.ISwagEvent;
	
	/**
	 * @private
	 * 
	 * Provides a variety of methods of creating sequential and looping methods.
	 * 
	 * @author Patrick Bay
	 * 
	 * @see swag.core.SwagSequencer
	 * 
	 */
	public class SwagSequence implements ISwagSequence {
		
		/**
		 * @sequence 
		 */		
		private static var _sequenceChain:Array=new Array();
		/**
		 * @private 
		 */
		private var _method:Function=null;
		/**
		 * @private 
		 */
		private var _beacon:Number=null;
		/**
		 * @private 
		 */
		private var _event:ISwagEvent=null;
		/**
		 * @private
		 */
		private var _startDelayTimer:Timer=null;
		/**
		 * @private
		 */
		private var _beaconTimer:Timer=null;
		
		public function SwagSequence(sequenceMethod:Function=null) {
			this._method=sequenceMethod;
		}//constructor
		
		/**
		 * Starts the sequence dispatching beacons, responding to events, and / or processing
		 * other sequence triggers with an optional delay.
		 * <p>Any running timers, existing listeners, and other sequence monitors are
		 * reset to their initial values when this method is invoked.</p>
		 *  
		 * @param startDelay An optional delay to hold the sequence before starting, in milliseconds.
		 * If this value is 0 or smaller, no delay is applied.
		 * 
		 */
		public function start(startDelay:Number=0):void {
			if (this._startDelayTimer!=null) {
				if (this._startDelayTimer.running) {
					this._startDelayTimer.stop();
				}//if
				this._startDelayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, this.startOnDelay);
				this._startDelayTimer=null;
			}//if
			if (this._beaconTimer!=null) {
				if (this._beaconTimer.running) {
					this._beaconTimer.stop();
				}//if
				this._beaconTimer.removeEventListener(TimerEvent.TIMER, this.onBeaconTimer);
				this._beaconTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, this.onBeaconTimer);
				this._beaconTimer=null;
			}//if
			if (delay>0) {
				this._startDelayTimer=new Timer(startDelay, 1);
				this._startDelayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.startOnDelay);
				this._startDelayTimer.start();
			} else {
				this.startOnDelay();
			}//else
		}//start
		
		/**
		 * @private 
		 */
		private function startOnDelay(... args):void {
			if (this._startDelayTimer!=null) {
				if (this._startDelayTimer.running) {
					this._startDelayTimer.stop();
				}//if
				this._startDelayTimer=null;
			}//if
			if (this.beacon>0) {
				this._beaconTimer=new Timer(this.beacon, 0);
				this._beaconTimer.addEventListener(TimerEvent.TIMER, this.onBeaconTimer);
				this._beaconTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this.onBeaconTimer);
				this._beaconTimer.start();
			}//if
			SwagDispatcher.dispatchEvent(new SwagSequenceEvent(SwagSequenceEvent.START), this);
		}//startOnDelay
		
		/**
		 * @private 
		 */
		private function onBeaconTimer(eventObj:TimerEvent):void {
			SwagDispatcher.dispatchEvent(new SwagSequenceEvent(SwagSequenceEvent.BEACON), this);
		}//onBeaconTimer
		
		/**
		 * Stops the sequence from dispatching beacons, responding to events, or processing
		 * other sequence triggers. 
		 * 
		 */
		public function stop():void {
			if (this._startDelayTimer!=null) {
				if (this._startDelayTimer.running) {
					this._startDelayTimer.stop();
				}//if
				this._startDelayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, this.startOnDelay);
				this._startDelayTimer=null;
			}//if
			if (this._beaconTimer!=null) {
				if (this._beaconTimer.running) {
					this._beaconTimer.stop();
				}//if
				this._beaconTimer.removeEventListener(TimerEvent.TIMER, this.onBeaconTimer);
				this._beaconTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, this.onBeaconTimer);
				this._beaconTimer=null;
			}//if
			SwagDispatcher.dispatchEvent(new SwagSequenceEvent(SwagSequenceEvent.STOP), this);
		}//stop
		
		/**
		 * The method to invoke for this sequence object.
		 */
		public function set method(methodSet:Function):void {
			this._method=methodSet;
		}//set method
		
		public function get method():Function {
			return (this._method);
		}//get method
		
		/**
		 * The beacon, or repeating timer, to set for this sequence object, in milliseconds.
		 * <p>Setting this value to 0 or less disables the beacon timer.</p>
		 * 
		 */
		public function set beacon(beaconSet:Number):void {
			this._beacon=delaySet;
		}//set beacon
		
		public function get beacon():Number {
			return (this._beacon);
		}//get beacon
		
	}//SwagSequence class
	
}//package