package swf.bridge {
	/**
	 * A <code>FdtRequest</code> can be send over to FDT to trigger some functions 
	 * in FDT. The results of these functions are collected and send to the function 
	 * given to the method <code>sendTo</code>.
	 */
	public class FdtRequest {
		private var _make : Function;

		/***
		 * This constructor may change in future, please use 
		 * <code>FdtViewBridge</code>, <code>FdtDialogBridge</code>, or <code>IFdtActionBrige</code>
		 * or use thier requestors to create a FdtRequest.
		 */
		public function FdtRequest(make : Function = null) {
			if (make == null) {
				_make = function(thisObject : Object, a : Array, rt : Function) : void {
					rt.apply(thisObject, a);
				};
			} else {
				_make = make;
			}
		}

		/***
		 * Transfers the request to FDT and calls function <code>f</code>
		 * with the request result.
		 * 
		 * <pre>
		 * function deleteResourceAndCreateFolder(path1 : String, path2 : String) : void {
		 *     var r : FdtRequest = _bridge.newRequest();
		 *     r.add(_bridge.workspace.deleteResource(path1));
		 *     r.add(_bridge.workspace.createFolder(path2));
		 *     r.sendTo(this, res);				
		 * }
		 * 
		 * private function res(deleteResult : Boolean, createdFolder : IFdtResource) : void {
		 *     trace( "Is resource deleted: ", deleteResult);	
		 *     trace( "New create folder: ", createdFolder as FdtFolder);
		 * }
		 * </pre>
		 *
		 * @param thisObject the object to use as this in the call of function <code>f</code>
		 * i.e.: <br> <code> f.apply(this.object, result1, result2, ...) </code>  
		 * @param f After the request is processed by FDT the function <code>f</code> is called 
		 * with the request results as parameters.
		 * 
		 */
		public function sendTo(thisObject : Object, f : Function) : void {
			if (f == null) {
				f = function(... args) : void {
				};
			}
			_make(thisObject, new Array(), f);
			_make = null;
		}

		/***
		 * Extends this request with another one.
		 * @param request the other request
		 * 
		 * returns this 
		 */
		public function add(request : FdtRequest) : FdtRequest {
			if (_make == null) {
				throw new Error("FDT Request is already send.");
			}
			_make = create(_make, request._make);
			return this;
		}

		private function create(make1 : Function, make2 : Function) : Function {
			return function(thisObject : Object, a : Array, rt : Function) : void {
				make1(thisObject, a, function(... args) : void {
					make2(thisObject, args, rt);
				});
			} ;
		}
	}
}
