# Purpose

Use this script to batch download [Integrated Postsecondary Education
Data System (IPEDS)](http://nces.ed.gov/ipeds/) files. The downloaded
files are not unzipped or processed in any way. This script simply
saves you the trouble of having to point and click your way through
the data center.

(You can also download database files
[here](https://nces.ed.gov/ipeds/Section/accessdatabase/), but you
need MS Access to open them and they only go back to 2007-2008.)

Only those files listed in `ipeds_file_list.txt` will be
downloaded. The default behavior is to download each of the following
files into their own subdirectories:
 
1. Data file  
2. Dictionary file

You can also choose to download other data versions and/or program files:  
  
1. Data file (STATA version)  
2. STATA program file (default if you ask for STATA version data)  
3. SPSS program file  
4. SAS program file

# IMPORTANT NOTE

The default behavior is to download **ALL OF IPEDS**. If you don't
want everything, modify `ipeds_file_list.txt` to include only those
files that you want. Simply erase those you don't want, keeping one
file name per row or comment them out using a hash symbol (#). Since
the downloading script ignores lines starting with hashes, you can add
notes or better section headers to the file if you want.

I try to keep `ipeds_file_list.txt` updated, but if I've missed a file
or haven't updated in a while, just add the name of the file or files,
one to a line. If you notice missing files, feel free to submit a pull
request with an updated version of `ipeds_file_list.txt`.

You also have the option of whether you wish to overwrite existing
files.  If you do, change the `overwrite` option to `TRUE`. The
default behavior is to only download files listed in
`ipeds_file_list.txt` that have not already been downloaded.

# To Run

For the default options, run the script `downloadipeds.R` as is. It
will create subdirectories as needed to store data and program
files. You may wish to place the folder in its own directory. Just
make sure that `ipeds_file_list.txt` is in the same directory. For
example, let's say you place both files in a directory called `ipeds`:

```
./ipeds
|__ downloadipeds.R
|__ ipeds_file_list.txt
```

If you run it with the default options, two new subdirectories will be
created, one for the `data` files and one for the `dictionary`
files. Using the above example, your directory will look like this
after it is finished:

```
./ipeds
|__ downloadipeds.R
|__ ipeds_file_list.txt
|__ /data
|   |__ HD2015.zip
|   |__ IC2015.zip
|   |__ <...>
|
|__ /dictionary
    |__ HD2015_Dict.zip
    |__ IC2015_Dict.zip
    |__ <...>
```

To download other program scripts or Stata versions of the data,
change the following commands in `downloadipeds.R` from `FALSE` to
`TRUE`:

```
## -----------------------------------------------------------------------------
## CHOOSE WHAT YOU WANT (TRUE == Yes, FALSE == No)
## -----------------------------------------------------------------------------

## default
primary_data = TRUE
dictionary = TRUE

## STATA version
## (NB: downloading Stata version of data will also get Stata program files)
stata_data = FALSE

## other program files
prog_spss = FALSE
prog_sas  = FALSE

## overwrite already downloaded files
overwrite = FALSE
```

To change output directory, modify `out_dir` (default is the current directory):

```
## -----------------------------------------------------------------------------
## CHOOSE OUTPUT DIRECTORY (DEFAULT == '.', which is current directory)
## -----------------------------------------------------------------------------

out_dir = '.'

```

# Data size

As of 2 December 2019, downloading all IPEDS files (setting all
options to `TRUE`) requires approximately 2.22 GB of disk
space. Granted, you probably don't need both regular and Stata
versions of the data files (which are the bulk of the directory
size). Here are the approximate subdirectory file sizes if you
download all data files from all years:

|Subdirectory|Approximate Size|
|:--|:-:|
|`./data`|1.07 GB|
|`./dictionary`|30.4 MB|
|`./sas_prog`|6.1 MB|
|`./spss_prog`|19.5 MB|
|`./stata_data`|1.09 GB|
|`./stata_prog`|6.5 MB|

# Combine

To combine multiple IPEDS data files into a single dataset, you may
find the following script useful: [Combine
IPEDS](https://gist.github.com/btskinner/f42c87507169d0ba773c)
