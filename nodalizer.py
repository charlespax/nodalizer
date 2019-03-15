#!/usr/bin/env python3

import urllib.request
import shutil

my_url = 'http://cdimage.ubuntu.com/daily-live/current/disco-desktop-amd64.iso.zsync'
my_file_name = 'disco-desktop-amd64.iso.zsync'

def downloadFile(url, file_name):
    with urllib.request.urlopen(url) as response, open(file_name, 'wb') as out_file:
        shutil.copyfileobj(response, out_file)

def main():
    print("Main code goes here.")
    downloadFile(my_url, my_file_name)

if __name__ == "__main__":
    main()
