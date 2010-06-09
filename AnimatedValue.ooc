import os/Time

NAnimatedValue: class {
    /** Whether or not the animation is presently running. */
    __running := false
    /** The time for when the animation was started (in milliseconds). */
    __start: ULLong
    /** The time that had elapsed before the animation was stopped. */
    __elapsed: ULLong = 0
    /** The duration of the animation in milliseconds. */
    __duration: ULLong = 1
    /** 1.0 divided by :field:`__duration`. */
    __durationOverOne: Double
    /** The initial value of the animation. */
    _initial: Double
    /** The target value of the animation. */
    _target: Double
    
    init: func ~noStart (from_, target: Double, duration: ULLong) {
        init(from_, target, duration, false)
    }
    
    init: func (=_initial, _target, duration: ULLong, running: Bool) {
        setDuration(duration)
        if (running) start()
    }
    
    /** Returns the initial value */
    initial: final func -> Double {_initial}
    /** Sets the initial value */
    setInitial: final func (=_initial) {}
    
    /** Returns the target value */
    target: final func -> Double {_target}
    /** Sets the target value */
    setTarget: final func (=_target) {}
    
    /** Returns the progress of the animation, clamped 0.0 to 1.0 */
    progress: final func -> Double {
        if (!__running && __duration <= __elapsed)
            return 1.0
        delta := __durationOverOne * (__running ? (Time millisec() - __start) : __elapsed)
        if (1.0 < delta) {
            stop()
            return 1.0
        }
        if (delta < 0.0) return 0.0
        return delta
    }
    
    /**
        Returns the interpolated value.
        
        :note: This function can be overridden in subclasses in the event that
        you would like to implement something other than linear interpolation.
        In such a case, you can call :meth:`progress` to get the current
        progress of the animation.
    */
    value: func -> Double {
        return _initial + (_target-_initial)*progress()
    }
    
    /** Resets the animator to its initial state. */
    reset: final func {
        __elapsed = 0
    }
    
    /** Starts/resumes the animator. */
    start: final func {
        __start = Time millisec() - __elapsed
        __running = true
    }
    
    /** Resets and starts the animation. */
    restart: final func { this reset(). start() }
    
    /** Stops/pauses the animation.  It can be resumed using :meth:`start`. */
    stop: final func {
        if (!__running)
            return
        __elapsed = Time millisec() - __start
        __running = false
    }
    
    duration: final func -> ULLong { __duration }
    
    /** Sets the duration of the animation. */
    setDuration: final func (=__duration) {
        duration := __duration
        if (duration == 0) duration = 1
        __durationOverOne = 1.0 / (duration as Double)
    }
}