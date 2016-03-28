############################################################
# name: gender.py
# purpose; explore gender data, assign gender
#
# author: rayz
############################################################


import os
import glob
import pandas as pd
import numpy as np
import sys

##############
# global vars
#
## set the path here for the SSA name tables
path = '.\\data\\'
#############


############
# name glob_files_to_frame():
# purpose: take all of the individual files and put them in a large dataframe
# input: na
# output: dataframe
#
############
def glob_files_to_frame():
    allFiles = glob.glob(os.path.join(path,"*.csv"))


    np_array_list = []
    for file in allFiles:
        df = pd.read_csv(file,index_col=None, header=0)
        np_array_list.append(df.as_matrix())

    comb_np_array = np.vstack(np_array_list)
    bigDf = pd.DataFrame(comb_np_array)
    return (bigDf)

############
# name: rename_extension
# purpose: take a file with extension .xxx and rename to .yyy
# input: str oldext, str newext 
# output: na
# Note: this routine makes changes on the directory provided in 'path'
############
def rename_extension(oldext, newext):
    for filename in os.listdir(path):
        infilename = os.path.join(path,filename)
        # make sure you are working on only files
        if not os.path.isfile(infilename): 
            continue
        oldbase = os.path.splitext(filename)
        newname = infilename.replace(oldext, newext)
        output = os.rename(infilename, newname)

##############
# name: create_name_tables()
#
#
#
# purpose: takes the SSA glob and creates a master names table
##############

def create_name_tables():

    nameDf = glob_files_to_frame()
    # sort the names by column 0 and then 2
    nameDf.sort([0,2] , ascending = [True, False], inplace = True)

    # don't really need the number of occurrences per name, get unique names
    unameDf = nameDf.drop(2, axis = 1)
    # get rid of duplicates
    unameDf = unameDf.drop_duplicates()

    # print out to files, let's keep the duplicates and values frame as well
    cols = ['name','sex']
    unameDf.columns = cols
    unameDf.to_csv("names_unique_male_and_female_from_SSA_1880-2014.csv", index=False) 


    # logic to total up names
    # for any name, it could be male or female (ex: Boy named 'Sue')
    # so how do we decide which is it? Probably by preponderance
    # so need to count up occurrences
    # group by name and sex
    groupedDf = nameDf.groupby([0,1])
    # count up all the yearly occurrences of names 
    groupedSumDf =  groupedDf.aggregate(np.sum)
    groupedSumDf.reset_index(inplace=True)

    # add columns to the dataframe
    cols = ['name','sex','count']
    groupedSumDf.columns = cols

    # sort the names alphabetically and then by count highest to lowest
    # this is essentially sorting names by alpha and then sorting ambigendrous names
    # names that are both popularly male and female
    groupedSumDf.sort(['name', 'count'], ascending = [True,False], inplace = True)
    groupedSumDf.to_csv('names_ambigendrous_with_counts.csv', index=False)

    # now drop the ambigendrous duplicates and just use the version with the most
    # occurrences (e.g. use "Kelly, F" rather than "Kelly, M"
    groupSumNoDupsDf = groupedSumDf.drop_duplicates(cols='name')
    groupSumNoDupsDf.to_csv("names_preponderance_with_counts.csv", index=False)



##############
def main():
    # only need to rename once, assume your files are in the path dir
    #rename_extension('.txt','.csv')

    # create name files/tables based on SSA tables
    # if commented out it means the files exist in the dir and are not needed
    #create_name_tables()

     
    # read cobra data into frame
    cobraDf = pd.read_csv('cobra_data.csv')
    # read names into a dataframe
    namesDf = pd.read_csv('names_preponderance_with_counts.csv')
    # want to interate over cobra and change it as we go, requiring a copy
    cobra2Df = cobraDf

    #list out cobraDf
    cobraDf.to_csv('cobraDf.csv', index=False)
    cobra2Df.to_csv('cobra2Df.csv', index=False)

    for index, row in cobraDf.iterrows():
        name = row['forename']
        if pd.isnull(name):
            continue
        if (len(name) == 1):
            continue
        if ( (' ' in name )== True):
            names = name.split()
            name = names[0]
        if ('.' in name) == True:
            if len(name) == 2:
                continue
        # locate the sex of the name in the name table
        sex = namesDf.loc[namesDf.name == name]['sex']
        # not sure why, it returns a series, need a string
        gend = sex.to_string()
        print 'name is: ' + name
        # split out the index from the gender
        gender = gend.split()
        if gender[1] in ('M','F'):
            print "gender is: " + gender[1]
            cobra2Df.loc[index ,'m_f'] =  gender[1]
    # save the name analysis
    cobra2Df.to_csv('outnames.csv')



if __name__ == "__main__":
    main()
