class ApplicantForm extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			firstName: "",
			lastName: "",
			email: "",
			phone: "",
			zipcode: "",
			referralCode: "",
		};

		this.handleChange = this.handleChange.bind(this);
		this.handleSubmit = this.handleSubmit.bind(this);
	}

	handleChange(event) {
		console.log("Changing: " + event.target.id);
		this.setState({ [event.target.id]: event.target.value})
	}

	handleSubmit(event) {
		console.log("Submitted:")
		console.log(this.state);
		event.preventDefault();
	}

	render() {
		return (
			<div className="container">
			<div className="row">
				<div className="col-sm-6 col-md-4 col-md-offset-4">
					<div className="account-wall">
						<div className="logo"/>
						<h1 className="text-center applicant-form-title">Sign up to get paid while you shop!</h1>
						<form className="applicant-form" onSubmit={this.handleSubmit}>
							<label htmlFor="firstName" className="sr-only">First Name</label>
							<input value={this.state.firstName} onChange={this.handleChange}
								   type="text" id="firstName" className="form-control form-control-first"
								   placeholder="First Name" required="" autoFocus=""/>
							<label htmlFor="lastName" className="sr-only">Last Name</label>
							<input value={this.state.lastName} onChange={this.handleChange}
								   type="text" id="lastName" className="form-control"
								   placeholder="Last Name" required="" autoFocus=""/>
							<label htmlFor="email" className="sr-only">Email address</label>
							<input value={this.state.email} onChange={this.handleChange}
								   type="email" id="email" className="form-control"
								   placeholder="Email address" required="" autoFocus=""/>
							<label htmlFor="phone" className="sr-only">Cell Phone</label>
							<input value={this.state.Phone} onChange={this.handleChange}
								   type="tel" id="phone" className="form-control"
								   placeholder="Cell Phone" required="" autoFocus=""/>
							<label htmlFor="zipcode" className="sr-only">Zip Code</label>
							<input value={this.state.zipcode} onChange={this.handleChange}
								   type="text" id="zipcode" className="form-control"
								   placeholder="Zip Code" required="" autoFocus=""/>
							<label htmlFor="referralCode" className="sr-only">Referral Code</label>
							<input value={this.state.referralCode} onChange={this.handleChange}
								   type="text" id="referralCode" className="form-control form-control-last"
								   placeholder="Referral Code" required=""/>
							<button className="btn btn-lg btn-primary btn-block" type="submit">Apply</button>
						</form>
					</div>
				</div>
			</div>
			</div>
		);
	}
}

ReactDOM.render(
	<ApplicantForm />,
	document.getElementById('applicant-sign-up')
);
