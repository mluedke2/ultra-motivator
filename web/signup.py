#!C:\Python27\python.exe -u
#!/usr/bin/env python

import MySQLdb
import hashlib
import cgi
import uuid

def hash_password(password):
    salt = uuid.uuid4().hex
    return hashlib.sha256(salt.encode() + password.encode()).hexdigest() + ':' + salt

def show_signup_ui():
	print """

	 <div class="center">
	  <form method="post" action="#">
		<p><input type="text" name="username" placeholder="Username" autocomplete="username" /></p>
		<p><input type="password" name="password" placeholder="Password" autocomplete="new-password" /></p>
		<p><input type="password" name="confirm_password" placeholder="Confirm Password" autocomplete="new-password" /></p>
		<p><input type="submit" value="Sign Up" /></p>
	  </form>
	  </div>

	</body>

	</html>
	"""

print "Content-type: text/html"
print

print """
<html>

<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Ultra Motivator Sign Up</title>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css">
<link rel="stylesheet" href="style.css" />
</head>

<body>

<h1> Ultra Motivator Sign Up </h1>
"""

form = cgi.FieldStorage()

if "username" not in form or "password" not in form or "confirm_password" not in form:
	print """<h3>Please Sign Up</h3>"""
	show_signup_ui()
else:
	input_username = form.getvalue("username", "")
	input_password = form.getvalue("password", "")
	confirm_password = form.getvalue("confirm_password", "")
	
	if input_password != confirm_password:
		print """<h3>Password Fields Did Not Match!</h3>"""
		show_signup_ui()
	else:
		try:
			conn = MySQLdb.connect (
			host = "my_host",
			user = "my_user",
			passwd = "my_password",
			db = "my_db")
	
			cur = conn.cursor()

			command = "INSERT INTO User(username, password) VALUES(%s,%s)"
			cur.execute(command, (input_username, hash_password(input_password)))
			print """<h1>Signed Up As %s</h1>""" % input_username
			print """<p>"If you want to build a ship, don't drum up the people to gather wood, and don't assign them tasks and work. Instead, teach them to yearn for the vast and endless sea." - Antoine de Saint-Exupery</p>"""
	
		except MySQLdb.Error, e:
			print """<h1>Error %d: %s</h1>""" % (e.args[0], e.args[1])
		finally:
			if cur:
				cur.close()
			if conn:
				conn.close()
	print """</body></html>"""
