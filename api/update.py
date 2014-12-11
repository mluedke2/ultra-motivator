#!/usr/bin/python
print "Content-type:text/html\n\n"
import MySQLdb
import hashlib
import cgi
import sys
import json
import uuid

def check_password(hashed_password, user_password):
    password, salt = hashed_password.split(':')
    return password == hashlib.sha256(salt.encode() + user_password.encode()).hexdigest()

def hash_password(password):
    salt = uuid.uuid4().hex
    return hashlib.sha256(salt.encode() + password.encode()).hexdigest() + ':' + salt

# grab data from POSTed JSON
data = sys.stdin.read()
myjson = json.loads(data)
input_username = myjson['username']
input_current_password = myjson['current_password']
input_new_password = myjson['new_password']

try:
	conn = MySQLdb.connect (
	host = "my_host",
	user = "my_user",
	passwd = "my_password",
	db = "my_db")

	#create a cursor for the select
	cur = conn.cursor()

	cur.execute("SELECT username, password FROM User")
	results = cur.fetchall()

	signed_in = False;

	##Iterate 
	for row in results :
		name = str(row[0])
		password = str(row[1])
		if name == input_username and check_password(password, input_current_password):
			command = "UPDATE User SET password = %s WHERE username = %s"
			cur.execute(command, (hash_password(input_new_password), input_username))
			print json.dumps({'username':input_username, 'password':input_new_password})
			signed_in = True;
			break
			
	if signed_in == False:
		print json.dumps({'error':'invalid username and/or password'})

except MySQLdb.Error, e:
	print json.dumps({'error':"Error %d: %s" % (e.args[0], e.args[1])})
	sys.exit (1)
		
finally:
	if cur:
		# close the cursor
		cur.close()
	if conn:
		# close the connection
		conn.close()
