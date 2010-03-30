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

class UploadPostHelper
{

		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------

		/**
		 * Boundary used to break up different parts of the http POST body
		 */
		private static var _boundary:String = "";

		/**
		 * Get the boundary for the post.
		 * Must be passed as part of the contentType of the UrlRequest
		 */
		public static function getBoundary():String {

			if(_boundary.length == 0) {
				for ( i in 0...0x20 ) {
					_boundary += String.fromCharCode( Math.round( 97 + Math.random() * 25 ) );
				}
			}

			return _boundary;
		}

		/**
		 * Create post data to send in a UrlRequest
		 */
		public static function getPostData(fileName:String, byteArray:ByteArray, parameters:Hash<String> = null):ByteArray {

			var i:Int;
			var bytes:String;

			var postData:ByteArray = new ByteArray();
			postData.endian = Endian.BIG_ENDIAN;

			//add Filename to parameters
			if(parameters == null) {
				parameters = new Hash<String>();
			}
			parameters.set("Filename",  fileName );
trace( ":filename="+fileName);
			//add parameters to postData
			for( key in parameters.keys() ) {
				postData = BOUNDARY(postData);
				postData = LINEBREAK(postData);
				bytes = 'Content-Disposition: form-data; name="' + key + '"';
trace( ":"+bytes);
				for ( i in 0...(bytes.length) ) {
					postData.writeByte( bytes.charCodeAt(i) );
				}
				postData = LINEBREAK(postData);
				postData = LINEBREAK(postData);
				postData.writeUTFBytes( parameters.get( key ) );
				postData = LINEBREAK(postData);
			}

			//add Filedata to postData
			postData = BOUNDARY(postData);
			postData = LINEBREAK(postData);
			bytes = 'Content-Disposition: form-data; name="Filedata"; filename="';
trace( ":"+bytes);
			for ( i in 0...(bytes.length) ) {
				postData.writeByte( bytes.charCodeAt(i) );
			}
			postData.writeUTFBytes(fileName);
			postData = QUOTATIONMARK(postData);
			postData = LINEBREAK(postData);
			bytes = 'Content-Type: application/octet-stream';
			for ( i in 0...(bytes.length) ) {
				postData.writeByte( bytes.charCodeAt(i) );
			}
			postData = LINEBREAK(postData);
			postData = LINEBREAK(postData);
			postData.writeBytes(byteArray, 0, byteArray.length);
			postData = LINEBREAK(postData);

			//add upload filed to postData
			postData = LINEBREAK(postData);
			postData = BOUNDARY(postData);
			postData = LINEBREAK(postData);
			bytes = 'Content-Disposition: form-data; name="Upload"';
			for ( i in 0...(bytes.length) ) {
				postData.writeByte( bytes.charCodeAt(i) );
			}
			postData = LINEBREAK(postData);
			postData = LINEBREAK(postData);
			bytes = 'Submit Query';
			for ( i in 0...(bytes.length) ) {
				postData.writeByte( bytes.charCodeAt(i) );
			}
			postData = LINEBREAK(postData);

			//closing boundary
			postData = BOUNDARY(postData);
			postData = DOUBLEDASH(postData);

			return postData;
		}

		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------

		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------

		/**
		 * Add a boundary to the PostData with leading doubledash
		 */
		private static function BOUNDARY(p:ByteArray):ByteArray {
			var l:Int = UploadPostHelper.getBoundary().length;

			p = DOUBLEDASH(p);
			for ( i in 0...l ) {
				p.writeByte( _boundary.charCodeAt( i ) );
			}
			return p;
		}

		/**
		 * Add one linebreak
		 */
		private static function LINEBREAK(p:ByteArray):ByteArray {
			p.writeShort(0x0d0a);
			return p;
		}

		/**
		 * Add quotation mark
		 */
		private static function QUOTATIONMARK(p:ByteArray):ByteArray {
			p.writeByte(0x22);
			return p;
		}

		/**
		 * Add Double Dash
		 */
		private static function DOUBLEDASH(p:ByteArray):ByteArray {
			p.writeShort(0x2d2d);
			return p;
		}
}




class Test {
       static var mc : MovieClip;
       static var imageFile : flash.net.FileReference;
       static var loader : Loader;
       static var container : MovieClip;
       static var hiddenLoader : Loader;
       static var hiddenContainer : MovieClip;
       static var urlLoader : URLLoader;
       static var urlRequest : URLRequest;
       static var bmd : BitmapData;
       static var byteArray : ByteArray;
       static var progress : MovieClip;
       static var playProgress : Int;
       static var finalWidth : Int;
       static var finalHeight : Int;
       static var sessionid : String;

