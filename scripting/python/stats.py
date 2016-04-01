#############################
# name: stats.py
# purpose: analyize dataframe for various statistical measure
# input: na
# output: na
# author: rayz
#
#############################
import pandas as pd
import logging
import os

#############################
# Global Variables
##
baseDir = r'\projects\python\cobra'
##
resultsFile = 'resultsFile.csv'
##
inputData = 'relations_country_corrected.csv'
#############################


#############################
# name: initialize_dirs(baseDir)
# input: str baseDir
# output: na
# purpose: a generic routine to handle setting all the dirs up
#############################
def initialize_dirs(baseDir):
    workingDir = os.path.join(baseDir,'stats')
    dataDir = os.path.join(workingDir,'data')
    # main data file for input
    inputDataFile = os.path.join(workingDir,inputData)
    # primary output file
    resultsDir = os.path.join(workingDir,'results')
    outputDataFile = os.path.join(resultsDir,resultsFile)
    # logging dir
    logDir = os.path.join(workingDir,'log')
    return workingDir,dataDir,resultsDir,logDir,inputDataFile,outputDataFile
    



#############################
# name: initialize_logger(outputDir)
# input: outputDir str
# output: na
# purpose: a generic routine handle logging streams
#############################
def initialize_logger(logDir):
    print logDir
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)
     
    # create console handler and set level to info
    handler = logging.StreamHandler()
    handler.setLevel(logging.INFO)
    formatter = logging.Formatter("%(levelname)s - %(message)s")
    logger.addHandler(handler)
 
    # create error file handler and set level to error
    handler = logging.FileHandler(os.path.join(logDir, "error.log"),"w", encoding=None, delay="true")
    handler.setLevel(logging.ERROR)
    formatter = logging.Formatter("%(levelname)s - %(message)s")
    handler.setFormatter(formatter)
    logger.addHandler(handler)
 
    # create debug file handler and set level to debug
    handler = logging.FileHandler(os.path.join(logDir, "all.log"),"w")
    handler.setLevel(logging.DEBUG)
    formatter = logging.Formatter("%(levelname)s - %(message)s")
    handler.setFormatter(formatter)
    logger.addHandler(handler)



#############################

#############################
# name: read_csv_to_dataframe
# input: str filename	
# output: df dataframe 
# purpose: read a csv into dataframe
#############################
def read_csv_to_dataframe(filename):
    try:
        df = pd.read_csv(filename)
    except OSError as e:
       logging.error("Wrong filename or path")
       logger.info(filename + " File name or path is invalid - edit the values in global variables section")
       raise
    return df

#############################
# name: drop_duplicate_names(df)
# input: dataframe df 	
# output:  na
# purpose: perform gender stats analysis on data
#############################
def drop_duplicate_names(df):
    origRows = len(df)
    uniqueNamesDf = df.drop_duplicates(['surname','forename'])
    uniqueRows = len (uniqueNamesDf)
    diffRows = origRows - uniqueRows
    logging.info ('rows dropped as duplicates: ' + str(diffRows) )
    return uniqueNamesDf

#############################
# name: frame_sort(df, cols)
# input: dataframe df , list columns	
# output:  sorted frame
# purpose: sort by columns 
#############################
def frame_sort(df, cols):
    logging.debug('entered frame_sort routine')
    return df.sort_values(by=cols)


#############################
# name: gender_count(df)
# input: dataframe df 
# output: series count 
# purpose:  count male and female
#############################
def gender_count(df):
    counts = df.value_counts(dropna=False)
    logging.info ( 'distinct letter writers -  gender counts: ' )
    logging.info(counts)
    return counts

#############################
# name: country_count(df)
# input: dataframe df 
# output: series count 
# purpose:  count male and female
#############################
def country_count(df):
    counts = df['country'].value_counts(dropna=False)
    logging.info ('distinct letter writers -  country counts: ' )
    logging.info(counts)
    return (counts)


#############################
# name: country_count(df)
# input: dataframe df 
# output: series count 
# purpose:  count male and female
#############################
def states_count(df):
    for country in ('US','CA','AU'):
        counts = df.loc[df.country == country]['state'].value_counts(dropna=False)
        logging.info ('distinct letter writers -  state counts: '  + country)
        logging.info(counts)

#############################
# name: prolific_count(df)
# input: dataframe df 
# output: dataframe  
# purpose:  count top 20 letter writers
#############################
def prolific_count(df):
    lettersDf = df.groupby(['surname','forename']).size().reset_index(name='letters')
    newLettersDf = lettersDf.sort_values(by='letters', ascending  = False)[:20]
    # get rid of the re-ordered old indices
    newLettersDf.reset_index(inplace=True, drop=True) 
    # want indexes to begin with 1 as this is an ouput list
    newLettersDf.index += 1 
    logging.info ('most prolific writers: '  )
    logging.info(newLettersDf)

#############################
def main():
    # initialize dirs
    workingDir,dataDir,resultsDir,logDir,dataFile,resultsFile = initialize_dirs(baseDir)
    # initialize logger
    initialize_logger (logDir)
    print logDir

    # read in cobra data
    cobraDf = read_csv_to_dataframe(dataFile)
    logging.info( 'total input rows =: ' + str(len(cobraDf)))
    cobraUniqueNamesDf = drop_duplicate_names(cobraDf)
    cobraUniqueNamesDf.to_csv('relations_unique_names.csv',index=False,na_rep='NULL')
    logging.info('unique names rows = ' + str(len(cobraUniqueNamesDf)))
    cobraUniqueNamesSortedDf = frame_sort(cobraUniqueNamesDf,['surname','forename'])
    cobraUniqueNamesSortedDf.to_csv('relations_unique_names_sorted.csv',index=False,na_rep='NULL') 
    # get the unique names gender breakdown
    countSer = gender_count(cobraUniqueNamesSortedDf['m_f'])
    # get the breakdown by country
    country_count(cobraUniqueNamesSortedDf)
    # get the breakdown by state and counrty
    states_count(cobraUniqueNamesSortedDf)
    # get the prolific writers count
    prolific_count(cobraDf)


if  __name__ == '__main__':
   main()





