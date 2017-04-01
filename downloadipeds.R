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
        if (file.exists(dest) & !overwrite) {
            message(paste0('Already have: ', dest))
            return(0)
        } else {
            download.file(paste0(url, file, suffix), dest)
            return(1)
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
url <- 'https://nces.ed.gov/ipeds/datacenter/data/'

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

## loop through files
for(i in 1:length(ipeds)) {

    ow <- overwrite
    f <- ipeds[i]
    mess(paste0('Now downloading: ', f))

    ## data
    d1 <- get_file(primary_data, './data/', url, f, '.zip', ow)

    ## dictionary
    d2 <- get_file(dictionary, './dictionary/', url, f, '_Dict.zip', ow)

    ## Stata data and program (optional)
    d3 <- get_file(stata_data, './stata_data/', url, f, '_Data_Stata.zip', ow)
    d4 <- get_file(stata_data, './stata_prog/', url, f, '_Stata.zip', ow)

    ## SPSS program (optional)
    d5 <- get_file(prog_spss, './spss_prog/', url, f, '_SPS.zip', ow)

    ## SAS program (optional)
    d6 <- get_file(prog_sas, './sas_prog/', url, f, '_SAS.zip', ow)

    ## get number of download requests
    dls <- sum(d1, d2, d3, d4, d5, d6)

    if (dls > 0) {
        ## set pause based on number of download requests
        pause <- max(dls, 3)
        ## pause and countdown
        countdown(pause, 'Give IPEDS a little break ...')
    } else {
        message('No downloads necessary; moving to next file')
    }
}

mess('Finished!')

## =============================================================================
## END
################################################################################
