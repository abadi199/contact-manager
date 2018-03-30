document.addEventListener("DOMContentLoaded", function(event) { 
  const elmApp = Elm.Main.embed(document.getElementById("root"));
  elmApp.ports.confirm.subscribe(function(args) {
    if (confirm(args.question))
    {
      const confirmedEvent = new Event('confirmed');
      const deleteButtonElement = document.getElementById(args.domId);
      deleteButtonElement.dispatchEvent(confirmedEvent);
    }
  })
});
