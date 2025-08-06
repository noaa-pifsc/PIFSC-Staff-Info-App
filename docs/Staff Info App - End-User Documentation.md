# Staff Information App End-User Documentation

## Overview
The Staff Information Application (SIA) is a web app that provides access to the PIFSC Oracle personnel database for information that does not contain sensitive information or PII.  There are two web pages; one provides a sortable tabular staff directory listing and the other shows a formatted organization hierarchy chart.    

## Application Access
-   Test: https://picapps-test.nmfs.local/staff-directory/
-   Production: https://picapps.nmfs.local/staff-directory/

## Requirements
-   Any modern web browser
-   PIFSC network connection 

## Implementation
-   ### Shared Elements
    -   There is a navigation menu at the top of both web pages that provides links to the two pages, the link for the current page is grayed out and the corresponding link is not enabled
-   ### Staff Directory
    -   The staff directory displays all current PIFSC personnel in a table with several columns of information.  Each column heading is implemented as a link that provides sorting capabilities with the appropriate icons showing the current sort order for the column (if any) or if there is no sorting applied to the given column it is shown with a general sort icon.  
    -   Email and phone numbers are implemented as links.
-   ### Organization Chart
    -   This web page displays all of the current PIFSC personnel in a hierarchical diagram using HTML and css
    -   The Directors Office is shown at the top of the page 
        -   The Divisions are shown below along with all Subdivisions, Programs and Subprograms nested below the corresponding Divisions.  
    -   Each individual is shown below their corresponding organizational unit with their abbreviated position with indicators based on their employer (e.g. (c) for contractors, (CI) for cooperative institute employees)
    -   Features:
        -   Tooltips are implemented for all personnel.  When a given person's email or phone numbers are stored in the database, links for each are available in the tooltip.  
