import sys
from time import sleep
from twitter import Api, TwitterError
import pandas as pd
import sqlalchemy
from datetime import datetime
from sqlalchemy.dialects import mysql

DB_HOST = "localhost"
DB_USER = "_"
DB_PASS = "_"
DB_DB = "twitter"

TWITTER_CONSUMER_API_KEY = '_'
TWITTER_CONSUMER_API_SECRET_KEY = '_'
TWITTER_ACCESS_TOKEN = '_-_'
TWITTER_ACCESS_TOKEN_SECRET = '_'

TWITTER_DELAY_ON_RATE_LIMIT = 930

engine = sqlalchemy.create_engine("mysql://" + DB_USER + ":" + DB_PASS + "@" + DB_HOST + '/' + DB_DB)

account_activity = ['id','screen_name','list_slug','created_at','last_activity']
df_accounts = pd.DataFrame(columns=account_activity)

api = Api(TWITTER_CONSUMER_API_KEY, TWITTER_CONSUMER_API_SECRET_KEY, TWITTER_ACCESS_TOKEN, TWITTER_ACCESS_TOKEN_SECRET)

try:
    user_data = api.VerifyCredentials()   
except TwitterError as e:
    print(e.message[0]['message'], e.message[0]['code'])
    if e.message[0]['code'] == 88:
        for x in range(0, TWITTER_DELAY_ON_RATE_LIMIT):
            print(x, end='\r')
            sleep(1)
            
        user_data = api.VerifyCredentials()
    
    if e.message[0]['code'] == 32:
        sys.exit() # or return   

user_id = user_data.id

try:
    lists = api.GetLists(user_id)
except TwitterError as e:
    sys.exit('ERROR: Twitter' + str(e))

for list in lists:
    list_items = api.GetListMembers(slug=list.slug,list_id=list.id)
    
    for y in list_items:
                
        if y.status == None:
            last_activity = datetime.strptime(y.created_at,'%a %b %d %H:%M:%S +0000 %Y')
        else:
            last_activity = datetime.strptime(y.status.created_at,'%a %b %d %H:%M:%S +0000 %Y')
        
        created_at = datetime.strptime(y.created_at,'%a %b %d %H:%M:%S +0000 %Y')
        df_accounts.loc[len(df_accounts)] = [y.id, y.screen_name, list.slug, created_at,last_activity]

pd.to_numeric(df_accounts['id'], errors='coerce')
df_accounts.set_index('id', inplace=True)
df_accounts.drop_duplicates(keep=False, inplace=True)
pd.to_datetime(df_accounts['last_activity'], errors='coerce')

dtype={'id': sqlalchemy.dialects.mysql.BIGINT(unsigned=True), 
       'screen_name': sqlalchemy.types.VARCHAR(length=16),
       'list_slug': sqlalchemy.types.VARCHAR(length=25),
       'created_at': sqlalchemy.types.DATE(),
       'last_activity': sqlalchemy.types.DATE(),
}

df_accounts.to_sql('accounts', con=engine, if_exists='append', dtype=dtype)
