import json
import requests
import pandas as pd 

id_df = pd.read_csv("input_movie_ids.csv")

#--------------------------------------------------------------------
# creating new columns with corresponding attributes in dataframe
id_df['Title_id'] = ''
id_df['Title'] = ''
id_df['Year'] = ''
id_df['Rated'] = ''
id_df['Runtime'] = ''
id_df['Director'] = ''
id_df['Actors'] = ''
id_df['Plot'] = ''
id_df['Language'] = ''
id_df['Awards'] = ''
id_df['Type'] = ''
id_df['BoxOffice'] = ''
id_df['Production'] = ''
id_df['Website'] = ''
#--------------------------------------------------------------------


request_string = "http://www.omdbapi.com/?apikey="

key = '5b84163b' #need to change the keys after 1000 api calls
add = '&i='

#--------------------------------------------------------------------
# computing column index for each column in dataframe
col_ind_Title_id = id_df.columns.get_loc("Title_id")
col_ind_Title = id_df.columns.get_loc("Title")
col_ind_Year = id_df.columns.get_loc("Year")
col_ind_Rated = id_df.columns.get_loc("Rated")
col_ind_Runtime = id_df.columns.get_loc("Runtime")
col_ind_Director = id_df.columns.get_loc("Director")
col_ind_Actors = id_df.columns.get_loc("Actors")
col_ind_Plot = id_df.columns.get_loc("Plot")
col_ind_Language = id_df.columns.get_loc("Language")
col_ind_Awards = id_df.columns.get_loc("Awards")
col_ind_Type = id_df.columns.get_loc("Type")
col_ind_BoxOffice = id_df.columns.get_loc("BoxOffice")
col_ind_Production = id_df.columns.get_loc("Production")
col_ind_Website = id_df.columns.get_loc("Website")
#--------------------------------------------------------------------


k=0         #loop iterating variable, will be used as row count while assigning in dataframe
j = 2       #loop iterating variable, for progress tracking 

for title_id_i in id_df.tconst:
    
    
    cur_req_str = request_string + key + add + title_id_i       #appending strings to obtain the api requesting url 

    response = requests.get(cur_req_str)
    response_dict = json.loads(response.text)                   #contains response dictionary

    
    if response_dict['Response'] != 'False' and (response_dict['Type'] == 'short' or response_dict['Type'] == 'movie'):
        
        #--------------------------------------------------------------------
        #assiging data from response dictionary to dataframe
        id_df.iat[k, col_ind_Title_id] = title_id_i
        id_df.iat[k, col_ind_Title] = response_dict['Title']
        id_df.iat[k, col_ind_Year] = response_dict['Year']
        id_df.iat[k, col_ind_Rated] = response_dict['Rated']
        id_df.iat[k, col_ind_Runtime] = response_dict['Runtime']
        id_df.iat[k, col_ind_Director] = response_dict['Director']
        id_df.iat[k, col_ind_Actors] = response_dict['Actors']
        id_df.iat[k, col_ind_Plot] = response_dict['Plot']
        id_df.iat[k, col_ind_Language] = response_dict['Language']
        id_df.iat[k, col_ind_Awards] = response_dict['Awards']
        id_df.iat[k, col_ind_Type] = response_dict['Type']
        id_df.iat[k, col_ind_BoxOffice] = response_dict['BoxOffice']
        id_df.iat[k, col_ind_Production] = response_dict['Production']
        id_df.iat[k, col_ind_Website] = response_dict['Website']
        #--------------------------------------------------------------------

        k += 1
        print(j)
    else :
        print('data not available for: ', j)
    
    j +=1
  


id_df.to_csv("output_movie_data.csv", columns = ['Title_id','Title', 'Year', 'Rated', 'Runtime', 'Director', 'Actors','Plot', 'Language', 'Awards', 'Type', 'BoxOffice', 'Production', 'Website'], index = False)
