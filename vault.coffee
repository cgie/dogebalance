casper = require("casper").create(
  pageSettings:
    userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:23.0) Gecko/20130404 Firefox/23.0"
)

getBalance = ->
  balance = document.querySelectorAll('span.abbr')
  Array::map.call balance, (s) -> s.innerText.replace /,/, ""

getConfirmed = ->
  confirmed = document.querySelectorAll('span#b-confirmed')
  Array::map.call confirmed, (s) -> s.innerText.replace /,/, ""

getUnconfirmed = ->
  unconfirmed = document.querySelectorAll('span#b-unconfirmed')
  Array::map.call unconfirmed, (s) -> s.innerText.replace /,/, ""

getEUR = ->
  __utils__.getFieldValue 'EUR'

casper.start "https://www.dogevault.com", ->
  @waitForSelector "form#new_user", ->
    @fill "form#new_user", {user_name: "user", user_password: "pass"}, false

casper.then ->
  @waitForSelector "form#new_user input[type=submit][value='Login']", ->
    @click "form#new_user input[type=submit][value='Login']"

casper.then ->
  bal = @evaluate getBalance
  XDG = bal[0]
  @thenOpen "http://doge.poolerino.com/", ->
    @waitForSelector "form#loginForm", ->
      @fill "form#loginForm", {username: "user", password: "pass"}, false
      @then ->
        @waitForSelector "form#loginForm input[type=submit][value='Login']", ->
          @click "form#loginForm input[type=submit][value='Login']"
          @then ->
            @waitForSelector "span#b-confirmed", ->
              confirmed = @evaluate getConfirmed
              unconfirmed = @evaluate getUnconfirmed
              @then ->
               sum = (parseFloat XDG) + (parseFloat confirmed[0]) + (parseFloat unconfirmed[0])
               @thenOpen "http://coinmill.com/XDG_calculator.html#XDG=#{sum}", ->
                 @waitFor ->
                   "" != @evaluate getEUR
                 , ->
                   EUR = @evaluate getEUR
                   @echo """
                         Wallet:     \t #{XDG}
                         Confirmed:  \t #{confirmed}
                         Unconfirmed:\t #{unconfirmed}
                         Total: #{sum} Ɖ ~ #{EUR} €
                         """

casper.run()
