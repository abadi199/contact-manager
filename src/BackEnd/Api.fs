module ContactManager.Api

open Giraffe
open ContactManager.Repository
open ContactManager.Contact
open Microsoft.AspNetCore.Http
open ContactManager.Company

let getCompaniesHandler (next: HttpFunc) (ctx: HttpContext) =
    let companies = getCompanies ()
    json companies next ctx 

let newCompanyHandler (next: HttpFunc) (ctx: HttpContext) =
    task {
        let! company = ctx.BindJsonAsync<Company>() 
        newCompany company
        let companies = getCompanies ()
        return! json companies next ctx 
    }

let companyHandler () =
    choose [
        GET >=> choose [ 
            route "/api/company" >=> getCompaniesHandler 
        ]
        POST >=> choose [ 
            route "/api/company/new" >=> newCompanyHandler 
        ]
    ]




let apiHandler () =
    choose [ 
        routeStartsWith "/api/company" >=> companyHandler ()
        routeStartsWith "/api/contact" >=> contactHandler ()
    ]
