from facebook import GraphAPI
import time
from datetime import datetime, timedelta
import pandas as pd

accessToken = '_'
user = '_'
days = 10

graph = GraphAPI(accessToken)
profile = graph.get_object(user)
until = datetime.today()
since = datetime.today() - timedelta(days=1)

header = [u'permalink_url', u'message', u'likes_total_count', u'wow_total_count', u'loves_total_count', u'comments_total_count', u'created_time']
dfPosts = pd.DataFrame(columns=header)

for days in range(1,days):
    content = graph.get_connections(profile['id'], 'posts', fields='created_time,permalink_url,comments.limit(1).summary(true),reactions.type(LIKE).limit(0).summary(1).as(like),reactions.type(WOW).limit(0).summary(1).as(wow),reactions.type(LOVE).limit(0).summary(1).as(love),message', until=until, since=since, limit=100)
    
    for item in content['data']:
        if 'message' in item.keys():
            dfPosts.loc[len(dfPosts)] = [item['permalink_url'], item['message'], item['like']['summary']['total_count'], item['wow']['summary']['total_count'], item['love']['summary']['total_count'], item['comments']['summary']['total_count'], item['created_time']]
    
    time.sleep(25)

    until = until - timedelta(days=1)
    since = since - timedelta(days=1)

print(dfPosts)
