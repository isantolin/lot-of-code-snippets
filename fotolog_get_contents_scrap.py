from requests import get, exceptions
from bs4 import BeautifulSoup
import dateutil.parser as parser
import os
from urllib.parse import urlparse
from magic import from_buffer
import pandas as pd
import sqlalchemy

headers = {'User-Agent': 'Mozilla/5.0'}
accounts = ['_']


DB_HOST = "localhost"
DB_USER = "_"
DB_PASS = "_"
DB_DB = "Fotolog"

engine = sqlalchemy.create_engine("mysql+mysqldb://" + DB_USER + ":" + DB_PASS + "@" + DB_HOST + '/' + DB_DB)

hdr_posts = ['idPost', 'UserPost', 'PostText', 'PhotoPath', 'PhotoOriginalURL', 'PhotoOriginalURLStatus', 'Date']
hdr_comments = ['idComment', 'idPost', 'commentAccount', 'commentContent']

df_posts = pd.DataFrame(columns=hdr_posts)
df_comments = pd.DataFrame(columns=hdr_comments)

for account in accounts:
    directory = 'media-' + account
    r = get('https://fotolog.com/' + account, headers=headers)
    source = BeautifulSoup(r.text, "lxml")
    year_data = source.find_all("a", {'class': "stream__item__link"})

    for year_item in year_data:
        if year_item.text != '':
            url_year = 'https://fotolog.com/' + account + '/archive/' + year_item.text
            r_year = get(url_year, headers=headers)
            source_year = BeautifulSoup(r_year.text, "lxml")
            item_data = source_year.find_all("a", {'class': "stream__item__link stream__item__link--thumb"})

            for item_item in item_data:
                url_item = 'https://fotolog.com' + item_item['href']
                id_item = item_item['href'].split('/')[2]

                r_item = get(url_item, headers=headers)
                source_item = BeautifulSoup(r_item.text, "lxml")
                item_image_data = source_item.find("img", {'class': "stream__item__link__image JS_post_img"})
                item_text_data = source_item.find('span', {'class': "meta__item__text JS_comment_item"})

                item_date_data = source_item.find("h1", {'class': "header__title"})
                item_comment_content_data = source_item.find_all("li", {'class': "meta__item JS_comments"})
                item_date_date = parser.parse(item_date_data.text, fuzzy=True)

                if item_text_data is not None:
                    item_text_data = item_text_data.text

                if not os.path.exists(directory):
                    os.makedirs(directory)

                try:
                    r_image = get(item_image_data['src'], allow_redirects=True)

                    if r_image.status_code != 404:
                        filename, file_extension = os.path.splitext(urlparse(item_image_data['src']).path.split('/')[2])

                        if (file_extension == ''):
                            mime = from_buffer(r_image.iter_content(256).__next__(), mime=True)

                            if mime == 'image/jpeg':
                                file_extension = '.jpg'
                            else:
                                print('Mime no adicionado. Agregar')
                                quit()

                        open(directory + '/' + filename + file_extension, 'wb').write(r_image.content)
                        filename = filename + file_extension
                    else:
                        filename = ''

                    print(id_item)
                    df_posts.loc[len(df_posts)] = [id_item, account, item_text_data.encode('cp1252'), filename, item_image_data['src'], r_image.status_code, item_date_date]

                except exceptions.SSLError as e:
                    print(e)
                    pass

                comment_user_text = BeautifulSoup(str(item_comment_content_data), "lxml")

                for comment_user_text_item in comment_user_text:
                    item_comment_author_data = comment_user_text_item.find_all("a", {'class': "meta__item__link meta__item__link--author"})
                    item_comment_comment_data = comment_user_text_item.find_all("span", {'class': "meta__item__text JS_comment_item"})

                    for icad, iccd in zip(item_comment_author_data, item_comment_comment_data):
                        print(iccd['data-commentid'])
                        df_comments.loc[len(df_comments)] = [iccd['data-commentid'], id_item, icad.text, iccd.text]

df_posts.set_index('idPost', inplace=True)
df_comments.set_index('idComment', inplace=True)

df_posts.to_sql('accountPosts', con=engine, if_exists='append')
df_comments.to_sql('postComments', con=engine, if_exists='append')
