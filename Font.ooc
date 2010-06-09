import Types
import GUI
import Renderer

NFontData: abstract class {
    _renderer: NRenderer
    
    init: func (=_renderer) {
        if (_renderer == null)
            Exception new(This, "Cannot initialize font data with a null renderer") throw()
    }
    
    /** Returns the renderer associated with this font data */
    renderer: func -> NRenderer { _renderer }
    
    /**
        Returns the weight of the font (from 0.0 to 1.0).  Depending on the
        implementation, this may never be used, and should return 0.5 in such
        cases.
    */
    weight: abstract func -> NFloat
    
    /**
        Returns whether or not the font is bold.
    */
    isBold: abstract func -> Bool
    
    /**
        Returns whether or not the font is italicized.
    */
    isItalic: abstract func -> Bool
    
    /**
        Returns whether or not the font can render the given character.
    */
    supportsGlyph: abstract func (chr: ULong) -> Bool
    
    /**
        Returns the pixel size of the glyph for the character.
        
        In the event that the glyph is unsupported, a default size should be
        provided for that glyph.
    */
    glyphSize: abstract func (chr: ULong) -> NSize
    
    /**
        Returns the relative horizontal position of the next character to
        follow the glyph without kerning.
    */
    glyphAdvance: abstract func (chr: ULong) -> NPoint
    
    /**
        Returns the kerning for the given glyph pairing.
    */
    glyphKerning: abstract func (left, right: ULong) -> NPoint
    
    /**
        Returns the relative offset of the glyph from the baseline.
    */
    glyphBearing: abstract func (chr: ULong) -> NPoint
    
    /**
        Returns what should be the minimum height of a line for the font.
    */
    lineHeight: abstract func -> NFloat
    
    /**
        Returns the font's ascender.
    */
    ascender: abstract func -> NFloat
    
    /**
        Returns the font's ascender.
    */
    descender: abstract func -> NFloat
}

NFont: class {
    /** The GUI that will be using the font */
    _gui: NGUI
    
    /** The URL the font was/is to be loaded from */
    url: String = ""
    
    /** The pixel height of the font */
    height: Int = 12
    
    /** Whether or not the font is bold */
    bold := false
    
    /** Whether or not the font is italicized */
    italic := false
    
    /**
        The font data provided by the last renderer to use the font.
    */
    data: NFontData
    
    __loaded?: func -> Bool {
        (data != null && _gui renderer() == data renderer())
    }
    
    __load: func -> Bool {
        ld := __loaded?()
        if (!ld) {
            rd := _gui renderer()
            if (rd && rd loadFont(this))
                return true
            else
                return false
        }
        return true
    }
    
    init: func (=_gui, url: String, =height, =bold, =italic) {
        if (_gui == null)
            Exception new(This, "Cannot instantiate a font without a GUI instance") throw()
        
        this url = url ? url clone() : null
        __load()
    }
    
    /** Returns the height of the font in pixels. */
    height: func -> Int { height }
    
    /**
        Returns the weight of the font (from 0.0 to 1.0).  Depending on the
        implementation, this may never be used, and should return 0.5 in such
        cases.
    */
    weight: func -> NFloat {
        __load() ? data weight() : 0.5
    }
    
    /**
        Returns whether or not the font is bold.
    */
    isBold: func -> Bool { bold }
    
    /**
        Returns whether or not the font is italicized.
    */
    isItalic: func -> Bool { italic }
    
    /**
        Returns whether or not the font can render the given character.
    */
    supportsGlyph: func (chr: ULong) -> Bool {
        __load() ? data supportsGlyph(chr) : false
    }
    
    /**
        Returns the pixel size of the glyph for the character.
        
        In the event that the glyph is unsupported, a default size should be
        provided for that glyph.
    */
    glyphSize: func (chr: ULong) -> NSize {
        __load() ? data glyphSize(chr) : NSize zero()
    }
    
    /**
        Returns the relative horizontal position of the next character to
        follow the glyph without kerning.
    */
    glyphAdvance: func (chr: ULong) -> NPoint {
        __load() ? data glyphAdvance(chr) : NPoint zero()
    }
    
    /**
        Returns the kerning for the given glyph pairing.
    */
    glyphKerning: func (left, right: ULong) -> NPoint {
        __load() ? data glyphKerning(left, right) : NPoint zero()
    }
    
    /**
        Returns the relative offset of the glyph from the baseline.
    */
    glyphBearing: func (chr: ULong) -> NPoint {
        __load() ? data glyphBearing(chr) : NPoint zero()
    }
    
    /**
        Returns what should be the minimum height of a line for the font.
    */
    lineHeight: func -> NFloat {
        __load() ? data lineHeight() : 0.0
    }
    
    /**
        Returns the font's ascender.
    */
    ascender: func -> NFloat {
        __load() ? data ascender() : 0.0
    }
    
    /**
        Returns the font's ascender.
    */
    descender: func -> NFloat {
        __load() ? data descender() : 0.0
    }
    
    /**
        Returns the size of the text for the given string.
    */
    sizeOfText: func (str: String) -> NSize {
        if (!__load())
            return NSize zero()
        
        iter := str iterator()
        lastChr, chr: ULong
        lastChr = 0
        
        init: Bool = false
        rect: NRect = NRect new(0.0, 0.0, 0.0, 0.0)
        charRect: NRect
        point: NPoint
        while (iter hasNext()) {
            chr := iter next()
            
            charRect origin = point
            charRect size = glyphSize(chr)
            charRect origin add(glyphKerning(lastChr, chr)) .add(glyphBearing(chr))
            
            if (init) {
                if (charRect left() < rect left()) rect setLeft(charRect left())
                if (charRect right() > rect right()) rect setRight(charRect right())
                if (charRect top() < rect top()) rect setTop(charRect top())
                if (charRect bottom() > rect bottom()) rect setBottom(charRect bottom())
            } else {
                init = true
                rect = charRect
            }
            
            point x += glyphAdvance(chr) x
            
            lastChr = chr
        }
        
        return rect size
    }
}