class Deferrable {
	
	private var d_run;			// function returning true if completed, false if callback needed
	private var d_callback;		// callback function for deferred completion of task
	private var d_fallback;		// fallback function for breaking the task
	
	private var d_canceled = false;		// true: task is canceled
	private var d_deferred = false;		// true: task is deferred and will be continued later
	private var d_complete = false;		// true: task is completed
	
	function initialize(run, done, fail) {
		d_run = run;
		d_callback = done;
		d_fallback = fail;
	}
	
	// perform the task, return task status
	function run() {
		return d_run.invoke();
	}
	
	// function setCallback(callback) {
	// 	d_callback = callback;
	// }
	
	// function setFallback(fallback) {
	// 	d_fallback = fallback;
	// }
	
	// use in derived classes:
	
	// mark as canceled task - should be called when an error occured in d_run
	function cancel(error) {
		d_canceled = true;
		
		d_fallback.invoke(error);
		
		return d_complete;
	}
	
	// mark as deferred task - should be called when d_run could not complete yet
	function defer() {
		d_deferred = true;
		return d_complete;
	}
	
	// mark as completed task, invokes callback if task was previously deferred
	function complete() {
		d_complete = true;
		if (d_deferred) { 		// why only when deferred?
			d_callback.invoke();
		}
		return d_complete;
	}
}

class DeferredFor extends Deferrable {

	private var d_idx = 0;
	private var d_end = 0;

	private var d_fac;		// function to retrieve deferrable by idx

	function initialize(idx, end, fac, callback, fallback) {
		Deferrable.initialize(method(:run), callback, fallback);
		d_idx = idx;
		d_end = end;
		d_fac = fac;
	}

	// iterates until received false (not complete)
	function run() {
		for (; d_idx != d_end; ++d_idx) {
			var deferrable = d_fac.invoke(d_idx, method(:proceed), method(:cancel));		// create task
			// deferrable.setCallback(method(:proceed));	// request to continue run() after completion
			// deferrable.setFallback(method(:cancel));	// request to break the for loop immediately
			
			// only continue to next task if current completed
			if (!deferrable.run()) {
				// not completed, so return from function and proceed is called when done
				return Deferrable.defer();		
			}
		}
		// for loop completed, so done
		return Deferrable.complete();
	}
	
	function proceed() {
		d_idx++;			// this was skipped due to break in for loop
		run();
	}
	
	function cancel(error) {
		// if this is called, break the running for loop
		d_idx = d_end;
		
		// // execute fallback
		// d_fallback.invoke(error);

		// let deferrable class handle the cancel properly
		Deferrable.cancel(error);
	}
	
	function idx() {
		return d_idx;
	}
	
	function end() {
		return d_end;
	}
}