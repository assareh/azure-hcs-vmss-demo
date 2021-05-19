#!/bin/bash
# Script to deploy a very simple web application.
# The web app has a customizable image and some text.

cat << EOM > /var/www/html/index.html
<html>
  <head><title>Meow!</title></head>
  <body style="margin: 0; padding: 0; overflow: hidden;">

  <!-- BEGIN -->
  <img width="100%" src="http://${PLACEHOLDER}/${WIDTH}/${HEIGHT}">
  <b style="font-family: metro-web,Metro,-apple-system,BlinkMacSystemFont,Roboto,Oxygen-Sans,Ubuntu,Cantarell,Helvetica,sans-serif;
            font-size: 18pt; position: absolute; top: 5%; left: 5%; color: white; text-shadow: -1px 1px 2px black,1px 1px 2px black,
            1px -1px 0 black, -1px -1px 0 black;">Welcome to ${PREFIX}'s app!</b>
  <!-- END -->

  </div>
  </body>
</html>
EOM

echo "Script complete."