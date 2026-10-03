---
title: "Make Request Form Fields Read-Only for Sales Users"
jira_key: "CLM-361"
jira_project: "CLM"
jira_project_name: "IronClad CLM"
jira_issue_type: "Task"
jira_status: "In Progress"
jira_priority: "High"
jira_url: "https://jira.cs.sys/browse/CLM-361"
jira_assignee: "Jitesh Bhatia"
jira_reporter: "Shirae Johnson"
jira_created: "2026-04-29T18:20:38.815+0000"
jira_updated: "2026-09-28T16:08:43.022+0000"
pulled_at: "2026-09-28T16:44:05.049291+00:00"
attachment_count: 0
attachment_failures: 0
---

# CLM-361: Make Request Form Fields Read-Only for Sales Users

**Type**: Task
**Status**: In Progress
**Priority**: High
**Assignee**: Jitesh Bhatia
**Reporter**: Shirae Johnson
**Created**: 2026-04-29T18:20:38.815+0000
**Updated**: 2026-09-28T16:08:43.022+0000
**URL**: https://jira.cs.sys/browse/CLM-361

**Labels**: Legal
**Components**: Salesforce

## Description

# Ticket # of issue - 1328
 # Summary of issue reported - Shirae Johnson requested to escalate this to Tier II - the following legal request was created without an IC workflow and without certain required fields - they need to know how.

They needed to understand why an IC workflow wasn't attached.

