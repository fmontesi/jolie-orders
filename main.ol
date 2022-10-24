type User {
	name: string
	email: string
	karma: int
}

type ListUsersRequest {
	minKarma?: int
}

type ListUsersResponse {
	usernames*: string
}

type ViewUserRequest {
	username: string
}

interface UsersInterface {
RequestResponse:
	listUsers( ListUsersRequest )( ListUsersResponse ),
	viewUser( ViewUserRequest )( User ) throws UserNotFound( string )
}

service App {
	execution: concurrent
    
	inputPort Web {
		location: "socket://localhost:8080"
		protocol: http {
			format = "json"
			osc << {
				listUsers << {
					template = "/api/user"
					method = "get"
					statusCodes.UserNotFound = 404
				}
				viewUser << {
					template = "/api/user/{username}"
					method = "get"
				}
			}
		}
		interfaces: UsersInterface
	}

	init {
		users << {
			john << {
				name = "John Doe", email = "john@doe.com", karma = 4
			}
			jane << {
				name = "Jane Doe", email = "jane@doe.com", karma = 6
			}
		}
	}
    
	main {
		[ viewUser( request )( user ) {
			username = request.username
			if( is_defined( users.(username) ) ) {
				user << users.(username)
			} else {
				throw( UserNotFound, username )
			}
		} ]

		[ listUsers( request )( response ) {
			i = 0
			foreach( username : users ) {
				user << users.(username)
				if( !( is_defined( request.minKarma ) && user.karma < request.minKarma ) ) {
					response.usernames[i++] = username
				}
			}
		} ]
	}
}
