#!/usr/bin/python
print "Content-type:text/html\n\n"
import MySQLdb
import hashlib
import cgi
import sys
import json
import uuid

def hash_password(password):
    salt = uuid.uuid4().hex
    return hashlib.sha256(salt.encode() + password.encode()).hexdigest() + ':' + salt

# grab data from POSTed JSON
data = sys.stdin.read()
myjson = json.loads(data)
input_username = myjson['username']
input_password = myjson['password']

try:
	conn = MySQLdb.connect (
	host = "my_host",
	user = "my_user",
	passwd = "my_password",
	db = "my_db")
  
	#create a cursor for the select
	cur = conn.cursor()

	#execute a sql query
	command = "INSERT INTO User(username, password) VALUES(%s,%s)"
	cur.execute(command, (input_username, hash_password(input_password)))
	print json.dumps({'username':input_username, 'password':input_password})

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
