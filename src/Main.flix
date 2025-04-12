use Http.Response;
use Http.Response.Response;

use Request.Request;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.util.concurrent.Executors;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;
import com.sun.net.httpserver.Headers;


enum Request({
    method = String, 
    path = String, 
    body = String
}) 

def main(): Unit \ {Net, IO} =
    println("Starting server...");
    start();

    def loop(): Unit = loop();
    loop()

def start():Unit \ {Net, IO} = 
    let server = HttpServer.create(new InetSocketAddress(3000), 0);
    server.createContext("/", httpHandler());
    server.start()

def httpHandler(): HttpHandler \ IO = new HttpHandler {
    def handle(_this:HttpHandler, t:HttpExchange): Unit \ {IO} =
        let Response({status, headers, body}) =
            Request({
                method = t.getRequestMethod(), 
                path = t.getRequestURI().getPath(), 
                body = t.getRequestBody().toString()
            }) |>
            router;

        foreach((key, values) <- headers) {
            let value = String.unwords(values);
            unsafe t.getResponseHeaders().set(key, value)
        };

        if (body.length() > 0) {
            unsafe t.sendResponseHeaders(status, Int32.toInt64(body.length()))
        } else { () };

        let os = t.getResponseBody();
        os.write(body.getBytes());
        os.close()
}

def router(request: Request): Http.Response = {
    let Request({method, path | _}) = request;

    let segments =
        path |>
        String.splitOn(substr="/") |> 
        List.drop(1);

    match (method, segments) {
        case ("PUT",    "bucket" :: bucketName :: Nil) => Bucket.createBucket(request, bucketName)
        case ("DELETE", "bucket" :: bucketName :: Nil) => Bucket.deleteBucket(request, bucketName)
        case ("HEAD",   "bucket" :: bucketName :: Nil) => Bucket.headBucket(request, bucketName)
        case ("GET",    "bucket" :: Nil) => Bucket.listBuckets(request)
        case _ => notFound()
    }
}

def notFound(): Response = {
    Response({status = 404, headers = Map#{}, body = "Not Found"})
}

mod Bucket {
    use Http.Response;
    use Http.Response.Response;

    use Request.Request;


    pub def createBucket(_: Request, bucketName: String): Response = {
        Response({status = 200, headers = Map#{}, body = "CreateBucket ${bucketName}"})
    }

    pub def deleteBucket(_: Request, bucketName: String): Response = {
        Response({status = 200, headers = Map#{}, body = "DeleteBucket ${bucketName}"})
    }

    pub def headBucket(_: Request, bucketName: String): Response = {
        Response({status = 200, headers = Map#{}, body = "HeadBucket ${bucketName}"})
    }

    pub def listBuckets(_: Request): Response = {
        Response({status = 200, headers = Map#{}, body = "ListBuckets"})
    }
}
