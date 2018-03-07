package com.yanrishatum.bfont;
import haxe.io.Input;
import haxe.xml.Fast;

/**
 * ...
 * @author Yanrishatum
 */
class BitmapFontChar
{
  
  public var id:Int;
  public var x:Int;
  public var y:Int;
  public var width:Int;
  public var height:Int;
  public var xOffset:Int;
  public var yOffset:Int;
  public var xAdvance:Int;
  public var page:Int;
  public var channel:BitmapFontCharChannel;
  
  public var kerning:Map<Int, Int>;
  
  #if haxepunk
  public var region:com.haxepunk.graphics.atlas.AtlasRegion;
  #end
  
  public function new() 
  {
    kerning = new Map();
  }
  
  public function loadFast(f:Fast):Void
  {
    this.id = Std.parseInt(f.att.id);
    this.x = Std.parseInt(f.att.x);
    this.y = Std.parseInt(f.att.y);
    this.width = Std.parseInt(f.att.width);
    this.height = Std.parseInt(f.att.height);
    this.xOffset = Std.parseInt(f.att.xoffset);
    this.yOffset = Std.parseInt(f.att.yoffset);
    this.xAdvance = Std.parseInt(f.att.xadvance);
    this.page = Std.parseInt(f.att.page);
    this.channel = Std.parseInt(f.att.chnl);
  }
  
  public function loadBinaryInput(input:Input):Void
  {
    this.id = input.readInt32();
    this.x = input.readUInt16();
    this.y = input.readUInt16();
    this.width = input.readUInt16();
    this.height = input.readUInt16();
    this.xOffset = input.readInt16();
    this.yOffset = input.readInt16();
    this.xAdvance = input.readInt16();
    this.page = input.readByte();
    this.channel = input.readByte();
  }
  
}

@:enum
abstract BitmapFontCharChannel(Int) from Int
{
  var Blue = 1;
  var Green = 2;
  var Red = 4;
  var Alpha = 8;
  var All = 15;
}