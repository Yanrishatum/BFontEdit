package com.yanrishatum.bfont;
import haxe.io.Input;
import haxe.xml.Fast;

/**
 * ...
 * @author Yanrishatum
 */
class BitmapFontInfo
{

  public var face:String;
  public var size:Int;
  public var bold:Bool;
  public var italic:Bool;
  public var charset:Int;
  public var unicode:Bool;
  public var stretchH:Float; // 0...1
  public var smooth:Bool;
  public var aa:Int;
  public var padding:BitmapFontPadding;
  public var spacing:BitmapFontSpacing;
  public var outline:Int;
  
  public function new() 
  {
    
  }
  
  public function loadFast(f:Fast):Void
  {
    this.face = f.att.face;
    this.size = Std.parseInt(f.att.size);
    this.bold = f.att.bold == "1";
    this.italic = f.att.italic == "1";
    this.charset = f.has.charset ? Std.parseInt(f.att.charset) : 0;
    this.unicode = f.att.unicode == "1";
    this.stretchH = f.has.stretchH ? Std.parseFloat(f.att.stretchH) / 100 : 100;
    this.smooth = f.att.smooth == "1";
    this.aa = f.has.aa ? Std.parseInt(f.att.aa) : 1;
    
    var arr:Array<String> = f.att.padding.split(",");
    var i1:Int, i2:Int, i3:Int, i4:Int;
    if (arr.length == 0) padding = { left:0, right: 0, up: 0, down: 0 };
    else if (arr.length < 2)
    {
      i1 = Std.parseInt(arr[0]);
      padding = { left: i1, right: i1, up: i1, down: i1 };
    }
    else if (arr.length < 4)
    {
      i1 = Std.parseInt(arr[0]);
      i2 = Std.parseInt(arr[1]);
      padding = { left: i2, right: i2, up: i1, down: i1 };
    }
    else
    {
      i1 = Std.parseInt(arr[0]);
      i2 = Std.parseInt(arr[1]);
      i3 = Std.parseInt(arr[2]);
      i4 = Std.parseInt(arr[3]);
      padding = { up: i1, right: i2, down: i3, left: i4 };
    }
    
    arr = f.att.spacing.split(",");
    if (arr.length == 0) spacing = { horizontal: 0, vertical: 0 };
    else if (arr.length == 1)
    {
      i1 = Std.parseInt(arr[0]);
      spacing = { horizontal: i1, vertical: i1 };
    }
    else
    {
      i1 = Std.parseInt(arr[0]);
      i2 = Std.parseInt(arr[1]);
      spacing = { horizontal: i1, vertical: i2 };
    }
    
    outline = f.has.outline ? Std.parseInt(f.att.outline) : 0;
    
  }
  
  public function loadBinaryInput(input:Input, version:Int, size:Int):Void
  {
    this.size = input.readUInt16();
    var packed:Int = input.readByte();
    this.smooth = (packed & 128) == 128;
    this.unicode = (packed & 64) == 64;
    this.italic = (packed & 32) == 32;
    this.bold = (packed & 16) == 16;
    // fixedHieght does something?
    this.charset = input.readByte();
    this.stretchH = input.readUInt16() / 100;
    this.aa = input.readByte();
    this.padding = {
      up: input.readByte(),
      right: input.readByte(),
      down: input.readByte(),
      left: input.readByte()
    };
    this.spacing = {
      horizontal: input.readByte(),
      vertical: input.readByte()
    };
    size -= 13;
    if (version >= 2)
    {
      outline = input.readByte();
      size--;
    }
    else
    {
      outline = 0;
    }
    face = input.readUntil(0);
    size -= face.length;
    while (size > 0)
    {
      input.readByte();
    }
  }
  
}

@:structInit
class BitmapFontPadding
{
  
  public var up:Int;
  public var down:Int;
  public var left:Int;
  public var right:Int;
  
}

@:structInit
class BitmapFontSpacing
{
  
  public var horizontal:Int;
  public var vertical:Int;
  
}