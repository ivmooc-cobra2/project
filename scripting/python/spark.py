import pandas as pd
import matplotlib.pyplot as plt
import numpy as np


def main():

    df = pd.read_csv("gender_by_date_sparkline.csv")

    for gender in ['M','F']:
        if gender == 'M':
            df[df['gender'] == gender].groupby('year').size().plot(kind='line',color='b',title='Letter Writers')
        if gender == 'F':
            df[df['gender'] == gender].groupby('year').size().plot(kind='line',color='r',title='Letter Writers')

    plt.show()

if __name__ == "__main__":
   main()
