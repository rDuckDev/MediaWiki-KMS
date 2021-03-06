# MediaWiki KMS

A collection of resources that help to install MediaWiki as a knowledge management system (KMS).

**:warning: This project was deprecated on 06/15/2021! :warning:**

I created the MediaWiki KMS project to help install Parsoid when it ran under NodeJS. At that time, the installation instructions felt incomplete and the dependencies felt difficult to reason about. Now that Parsoid (the PHP version) ships with MediaWiki, the remainder of my scripts are a rehash of the official Ubuntu, MediaWiki, MediaWiki extensions, and Webmin documentation. Therefore, I deprecated this project in favor of the official documentation for each respective project.

## Versions

* [Ubuntu Server 20.04 LTS](https://ubuntu.com/download/server)
* MediaWiki 1.35 LTS

## Installation

### Ubuntu

* [Install Ubuntu Server](https://ubuntu.com/tutorials/install-ubuntu-server)
  * Check the **Install OpenSSH server** option, if desired
  * Leave all **Featured Server Snaps** unchecked (recommended)
* Install updates and patches

  ```bash
  sudo su
  apt-get update && apt-get dist-upgrade -y
  reboot now
  ```

* Install the LAMP stack and required software

  ```bash
  cd /tmp
  sudo su
  wget https://github.com/rDuckDev/MediaWiki-KMS/raw/master/install-host.sh
  bash install-host.sh
  ```

### MediaWiki

* Install MediaWiki on Ubuntu:
  * `wget https://github.com/rDuckDev/MediaWiki-KMS/raw/master/install.sh`
  * `sudo bash install.sh`
* Configure MediaWiki using your browser
  * Download LocalSettings.php and add (or update) the following lines:
    ```php
    ## Database settings
    $wgDBuser = "wiki";
    $wgDBpassword = "<output from README>";
    $wgDBadminuser = "wiki-sysop";
    $wgDBadminpassword = "<output from README>";
    # Configure MultimediaViewer
    $wgDefaultUserOptions['multimediaviewer-enable'] = 1;
    # Configure WikiEditor and CodeEditor
    $wgDefaultUserOptions['usebetatoolbar'] = 1;
    # Configure VisualEditor
    $wgVisualEditorEnableDiffPage = true;
    $wgVisualEditorEnableWikitext = true;
    $wgDefaultUserOptions['visualeditor-enable'] = 1;
    $wgHiddenPrefs[] = 'visualeditor-enable';
    $wgVisualEditorAvailableNamespaces = [
        "User" => true,
        "Help" => true
    ];
    ```
  * Upload LocalSettings.php to /var/www/html/WikiName

## Update

### MediaWiki

* Update MediaWiki-KMS:
  * `wget https://github.com/rDuckDev/MediaWiki-KMS/raw/master/update.sh`
  * `sudo bash update.sh`
* Update LocalSettings.php

## Notes

* [Parsoid](https://www.mediawiki.org/wiki/Parsoid) (PHP version) is included MediaWiki 1.35+.
* When using Webmin, set **MySQL configuration file** to `/etc/mysql/mariadb.cnf` in the **MySQL Database Server** module.

### Software

* Apache
* MariaDB
* PHP
* Ghostscript
* ImageMagick
* Poppler
* Admin (one)
  * [Cockpit](https://cockpit-project.org/)
  * [Webmin](https://webmin.com/)
  * OpenSSH
  * GUI (minimal)
    * Firefox
    * gedit

### Useful links

* [MediaWiki maintenance](https://doc.wikimedia.org/mediawiki-core/master/php/group__Maintenance.html)
* [PHP security tips](https://www.cyberciti.biz/tips/php-security-best-practices-tutorial.html)
* [MySQL performance tips](https://www.percona.com/blog/2014/01/28/10-mysql-performance-tuning-settings-after-installation/)
