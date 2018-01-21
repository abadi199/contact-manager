module ContactManager.Api

open Giraffe
open ContactManager.Repository
open Microsoft.AspNetCore.Http
open ContactManager.Model

let getCompaniesHandler (next: HttpFunc) (ctx: HttpContext) =
    let filter = ctx.BindQueryString<Filter>()
    let companies = getCompanies filter
    json companies next ctx 

let newCompanyHandler (next: HttpFunc) (ctx: HttpContext) =
    task {
        let! company = ctx.BindJsonAsync<Company>() 
        return! json (newCompany company) next ctx 
    }

let updateCompanyHandler (next: HttpFunc) (ctx: HttpContext) =
    task {
        let! company = ctx.BindJsonAsync<Company>() 
        return! json (updateCompany company) next ctx 
    }

let deleteCompanyHandler (companyId: int) (next: HttpFunc) (ctx: HttpContext) =
    json (deleteCompany companyId) next ctx


let companyHandler () =
    choose [
        GET >=> choose [ 
            route "/api/company" >=> getCompaniesHandler 
        ]
        POST >=> choose [ 
            route "/api/company/new" >=> newCompanyHandler 
            route "/api/company" >=> updateCompanyHandler 
        ]
        DELETE >=> choose [
            routef "/api/company/%i" deleteCompanyHandler
        ]
    ]

let getCategoriesHandler (next: HttpFunc) (ctx: HttpContext) =
    let categories = getCategories () 
    json categories next ctx

let newCategoryHandler (next: HttpFunc) (ctx: HttpContext) =
    task {
        let! categoryName = ctx.BindJsonAsync<string>() 
        newCategory categoryName
        let categories = getCategories ()
        return! json categories next ctx 
    }

let categoryHandler () =
    choose [
        GET >=> choose [
            route "/api/category" >=> getCategoriesHandler
        ]
        POST >=> choose [
            route "/api/category/new" >=> newCategoryHandler
        ]
    ]

let apiHandler () =
    choose [ 
        routeStartsWith "/api/company" >=> companyHandler ()
        routeStartsWith "/api/category" >=> categoryHandler ()
    ]
