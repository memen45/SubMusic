class Deferrable {
	
	private var d_run;			// function returning true if completed, false if callback needed
	private var d_callback;		// callback function for deferred completion of task
	
	private var d_deferred = false;
	private var d_complete = false;
	
	function initialize(run) {
		d_run = run;
	}
	
	// perform the task, return task status
	function run() {
		return d_run.invoke();
	}
	
	function setCallback(callback) {
		d_callback = callback;
	}
	
	// use in derived classes:
	
	// mark as deferred task - should be called when d_run could not complete yet
	function defer() {
		d_deferred = true;
		return d_complete;
	}
	
	// mark as completed task, invokes callback if task was previously deferred
	function complete() {
		d_complete = true;
		if (d_deferred) { 
			d_callback.invoke();
		}
		return true;
	}
}

class DeferredFor {

	private var d_idx = 0;
	private var d_end = 0;
	
	private var d_fac;		// function to retrieve deferrable by idx
	private var d_callback;	// function to callback after completion of the loop

	function initialize(idx, end, fac, callback) {
		d_idx = idx;
		d_end = end;
		d_fac = fac;
		d_callback = callback;
	}

	// iterates until received false (not complete)
	function run() {
		for (; d_idx < d_end; ++d_idx) {
			var deferrable = d_fac.invoke(d_idx);		// create task
			deferrable.setCallback(method(:proceed));	// request to continue run() after completion
			
			// continue to next task if completed
			if (!deferrable.run()) {
				return;				
			}
		}
		d_callback.invoke();
	}
	
	function proceed() {
		d_idx++;			// this was skipped due to break in for loop
		run();
	}
	
	function idx() {
		return d_idx;
	}
	
	function end() {
		return d_end;
	}
}