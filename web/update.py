#!C:\Python27\python.exe -u
#!/usr/bin/env python

import MySQLdb
import hashlib
import cgi
import uuid

def check_password(hashed_password, user_password):
    password, salt = hashed_password.split(':')
    return password == hashlib.sha256(salt.encode() + user_password.encode()).hexdigest()
    
def hash_password(password):
    salt = uuid.uuid4().hex
    return hashlib.sha256(salt.encode() + password.encode()).hexdigest() + ':' + salt
    
def show_update_ui():
	print """
	 <div class="center">
	  <form method="post" action="#">
		<p><input type="text" name="username" placeholder="Username" required autofocus autocomplete="username" /></p>
		<p><input type="password" name="current_password" placeholder="Current Password" required autocomplete="current-password" /></p>
		<p><input type="password" name="new_password" placeholder="New Password" required autocomplete="new-password" /></p>
		<p><input type="password" name="confirm_new_password" placeholder="Confirm New Password" required autocomplete="new-password" /></p>
		<p><input type="submit" value="Update" /></p>
	  </form>
	  </div>
	</body>
	</html>
	"""

print "Content-type: text/html\n"
print """
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Ultra Motivator Update Password</title>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.1/css/bootstrap.min.css">
<link rel="stylesheet" href="style.css" />
</head>
<body>
<h1> Ultra Motivator Update Password </h1>
"""

form = cgi.FieldStorage()

if "username" not in form or "current_password" not in form or "new_password" not in form or "confirm_new_password" not in form:
	show_update_ui()
else:
	
	input_username = form.getvalue("username", "")
	input_current_password = form.getvalue("current_password", "")
	input_new_password = form.getvalue("new_password", "")
	input_confirm_new_password = form.getvalue("confirm_new_password", "")

	if input_new_password != input_confirm_new_password:
		print """<h3>New Password Fields Did Not Match!</h3>"""
		show_update_ui()
	else:
		try:
			conn = MySQLdb.connect (
			host = "my_host",
			user = "my_user",
			passwd = "my_password",
			db = "my_db")
		
			cur = conn.cursor()

			cur.execute("SELECT username, password FROM User")
			results = cur.fetchall()

			signed_in = False;

			for row in results :
				name = str(row[0])
				password = str(row[1])
				if name == input_username and check_password(password, input_current_password):
					command = "UPDATE User SET password = %s WHERE username = %s"
					cur.execute(command, (hash_password(input_new_password), input_username))
					print """<h1>Password Updated For %s</h1>""" % input_username
					signed_in = True;
					break
			
			if signed_in == False:
				print """<h3>invalid username and/or password</h3>"""
		
		except MySQLdb.Error, e:
			print "Error %d: %s" % (e.args[0], e.args[1])
		finally:
			if cur:
				# close the cursor
				cur.close()
			if conn:
				# close the connection
				conn.close()
	print """</body></html>"""