Request: *Req-321289*
[https://crowdstrike.lightning.force.com/lightning/r/Questionnaire_Request_Form__c/a1zNs000009FZptIAG/view]

According to Timothe, the sales requestor edited the request type which was originally a Consult with Legal so no Ironclad workflow was created. Additionally, changing the request type don't appear in the feed of the SF request, only updating the status appear here.

Link to slack thread - [https://crowdstrike.slack.com/archives/C0A7MKYMQGK/p1777484077980549]

## All Fields

| Field ID | Display Name | Value |
|----------|--------------|-------|
| `aggregateprogress` | Σ Progress | ['progress', 'total'] |
| `creator` | Creator | hlabiaga |
| `customfield_10003` | Story Points | 2.0 |
| `customfield_10005` | Rank (Obsolete) | "9223372036854775807" |
| `customfield_10300` | Sprint | ['com.atlassian.greenhopper.service.sprint.Sprint@35673087[activatedDate=2026-04-28T18:15:56.366Z,autoStartStop=false,completeDate=2026-05-07T14:47:54.585Z,endDate=2026-05-01T06:00:00.000Z,goal=,id=17940,incompleteIssuesDestinationId=<null>,name=CLM Sprint 10,rapidViewId=9801,sequence=17940,startDate=2026-04-24T06:00:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@3efeb68e[activatedDate=2026-05-07T14:49:56.970Z,autoStartStop=false,completeDate=2026-05-13T14:45:19.459Z,endDate=2026-05-13T16:00:00.000Z,goal=<null>,id=18196,incompleteIssuesDestinationId=<null>,name=CLM Sprint 11,rapidViewId=9801,sequence=18196,startDate=2026-05-08T16:00:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@4ced6d9a[activatedDate=2026-05-13T16:00:06.647Z,autoStartStop=false,completeDate=2026-05-20T15:38:46.441Z,endDate=2026-05-20T19:00:00.000Z,goal=,id=18331,incompleteIssuesDestinationId=<null>,name=CLM Sprint 12,rapidViewId=9801,sequence=18331,startDate=2026-05-13T19:00:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@4b3d8e8[activatedDate=2026-05-20T15:39:19.983Z,autoStartStop=false,completeDate=2026-05-28T16:00:40.762Z,endDate=2026-05-27T19:00:00.000Z,goal=,id=18332,incompleteIssuesDestinationId=<null>,name=CLM Sprint 13,rapidViewId=9801,sequence=18332,startDate=2026-05-20T19:00:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@85c23f1[activatedDate=2026-05-28T16:02:09.050Z,autoStartStop=false,completeDate=2026-06-03T17:43:17.393Z,endDate=2026-06-03T16:00:00.000Z,goal=,id=18488,incompleteIssuesDestinationId=<null>,name=CLM Sprint 14,rapidViewId=9801,sequence=18488,startDate=2026-05-28T16:00:00.000Z,state=CLOSED,synced=false]'] |
| `customfield_11300` | Rank | "2|hypevc:07c3n1x9" |
| `customfield_11700` | Time in Status | "3_*:*_1_*:*_0_*|*_10031_*:*_1_*:*_6124440827" |
| `customfield_11701` | Date of First Response | "2026-04-29T20:25:58.501+0000" |
| `customfield_13400` | Development | "{}" |
| `customfield_14221` | Template | "{}" |
| `customfield_14410` | Notification Count | 0 |
| `customfield_15236` | Deployed to CIDs | "None" |
| `customfield_15238` | PIR | ['PIRS_GO_HERE'] |
| `customfield_15606` | MI | "null" |
| `customfield_15611` | Exploit Type | "null" |
| `customfield_16009` | Report ID | "null" |
| `customfield_16026` | Shown In UI | No |
| `customfield_17605` | Coordinating Architect (CAT) Effort | TBD |
| `customfield_17608` | Product Manager (PM) | None Assigned |
| `customfield_17629` | Crypto Justification | Expiration |
| `customfield_17641` | Last Comment | "[~jbhatia] Liz Kelly would like to lock down the request form fields for the sales team on legal requests. " |
| `customfield_20217` | [CHART] Date of First Response | "2026-04-29T20:25:58.501+0000" |
| `customfield_20218` | [CHART] Time in Status | "3_*:*_1_*:*_0_*|*_10031_*:*_1_*:*_6124440827" |
| `customfield_22455` | Remediation Instance ID | "None" |
| `customfield_22456` | Remediation Instance Name | "None" |
| `customfield_22457` | Remediation Instance Owner | "None" |
| `customfield_22458` | Remediation Instance Updater | "None" |
| `customfield_22459` | Description of remediation instance | "None" |
| `customfield_22460` | Remediated Pattern ID | "None" |
| `customfield_22461` | Remediated Instance ID | "None" |
| `customfield_22462` | Kill Scope | "None" |
| `customfield_22463` | Safe Quarantine | "None" |
| `customfield_22464` | Forced Quarantine | "None" |
| `customfield_22465` | Registry Persistence Removal | "None" |
| `customfield_22467` | Channel File Priority | "None" |
| `customfield_22604` | originId | "3964068" |
| `customfield_22605` | openTasksCount | "0.0" |
| `customfield_22606` | closedTasksCount | "0.0" |
| `customfield_22607` | allTasksCount | "0.0" |
| `customfield_22609` | Stoplight | Green |
| `customfield_22619` | End Products | "replaceme" |
| `customfield_22620` | Value Proposition | "replaceme" |
| `customfield_22625` | Providing Team | "replaceme" |
| `customfield_22626` | Required Capabilities | "replaceme" |
| `customfield_22627` | Required Capacity | "replaceme" |
| `customfield_22631` | Committing Manager | replaceme |
| `customfield_22740` | Sales Connector | None Assigned |
| `customfield_23017` | Vendor Status | Needs Review |
| `customfield_23023` | Integration Status | Sourcing |
| `customfield_23026` | License Status | Needs Review |
| `customfield_23401` | Falcon Apps & Modules | ['No Module(s)'] |
| `customfield_23521` | Partner Agent Required | ['No'] |
| `customfield_23533` | Tech Writer Assigned | None Assigned |
| `customfield_23543` | Feature Flag Details | "Feature Flag Name: 

Component: ex. Microservice/UI/Sensor/VM" |
| `customfield_23601` | Deployment Date | "2026-10-06" |
| `customfield_23707` | Hunt leads suppressed by new rules or updates | 0.0 |
| `customfield_23708` | Hunt leads investigated | 0.0 |
| `customfield_23709` | Detections Triggered | 0.0 |
| `customfield_23710` | Notifications sent via email or slack | 0.0 |
| `customfield_23711` | Detections referred to OW | 0.0 |
| `customfield_23900` | FXE Customer Type | Subscription |
| `customfield_24536` | QA Assignee | None Assigned |
| `customfield_24917` | RCA | Not Needed |
| `customfield_25141` | UX Design Assigned | None Assigned |
| `customfield_30016` | Technical Design Review Status | Not Started |
| `customfield_30017` | Test Plan Review Status | Not Started |
| `customfield_30213` | AI Required? | No |
| `progress` | Progress | ['progress', 'total'] |
| `resolution` | Resolution | Done |
| `votes` | Votes | ['self', 'votes', 'hasVoted'] |
| `watches` | Watchers | ['self', 'watchCount', 'isWatching'] |
| `worklog` | Log Work | ['startAt', 'maxResults', 'total'] |
| `workratio` | Work Ratio | -1 |

## Comments
### Liz Glass - 2026-04-29T20:25:58.501+0000

[~jbhatia] this is the issue where the sales user was able to update the request type on the request form. Let's evaluate which fields are editable for sales and lock down where necessary. 
### Jitesh Bhatia - 2026-07-08T23:56:55.859+0000

This validation rule blocks users from editing the Request if they aren't the CLM Actor - [https://crowdstrike.my.salesforce-setup.com/lightning/setup/ObjectManager/01Id0000000rpC5/ValidationRules/03dNs000000y5KzIAI/view]

In this case though the submitter was the CLM Actor, so they were able to update the Request Type.
### Jitesh Bhatia - 2026-07-09T19:11:11.646+0000

Sales has edit access to the Request Type field via the Sales Profile - https://crowdstrike.my.salesforce-setup.com/lightning/setup/EnhancedProfiles/page?address=%2F00e6T000002JarA%3Fs%3DObjectsAndTabs%26o%3D01Id0000000rpC5
### Jitesh Bhatia - 2026-07-20T19:43:33.083+0000

Hi [~eglass] here are the fields Sales can edit on the Request Form - [https://docs.google.com/spreadsheets/d/13iaRB4cGS_9VKqkyFDc73QKhgdSrftTFMwD28cCbNhk/edit?usp=sharing.]

Generally, they're blocked from editing the Request Form if they're not the CLM Actor. This is the validation rule that blocks them - [https://crowdstrike.my.salesforce-setup.com/lightning/setup/ObjectManager/01Id0000000rpC5/ValidationRules/03dNs000000y5KzIAI/view.]

However, even if they are the CLM Actor, I agree that it makes sense to still block them from editing certain fields on the Request Form. For example, Request Type is probably one they should not change.

Maybe we can see what fields from the above list Liz Kelly wants completely locked down? Then I could create a validation rule to block them from editing these fields if the RecordType = Legal Request. Reason for limiting it to Legal Requests is that Sales might need edit access to these fields on the other types of Requests (ProServ, Security, etc.)
### Jitesh Bhatia - 2026-07-23T15:43:18.647+0000

Jitesh to pull in the editable fields for Sales that are on the Legal Request page then we can see what fields from there to include in the validation rule. [~eglass] to run this by PS Ops to see if they want to block Sales too.
### Jitesh Bhatia - 2026-08-14T17:30:43.198+0000

[~eglass] sorry for the late follow up on this one. I've filtered the sheet down showing the editable fields that are on the Legal Request page - https://docs.google.com/spreadsheets/d/13iaRB4cGS_9VKqkyFDc73QKhgdSrftTFMwD28cCbNhk/edit?gid=0#gid=0
### Liz Glass - 2026-09-10T15:02:49.008+0000

[~jbhatia] Liz Kelly would like to lock down the request form fields for the sales team on legal requests. 
