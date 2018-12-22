#http://www.afip.gov.ar/genericos/cinscripcion/archivocompleto.asp
import pandas as pd
import sqlalchemy

DB_HOST = "localhost"
DB_USER = "_"
DB_PASS = "_"
DB_DB = "AFIP"

engine = sqlalchemy.create_engine("mysql://" + DB_USER + ":" + DB_PASS + "@" + DB_HOST + '/' + DB_DB)
header = ['CUIT','Denominacion', 'ImpuestoGanancias', 'ImpuestoIVA', 'Monotributo', 'IntegraSociedades', 'Empleador', 'ActividadMonotributo']
df = pd.read_fwf('SELE-SAL-CONSTA.p20out1.20181103.tmp', widths=[11,30,2,2,2,1,1,2] ,encoding='ISO-8859-1', names=header, na_filter=False)

df['CUIT'].astype('int64')
df['Denominacion'].str.strip()
df['ActividadMonotributo'].astype('int64')
df.set_index('CUIT', inplace=True)

df.to_sql('ConstanciasInscripcion', con=engine, if_exists='append')
