# REDDIT SUPPORT POST

[Reddit Link](https://www.reddit.com/r/PowerShell/comments/w1ztao/absolute_powershell_n00b_looking_for_a_way_to)

Here's the situation:

I'm on a mail list that monitors certain products and sends an email when it detects an outage - this email has a specific subject and within the body of the text contains a few key fields, particularly client name and a client ID alphanumeric string. I am CCed on this email, not in the TO: field.

When I receive an email, I'm supposed to reply to a specific person that is not typically included on the email with the above two fields in the reply. I have a draft template I can use; I just need to update it with the above fields.

I'd like to see if I can use PowerShell to automate creating the draft email - when I get an email, I'd like a new email reply to automatically populate with the template and the two above-referenced fields automatically updated. I don't think there's an easy way to automate looking up the specific person I'm supposed to reply to, so I'm fine with that draft just popping up and then all I have to do is update the reply to and hit send.

I'm assuming most of this is do-able, but I really don't know where to start. Advice & guidance would be greatly appreciated - a workable script is nice, but knowledge sharing is even nicer!


## PROPOSED SOLUTION

The problem can be divided in 3:

1) Call the script: __EASY__ ou can add a OUTLOOK Rule to call a script when you receive an email
2) Create the REPLY email: Using the provided script as a guide, you can create the reply email. Check the functio and the template file
3) Send the email: Multiple possibilities. Not in the scope of this post. In the function, I use GOOGLE GMAIL.



I have created 3 files, in FormatEmailReply.ps1, OnReceive.ps1 and Template.txt there's a function that you can modify to your needs, but the basis is there. You call

### FormatEmailReply.ps1

I have created a function that will be called when you create a reply. You pass the following arguments:
- $To                   SEND TO
- $ClientName
- $ClientId             
- $template 			FILE PATH
- $Subject              EMAIL SUBJECT
- $Test                 IF SET, IF WILL ONLY LOG THE DATA TO BE SENT


### OnReceive.ps1

Script to be called when you receive an email

### Template.txt

The template email. You put __CLIENT_ID__ and __CLIENT_NAME__ where you need these fields to be replaced.

## EMAIL SEND VIA POWERSHELL

 In this script I use powershell to send the email, and I use Google gmail to send it. This can be changed to your needs.


