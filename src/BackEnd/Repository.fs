module ContactManager.Repository

open System.IO
open NPoco
open Microsoft.Data.Sqlite
open ContactManager.Company 

let private connString = "Filename=" + Path.Combine(Directory.GetCurrentDirectory (), "ContactManager.db")

let getCompanies () =
    use conn = new SqliteConnection(connString) 
    conn.Open ()
    use db = new Database(conn)
    db.Fetch<Company>()

let newCompany (newCompany: Company) =
    use conn = new SqliteConnection(connString) 
    conn.Open ()
    use txn: SqliteTransaction = conn.BeginTransaction()
    let cmd = conn.CreateCommand()
    cmd.Transaction <- txn
    cmd.CommandText <- "insert into Company(Name, Address1, Address2, City, State, ZipCode, PhoneNumber, FaxNumber, Category) values ($Name, $Address1, $Address2, $City, $State, $ZipCode, $PhoneNumber, $FaxNumber, $Category)"
    cmd.Parameters.AddWithValue("$Name", newCompany.Name) |> ignore
    cmd.Parameters.AddWithValue("$Address1", newCompany.Address1) |> ignore
    cmd.Parameters.AddWithValue("$Address2", newCompany.Address2) |> ignore
    cmd.Parameters.AddWithValue("$City", newCompany.City) |> ignore
    cmd.Parameters.AddWithValue("$State", newCompany.State) |> ignore
    cmd.Parameters.AddWithValue("$ZipCode", newCompany.ZipCode) |> ignore
    cmd.Parameters.AddWithValue("$PhoneNumber", newCompany.PhoneNumber) |> ignore
    cmd.Parameters.AddWithValue("$FaxNumber", newCompany.FaxNumber) |> ignore
    cmd.Parameters.AddWithValue("$Category", newCompany.Category) |> ignore
    cmd.ExecuteNonQuery () |> ignore
    txn.Commit ()

let deleteCompany (companyId: int) =
    use conn = new SqliteConnection(connString)
    conn.Open ()
    use db = new Database(conn)
    let company = db.SingleById<Company>(companyId)
    db.Delete(company)