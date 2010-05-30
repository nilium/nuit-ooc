import Types
import Font
import Image

NRenderer: abstract class {
    _fillColor: NColor
    
    /**
        Sets up the system for rendering the GUI.
        
        :note: It's recommended that you cache as much as possible after the
        first call to this, as it will be called per-frame.  The entire
        renderer should be fairly well-optimized, but you should take care
        to ensure that very little work needs to be done in order to draw using
        these methods.
    */
    acquire: abstract func
    
    /**
        Resets the system to its previous state prior to it being set up for
        GUI rendering.
    */
    release: abstract func
    
    /**
        Saves all state changes to later be restored.  All calls to
        :meth:`saveState` should have a corresponding :meth:`restoreState`
        call to potential memory leaks and other mishaps.
    */
    saveState: abstract func
    
    /**
        Restores the last state saved by :meth:`saveState`.
    */
    restoreState: abstract func
    
    /**
        Gets the absolute size of the renderable area (referred to as the
        screen) for all purposes.
    */
    screenSize: abstract func -> NSize
    
    /**
        Gets the current clipping region set by :meth:`setClippingRegion`.
    */
	clippingRegion: abstract func -> NRect
	
	/**
	    Sets the clipping region.  This causes all drawing to be clipped to the
	    designated :param:`region`, meaning no drawing will occur outside of
	    that region after this call.
	*/
	setClippingRegion: abstract func (region: NRect)
	
	/**
	    Adds a clipping region such that the intersection of the current
	    clipping region and the new :param:`region` is the new clipping region.
	    
	    Not to be confused with :meth:`clippingRegion`, which returns the
	    current clipping region.
	*/
	clipRegion: abstract func (region: NRect) {
	    setClippingRegion(region % clippingRegion())
	}
	
	/**
	    Enables clipping of all drawing to the clipping region set by
	    :meth:`setClippingRegion`.
	*/
	enableClipping: abstract func
	
	/**
	    Disables clipping of drawing.
	*/
	disableClipping: abstract func
	
	/**
	    Gets the drawing origin set by :meth:`setDrawingOrigin`.
	*/
	drawingOrigin: abstract func -> NPoint
	
	/**
	    Sets the origin for all drawing operations.
	*/
	setDrawingOrigin: abstract func (point: NPoint)
	
	/**
	    Translates the drawing origin by the provided relative point.
	*/
	translateDrawingOrigin: func (trans: NPoint) {
	    trans add(drawingOrigin())
	    setDrawingOrigin(trans)
	}
	
	/**
	    Gets the current fill color, set by :meth:`setFillColor`.
	*/
	fillColor: abstract func -> NColor
	
	/**
	    Sets the current fill color.
	    
	    The fill color should tint images being drawn and is used for filling
	    rectangles.
	*/
	setFillColor: abstract func (fillColor: NColor)
	
	/**
	    Fills the :param:`rect` with the current fill color.
	*/
	fillRect: abstract func (rect: NRect)
	
	/**
	    Loads a single-frame image from the given :param:`url`.  URLs are
	    assumed to be on the filesystem, but may point elsewhere.  There is no
	    requirement to support any specific type of URL.
	*/
	loadImage: abstract func (url: String) -> NImage
	
	/**
    	Loads a multi-frame image from the given :param:`url`.  URLs are
        assumed to be on the filesystem, but may point elsewhere.  There is no
        requirement to support any specific type of URL.
        
        Each frame is loaded left to right, top to bottom, from the image until
        no more frames can be loaded.  This means that a 300x300 pixel image
        with a 64x64 pixel frame size will have 16 frames and 44 pixels of
        unused space at the bottom and right sides of the image.
        
        :param: frameSize The size of each frame.
        :param: frameCount The total number of frames to load from the image.
	*/
	loadImageWithFrames: abstract func (url: String, frameSize: NSize, frameCount: Int) -> NImage
	
	/**
	    Draws an :param:`image` in the area specified by :param:`inRect`.  The
	    image should be stretched to fill the area.
	*/
	drawImage: abstract func (image: NImage, frame: Int, inRect: NRect)
	
	/**
	    Draws a portion of an :param:`image`, designated by :param:`subimage`
	    in pixels, in the area specified by :param:`inRect`.  The subimage
	    should be stretched to fill the area.
	    
	    :param: frame The image frame to draw.
	*/
	drawSubimage: abstract func (image: NImage, frame: Int, subimage: NRect, inRect: NRect)
	
	/**
	    Draws :param:`text` at the specified :param:`point` using the given
	    :param:`font`.  The point specifies the upper-left corner of the text.
	*/
	drawText: abstract func (text: String, font: NFont, point: NPoint)
}
