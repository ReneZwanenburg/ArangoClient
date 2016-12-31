module arangoclient.api;

import vibe.web.rest;
import vibe.data.json;
import vibe.http.common : HTTPMethod;

@path("_open")
interface AuthenticationAPI
{
	struct AuthenticationResponse
	{
		string jwt;
		bool must_change_password;
	}
	
	@method(HTTPMethod.POST)
	AuthenticationResponse
	auth(string username, string password);
}

@path("_api")
interface API
{
	@property DatabaseAPI database();
	@property CollectionAPI collection();
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
	current();
	
	
	alias Databases = string[];
	
	Result!Databases
	user();
	
	
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

interface CollectionAPI
{
	enum CollectionType
	{
		Document = 2,
		Edge = 3
	}

	enum KeyType
	{
		Traditional = "traditional",
		AutoIncrement = "autoincrement"
	}

	static struct KeyOptions
	{
		bool allowUserKeys;
		KeyType type;
		int increment;
		int offset;
	}
	
	static struct CreateResult
	{
		string id;
		string name;
		bool waitForSync;
		bool isVolatile;
		bool isSystem;
		int status;
		CollectionType type;
		bool error;
		ushort code;
	}
	
	CreateResult
	create(string name, CollectionType type);
	
	CreateResult
	create(string name, CollectionType type, KeyOptions keyOptions);
	
	CreateResult
	create(
		string name, CollectionType type, KeyOptions keyOptions, ulong journalSize,
		int replicationFactor, bool waitforSync, bool doCompact, bool isVolatile,
		string[] shardKeys, int numberOfShards, bool isSystem, int indexBuckets
	);
	
	
	static struct DeleteResult
	{
		string id;
		bool error;
		ushort code;
	}
	
	@path(":name")
	DeleteResult
	delete_(string _name);
	
	@path(":name")
	@queryParam("isSystem", "isSystem")
	DeleteResult
	delete_(string _name, bool isSystem);
	
	
	static struct CollectionInfo
	{
		string id;
		string name;
		bool isSystem;
		int status;
		CollectionType type;
		bool error;
		ushort code;
	}
	
	@path(":name/truncate")
	@method(HTTPMethod.PUT)
	CollectionInfo
	truncate(string _name);
}

struct Result(T)
{
	T result;
	bool error;
	ushort code;
}