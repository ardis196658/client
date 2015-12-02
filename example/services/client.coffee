angular.module 'mmpgClient', []
  .factory 'Client', ->
    new MMPG.Client(window.location.hostname + ':8080')

  .factory 'EventStream', (Client) ->
    Client.eventStream()

  .service 'Session', (Client, $localStorage) ->
    new class
      constructor: ->
        @reset()

      login: (user) ->
        Client.login(user)
          .done (data) =>
            @update(new MMPG.Webtoken(data))

      update: (token) ->
        @user.email = token.payload.email
        @user.name = @user.email.split('@')[0]
        @user.logged = true
        $localStorage.token = token.string
        Client.setAuth(token)

      renew: ->
        token = $localStorage.token
        return unless token

        Client.setAuth(token)

        Client.renew(token)
          .done (newToken) =>
            @update(new MMPG.Webtoken(newToken))
          .fail =>
            @logout()

      logout: ->
        delete $localStorage.token
        @reset()

      reset: ->
        @user =
          email: null
          name: null
          logged: false

  .run (Session) ->
    Session.renew()
