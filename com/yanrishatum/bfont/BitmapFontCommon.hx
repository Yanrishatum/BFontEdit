package com.yanrishatum.bfont;
import haxe.io.Input;
import haxe.xml.Fast;

/**
 * ...
 * @author Yanrishatum
 */
class BitmapFontCommon
{

  public var lineHeight:Int;
  public var base:Int;
  public var scaleW:Int;
  public var scaleH:Int;
  public var pages:Int;
  public var packed:Bool;
  public var alphaChannel:BitmapFontChannel;
  public var redChannel:BitmapFontChannel;
  public var greenChannel:BitmapFontChannel;
  public var blueChannel:BitmapFontChannel;
  
  public function new() 
  {
    
  }
  
  public function loadFast(f:Fast):Void
  {
    this.lineHeight = Std.parseInt(f.att.lineHeight);
    this.base = Std.parseInt(f.att.base);
    this.scaleW = Std.parseInt(f.att.scaleW);
    this.scaleH = Std.parseInt(f.att.scaleH);
    this.pages = Std.parseInt(f.att.pages);
    this.packed = f.att.packed == "1";
    if (packed)
    {
      alphaChannel = f.has.alphaChnl ? Std.parseInt(f.att.alphaChnl) : 0;
      redChannel = f.has.redChnl ? Std.parseInt(f.att.redChnl) : 0;
      greenChannel = f.has.greenChnl ? Std.parseInt(f.att.greenChnl) : 0;
      blueChannel = f.has.blueChnl ? Std.parseInt(f.att.blueChnl) : 0;
    }
    else
    {
      alphaChannel = 0;
      redChannel = 0;
      greenChannel = 0;
      blueChannel = 0;
    }
  }
  
  public function loadBinaryInput(input:Input, version:Int, size:Int):Void
  {
    this.lineHeight = input.readUInt16();
    this.base = input.readUInt16();
    this.scaleW = input.readUInt16();
    this.scaleH = input.readUInt16();
    this.pages = input.readUInt16();
    var packed:Int = input.readByte();
    this.packed = packed != 0;
    this.alphaChannel = input.readByte();
    this.redChannel = input.readByte();
    this.greenChannel = input.readByte();
    this.blueChannel = input.readByte();
    // TODO: Validate size
  }
  
}

@:enum
abstract BitmapFontChannel(Int) from Int to Int
{
  var GlyphData = 0;
  var Outline = 1;
  var GlyphAndOutline = 2;
  var Zero = 3;
  var One = 4;
}