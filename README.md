# Locator

## Description

This script is used for server collecting and identification. You can use this script to locate your server, located in which building and even in which rack.

A wireless scanner is strongly recommend for this project.

## Dependency

You need two sheets:

- A: Sheet have SN number and **IPMI address**.
- B: Sheet have **IPMI address** and server position information.

## Usage

You need to edit your source file including server IPMI IP and position in folder "`total`" and make sure you have  CSV file including SN and IPMI IP in folder "`CSV`".

You can run this script after you set everything good.

> ./locator.sh

You can quit by typeing `q` to save and quit or typeing `q!` to save without saving.

You can see what you logged in a day by:

> ./locator.sh showlog

You can entering debug mode by:

> ./locator.sh debug [SN number]

`SN number is optional.`

You can clear logs by:

> ./locator.sh cleanlog

## Error Code

`404`: No IPMI address matched.

`400`: No Position matched.

`500`: Conflict content.

`501`: No Content.

`503`: Multiple Position matched.

## Banner Editing

You can edit banner by modifing the file `banner.txt`.

## Author
Lingxi - i@lingxi.de

## License
BY-NC-SA

## Change Log
**2017/08/25**   The very first upload, but verified by 1.5k servers proving everything runs good.

**2017/08/26**   Rebuild with awk part so that you can define column in sheets.

**2017/08/28**   Fixed Building display error.
