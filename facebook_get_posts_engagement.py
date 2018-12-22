from facebook import GraphAPI
import time
from datetime import datetime, timedelta
import sys

access_token = '_|_'
user = 'BillGates'

def main():
    
    data_reorg = []
    untl = datetime.today()
    snc = datetime.today() - timedelta(days=1)
    
    print('Trazendo dados dos últimos 30 días... de: ' + user)
    for days in range(1,30):
        data = data_access(user, access_token, untl, snc)

        if not data['data']:
            time.sleep(1)
        else:
            data_reorg = data_model(data, data_reorg)
            time.sleep(10)

        untl = untl - timedelta(days=1)
        snc = snc - timedelta(days=1)
    
    header = [u'permalink_url', u'message', u'reactions_total_count', u'comments_total_count', u'created_time']
    option_input_to_generate(data_reorg, header)


def data_access(user, access_token, date_until, date_since):
    graph = GraphAPI(access_token)
    profile = graph.get_object(user)

    print('Getting info from: '+ str(date_until) + ' To: ' + str(date_since))
    content = graph.get_connections(profile['id'], 'posts', fields='created_time,permalink_url,comments.limit(1).summary(true),reactions.limit(1).summary(true),message', until=date_until, since=date_since, limit=100)
    return content


def data_model(incoming, data_struct):

    for item in incoming['data']:
        if 'message' in item.keys():
            selected = [item['permalink_url'], item['message'], item['reactions']['summary']['total_count'], item['comments']['summary']['total_count'], item['created_time']]
            data_struct.append(selected)
    return data_struct


def data_output_xlsx(data, header):
    from openpyxl import Workbook
    flnm = 'data.xlsx'
    
    write_wb = Workbook()
    write_worksheet = write_wb.active
    write_worksheet.title = "Data"

    write_worksheet.append(header)
    for row in data:
        write_worksheet.append(row)
        
    write_wb.save(filename = flnm)
    print('Arquivo '+ flnm + ' criado')


def data_output_csv(data, header):
    import csv
    from csv import writer
    flnm = 'data.csv'
    
    with open(flnm, 'w', newline='\n') as csvfile:
        spamwriter = writer(csvfile, delimiter=',',quotechar='"', quoting=csv.QUOTE_MINIMAL)
        spamwriter.writerow(header)
        for row in data:
            spamwriter.writerow(row)
    
    print('Arquivo '+ flnm + ' criado')


def data_output_json(data, header):
    from json import dump
    flnm = 'data.json'
    
    for row in data:
        dictionary = dict(zip(header, row))
    
    with open(flnm, 'w') as fp:
        dump(dictionary, fp)
        
    print('Arquivo '+ flnm + ' criado')


def option_input_to_generate(content, header):
    formats = ['csv', 'xls', 'json']
    number = 0
    for x in formats:
        print(str(number) + ') ' + x)
        number += 1
    
    try:    
        opcion = int(input('Elija la Lista: '))
    except ValueError:
        sys.exit('ERROR: Insira valor numerico')
    
    if opcion == 0:
        data_output_csv(content, header)
    elif opcion == 1:
        data_output_xlsx(content, header)
    elif opcion == 2:
        data_output_json(content, header)
    else:
        sys.exit('Opcion no valida')


if __name__ == "__main__":
    main()
