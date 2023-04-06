*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.Desktop
Library           String
Library           RPA.PDF
Library           RPA.Archive

*** Variables ***


*** Keywords ***
    #ToDo Make Keywords
Prepare the csvfile
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}
Fill in order
    [Arguments]    ${row}
    Close the annoying modal
    Get Head    ${row}
    Get Body    ${row}
    Get Legs    ${row}
    Give Address    ${row}
    Preview robot
    Wait Until Keyword Succeeds    5x    1 sec    Submit order
    Store as PDF    ${row}

Get Head
    [Arguments]    ${row}
    Click Element   //*[@id="head"]
    ${index}    Set Variable    ${${row}[Head]+1}
    Click Element    //*[@id="head"]/option[${index}]

Get Body
    [Arguments]    ${row}
    ${index}    Set Variable    ${${row}[Body]}
    Click Element    //*[@id="id-body-${index}"]

Get Legs
    [Arguments]    ${row}
    Click Element    alias:Div3input
    Type Text    ${row}[Legs]
    

Give Address
    [Arguments]    ${row}
    Click Element    //*[@id="address"]
    Type Text    ${row}[Address]

Preview robot
    Click Button    //*[@id="preview"]

Submit order
    Click Button    //*[@id="order"]
    Wait Until Element Is Visible    //*[@id="receipt"]

Store as PDF
    [Arguments]    ${row}
    ${receipt_html}=    Get Element Attribute    //*[@id="receipt"]    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}receipts${/}order${row}[Order number].pdf
    Screenshot    id:robot-preview-image    filename=picture${row}[Order number].png
    ${files}=    Create List    ${OUTPUT_DIR}${/}receipts${/}order${row}[Order number].pdf    picture${row}[Order number].png
    Add Files To Pdf    ${files}    ${OUTPUT_DIR}${/}receipts${/}order${row}[Order number].pdf
    Wait And Click Button    //*[@id="order-another"]

Get orders with pdf
    ${table}=    Read table from CSV    orders.csv    header=${True}
    FOR    ${row}    IN    @{table}
        Fill in order     ${row}
    END

Close the annoying modal
    Click Button When Visible     css:#root > div > div.modal > div > div > div > div > div > button.btn.btn-dark
    
Make zipfile
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    allreceipts.zipfile
    
*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    #ToDo: Implement your keyword here
    Prepare the csvfile
    Open Chrome Browser    https://robotsparebinindustries.com/#/robot-order
    Get orders with PDF
    Make zipfile
        

