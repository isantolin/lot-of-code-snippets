import requests
from gevent import monkey

monkey.patch_all(thread=False, select=False)
from bs4 import BeautifulSoup
import pandas as pd
import sqlalchemy
import re
import requests
import grequests
import io

request = requests.get('https://rdlist.nic.ar/rd_list/')
soup = BeautifulSoup(request.text, 'html.parser')
mydivs = soup.findAll("a", {"href": re.compile(r'csv')})
last_file = int(re.sub("[^0-9]", "", mydivs[0]['href']))

lst = []
init = 201
DB_HOST = "localhost"
DB_USER = "root"
DB_PASS = "_"
DB_DB = "NicAr"
urls = []

for i in range(201, last_file):
    urls.append("https://rdlist.nic.ar/rd_list/download/" + str(i) + "/csv/")

requests = (grequests.get(u) for u in urls)
responses = grequests.map(requests, size=4)

for response in responses:
    if response is not None:
        if 199 < response.status_code < 400:
            print(response.headers['Content-Type'])
            df_temp = pd.read_csv(io.BytesIO(response.content),
                                  engine='python',
                                  encoding='utf-8',
                                  header=0,
                                  delimiter=',',
                                  error_bad_lines=False,
                                  decimal=",",
                                  na_values='')
            lst.append(df_temp)
            del df_temp
    else:
        print("Empty Response")

df = pd.concat(lst, ignore_index=True)
del lst
df = df[~df.index.duplicated(keep='first')]
df["fecha_registro"] = pd.to_datetime(df["fecha_registro"], format='%Y-%m-%d %H:%M:%S.%f')

engine = sqlalchemy.create_engine("mysql://" + DB_USER + ":" + DB_PASS + "@" + DB_HOST + '/' + DB_DB)

dtype = {'tipo': sqlalchemy.types.CHAR(),
         'dominio': sqlalchemy.types.VARCHAR(length=170),
         'zona': sqlalchemy.types.VARCHAR(length=170),
         'id_dominio': sqlalchemy.types.INT(),
         'titular': sqlalchemy.types.VARCHAR(length=170),
         'tipo_doc': sqlalchemy.types.VARCHAR(length=8),
         'fecha_registro': sqlalchemy.types.DATETIME(timezone=False)
         }

df.to_sql('NicArActividad', con=engine, if_exists='replace', dtype=dtype)