    static function main() {
      flash.Lib.current.loaderInfo.addEventListener(Event.COMPLETE, flashLoaderComplete);
      trace(" " );
      trace(flash.Lib.current.loaderInfo.parameters);

         trace( "Flash-object size: w="+flash.Lib.current.stage.stageWidth+",h="+flash.Lib.current.stage.stageHeight);

         hiddenContainer = new MovieClip();
         hiddenContainer.graphics.beginFill(0xcccccc);
         hiddenContainer.graphics.drawRect(0, 0, 10, 10);
         hiddenContainer.graphics.endFill();
         hiddenContainer.x = 0;
         hiddenContainer.y = 0;
         hiddenContainer.width = flash.Lib.current.stage.stageWidth;
         hiddenContainer.height = flash.Lib.current.stage.stageHeight;
         flash.Lib.current.addChild(hiddenContainer);
         hiddenLoader = new Loader();
         hiddenLoader.x = 0;
         hiddenLoader.y = 0;
         hiddenLoader.width = 150;
         hiddenLoader.height = 150;
         hiddenContainer.addChild( hiddenLoader );

         container = new MovieClip();
         container.graphics.beginFill(0xffcccc);
         container.graphics.drawRect(0, 0, 10, 10);
         container.graphics.endFill();
         container.x = 0;
         container.y = 0;
         container.width = flash.Lib.current.stage.stageWidth;
         container.height = flash.Lib.current.stage.stageHeight;
         flash.Lib.current.addChild(container);

         trace("w="+container.width+",h="+container.height);

         imageFile = new flash.net.FileReference();
         imageFile.addEventListener( flash.events.Event.SELECT, filedialoglistener);
         imageFile.addEventListener( flash.events.Event.COMPLETE , fileLoadedCompletelyIntoFlash);

         var browse = flash.Lib.attach("browse");
         browse.x = 0;
         browse.y = 0;
         flash.Lib.current.addChild(browse);
         browse.addEventListener(flash.events.MouseEvent.CLICK, clickBrowseForFiles);

         var upload = flash.Lib.attach("upload");
         upload.x = 80;
         upload.y = 0;
         flash.Lib.current.addChild(upload);
         upload.addEventListener(flash.events.MouseEvent.CLICK, clickSendImage);


         progress = flash.Lib.attach("progress");
         progress.x = flash.Lib.current.stage.stageWidth / 2 - 50;
         progress.y = flash.Lib.current.stage.stageHeight / 2 - 50;
         flash.Lib.current.addChild(progress);
         playProgress = 0;
         progress.visible = false;

         loader = new Loader();
         loader.x = 0;
         loader.y = 0;
         loader.width = 150;
         loader.height = 150;
         container.addChild( loader );
    }

     static function flashLoaderComplete(myEvent:Event)
     {
            var params:Dynamic<String> = flash.Lib.current.loaderInfo.parameters;
            finalWidth = Std.parseInt( params.finalwidth );
            finalHeight = Std.parseInt( params.finalheight );
            sessionid = params.id;
            trace(" finalwidth = "+finalWidth );
            trace(" finalheight = "+finalHeight );
            trace(" id = "+sessionid );
     }



    static function clickSendImage(event:flash.events.MouseEvent)
    {
        trace( "clickSendImage()" );
        progress.play();
        playProgress = 1;
        progress.visible = true;
        /*
        if( playProgress > 0 ) {
                progress.stop();
                playProgress = 0;
                progress.visible = false;
        } else {
                progress.play();
                playProgress = 1;
                progress.visible = true;
        }
        */
        Test.encodeImage();

    }

    static function clickBrowseForFiles(event:flash.events.MouseEvent)
    {
        trace( "clickBrowseForFiles()" );
        var fileFilter = [ new FileFilter("Images (*.jpg, *.jpeg)","*.jpg; *.jpeg") ];
        imageFile.browse(fileFilter);

    }

    static function filedialoglistener(event:flash.events.Event) {

          trace( "About to load " + imageFile.name + " into flash-object" );
          imageFile.load();
  }

