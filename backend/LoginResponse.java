package backend;

public class LoginResponse {

	String description;
	String response;

	public LoginResponse() {

	}

	public LoginResponse(String description, String response) {
		this.description = description;
		this.response = response;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getResponse() {
		return response;
	}

	public void setResponse(String response) {
		this.response = response;
	}

}
