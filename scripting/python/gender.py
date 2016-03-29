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
import re

##############
# global vars
#
## set the path here for the SSA name tables
path = '.\\data\\'
## this is the cobra data file that the gender results get set in
genderAnalysisFile =  'relations_gendered.csv'
## list of titles that designate a male gender
mtitles = ('jr.', 'jr', 'sr.', 'sr', 'mr','mr.', 'sir', 'iii', 'ii', 'ii.', 'iii.')
## list of titles that designate a female gender
ftitles = ('mrs', 'ms', 'miss','mrs.','ms.','miss.')
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


def gender_analysis(cobraDf, namesDf):

    # want to interate over cobra and change it as we go, requiring a copy
    cobraCopyDf = cobraDf

    # create a regex for name searches
    # want strings of the form 'R. Ray'
    initialMiddleTest = re.compile(r'\w\. +\w\w')
    initialTest = re.compile(r'^\w\.\w\.$')
    singleInitialTest = re.compile(r'(^\w\.$)')
    
    
    for index, row in cobraDf.iterrows():
        name = row['forename']
        
        if pd.isnull(name):
            continue
        print 'name is: ' + name
        # single initial
        if (not (singleInitialTest.search(name) == None)):
            pass
        
        # two initials A.B.
        elif (not (initialTest.search(name) == None)):
            pass
        
        # space in name
        elif ( (' ' in name )== True):
            names = name.split()
            # ex. Mary Ann
            if (not len(names[0])< 2) and (not names[0][1] == '.'):
                name = names[0]
            # ex R. Rau
            elif ('.' in names[0]) == True:
                if not (initialMiddleTest.search(name)) == None:
                    name = names[1]
                
        # locate the sex of the name in the name table
        sex = namesDf.loc[namesDf.name == name]['sex']
        # not sure why, it returns a series, need a string
        gend = sex.to_string()
        
        # split out the index from the gender
        gender = gend.split()

               

        # assign gender        
        if gender[1] in ('M','F'):
            print "gender is: " + gender[1]
            cobraCopyDf.loc[index ,'m_f'] =  gender[1]
        # may need to use the title to determine gender
        elif pd.notnull(cobraCopyDf.loc[index ,'person_title']):
            title = cobraCopyDf.loc[index ,'person_title']
            keep = title 
            if title.lower() in mtitles:
                cobraCopyDf.loc[index ,'m_f'] =  'M'
                print "gender is: " + 'M'
            elif title.lower() in ftitles: 
               cobraCopyDf.loc[index ,'m_f'] =  'F'
               print "gender is: " + 'F'
    return cobraCopyDf



##############
# name: main()
#
##############
def main():
    # Operation 1
    # only need to rename once, so this should normally be commented out
    # assume your files are in the path dir
    #rename_extension('.txt','.csv')

    #  Operation 2
    # create name files/tables based on SSA tables
    # if commented out it probably means the files exist in the dir and are not needed
    # otherwise uncomment the first and second operations commands
    #create_name_tables()
     
    # read cobra data into frame
    cobraDf = pd.read_csv('relations.csv')
    # read names into a dataframe
    namesDf = pd.read_csv('names_preponderance_with_counts.csv')

    # perform and save the name to gender analysis
    cobraGenderResultsDf = gender_analysis(cobraDf, namesDf)
    cobraGenderResultsDf.to_csv(genderAnalysisFile,na_rep='NULL')

if __name__ == "__main__":
    main()
