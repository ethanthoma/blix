enum Request({
    method = String, 
    path = String,
    body = String
})

mod Server {
    use Http.Response
    use Http.Response.Response
    use Request.Request
    use Server.Server

    import java.net.InetSocketAddress;

    import com.sun.net.httpserver.HttpExchange
    import com.sun.net.httpserver.HttpHandler
    import com.sun.net.httpserver.HttpServer


    pub enum Server({
        port = Int32,
        httpHandler = Request -> Response \ {}
    })

    pub def start(server: Server): Unit \ {Net, IO} = 
        let Server({port, httpHandler}) = server;
        println("Starting server on port ${port}...");
        let httpServer = HttpServer.create(new InetSocketAddress(port), 0);
        httpServer.createContext("/", contextHandler(httpHandler));
        httpServer.start();

        def loop(): Unit = loop(); loop()

    pub def contextHandler(httpHandler: Request -> Response): HttpHandler \ IO = new HttpHandler {
        def handle(_this: HttpHandler, t: HttpExchange): Unit \ IO =
            let Response({status, headers, body}) =
                Request({
                    method = t.getRequestMethod(), 
                    path = t.getRequestURI().getPath(), 
                    body = t.getRequestBody().toString()
                }) |>
                httpHandler;

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
}
