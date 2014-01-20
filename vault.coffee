casper = require("casper").create(
  imageLoad: false
)

getBalance = ->
  balance = document.querySelectorAll('span.abbr')
  Array::map.call balance, (s) -> s.innerText.replace /,/, ""

getEUR = ->
  __utils__.getFieldValue 'EUR'

casper.start "https://www.dogevault.com", ->
  @fill "form#new_user", {user_name: "user", user_password: "pass"}, false

casper.then ->
  @captureSelector "vaultshot0.png", "html"

casper.waitForSelector "form#new_user input[type=submit][value='Login']", ->
  @click "form#new_user input[type=submit][value='Login']"

casper.then ->
  bal = @evaluate getBalance
  XDG = bal[0]
  @thenOpen "http://coinmill.com/XDG_calculator.html#XDG=#{XDG}", ->
    @waitFor ->
      "" != @evaluate getEUR
    , ->
      EUR = @evaluate getEUR
      @echo "#{XDG} Ɖ ~ #{EUR} €"

casper.run()

