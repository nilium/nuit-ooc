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
    
    /**
        Gets the pixel size of the individual frames in the image.
    */
    frameSize: abstract func -> NSize
    
    /**
        Gets the number of frames in the image.
    */
    frames: abstract func -> Int
}

NImage: class {
    /** The url the image data was loaded from */
    url: String
    /** The image data loaded by the NRenderer */
    imageData: NImageData
    
    init: func(url: String) {
        this url = url clone()
    }
    
    /**
        Gets the actual size of the image in pixels.
    */
    size: func -> NSize {
        if (imageData == null)
            Exception new(This, "Image has not been loaded") throw()
        
        return imageData size()
    }
    
    /**
        Gets the pixel size of the frames in the image.
    */
    frameSize: func -> NSize {
        if (imageData == null)
            Exception new(This, "Image has not been loaded") throw()
        
        return imageData frameSize()
    }
    
    /**
        Gets the number of frames in the image.
    */
    frames: func -> Int {
        if (imageData == null)
            Exception new(This, "Image has not been loaded") throw()
        
        return imageData frames()
    }
}
