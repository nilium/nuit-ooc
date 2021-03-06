import Types
import GUI
import Renderer

/**
    Data loaded by the NRenderer for its own purposes.  Should contain all
    data relevant to drawing the image and accessing the attributes provided by
    the methods of NImageData.
*/
NImageData: abstract class {
    _renderer: NRenderer
    
    init: func (=_renderer) {
        if (_renderer == null)
            Exception new(This, "Cannot initialize image data with a null renderer") throw()
    }
    
    /** Returns the renderer associated with this image data */
    renderer: func -> NRenderer { _renderer }
    
    /**
        Gets the actual size of the image in pixels.
    */
    size: abstract func -> NSize
}

NImage: class {
    /** The GUI that will be using the image */
    _gui: NGUI
    /** The url the image data was loaded from */
    url: String
    /** The image data loaded by the NRenderer */
    data: NImageData
    /** Whether or not the image uses frames */
    _framedImage := false
    /** The size of each frame */
    frameSize: NSize
    /** The number of frames in the image */
    frameCount: Int = 1
    
    __loaded?: func -> Bool {
        (data != null && _gui renderer() == data renderer())
    }
    
    __load: func -> Bool {
        ld := __loaded?()
        if (!ld) {
            rd := _gui renderer()
            if (rd && rd loadImage(this))
                return true
            else
                return false
        }
        return true
    }
    
    init: func(=_gui, .url) {
        if (_gui == null)
            Exception new(This, "Cannot instantiate a font without a GUI instance") throw()
        
        this url = url ? url clone() : null
    }
    
    init: func ~framed (=_gui, .url, =frameSize, =frameCount) {
        if (_gui == null)
            Exception new(This, "Cannot instantiate a font without a GUI instance") throw()
        
        _framedImage = true
        this url = url ? url clone() : null
    }
    
    /**
        Gets the actual size of the image in pixels.
    */
    size: func -> NSize {
        __load() ? data size() : NSize zero()
    }
    
    /**
        Gets the pixel size of the frames in the image.
    */
    frameSize: func -> NSize { _framedImage ? frameSize : size() }
    
    /**
        Gets the number of frames in the image.
    */
    frames: func -> Int { _framedImage ? frameCount : 1 }
}
