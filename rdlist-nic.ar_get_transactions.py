import requests
from bs4 import BeautifulSoup
import pandas as pd
import sqlalchemy
import urllib
import re
import http


request = requests.get('https://rdlist.nic.ar/rd_list/')
soup = BeautifulSoup(request.text, 'html.parser')
mydivs = soup.findAll("a", {"href": re.compile(r'csv')})
last_file = int(re.sub("[^0-9]", "", mydivs[0]['href']))

lst = []
i = 201
DB_HOST = "localhost"
DB_USER = "_"
DB_PASS = "_"
DB_DB = "NicAr"

while True:
    try:
        df_temp = pd.read_csv("https://rdlist.nic.ar/rd_list/download/" + str(i) + "/csv/", encoding='ISO-8859-1', header=0, delimiter=',', error_bad_lines=False, decimal=",", na_values='')
        lst.append(df_temp)
        del df_temp
    except (urllib.error.HTTPError, urllib.error.URLError, ConnectionResetError, http.client.IncompleteRead) as err:
        print(err)
        if last_file < i:
            break
        else:
            pass
    print(i)
    i = i + 1

df = pd.concat(lst, ignore_index=True)
del lst
df = df[~df.index.duplicated(keep='first')]
df["fecha_registro"] = pd.to_datetime(df["fecha_registro"], infer_datetime_format=True)

engine = sqlalchemy.create_engine("postgresql://" + DB_USER + ":" + DB_PASS + "@" + DB_HOST + '/' + DB_DB)

dtype = {'tipo': sqlalchemy.types.CHAR(),
         'dominio': sqlalchemy.types.VARCHAR(length=170),
         'zona': sqlalchemy.types.VARCHAR(length=170),
         'id_dominio': sqlalchemy.types.INT(),
         'titular': sqlalchemy.types.VARCHAR(length=170),
         'tipo_doc': sqlalchemy.types.VARCHAR(length=8),
         'fecha_registro': sqlalchemy.types.TIMESTAMP(timezone=False)
         }

df.to_sql('NicArActividad', con=engine, if_exists='replace', dtype=dtype)
