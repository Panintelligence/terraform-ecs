# Localisation - How to Add / Edit Localisation for the Application

## Generating a language file
Firstly, you need to login to the Dashboard and open the right-hand menu and select 'Generate language file'. This will create a language file containing all of the user entered information that can be translated. The name of the new file will be presented to you and it will be saved to the install directory of the Dashboard.

## Making the file work as a custom locale
Once the file has been generated there are a few steps you must take. First, head to the localisation folder: `*INSTALL_DIR*/tomcat/webapps/panMISDashboardResources/locale`. The messages files contained within this directory are property files containing key / value pairs. Editing the value portion of the property will change the text which is displayed in the application. All files must be UTF-8 encoded.

To add new localisations to the application, create a copy of the 'messagesStatic.properties' file in the locale folder. This file needs to be renamed to include the relevant locale e.g. ‘messagesStatic_pt_PT.properties’. This file can then be edited to change the language for various parts of the Dashboard.

The same can be achieved with the user generated language file by changing the name of the file to reflect the relevant locale e.g. ‘messagesUserEntered_pt_PT.properties’ and moving this file into the locale directory.

You also need to edit 'available-languages.properties' in locale to enable the Dashboard to pick up your new language files - e.g. add Portuguese=pt_PT. This will then create a drop down menu for the language on the login screen of the Dashboard.

Now, any changes made to the 'messages*' language file with the code corresponding to the language you select when logging in will be reflected in the Dashboard. An alternative to selecting your desired language from the drop-down on the login page is to change the URL language query to match the locale e.g. change 'lang=en_GB' to 'lang=pt_PT'. Taking 'en_GB' as an example, the 'en' represents the language whilst the 'GB' represents the country - both parts are important.

> NOTE: Whilst changes to the 'messagesStatic.properties' file are picked up upon refreshing the Dashboard changes to the 'messagesUserEntered*.properties' file will require a restart

## Adding and updating translations

The format for the ‘messagesUserEntered' is that each key/value pair occupies its own line and the key and value are separated by an equals sign ('='). The key is generated from the original value of the translatable text e.g. if the original name of a chart is “Number of Charts“ then “Number of Charts” is encoded and used as the key. This means that even if there are multiple, identical translatable values present on The Dashboard there will only be one key/value pair in the language file and updating the value component of this with your desired text will provide translation for all of those areas.

If you add new content to the Dashboard that contains translatable fields or update the value of an existing translatable field you will need to add new key/value pairs to the ‘messagesUserEntered’ file. The key is encoded in ‘Form URL’ format (application/x-www-form-urlencoded) and is human-readable for English alphabet characters so you might be able to derive it from the new content yourself. Another way of getting the new key/value pair is to:

1. Generate another language file in the same manner as you did above

2. Find the line matching the new/updated content

3. Copy that key/value pair line into the file that holds the rest of your translations

When the file is initially generated, it is sorted alphabetically with no duplicate values present. When manually inserting a new key/value pair we would recommend that you conform to this standard to avoid potential confusion in the future. Removal of the old key/value pair is not required. If you choose to leave it within the file then any future values that match it would be translated with no additional effort when the Dashboard next restarts.
