package {
	import swf.bridge.FdtMasterBridge;
	import swf.plugin.ISwfActionPlugin;
	import swf.plugin.ISwfWindowPlugin;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.TimerEvent;
	import flash.system.Security;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	[SWF(width=0,height=0)]
	public class SwfMasterPlugin extends Sprite implements ISwfWindowPlugin {
		private var _bridge : FdtMasterBridge;
		private var timer : Timer;
		private var size : int = 1;
		private var dir : int = 1;
		private var mWidth : Number;

		public function SwfMasterPlugin() {
			ISwfActionPlugin;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			trace("Sandbox: " + Security.sandboxType);
			_bridge = new FdtMasterBridge(loaderInfo, this);
			initDemo();
		}

		public function initDemo() : void {
			timer = new Timer(50);
			timer.addEventListener(TimerEvent.TIMER, showAction);
			timer.start();
		}

		private function showAction(event : TimerEvent) : void {
			size = size + dir;
			if (size == 15) {
				dir = -1;
				graphics.clear();
			} else if (size == 0) {
				dir = 1;
			}
			var h : int = size + mWidth - 17;
			graphics.beginFill(0x0000ff + size * 0x111100);
			graphics.drawRect(8 - size / 2 - 1, 8 - size / 2 - 1, h + 3, size + 3);
			graphics.beginFill(0xffffff);
			graphics.drawRect(8 - size / 2, 8 - size / 2, h + 1, size + 1);
			graphics.endFill();
			scaleX=1;
			scaleY=1;
		}


		override public function set width(value : Number) : void {
			super.width = value;
			mWidth = value;
		}
		
		
		public function setOptions(options : Dictionary) : void {
		}

		public function setSize(width : int, height : int) : void {
			this.width = width;
			this.height = height;
		}

		public function init() : void {
		}

		public function dialogClosed(dialogInstanceId : String, result : String) : void {
		}

	}
}


