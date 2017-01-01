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
	
	static struct User
	{
		string name;
		string passwd;
		bool active;
		Json extra;
	}
	
	alias Databases = string[];
	
	@method(HTTPMethod.GET)
	Result!CurrentDatabase
	current();
	
	@method(HTTPMethod.GET)
	Result!Databases
	user();
	
	Result!Databases
	get();
	
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
	
	static
	{
		struct KeyOptions
		{
			bool allowUserKeys;
			KeyType type;
			
			@optional:
			int increment;
			int offset;
		}
		
		struct CreateResult
		{
			string id;
			string name;
			bool waitForSync;
			bool isVolatile;
			bool isSystem;
			int status;
			CollectionType type;
			
			mixin Status;
		}
		
		struct DeleteResult
		{
			string id;
			
			mixin Status;
		}
		
		struct Info
		{
			mixin InfoTemplate;
		}
		
		struct Properties
		{
			mixin PropertiesTemplate;
		}
		
		struct Count
		{
			mixin CountTemplate;
		}
		
		struct Figures
		{
			mixin CountTemplate;
			FiguresInfo figures;
		}
		
		struct FiguresInfo
		{
			static
			{
				struct Indexes
				{
					ulong count;
					ulong size;
				}
				
				struct CompactionStatus
				{
					string message;
					string time;
				}
				
				struct ReadCache
				{
					ulong count;
					ulong size;
				}
				
				struct Alive
				{
					ulong count;
					ulong size;
				}
				
				struct Dead
				{
					ulong count;
					ulong size;
					ulong deletion;
				}
				
				struct DataFiles
				{
					ulong count;
					ulong fileSize;
				}
				
				struct Journals
				{
					ulong count;
					ulong fileSize;
				}
				
				struct Compactors
				{
					ulong count;
					ulong fileSize;
				}
				
				struct Revisions
				{
					ulong count;
					ulong size;
				}
			}
			
			Indexes indexes;
			CompactionStatus compactionStatus;
			ReadCache readCache;
			Alive alive;
			Dead dead;
			DataFiles datafiles;
			Journals journals;
			Compactors compactors;
			Revisions revisions;
			ulong lastTick;
			ulong uncollectedLogfileEntries;
			ulong documentReferences;
			string waitingFor;
		}
		
		struct Revision
		{
			mixin RevisionTemplate;
		}
		
		struct Checksum
		{
			mixin RevisionTemplate;
			
			string checksum;
		}
		
		struct CollectionInfo
		{
			mixin BasicInfoTemplate;
		}
		
		struct Load
		{
			mixin InfoTemplate;
			
			ulong count;
		}
	}

	
	CreateResult
	create(string name, CollectionType type);
	
	CreateResult
	create(string name, CollectionType type, KeyOptions keyOptions);
	
	CreateResult
	create(
		string name, CollectionType type, KeyOptions keyOptions, ulong journalSize,
		int replicationFactor, bool waitForSync, bool doCompact, bool isVolatile,
		string[] shardKeys, int numberOfShards, bool isSystem, int indexBuckets
	);
	
	@path(":name")
	DeleteResult
	delete_(string _name);
	
	@path(":name")
	@queryParam("isSystem", "isSystem")
	DeleteResult
	delete_(string _name, bool isSystem);
	
	@path(":name/truncate")
	@method(HTTPMethod.PUT)
	Info
	truncate(string _name);
	
	@path(":name")
	Info
	get(string _name);
	
	@path(":name/properties")
	@method(HTTPMethod.GET)
	Properties
	properties(string _name);
	
	@path(":name/count")
	@method(HTTPMethod.GET)
	Count
	count(string _name);
	
	@path(":name/figures")
	@method(HTTPMethod.GET)
	Figures
	figures(string _name);
	
	@path(":name/revision")
	@method(HTTPMethod.GET)
	Revision
	revision(string _name);
	
	@path(":name/checksum")
	@method(HTTPMethod.GET)
	@queryParam("withRevisions", "withRevisions")
	@queryParam("withData", "withData")
	Checksum
	checksum(string _name, bool withRevisions = false, bool withData = false);
	
	Result!(CollectionInfo[])
	get();
	
	@path(":name/load")
	@method(HTTPMethod.PUT)
	Load
	load(string _name);
	
	@path(":name/unload")
	@method(HTTPMethod.PUT)
	Info
	unload(string _name);
	
	@path(":name/properties")
	@method(HTTPMethod.PUT)
	Properties
	properties(string _name, bool waitForSync, ulong journalSize)
	
	@path(":oldName/rename")
	@method(HTTPMethod.PUT)
	Info
	rename(string _oldName, string name);
	
	@path(":name")
	@method(HTTPMethod.PUT)
	Result!bool
	rotate(string _name);
	
	private
	{
		mixin template BasicInfoTemplate()
		{
			string id;
			string name;
			bool isSystem;
			int status;
			CollectionType type;
		}
	
		mixin template InfoTemplate()
		{
			mixin BasicInfoTemplate;
			mixin Status;
		}
		
		mixin template PropertiesTemplate()
		{
			mixin InfoTemplate;
		
			bool waitForSync;
			bool doCompact;
			bool isVolatile;
			ulong journalSize;
			KeyOptions keyOptions;
			
			@optional
			{
				int replicationFactor;
				int numberOfShards;
				string[] shardKeys;
			}
		}
		
		mixin template CountTemplate()
		{
			mixin PropertiesTemplate;
			
			ulong count;
		}
		
		mixin template RevisionTemplate()
		{
			mixin InfoTemplate;
			
			string revision;
		}
	}
}

mixin template Status()
{
	bool error;
	ushort code;
	
	@optional
	{
		int errorNum;
		string errorMessage;
	}
}

struct Result(T)
{
	T result;
	mixin Status;
}