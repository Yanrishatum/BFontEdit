package com.yanrishatum.bfont.render;
#if haxepunk
import com.haxepunk.Graphic;
import com.yanrishatum.bfont.BitmapFontChar;
import com.yanrishatum.bfont.BitmapFontText;
import openfl.geom.Point;

/**
 * ...
 * @author Yanrishatum
 */
class HaxepunkBFontText extends Graphic
{
  
  public var text:BitmapFontText;
  private var drawLayer:Int;

  public function new() 
  {
    super();
    text = new HaxepunkBFontTextImpl(this);
  }
  
  public function drawChar(x:Int, y:Int, char:BitmapFontChar, red:Float, green:Float, blue:Float, alpha:Float):Void
  {
    char.region.draw(_point.x + x, _point.y + y, drawLayer, 1, 1, 0, red, green, blue, alpha);
  }
  
  override public function renderAtlas(layer:Int, point:Point, camera:Point) 
  {
		_point.x = Math.ffloor(point.x + x - camera.x * scrollX);
		_point.y = Math.ffloor(point.y + y - camera.y * scrollY);
    drawLayer = layer;
    text.render();
  }
  
}

private class HaxepunkBFontTextImpl extends BitmapFontText
{
  private var parent:HaxepunkBFontText;
  
  public function new(parent:HaxepunkBFontText)
  {
    super();
    this.parent = parent;
  }
  
  override function renderChar(x:Int, y:Int, char:BitmapFontChar, red:Float, green:Float, blue:Float, alpha:Float):Void 
  {
    parent.drawChar(x, y, char, red, green, blue, alpha);
  }
  
}

#end