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

let updateCompanyHandler (next: HttpFunc) (ctx: HttpContext) =
    task {
        let! company = ctx.BindJsonAsync<Company>() 
        updateCompany company |> ignore
        let companies = getCompanies ()
        return! json companies next ctx 
    }

let deleteCompanyHandler (companyId: int) (next: HttpFunc) (ctx: HttpContext) =
    deleteCompany companyId |> ignore
    let companies = getCompanies ()
    json companies next ctx


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
    let categories = getCategories () |> Seq.map (fun category -> category.Name)
    json categories next ctx

let newCategoryHandler (next: HttpFunc) (ctx: HttpContext) =
    task {
        let! categoryName = ctx.BindJsonAsync<string>() 
        newCategory categoryName
        let categories = getCategories () |> Seq.map (fun category -> category.Name)
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
