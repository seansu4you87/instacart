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
	}

	handleSubmit(event) {
		console.log("Submitted:")
		console.log(this.state);
		event.preventDefault();
	}

	render() {
		return (
			<p>Hello, Applicant!, apply here!</p>
		);
	}
}

ReactDOM.render(
	<ApplicantForm />,
	document.getElementById('applicant-sign-up')
);
