module arangoclient;

public import arangoclient.api;

import std.datetime;

auto arangoClient(string serverAddress, string databaseName, string user, string password)
{
	auto authClient				= new ArangoAuthenticationClient(serverAddress);
	auto tokenExpirationPeriod	= 24.hours; // Actual validity is one month, but we'll refresh daily
	auto tokenValidUntil		= Clock.currTime(UTC());
	auto client					= new ArangoClient(serverAddress ~ "/_db/" ~ databaseName);
	auto bearerToken			= "";
	
	client.requestFilter = (scope request)
	{
		auto now = Clock.currTime(UTC());
		
		if(now >= tokenValidUntil)
		{
			auto authResponse	= authClient.auth(user, password);
			bearerToken			= "bearer " ~ authResponse.jwt;
			tokenValidUntil		= now + tokenExpirationPeriod;
		}
		
		request.headers["Authorization"] = bearerToken;
	};
	
	return client;
}