################################################################################
##
## <PROJ> Batch download IPEDS files
## <FILE> downloadipeds.R
## <AUTH> Benjamin Skinner
## <INIT> 21 July 2015
## <REVN> 01 April 2017
##
################################################################################

## PURPOSE ---------------------------------------------------------------------

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
## The default behavior is download ALL OF IPEDS. If you don't want everything,
## modify `ipeds_file_list.txt` to only include those files that you want.
## Simply erase those you don't want, keeping one file name per row.
##
## You also have the option of whether you wish to overwrite existing files.
## If you do, change the -overwrite- option to TRUE. The default behavior is
## to only download files listed in `ipeds_file_list.txt` that have not already
## be downloaded.
## -----------------------------------------------------------------------------

## clear
rm(list = ls())

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

## =============================================================================
## FUNCTIONS
## =============================================================================

## message
mess <- function(to_screen) {
    message(rep('-',80))
    message(to_screen)
    message(rep('-',80))
}

## create subdirectories
make_dir <- function(opt, dir_name) { if (opt) dir.create(dir_name) }

## download file
get_file <- function(opt, dir_name, url, file, suffix, overwrite) {
    if (opt) {
        dest <- paste0(dir_name, file, suffix)
        if (file.exists(dest) & overwrite) {
            message(paste0('Already have: ', dest))
        } else {
            download.file(paste0(url, file, suffix), dest)
        }
    }
}

## countdown
countdown <- function(pause, text) {
    cat('\n')
    for (i in pause:0) {
        cat('\r', text, i)
        Sys.sleep(1)
        if (i == 0) { cat('\n\n') }
    }
}

## =============================================================================
## RUN
## =============================================================================

## read in files; remove blank lines
ipeds <- readLines('./ipeds_file_list.txt')
ipeds <- ipeds[ipeds != '']

## data url
url <- 'http://nces.ed.gov/ipeds/datacenter/data/'

## create folders if they don't exist
mess('Creating directories for downloaded files')
make_dir(primary_data, './data')
make_dir(stata_data, './stata_data')
make_dir(dictionary, './dictionary')
make_dir(stata_data, './stata_prog')
make_dir(prog_spss, './spss_prog')
make_dir(prog_sas, './sas_prog')

## get timer (pause == max(# of options, 3))
opts <- c(primary_data, stata_data, dictionary, prog_spss, prog_sas)
pause <- max(length(which(opts)), 3)

## loop through files
for(i in 1:length(ipeds)) {

    mess(paste0('Now downloading: ', ipeds[i]))

    ## data
    get_file(primary_data, './data/', url, ipeds[i], '.zip')

    ## dictionary
    get_file(dictionary, './dictionary/', url, ipeds[i], '_Dict.zip')

    ## Stata data and program (optional)
    get_file(stata_data, './stata_data/', url, ipeds[i], '_Data_Stata.zip')
    get_file(stata_data, './stata_prog/', url, ipeds[i], '_Stata.zip')

    ## SPSS program (optional)
    get_file(prog_spss, './spss_prog/', url, ipeds[i], '_SPS.zip')

    ## SAS program (optional)
    get_file(prog_sas, './sas_prog/', url, ipeds[i], '_SAS.zip')

    ## pause and countdown
    countdown(pause, 'Give IPEDS a little break ...')
}

mess('\nFinished!')

## =============================================================================
## END
################################################################################
