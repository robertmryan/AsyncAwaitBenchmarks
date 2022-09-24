#  AsyncAwaitBenchmarks

This is a quick and dirty app to compare benchmark of `concurrentPerform` and `TaskGroup` (vs serial execution), when running CPU intensive calculations.

Note:

 1. The cooperative thread pool on simulators is highly constrained, so most illustrative results can be see when you run this on physical devices.

 2. If you profile the app with Instruments, using the “Time Profiler” template (which includes “Points of Interest” tool), you can graphically see the performance.

- - -

Xcode 14.0

- - -

Robert M. Ryan; 23 September 2022
