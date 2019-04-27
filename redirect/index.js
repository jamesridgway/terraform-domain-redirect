'use strict';
exports.handler = (event, context, callback) => {
	let path = '';
	let querystring = '';

	let redirect = process.env.DESTINATION_ADDR;
	if (event['path'] != null) {
		redirect += event['path']
	}
	let queryParams = event['queryStringParameters'];
	if (queryParams != null) {
		redirect += '?'
		for (var keys = Object.keys(queryParams), i = 0, end = keys.length; i < end; i++) {
		  let key = keys[i];
		  let value = queryParams[key];
		  redirect += key + "=" + value;
		  if (i < end - 1) {
		  	redirect += "&";
		  }
		};
	}

	const response = {
		statusCode: 301,
		headers: {
			Location: redirect,
		}
	};

	return callback(null, response);
}; 