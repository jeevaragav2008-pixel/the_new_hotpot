import sqlite3
import sys
sys.path.append("backend")
from auth import verify_password

conn = sqlite3.connect("backend/hotpot.db")
c = conn.cursor()
h = c.execute("SELECT password_hash FROM admin_users WHERE username='jeeva1003'").fetchone()[0]
print("Testing 'hp8002':", verify_password("hp8002", h))
print("Stored hash:", h)
