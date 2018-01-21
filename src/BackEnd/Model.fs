module ContactManager.Model

type Category() =
    member val Id = 0 with get, set
    member val Name = "" with get, set

type Company() =
    member val Id = 0 with get, set
    member val Name = "" with get, set
    member val Address1 = "" with get, set
    member val Address2 = "" with get, set
    member val City = "" with get, set
    member val State = "" with get, set
    member val ZipCode = "" with get, set
    member val PhoneNumber = "" with get, set
    member val FaxNumber = "" with get, set
    member val CategoryId = 0 with get, set
    member val Category : Category = Category() with get, set


[<CLIMutable>]
type Filter =
    { PhoneNumber : Option<string>
      Category : Option<int> }