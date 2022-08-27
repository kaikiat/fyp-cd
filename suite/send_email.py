from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import smtplib
import re
from dns import resolver
import socket
import os
import smtplib, ssl

SMTP_USERNAME = 'kaikiat@nonscriberabbit.com'
# SMTP_PASSWORD = 'FYmp2MBpx8R4Z3Z@'
SMTP_PASSWORD = 'zrlfubbvwhppaxsd'
SMTP_HOST = 'smtp-relay.gmail.com'

msg = MIMEMultipart()
message = 'Test msg'
password = SMTP_PASSWORD
username = SMTP_USERNAME
smtphost = SMTP_HOST
msg['From'] = username
msg['To'] = 'kaikiat@sentient.io'
msg['Subject'] = 'hello world'
msg.attach(MIMEText(message, 'html'))
server = smtplib.SMTP(smtphost)
server.starttls()
server.login(username, password)
server.sendmail(msg['From'], msg['To'], msg.as_string())
server.quit()

# smtp_server = "smtp.gmail.com"
# port = 587  # For starttls
# sender_email = "kaikiat@nonscriberabbit.com"
# password = "jW=Uj298dsa"

# # Create a secure SSL context
# context = ssl.create_default_context()

# # Try to log in to server and send email
# try:
#     server = smtplib.SMTP(smtp_server,port)
#     server.ehlo() # Can be omitted
#     server.starttls(context=context) # Secure the connection
#     server.ehlo() # Can be omitted
#     server.login(sender_email, password)
#     # TODO: Send email here
# except Exception as e:
#     # Print any error messages to stdout
#     print(e)
# finally:
#     server.quit() 