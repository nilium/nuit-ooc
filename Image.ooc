import Types

/**
    Data loaded by the NRenderer for its own purposes.  Should contain all
    data relevant to drawing the image and accessing the attributes provided by
    the methods of NImageData.
*/
NImageData: abstract class {
    /**
        Gets the actual size of the image in pixels.
    */
    size: abstract func -> NSize
}

NImage: class {
    /** The url the image data was loaded from */
    url: String
    /** The image data loaded by the NRenderer */
    data: NImageData
    /** The size of each frame */
    frameSize: NSize
    /** The number of frames in the image */
    frameCount: Int = 1
    
    init: func(url: String) {
        this url = url clone()
    }
    
    /**
        Gets the actual size of the image in pixels.
    */
    size: func -> NSize {
        if (data == null)
            Exception new(This, "Image has not been loaded") throw()
        
        return data size()
    }
    
    /**
        Gets the pixel size of the frames in the image.
    */
    frameSize: func -> NSize { frameSize }
    
    /**
        Gets the number of frames in the image.
    */
    frames: func -> Int { frameCount }
}
