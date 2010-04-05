// extern class newsimage extends MovieClip {}
import Math;
import flash.Error;
import flash.display.MovieClip;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.HTTPStatusEvent;
import flash.events.ProgressEvent;
import flash.text.TextField;
import flash.net.FileReference;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.FileFilter;
import flash.display.Loader;
import lib.encode.JPGEncoder;
import flash.geom.Matrix;
import flash.utils.ByteArray;
import flash.utils.Endian;


class Test {

       static var mc1 : MovieClip;
       static var mc2 : MovieClip;
       static var ldr : Loader;
       static var debug : Bool;
    static function main() {

        debug = true;

       var ldr:Loader = new Loader();

       ldr.addEventListener(Event.COMPLETE, urlLoaderComplete );
         ldr.addEventListener(Event.INIT, urlLoaderComplete );
         ldr.addEventListener(Event.OPEN, urlLoaderComplete );
         ldr.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
         ldr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
         ldr.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
         ldr.addEventListener(ProgressEvent.PROGRESS, onProgressEvent);
       var url:String = "missingphoto.png";
       var urlReq:URLRequest = new URLRequest(url);
       ldr.load(urlReq);
       flash.Lib.current.addChild(ldr);
}



     static function urlLoaderComplete(ev:Event) {

            if( debug ) trace("urlLoadComplete()");
            if( debug ) trace("event: "+ev.toString() );
            // if( debug ) trace("bytesloaded="+urlLoader.bytesLoaded+", bytesTotal="+urlLoader.bytesTotal+"\n");
            // if( debug ) trace("data="+urlLoader.data);

     }



     static function onIOError(evt:IOErrorEvent)
        {
            trace( " IOError: " + evt.text );

        }

     static function onSecurityError(evt:SecurityErrorEvent)
        {
            trace( " SecurityErrorEvent.: " + evt.text );

        }

     static function onHttpStatus(evt:HTTPStatusEvent)
        {
            if( debug ) trace( " HTTPStatusEvent.: status " + evt.status );

        }

     static function onProgressEvent(evt:ProgressEvent)
        {
            if( debug ) trace( " ProgressEvent.: " + evt.bytesLoaded );
        }
}



