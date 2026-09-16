/**
 * @author RadialSpark
 * @date 05-11-2018
 * @description Utility class used to make HTTP callouts
 * 	05-11-2018 - Bradley Wong - created
 */

public without sharing class HttpUtility {

	/**
	* @description makes an http callout and returns the response
	* @param url {String} url endpoint
	* @param httpMethod {String} http method
	* @return {HttpResponse} response from request
	*/ 
	public static HttpResponse httpCallout(String url, String httpMethod, String requestBody, String contentType) {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(url);
		request.setHeader('Content-Type', contentType);
		request.setMethod(httpMethod);

		if (httpMethod == 'POST' || httpMethod == 'PUT') {
			request.setBody(requestBody);
		}

		HttpResponse response = http.send(request);
		return response;
	}

}