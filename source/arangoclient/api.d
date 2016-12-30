module arangoclient.api;

import vibe.web.rest;
import vibe.data.json;

@path("_open")
interface AuthenticationAPI
{
	struct AuthenticationResponse
	{
		string jwt;
		bool must_change_password;
	}
	
	AuthenticationResponse postAuth(string username, string password);
}

@path("_api")
interface API
{
	@property DatabaseAPI database();
}

interface DatabaseAPI
{
	static struct CurrentDatabase
	{
		string name;
		string id;
		string path;
		bool isSystem;
	}
	
	Result!CurrentDatabase
	getCurrent();
	
	
	alias Databases = string[];
	
	Result!Databases
	getUser();
	
	
	Result!Databases
	get();
	
	
	static struct User
	{
		string name;
		string passwd;
		bool active;
		Json extra;
	}
	
	Result!bool
	create(string name, User[] users);
	
	@path(":name")
	Result!bool delete_(string _name);
}

struct Result(T)
{
	T result;
	bool error;
	ushort code;
}