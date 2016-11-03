package com.yanrishatum.bfont;
import com.yanrishatum.bfont.BFont.RawBFontData;
import haxe.Json;

/**
 * ...
 * @author Yanrishatum
 */
class BFont
{

  public var glyphs:Map<Int, BFontGlyph>;
  /** Width of 'space' character */
  public var spaceSize:Int;
  /** Minimum line height */
  public var lineHeight:Int;
  /** Vertical offset relative to line. */
  public var leading:Int;
  
  public function new() 
  {
    glyphs = new Map();
  }
  
  public function load(file:String):Void
  {
    var json:RawBFontData = Json.parse(file);
    spaceSize = json.spaceSize;
    lineHeight = json.lineHeight;
    leading = json.leading;
    glyphs = new Map();
    for (glyph in json.glyphs)
    {
      var g:BFontGlyph = new BFontGlyph();
      g.load(glyph);
      glyphs.set(g.id, g);
    }
  }
  
  #if bfont_save
  public function save():String
  {
    var list:Array<RawBFontGlyphData> = new Array();
    for (g in this.glyphs)
    {
      list.push(g.save());
    }
    var data:RawBFontData =
    {
      spaceSize:spaceSize,
      lineHeight:lineHeight,
      leading:leading,
      glyphs:list
    };
    return Json.stringify(data);
  }
  #end
  
}

// Description of JSON format for .bfont files.
typedef RawBFontData =
{
  var spaceSize:Int; // Size of Space character (0x20) in pixels. Keep in mind that spacing of glyph is added as well.
  var lineHeight:Int; // Minimum height of single line in pixels.
  var leading:Int; // Vertical offset between lines in pixels.
  var glyphs:Array<RawBFontGlyphData>; // List of glyphs (see below).
  @:optional var letters:Array<RawBFontGlyphData>;
}

// Single glyph character format.
typedef RawBFontGlyphData =
{
  var id:Int; // UTF-8 ID of the character. 
  var x:Int; // X-Position of character on the image.
  var y:Int; // Y-Position of character on the image.
  var height:Int; // Character width in pixels.
  var width:Int; // Character height in pixels.
  var originX:Int; // Point-of-origin for that character. 0-0 origin is top-left corner of character rectangle.
  var originY:Int;
  var spacing:Int; // Offset to be placed after character in pixels.
}
