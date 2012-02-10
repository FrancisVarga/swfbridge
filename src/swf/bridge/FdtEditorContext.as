package swf.bridge {
	/**
	 * The editor context describes the current focused editor and its selection (cursor).
	 */
	public class FdtEditorContext {
		/**
		 * The file of associated with the currently active editor. 
		 */
		public var currentFile : String;
		
		/**
		 * This is the current line of which the cursor is at. 
		 * It is relative to thof the selection start of the current document.
		 */
		public var currentLine : String;
		
		/**
		 * Within the current line, this is the offset (distance) from the start of the line to the cursor.
		 */
		public var currentLineOffset : int;
		
		/**
		 * Within the current line, this is the offset (distance) from the start of the line to the beginning of the selection.
		 */
		public var selectionOffset : int;
		
		/**
		 * The length of the currently active selection. 
		 */
		public var selectionLength : int;
		
		/**
		 * The line seperator of the current line 
		 */
		public var currentLineSeperator : String;
	}
}