    static function fileLoadedCompletelyIntoFlash(event:flash.events.Event) {
           trace( "File loaded completely into flash!" );
           readSize( imageFile.data );
           loader.loadBytes(imageFile.data);
           loader.addEventListener(Event.ADDED_TO_STAGE,upload);
           loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaderComplete);
           hiddenLoader.loadBytes(imageFile.data);
           hiddenLoader.addEventListener(Event.ADDED_TO_STAGE,upload);
           hiddenLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,loaderComplete);
    }

    static var sofo : Array<UInt> = [  0xFF, 0xC0  ]; // [  0xFF, 0xC0 , 0x00 , 0x11 , 0x08 ];
    static var imageHeight : Int;
    static var imageWidth : Int;
    static function readSize( data : flash.utils.ByteArray ) {
           var index : Int;
            var s : String;
            s="\n";
           for( i in 0...sofo.length ){
            s = s + ";" + sofo[ i ] ;
           }
           // trace( "sofo="+s  );

            s ="\n";
           var b : UInt;
           var i : UInt = 0;
           index = 0;
           var size : UInt;
           var length : UInt;
           size = data.bytesAvailable;
           trace("size = " + size );
           b = data.readUnsignedByte();
           b = data.readUnsignedByte();
           while( data.bytesAvailable > sofo.length + 4 ) {
                  b = data.readUnsignedByte();
                  // trace("b="+b);
                  i = data.position;
                  if( i % 10 == 0 ) {
                      s = s + "\n" ;
                  }

                  s = s + " " + b;

                  if( b == sofo[ index ] ) {
                    // trace( "found " + index );
                    index++;
                  }else {
                    index=0;
                    b = data.readUnsignedByte();
                    // trace("lb1="+b);
                    length = b << 8;
                    b = data.readUnsignedByte();
                    // trace("lb2="+b);
                    length = length | b;
                    length = length - 2;
                    //trace("length="+length);
                    i = 0;
                    while( i < length ) {// && data.bytesAvailable > sofo.length + 4 ) {
                           b = data.readUnsignedByte();
                           i++;
                    }
                  }
                  if( index >= 2 ) {
                        b = data.readUnsignedByte();
                        b = data.readUnsignedByte();
                        b = data.readUnsignedByte();
                        imageHeight = data.readUnsignedShort();
                        imageWidth = data.readUnsignedShort();
                        trace( "Real image size determined; " + imageWidth + " x " + imageHeight );
                        break;
                  }

           }
           //trace ( "end" );
           //trace ( "s="+s );
    }

    static function loaderComplete(event:flash.events.Event) {
           try {
           trace( " Loader complete! ");
           var aContainer : MovieClip;
           if( imageWidth > imageHeight ) {
           trace( "1 w>h! ");
               event.target.width = flash.Lib.current.stage.stageWidth;
               event.target.height = event.target.width * (imageHeight/imageWidth);
               if( event.target == loader ) {
                   trace( "1 loader! ");
                  container.width = event.target.width;
                  container.height = container.width * (imageHeight/imageWidth);
               } else {
                 trace( "1 hiddenLoader ");
                  hiddenContainer.width = finalWidth;
                  hiddenContainer.height = container.width * (imageHeight/imageWidth);
               }
           } else {
           trace( "2 w<h! ");
               event.target.height = flash.Lib.current.stage.stageHeight;
               event.target.width = event.target.height * (imageWidth / imageHeight);
               if( Reflect.compare( event.target, loader ) == 0 ) {
                   trace( "2 loader! ");
                  container.height = event.target.height;
                  container.width = container.height * (imageWidth / imageHeight);
               } else {
                 trace( "2 hiddenLoader ");
                  hiddenContainer.height = finalHeight;
                  hiddenContainer.width = container.height * (imageWidth / imageHeight);
               }
           }
           trace( "new size;" +event.target.width+ " x "+event.target.height );
           // container.addChild( loader );
           trace( "Image loaded completely" );
           trace("w="+container.width+",h="+container.height);
           }catch( msg : String ) {
              trace("Error occurred: " + msg);
           }
    }

    static function upload(ev:Event) {
            trace( "Upload complete" );
     }

     static function encodeImage() {
       trace( "encodeImage()" );
            var width : Int = Math.round( loader.width );
            var height : Int = Math.round( loader.height );
            bmd = new BitmapData( width , height, true, 0xFFFFFFFF );
            bmd.draw( container, new Matrix(), null, null, null, true );
//       trace( "bitmap drawn" );
            byteArray = new JPGEncoder( 90 ).encode( bmd );
       trace( "jpgencoder run size="+byteArray.length );
          // set up the request & headers for the image upload;
          var params:Dynamic<String> = flash.Lib.current.loaderInfo.parameters;
          urlRequest = new URLRequest();
          urlRequest.url = 'http://www.t-s-t.se/uploadtest/image.php?path=images&userid='+params.userid;
          urlRequest.contentType = 'multipart/form-data; boundary=' + UploadPostHelper.getBoundary();
          urlRequest.method = URLRequestMethod.POST;
          urlRequest.data = UploadPostHelper.getPostData( imageFile.name, byteArray );
          urlRequest.requestHeaders.push( new URLRequestHeader( 'Cache-Control', 'no-cache' ) );
          // create the image loader & send the image to the server;
       trace( "url: "+ urlRequest.url );
          urlLoader = new URLLoader();
          urlLoader.addEventListener(Event.COMPLETE, urlLoaderComplete );
          urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
          urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
          urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
          urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgressEvent);
       trace("urlLoader eventlisterners created!");
          urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
          try {
                urlLoader.load( urlRequest );
            }
            catch (error:Error) {
                trace( " Unable to load URL: " + error);
            }

       trace( "urlLoader run." );
     }

     static function urlLoaderComplete(ev:Event) {
            progress.stop();
            playProgress = 0;
            progress.visible = false;
            trace("urlLoadComplete()");
            trace("event: "+ev.toString() );
            trace("bytesloaded="+urlLoader.bytesLoaded+", bytesTotal="+urlLoader.bytesTotal+"\n");
            // trace("data="+urlLoader.data);
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
            trace( " HTTPStatusEvent.: status " + evt.status );
        }

     static function onProgressEvent(evt:ProgressEvent)
        {
            trace( " ProgressEvent.: " + evt.bytesLoaded );
        }
}



