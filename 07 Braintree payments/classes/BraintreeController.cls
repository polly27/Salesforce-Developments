public with sharing class BraintreeController {
	
	@RemoteAction
	public static String getClientToken() {
		HttpRequest req = new HttpRequest();
		req.setEndpoint('https://braintree-server.herokuapp.com/client_token');
		req.setMethod('GET');
		HttpResponse res = new Http().send(req);
		return res.getBody();
	}

	@RemoteAction
	public static String payPalCheckout(String nonce) {
		Map<String, String> m = new Map<String,String>{
			'amount' => '10.00',
			'nonce' => nonce
		};
		String postData = system.JSON.serialize(m);

		HttpRequest req = new HttpRequest();
		req.setEndpoint('https://braintree-server.herokuapp.com/paypal_checkout');
		req.setMethod('POST');
		req.setBody(postData);
		HttpResponse res = new Http().send(req);
		return res.getBody();
	}

	@RemoteAction
	public static String creditCardCheckout(String nonce) {
		Map<String, String> m = new Map<String,String>{
			'amount' => '10.00',
			'nonce' => nonce
		};
		String postData = system.JSON.serialize(m);

		HttpRequest req = new HttpRequest();
		req.setEndpoint('https://braintree-server.herokuapp.com/credit_card_checkout');
		req.setMethod('POST');
		req.setBody(postData);
		HttpResponse res = new Http().send(req);
		return res.getBody();
	}

}