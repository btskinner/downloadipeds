################################################################################
##
## <PROJ> Batch download IPEDS files
## <FILE> downloadipeds.py
## <AUTH> Jon Lane (@admiralorbiter)
## <INIT> 15 July 2024
##
################################################################################

## PURPOSE ---------------------------------------------------------------------
##
## Use this script to batch download IPEDS files. Only those files listed
## in `ipeds_file_list.txt` will be downloaded. The default behavior is to
## download each of the following files into their own subdirectories:
##
## (1) Data file
## (2) Dictionary file
##
## You can also choose to download other data versions and/or program files:
##
## (1) Data file (STATA version)
## (2) STATA program file (default if you ask for DTA version data)
## (3) SPSS program file
## (4) SAS program file
##
## The default behavior is to download ALL OF IPEDS. If you don't want everything,
## modify `ipeds_file_list.txt` to only include those files that you want.
## Simply erase those you don't want, keeping one file name per row, or
## comment them out using a hash symbol (#).
##
## You also have the option of whether you wish to overwrite existing files.
## If you do, change the -overwrite- option to TRUE. The default behavior is
## to only download files listed in `ipeds_file_list.txt` that have not already
## been downloaded.
## -----------------------------------------------------------------------------

import os
import time
import requests

# CHOOSE WHAT YOU WANT (TRUE == Yes, FALSE == No)
primary_data = True
dictionary = True
stata_data = False
prog_spss = False
prog_sas = False
overwrite = False

# CHOOSE OUTPUT DIRECTORY (DEFAULT == '.', which is current directory)
out_dir = '.'

# FUNCTIONS
def mess(to_screen):
    print('-' * 80)
    print(to_screen)
    print('-' * 80)

def make_dir(opt, dir_name):
    if opt and os.path.exists(dir_name):
        print(f'Already have directory: {dir_name}')
    elif opt and not os.path.exists(dir_name):
        print(f'Creating directory: {dir_name}')
        os.makedirs(dir_name)

def get_file(opt, dir_name, url, file, suffix, overwrite):
    if opt:
        dest = os.path.join(dir_name, f"{file}{suffix}")
        if os.path.exists(dest) and not overwrite:
            print(f'Already have file: {dest}')
            return 0
        else:
            try:
                response = requests.get(f"{url}{file}{suffix}")
                response.raise_for_status()  # Raise HTTPError for bad responses
                with open(dest, 'wb') as f:
                    f.write(response.content)
                time.sleep(1)
                return 1
            except requests.exceptions.RequestException as e:
                print(f'Failed to download: {url}{file}{suffix} - {e}')
                return 0

def countdown(pause, text):
    print('\n')
    for i in range(pause, -1, -1):
        print(f'\r{text} {i}', end='', flush=True)
        time.sleep(1)
        if i == 0:
            print('\n')

# RUN
# read in files; remove blank lines & lines starting with #
with open('./ipeds_file_list.txt', 'r') as file:
    ipeds = [line.strip() for line in file if line.strip() and not line.startswith('#')]

# data url
url = 'https://nces.ed.gov/ipeds/datacenter/data/'

# init potential file paths
data_dir = os.path.join(out_dir, 'data')
stata_data_dir = os.path.join(out_dir, 'stata_data')
dictionary_dir = os.path.join(out_dir, 'dictionary')
stata_prog_dir = os.path.join(out_dir, 'stata_prog')
spss_prog_dir = os.path.join(out_dir, 'spss_prog')
sas_prog_dir = os.path.join(out_dir, 'sas_prog')

# create folders if they don't exist
mess('Creating directories for downloaded files')
make_dir(True, out_dir)
make_dir(primary_data, data_dir)
make_dir(stata_data, stata_data_dir)
make_dir(dictionary, dictionary_dir)
make_dir(stata_data, stata_prog_dir)
make_dir(prog_spss, spss_prog_dir)
make_dir(prog_sas, sas_prog_dir)

# get timer (pause == max(# of options, 3))
opts = [primary_data, stata_data, dictionary, prog_spss, prog_sas]

# loop through files
for f in ipeds:
    ow = overwrite
    mess(f'Now downloading: {f}')

    # data
    d1 = get_file(primary_data, data_dir, url, f, '.zip', ow)

    # dictionary
    d2 = get_file(dictionary, dictionary_dir, url, f, '_Dict.zip', ow)

    # Stata data and program (optional)
    d3 = get_file(stata_data, stata_data_dir, url, f, '_Data_Stata.zip', ow)
    d4 = get_file(stata_data, stata_prog_dir, url, f, '_Stata.zip', ow)

    # SPSS program (optional)
    d5 = get_file(prog_spss, spss_prog_dir, url, f, '_SPS.zip', ow)

    # SAS program (optional)
    d6 = get_file(prog_sas, sas_prog_dir, url, f, '_SAS.zip', ow)

    # get number of download requests
    dls = sum([d1 or 0, d2 or 0, d3 or 0, d4 or 0, d5 or 0, d6 or 0])

    if dls > 0:
        # set pause based on number of download requests
        pause = max(dls, 3)
        # pause and countdown
        countdown(pause, 'Give IPEDS a little break ...')
    else:
        print('No downloads necessary; moving to next file')

mess('Finished!')
