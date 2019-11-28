# https://www.agip.gob.ar/agentes/agentes-de-recaudacion/ib-agentes-recaudacion/padrones/padron-de-regimenes-generales-
from gevent import monkey
monkey.patch_all(thread=False, select=False)

import pandas as pd
import sqlalchemy
from bs4 import BeautifulSoup
import rarfile
from urllib.parse import urlparse
import os
import glob
import requests
import grequests
import numpy as np

DB_HOST = "localhost"
DB_USER = "_"
DB_PASS = "_"
DB_DB = "AFIP"
STORAGE_PATH = 'getFiles/'

request = requests.get('https://www.agip.gob.ar/agentes/agentes-de-recaudacion/ib-agentes-recaudacion/padrones/padron-de-regimenes-generales-')
content = BeautifulSoup(request.text, "html.parser")
links = content.findAll("a", href=True)

urls = []
for link in links:
    if '/filemanager/source/' in link['href']:
        if urlparse(link['href']).netloc == '':
            urls.append('https://www.agip.gob.ar' + link['href'])
        else:
            urls.append(link['href'])

print(urls)
requests = (grequests.get(u) for u in urls)
responses = grequests.map(requests)

for response in responses:
    if 199 < response.status_code < 400:
        mimetype = response.headers['Content-Type']

        if mimetype == 'application/x-rar-compressed':
            extension = '.rar'
        else:
            quit('Extension no reconocida')

        filename = response.headers['ETag'].replace('"', "") + extension
        open(STORAGE_PATH + filename, 'wb').write(response.content)

extension = '.rar'
os.chdir(STORAGE_PATH)
print("*" + extension)
for file in glob.glob("*" + extension):
    rf = rarfile.RarFile(file)
    rf.extractall('.')
    if os.path.isfile(STORAGE_PATH + file):
        os.remove(STORAGE_PATH + file)
    os.remove(file)

header = ['FechaDePublicacion', 'FechaVigenciaDesde', 'FechaVigenciaHasta', 'CUIT', 'TipoConstanciaInscripcion', 'MarcaAltaSujeto', 'MarcaAlicuota', 'AlicuotaPercepcion', 'AlicuotaRetencion', 'NroGrupoPercepcion', 'NroGrupoRetencion', 'RazonSocial']
dtypes = {'CUIT': 'int16', 'AlicuotaPercepcion': 'float16', 'AlicuotaRetencion': 'float16', 'NroGrupoPercepcion': 'int16', 'NroGrupoRetencion': 'int16'}
frame = pd.DataFrame()
lst = []

for file in glob.glob("*.txt"):
    df_temp = pd.read_csv(file, encoding='ISO-8859-1', names=header, header=None, delimiter=';', error_bad_lines=False, decimal=",", index_col='CUIT', na_values='')
    lst.append(df_temp)
    os.remove(file)
    del df_temp

df = pd.concat(lst)

# Dataframe Cleaning
del lst
df = df[~df.index.duplicated(keep='first')]

df["FechaDePublicacion"] = pd.to_datetime(df["FechaDePublicacion"], format='%d%m%Y')
df["FechaVigenciaDesde"] = pd.to_datetime(df["FechaVigenciaDesde"], format='%d%m%Y')
df["FechaVigenciaHasta"] = pd.to_datetime(df["FechaVigenciaHasta"], format='%d%m%Y')

df['RazonSocial'] = df['RazonSocial'].str.replace("#", " ")
df['RazonSocial'] = df['RazonSocial'].str.strip()
df = df.replace(r'^\s*$', np.nan, regex=True)
df.dropna(subset=['RazonSocial'], inplace=True)

engine = sqlalchemy.create_engine("postgresql://" + DB_USER + ":" + DB_PASS + "@" + DB_HOST + '/' + DB_DB)

dtype = {'CUIT': sqlalchemy.types.BIGINT(),
         'RazonSocial': sqlalchemy.types.VARCHAR(length=170),
         'FechaDePublicacion': sqlalchemy.types.DATE(),
         'FechaVigenciaDesde': sqlalchemy.types.DATE(),
         'FechaVigenciaHasta': sqlalchemy.types.DATE(),
         'TipoConstanciaInscripcion': sqlalchemy.types.VARCHAR(length=1),
         'MarcaAltaSujeto': sqlalchemy.types.VARCHAR(length=1),
         'MarcaAlicuota': sqlalchemy.types.VARCHAR(length=1),
         'AlicuotaPercepcion': sqlalchemy.types.FLOAT(),
         'AlicuotaRetencion':  sqlalchemy.types.FLOAT(),
         'NroGrupoPercepcion': sqlalchemy.types.INTEGER(),
         'NroGrupoRetencion': sqlalchemy.types.INTEGER(),
         }

df.to_sql('AgipRegistro', con=engine, if_exists='append', dtype=dtype)
