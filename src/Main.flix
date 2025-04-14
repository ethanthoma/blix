use Http.Response
use Http.Response.Response

use Request.Request
use Storage.Storage
use Server.Server.Server

import java.io.IOException
import java.io.OutputStream
import java.net.InetSocketAddress
import java.util.concurrent.Executors

import com.sun.net.httpserver.HttpExchange
import com.sun.net.httpserver.HttpHandler
import com.sun.net.httpserver.HttpServer
import com.sun.net.httpserver.Headers


enum Storage({path = String})

def main(): Unit \ {Net, IO, Sys} =
    let commands = getCommands();
    let storage = run parseCommands(commands) with Exit.runWithIO;
    let server = Server({port = 3000, httpHandler = router(storage)});
    Server.start(server)

def parseCommands(commands: List[Command]): Storage \ {Exit, IO} =
    let default = Storage({path = "./"});
    List.foldLeft((storage: Storage, command: Command) -> {
        let Storage(rec) = storage;
        match command {
            case Command.Option({name = "path", value = path}) => Storage({path = path | rec})
            case _ => {
                println("The command ${command} is not a valid command");
                Exit.exit(1)
            }
        }
    }, default, commands)

def router(storage: Storage, request: Request): Http.Response = {
    let Request({method, path | _}) = request;

    let segments =
        path |>
        String.splitOn(substr="/") |> 
        List.drop(1);

    match (method, segments) {
        case ("PUT",    "bucket" :: bucketName :: Nil) => Bucket.createBucket(request, storage, bucketName)
        case ("DELETE", "bucket" :: bucketName :: Nil) => Bucket.deleteBucket(request, storage, bucketName)
        case ("HEAD",   "bucket" :: bucketName :: Nil) => Bucket.headBucket(request, storage, bucketName)
        case ("GET",    "bucket" :: Nil)               => Bucket.listBuckets(request, storage)
        case _ => notFound()
    }
}

def notFound(): Response = {
    Response({status = 404, headers = Map#{}, body = "Not Found"})
}

enum Bucket({name = String})

mod Bucket {
    use Http.Response;
    use Http.Response.Response;

    use Request.Request;


    pub def createBucket(_: Request, _storage: Storage, bucketName: String): Response = {
        Response({status = 200, headers = Map#{}, body = "CreateBucket ${bucketName}"})
    }

    pub def deleteBucket(_: Request, _storage: Storage, bucketName: String): Response = {
        Response({status = 200, headers = Map#{}, body = "DeleteBucket ${bucketName}"})
    }

    pub def headBucket(_: Request, _storage: Storage, bucketName: String): Response = {
        Response({status = 200, headers = Map#{}, body = "HeadBucket ${bucketName}"})
    }

    pub def listBuckets(_: Request, _storage: Storage): Response = {
        Response({status = 200, headers = Map#{}, body = "ListBuckets"})
    }
}
