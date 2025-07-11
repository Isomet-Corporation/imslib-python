import imslib

conn = imslib.ConnectionList()

systems = conn.scan()
for ims in systems:
    print("Connected iMS:", ims.ConnPort())