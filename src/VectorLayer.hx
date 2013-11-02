package ;

/**
 * ...
 * @author eg
 */
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.geom.Point;
import map.Layer;
import map.QuadTree;
import map.MapService;
import map.LngLat;

import flash.utils.Timer;
import flash.events.TimerEvent;

class VectorLayer extends Layer
{
    var data:QuadTree;
    var ftimer:Timer;

    public static var COLORS = [0xB2182B, 0xD6604D, 0xF4A582, 0xFDDBC7, 0xE0E0E0, 0xBABABA, 0x878787, 0x4D4D4D];

    public function new(map_service:MapService = null)
    { 
        super(map_service, false);


        ftimer = new Timer(100, 1);
        ftimer.addEventListener(TimerEvent.TIMER_COMPLETE, redraw);

        data = new QuadTree();
        for (i in 0...100000)
        {
            var lng:Float = -30 + Math.random()*100;
            var lat:Float = Math.random()*80; 
            var clr:Int = Math.floor(Math.random()*8);
            var r:Int = 5 + (1 << Math.floor(i / 10000));
            data.push(lng,lat, {color: COLORS[clr], radius: r});
        }
    }

    override function updateContent(forceUpdate:Bool=false)
    {
        if (ftimer.running)
           ftimer.stop();

        if (forceUpdate)
           redraw(null);
        else
           ftimer.start();
    }

    function redraw(e:TimerEvent)
    {

        var zz:Int = this.mapservice.zoom_def + this.zoom;
        var scale:Float = Math.pow(2.0, this.zoom);
        var l2pt = this.mapservice.lonlat2XY;
        var cpt:Point = l2pt(center.lng, center.lat, zz);
        var pt:Point;

        graphics.clear();
        var lt:LngLat = getLeftTopCorner();
        var rb:LngLat = getRightBottomCorner();

 	//var data:Array<QuadData> = data.getData(lt.lng, rb.lat, rb.lng, lt.lat);

        var minsz:Float = 1.0/scale;
        var data:Array<QuadData> = data.getFilteredData(lt.lng, rb.lat, rb.lng, lt.lat, function(q:QuadData):Bool { return q.data.radius > minsz;}); //return scale*q.data.radius > 0.8;});

        var r:Float;
        for (d in data)
        {
            r = scale*d.data.radius;
            pt = l2pt(d.x, d.y, zz);
            graphics.lineStyle(r/2.0, d.data.color);
            graphics.drawRect((pt.x - cpt.x), (pt.y - cpt.y), r, r);
        }
    }
}

