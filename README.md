ceiling cat - he watches you
============================

A service for monitoring who's on a given page.

It uses a node server hooked up to a redis backend for tracking who's on eacy page.
You pass it a unique page key (usually a url) and a user and it'll report back
everyone who's there.

It currently uses polling every 15 seconds to see who's on there. Ideally I'd
like to use something like [socket.io](http://socket.io) to detect the
presence but I didn't want to deal with issues of passing it though a reverse
proxy or load balencer like [zeus](http://zeus.com).

## Usage

First create the new instance and tell ceiling cat whow you are.

    cat = new CeilingCat('http://ceilingcatserv.er');
    cat.me = 'Talby'

You can optionally set extra info to have stored whith the user. As an
example you can pass the last time the user interacted with the page.

    cat.info = function() {
      return CeilingCat.lastActionAt.getTime();
    };

Finally you have to set a callback which will report back who's on the page every
time ceiling cat sees you.

    cat.cb = function(data) {
      // data => {ok:true,peeps:[]}
    };

Where peeps is an array of the people on the page. Takes the form:

    {name: 'Value of Me', value: 'result of info function'}