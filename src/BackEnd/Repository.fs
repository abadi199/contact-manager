module ContactManager.Repository

open System.IO
open NPoco
open Microsoft.Data.Sqlite
open ContactManager.Model

let private connString = "Filename=" + Path.Combine(Directory.GetCurrentDirectory (), "ContactManager.db")

let getCompanies (filter: Filter)=
    use conn = new SqliteConnection(connString) 
    conn.Open ()
    use db = new Database(conn)
    let categories = 
        db.Fetch<Category> () 
            |> Seq.groupBy (fun category -> category.Id)
            |> Seq.map (fun (id, list) -> (id, Seq.head list))
            |> dict
    let companies = 
        db.Fetch<Company>(@"select Id, Name, Address1, Address2, City, State, ZipCode, PhoneNumber, FaxNumber, CategoryId from Company") 

    let applyPhoneFilter = 
        fun companies -> 
            match filter.PhoneNumber with 
            | None -> companies 
            | Some phoneNumber -> companies |> Seq.where (fun (company: Company) -> company.PhoneNumber.StartsWith(phoneNumber)  )    

    let applyCategoryFilter = 
        fun companies -> 
            match filter.Category with 
            | None -> companies 
            | Some categoryId -> companies |> Seq.where (fun (company: Company) -> company.CategoryId = categoryId )    
    
    companies 
        |> applyPhoneFilter 
        |> applyCategoryFilter 
        |> Seq.map (fun company -> 
            company.Category <- categories.Item(company.CategoryId)
            company
        )

let newCompany (newCompany: Company) =
    use conn = new SqliteConnection(connString) 
    conn.Open ()
    use txn: SqliteTransaction = conn.BeginTransaction ()
    let cmd = conn.CreateCommand ()
    cmd.Transaction <- txn
    cmd.CommandText <- @"
insert into Company(Name, Address1, Address2, City, State, ZipCode, PhoneNumber, FaxNumber, CategoryId) 
values ($Name, $Address1, $Address2, $City, $State, $ZipCode, $PhoneNumber, $FaxNumber, $CategoryId)"
    cmd.Parameters.AddWithValue("$Name", newCompany.Name) |> ignore
    cmd.Parameters.AddWithValue("$Address1", newCompany.Address1) |> ignore
    cmd.Parameters.AddWithValue("$Address2", newCompany.Address2) |> ignore
    cmd.Parameters.AddWithValue("$City", newCompany.City) |> ignore
    cmd.Parameters.AddWithValue("$State", newCompany.State) |> ignore
    cmd.Parameters.AddWithValue("$ZipCode", newCompany.ZipCode) |> ignore
    cmd.Parameters.AddWithValue("$PhoneNumber", newCompany.PhoneNumber) |> ignore
    cmd.Parameters.AddWithValue("$FaxNumber", newCompany.FaxNumber) |> ignore
    cmd.Parameters.AddWithValue("$CategoryId", newCompany.CategoryId) |> ignore
    cmd.ExecuteNonQuery () |> ignore
    txn.Commit ()

let updateCompany (company: Company) =
    use conn = new SqliteConnection(connString) 
    conn.Open ()
    use txn: SqliteTransaction = conn.BeginTransaction()
    let cmd = conn.CreateCommand()
    cmd.Transaction <- txn
    cmd.CommandText <- @"
update Company set 
Name = $Name, 
Address1 = $Address1, 
Address2 = $Address2, 
City = $City, 
State = $State, 
ZipCode = $ZipCode, 
PhoneNumber = $PhoneNumber, 
FaxNumber = $FaxNumber, 
CategoryId = $CategoryId
where Id = $CompanyId"
    cmd.Parameters.AddWithValue("$Name", company.Name) |> ignore
    cmd.Parameters.AddWithValue("$Address1", company.Address1) |> ignore
    cmd.Parameters.AddWithValue("$Address2", company.Address2) |> ignore
    cmd.Parameters.AddWithValue("$City", company.City) |> ignore
    cmd.Parameters.AddWithValue("$State", company.State) |> ignore
    cmd.Parameters.AddWithValue("$ZipCode", company.ZipCode) |> ignore
    cmd.Parameters.AddWithValue("$PhoneNumber", company.PhoneNumber) |> ignore
    cmd.Parameters.AddWithValue("$FaxNumber", company.FaxNumber) |> ignore
    cmd.Parameters.AddWithValue("$CategoryId", company.CategoryId) |> ignore
    cmd.Parameters.AddWithValue("$CompanyId", company.Id) |> ignore
    cmd.ExecuteNonQuery () |> ignore
    txn.Commit ()

let deleteCompany (companyId: int) =
    use conn = new SqliteConnection(connString)
    conn.Open ()
    use txn: SqliteTransaction = conn.BeginTransaction()
    let cmd = conn.CreateCommand()
    cmd.Transaction <- txn
    cmd.CommandText <- "delete from Company where Id = $Id"
    cmd.Parameters.AddWithValue("$Id", companyId) |> ignore
    cmd.ExecuteNonQuery () |> ignore
    txn.Commit ()

let getCategories () =
    use conn = new SqliteConnection(connString)
    conn.Open ()
    use db = new Database(conn)
    db.Fetch<Category>()

let newCategory (name: string) =
    use conn = new SqliteConnection(connString)
    conn.Open ()
    use txn: SqliteTransaction = conn.BeginTransaction()
    let cmd = conn.CreateCommand()
    cmd.Transaction <- txn
    cmd.CommandText <- "insert into Category(Name) values ($Name)"
    cmd.Parameters.AddWithValue("$Name", name) |> ignore
    cmd.ExecuteNonQuery () |> ignore
    txn.Commit ()
