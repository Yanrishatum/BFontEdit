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
  
  /**
   * Extends current BFont with additional glyphs from another BFont file.  
   * Note: Only glyphs are exported, space size, line height and leading does not overriden.
   */
  public function extend(file:String):Void
  {
    var json:RawBFontData = Json.parse(file);
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

typedef RawBFontData =
{
  var spaceSize:Int;
  var lineHeight:Int;
  var leading:Int;
  var glyphs:Array<RawBFontGlyphData>;
  @:optional var letters:Array<RawBFontGlyphData>;
}

typedef RawBFontGlyphData =
{
  var id:Int;
  var x:Int;
  var y:Int;
  var height:Int;
  var width:Int;
  var originX:Int;
  var originY:Int;
  var spacing:Int;
}