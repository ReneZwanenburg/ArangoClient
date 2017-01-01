module arangoclient;

public import arangoclient.api;

import vibe.web.rest : RestInterfaceClient;

alias ArangoClient = RestInterfaceClient!API;

alias ArangoAuthenticationClient = RestInterfaceClient!AuthenticationAPI;

auto arangoClient(string serverAddress, string databaseName, string user, string password)
{
	auto authClient = new ArangoAuthenticationClient(serverAddress);
	auto authResponse = authClient.auth(user, password);
	auto bearerToken = "bearer " ~ authResponse.jwt;

	auto client = new ArangoClient(serverAddress ~ "/_db/" ~ databaseName);
	client.requestFilter = (scope request)
	{
		request.headers["Authorization"] = bearerToken;
	};
	
	return client;
}