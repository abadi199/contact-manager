module ContactManager.App

open System
open System.IO
open Microsoft.AspNetCore.Builder
open Microsoft.AspNetCore.Cors.Infrastructure
open Microsoft.AspNetCore.Hosting
open Microsoft.Extensions.Logging
open Microsoft.Extensions.DependencyInjection
open Giraffe
open GiraffeViewEngine
open ContactManager.Api 

// ---------------------------------
// Views
// ---------------------------------

let layout (content: XmlNode list) =
    html [] [
        head [] [
            title []  [ encodedText "Contact Manager" ]
            link [ attr "rel"  "stylesheet"
                   attr "type" "text/css"
                   attr "href" "/bootstrap.min.css" ]
            script [ attr "src" "/elm.min.js" ] []    
            script [ attr "src" "/index.js" ] []
        ]
        body [] content
    ]

let indexView () =
    [
        div [ attr "id" "root" ] []
    ] |> layout

// ---------------------------------
// Web app
// ---------------------------------

let indexHandler () =
    let view      = indexView ()
    renderHtml view

let webApp =
    choose [
        GET >=>
            choose [
                route "/" >=> indexHandler ()
            ]
        routeStartsWith "/api" >=> apiHandler ()
        setStatusCode 404 >=> text "Not Found" ]

// ---------------------------------
// Error handler
// ---------------------------------

let errorHandler (ex : Exception) (logger : ILogger) =
    logger.LogError(EventId(), ex, "An unhandled exception has occurred while executing the request.")
    clearResponse >=> setStatusCode 500 >=> text ex.Message

// ---------------------------------
// Config and Main
// ---------------------------------

let configureCors (builder : CorsPolicyBuilder) =
    builder.WithOrigins("http://localhost:8080")
           .AllowAnyMethod()
           .AllowAnyHeader()
           |> ignore

let configureApp (app : IApplicationBuilder) =
    app.UseCors(configureCors)
       .UseGiraffeErrorHandler(errorHandler)
       .UseStaticFiles()
       .UseGiraffe(webApp)

let configureServices (services : IServiceCollection) =
    services.AddCors() |> ignore

let configureLogging (builder : ILoggingBuilder) =
    let filter (l : LogLevel) = l.Equals LogLevel.Error
    builder.AddFilter(filter).AddConsole().AddDebug() |> ignore

[<EntryPoint>]
let main _ =
    let contentRoot = Directory.GetCurrentDirectory()
    let webRoot     = Path.Combine(contentRoot, "WebRoot")
    WebHostBuilder()
        .UseKestrel()
        .UseContentRoot(contentRoot)
        .UseIISIntegration()
        .UseWebRoot(webRoot)
        .Configure(Action<IApplicationBuilder> configureApp)
        .ConfigureServices(configureServices)
        .ConfigureLogging(configureLogging)
        .Build()
        .Run()
    0