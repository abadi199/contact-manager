class Confirm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      show: true,
      domId: ""
    };
  }

  render() {
    const body = React.createElement(
      ReactBootstrap.Modal.Body,
      { key: "body" },
      this.props.question
    );
    const noButton = React.createElement(
      ReactBootstrap.Button,
      { key: "cancelButton", onClick: () => this.props.onCancel() },
      "No"
    );
    const yesButton = React.createElement(
      ReactBootstrap.Button,
      { key: "okButton", bsStyle: "primary", onClick: () => this.props.onOk() },
      "Yes"
    );
    const footer = React.createElement(
      ReactBootstrap.Modal.Footer,
      { key: "footer" },
      [noButton, yesButton]
    );
    const dialog = React.createElement(ReactBootstrap.Modal.Dialog, null, [
      body,
      footer
    ]);

    return React.createElement(
      ReactBootstrap.Modal,
      { show: this.state.show },
      [body, footer]
    );
  }
}

document.addEventListener("DOMContentLoaded", function(event) {
  const elmApp = Elm.Main.embed(document.getElementById("root"));
  let confirmComponent = null;

  elmApp.ports.confirm.subscribe(function(args) {
    if (confirmComponent) {
      confirmComponent.setState({ show: true, domId: args.domId });
    } else {
      confirmComponent = ReactDOM.render(
        React.createElement(
          Confirm,
          {
            onCancel: () => unmounConfirmationDialog(),
            onOk: () => confirmed(),
            question: "Are you sure you want to delete this company?"
          },
          null
        ),
        document.getElementById("confirmationDialog")
      );
      confirmComponent.setState({ ...confirmComponent.state, domId: args.domId });
    }
  });

  function unmounConfirmationDialog() {
    if (confirmComponent) {
      confirmComponent.setState({ ...confirmComponent.state, show: false });
    }
  }

  function confirmed(domId) {
    if (confirmComponent) {
      const confirmedEvent = new Event("confirmed");
      const deleteButtonElement = document.getElementById(confirmComponent.state.domId);
      deleteButtonElement.dispatchEvent(confirmedEvent);
      unmounConfirmationDialog();
    }
  }
});
