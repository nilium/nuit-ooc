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
	clipRegion: func (region: NRect) {
	    setClippingRegion(region intersection(clippingRegion()))
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
	    Loads the given :param:`image`.
	    
	    :return: True if the image was successfully loaded, false if not.
	    
	    :note: You should not call this yourself.  Images handle automatic
	    loading of themselves.
	*/
	loadImage: abstract func (image: NImage) -> Bool
	
	/**
	    Loads the given :param:`font`.
	    
	    :return: True if the font was successfully loaded, false if not.
	    
	    :note: You should not call this yourself.  Like images, fonts will
	    automatically load themselves.
	*/
	loadFont: abstract func (font: NFont) -> Bool
	
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
	    :param:`font`.  The point specifies the baseline.
	*/
	drawText: abstract func (text: String, font: NFont, point: NPoint)
}
