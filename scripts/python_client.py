#!/usr/bin/env python
import mysql.connector
import datetime
import time

mydb = mysql.connector.connect(
  host="127.0.0.1",
  port=6033,
  user="client",
  passwd="clientpass",
  database="testdb"
)

mycursor = mydb.cursor()
i = 0
sql = "INSERT INTO data (str) VALUES (%s)"
while True:
    date_object = datetime.date.today()
    val = str(i) + " " + str(date_object)
    mycursor.execute(sql, (val,))  
    mydb.commit()
    print(mycursor.rowcount, "record inserted.")
    time.sleep(1)