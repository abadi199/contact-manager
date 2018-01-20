module ContactManager.Repository

open System.IO
open NPoco
open Microsoft.Data.Sqlite
open ContactManager.Company 

let private connString = "Filename=" + Path.Combine(Directory.GetCurrentDirectory (), "ContactManager.db")

let getCompanies () =
    System.Console.WriteLine(connString)
    use conn = new SqliteConnection(connString) 
    conn.Open ()
    use db = new Database(conn)
    db.Fetch<Company>()