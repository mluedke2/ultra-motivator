#!C:\Python27\python.exe -u
#!/usr/bin/env python

import MySQLdb
import hashlib
import cgi

def check_password(hashed_password, user_password):
    password, salt = hashed_password.split(':')
    return password == hashlib.sha256(salt.encode() + user_password.encode()).hexdigest()

print "Content-type: text/html"
print

print """
<html>

<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Ultra Motivator Sign In</title>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css">
<link rel="stylesheet" href="style.css" />
</head>

<body>

<h1> Ultra Motivator Sign In </h1>
"""

form = cgi.FieldStorage()

if "username" not in form or "password" not in form:
	print """

	 <div class="center">
	  <form method="post" action="#">
		<p><input type="text" name="username" placeholder="Username" required autofocus autocomplete="username" /></p>
		<p><input type="password" name="password" placeholder="Password" required autocomplete="current-password" /></p>
		<p><input type="submit" value="Sign In" /></p>
	  </form>
	  </div>

	</body>

	</html>
	"""
else:
	
	input_username = form.getvalue("username", "")
	input_password = form.getvalue("password", "")

	try:
		conn = MySQLdb.connect (
		host = "my_host",
		user = "my_user",
		passwd = "my_password",
		db = "my_db")
		
		#create a cursor for the select
		cur = conn.cursor()

		#execute a sql query
		cur.execute("SELECT username, password FROM User")
		results = cur.fetchall()
	
		signed_in = False
		
		for row in results:
			name = str(row[0])
			password = str(row[1])
			if name == input_username and check_password(password, input_password):
				print """<h1>Signed in as %s</h1>""" % name
				print """<p>"If you want to build a ship, don't drum up the people to gather wood, and don't assign them tasks and work. Instead, teach them to yearn for the vast and endless sea." - Antoine de Saint-Exupery</p>"""
				signed_in = True
				break
			
		if signed_in == False:
			print """<h1>invalid username and/or password</h1>"""
		
	except MySQLdb.Error, e:
		print """<h1>Error %d: %s</h1>""" % (e.args[0], e.args[1])
	finally:
		if cur:
			# close the cursor
			cur.close()
		if conn:
			# close the connection
			conn.close()
	print """</body></html>"""
