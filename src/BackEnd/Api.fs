module ContactManager.Api

open Giraffe
open ContactManager.Repository
open ContactManager.Contact
open Microsoft.AspNetCore.Http

let getCompaniesHandler (next: HttpFunc) (ctx: HttpContext) =
    let companies = getCompanies ()
    json companies next ctx 

let companyHandler () =
    choose [
        route "/api/company" >=> getCompaniesHandler
    ]


let apiHandler () =
    choose [ 
        routeStartsWith "/api/company" >=> companyHandler ()
        routeStartsWith "/api/contact" >=> contactHandler ()
    ]
