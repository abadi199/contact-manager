module ContactManager.Contact

open Giraffe 

let contacts () = 
    json [| "Contact 1"; "Contact 2" |]

let contactHandler () =
    choose [
        route "/api/contact" >=> contacts ()
    ]