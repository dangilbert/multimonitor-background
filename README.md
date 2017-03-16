# Multi monitor background download script

Download multi monitor images and set them to the correct monitors on your mac.

## Usage

    bundle install
    ./random-background.rb

There are optional arguments to customise the backgrounds

> -c NAME,--category=NAME - Choose the category of background you want. Any of the category paths on www.triplemonitorbackgrounds.com will work
> -r,--refresh - Forces the selected category's background list to refresh  
> -d PATH,--directory=PATH - Choose the download directory for the images


If your monitors are not arranged the same as mine you'll have to alter the applescript:

`tell desktop x` should be updated to reflect your monitor configuration. I'll move this to yaml config at some point.

## Enhancements

Things I want to do but haven't finished yet

* Add yaml customisation for the default parameters
* Allow customisation of monitors through config
