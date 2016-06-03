package com.yanrishatum.bfont;
import com.yanrishatum.bfont.BFont.RawBFontGlyphData;
#if haxepunk
import com.haxepunk.graphics.atlas.AtlasRegion;
#end

/**
 * ...
 * @author Yanrishatum
 */
class BFontGlyph
{
  /** X offset on image */
  public var x:Int;
  /** Y offset on image */
  public var y:Int;
  /** Letter width */
  public var width:Int;
  /** Letter height */
  public var height:Int;
  
  /** Letter char id. */
  public var id:Int;
  
  /** Render offset to left */
  public var originX:Int;
  public var originY:Int;
  /** Spacing after letter end */
  public var spacing:Int;
  
  #if haxepunk
  public var region:AtlasRegion;
  #end
  
  public function new() 
  {
    
  }
  
  public function load(data:RawBFontGlyphData):Void
  {
    this.id = data.id;
    this.x = data.x;
    this.y = data.y;
    this.width = data.width;
    this.height = data.height;
    this.originX = data.originX;
    this.originY = data.originY;
    this.spacing = data.spacing;
  }
  
  #if bfont_save
  public function save():RawBFontGlyphData
  {
    return {
      id:id,
      x:x,
      y:y,
      width:width,
      height:height,
      originX:originX,
      originY:originY,
      spacing:spacing
    };
  }
  #end
  
}