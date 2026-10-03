---
title: "Partner Agreements - Related ACR - Ironclad Work"
jira_key: "CLM-469"
jira_project: "CLM"
jira_project_name: "IronClad CLM"
jira_issue_type: "Task"
jira_status: "Ready for QA"
jira_priority: "Medium"
jira_url: "https://jira.cs.sys/browse/CLM-469"
jira_assignee: "Vikas Chauhan"
jira_reporter: "Jitesh Bhatia"
jira_created: "2026-08-06T14:59:44.325+0000"
jira_updated: "2026-09-28T16:08:52.231+0000"
pulled_at: "2026-09-28T16:44:10.155903+00:00"
attachment_count: 4
attachment_failures: 0
---

# CLM-469: Partner Agreements - Related ACR - Ironclad Work

**Type**: Task
**Status**: Ready for QA
**Priority**: Medium
**Assignee**: Vikas Chauhan
**Reporter**: Jitesh Bhatia
**Created**: 2026-08-06T14:59:44.325+0000
**Updated**: 2026-09-28T16:08:52.231+0000
**URL**: https://jira.cs.sys/browse/CLM-469

**Labels**: Alliances, Legal
**Components**: Ironclad

## Description

{panel:title=Background|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
Currently, when Alliances Operations and Channels Account Managers create Legal requests through the Salesforce wizard, they must manually enter authorized counterparty territory information. This manual process is time-consuming and prone to inconsistencies, especially when the territory associations already exist in related Account Contact Relationship (ACR) records.
{panel}
{panel:title=User Story|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
*As an* alliances ops and channels account manager
*I want to* select a pre-existing ACR from a lookup field in the Salesforce request wizard (optional field)
*So that* I can automatically populate authorized counterparty territories associated with the selected ACR for the current account, reducing manual entry and ensuring consistency
{panel}
{panel:title=Acceptance Criteria|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
h3. Core Functionality
 * [ ] {*}Ironclad Integration{*}:
 ** Sync territory data from Request Form to Ironclad Properties
 ** Territory field remains editable in Ironclad Properties
 ** Make required field for archival {*}{{*}}Liz need to check with Michelle Cline on N/A option when the option is global and there are no listed territories{{*}}{*}{panel}
{panel:title=Tech Notes|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
 * Attempt to sync the Territory to the Counterparty Sales Territory property on the Ironclad Workflow via the Workflow Sync
 ** Observe if this works and still allows the Legal user to select additional Territories when working on the Workflow
 * If this doesn't sync the data over to Ironclad properly, may need to configure Salesforce automation to sync it to the workflow and properly format it
 * When the Ironclad Workflow is completed, the final format for the Counterparty Sales Territory should be like this: 
{code:java}
Albania, Andorra, Anguilla, and Barbados {code}
{panel}
{panel:title=Testing Notes|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
 
{panel}
 

## Attachments

| Filename | Size | Uploaded By | Date |
|----------|------|-------------|------|
| image-2026-08-17-18-44-00-746.png | 18.6 KB | Vikas Chauhan | 2026-08-17 |
| image-2026-08-31-18-43-15-814.png | 72.2 KB | Vikas Chauhan | 2026-08-31 |
| image-2026-08-27-18-07-16-694.png | 91.8 KB | Vikas Chauhan | 2026-08-27 |
| image-2026-08-31-18-43-46-301.png | 48.9 KB | Vikas Chauhan | 2026-08-31 |

## All Fields

| Field ID | Display Name | Value |
|----------|--------------|-------|
| `aggregateprogress` | Σ Progress | ['progress', 'total'] |
| `creator` | Creator | jbhatia |
| `customfield_10003` | Story Points | 4.0 |
| `customfield_10005` | Rank (Obsolete) | "9223372036854775807" |
| `customfield_10300` | Sprint | ['com.atlassian.greenhopper.service.sprint.Sprint@4f722678[activatedDate=2026-08-20T12:41:50.648Z,autoStartStop=false,completeDate=2026-09-09T19:30:35.515Z,endDate=2026-09-09T20:53:00.000Z,goal=<null>,id=19319,incompleteIssuesDestinationId=<null>,name=CLM Sprint 20,rapidViewId=9801,sequence=19319,startDate=2026-08-19T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@6e91766d[activatedDate=2026-09-09T19:44:48.939Z,autoStartStop=false,completeDate=2026-09-28T16:08:39.653Z,endDate=2026-09-23T21:29:00.000Z,goal=,id=19670,incompleteIssuesDestinationId=<null>,name=CLM Sprint 21,rapidViewId=9801,sequence=19670,startDate=2026-09-09T21:29:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@6b73a108[activatedDate=2026-09-28T16:09:10.118Z,autoStartStop=false,completeDate=<null>,endDate=2026-10-07T22:22:00.000Z,goal=,id=19811,incompleteIssuesDestinationId=<null>,name=CLM Sprint 22,rapidViewId=9801,sequence=19811,startDate=2026-09-23T22:22:00.000Z,state=ACTIVE,synced=false]'] |
| `customfield_11300` | Rank | "2|ifmdyw:" |
| `customfield_11700` | Time in Status | "null" |
| `customfield_11701` | Date of First Response | "2026-08-17T13:14:27.618+0000" |
| `customfield_13400` | Development | "{}" |
| `customfield_14221` | Template | "{}" |
| `customfield_14410` | Notification Count | 0 |
| `customfield_15236` | Deployed to CIDs | "None" |
| `customfield_15238` | PIR | ['PIRS_GO_HERE'] |
| `customfield_15606` | MI | "null" |
| `customfield_15611` | Exploit Type | "null" |
| `customfield_16009` | Report ID | "null" |
| `customfield_17605` | Coordinating Architect (CAT) Effort | TBD |
| `customfield_17608` | Product Manager (PM) | None Assigned |
| `customfield_17629` | Crypto Justification | Expiration |
| `customfield_17641` | Last Comment | " CLM-390: https://docs.google.com/spreadsheets/d/1CH69vMCi-GpJ6Qv_Fg4WBr0cZRd6yoARnwnvbH0ldMY/edit?usp=sharing" |
| `customfield_20217` | [CHART] Date of First Response | "2026-08-17T13:14:27.618+0000" |
| `customfield_20218` | [CHART] Time in Status | "null" |
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
| `customfield_22604` | originId | "4251785" |
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
| `customfield_23543` | Feature Flag Details | "Feature Flag Name: 

Component: ex. Microservice/UI/Sensor/VM" |
| `customfield_23601` | Deployment Date | "2026-10-06" |
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
| `lastViewed` | Last Viewed | "2026-09-27T12:46:55.964+0000" |
| `progress` | Progress | ['progress', 'total'] |
| `resolution` | Resolution | Done |
| `votes` | Votes | ['self', 'votes', 'hasVoted'] |
| `watches` | Watchers | ['self', 'watchCount', 'isWatching'] |
| `worklog` | Log Work | ['startAt', 'maxResults', 'total'] |
| `workratio` | Work Ratio | -1 |

## Comments
### Jitesh Bhatia - 2026-08-06T15:24:00.863+0000

Corresponding Salesforce story - CLM-390
### Vikas Chauhan - 2026-08-17T13:14:27.618+0000

NOTE: Need to check *"Counterparty Sales Territory"* inbound and outbound sync configuration.

TEST By Jitesh: https://demo.ironcladapp.com/c/685c32be83aacbb271e4093e/workflows/IC-33011

!image-2026-08-17-18-44-00-746.png|width=409,height=88!
### Vikas Chauhan - 2026-08-27T12:12:29.676+0000

[~lmeghani] : Let me know when you need this change on the Ironclad side for the corresponding Salesforce ticket.
### Vikas Chauhan - 2026-08-27T12:36:55.855+0000

Unable to find the corresponding "{*}Counterparty Sales Territory"{*} salesforce property for the mapping?

!image-2026-08-27-18-07-16-694.png|width=531,height=260!
### Vikas Chauhan - 2026-08-31T05:58:30.090+0000

Inbound sync for IC property "{*}Counterparty Sales Territory" <{*} Salesforce *"Partner territory"* configured on DEV, QAT and UAT
### Vikas Chauhan - 2026-08-31T13:12:37.929+0000

{*}Test on DEV successful{*}: [https://demo.ironcladapp.com/c/67a54beb1919d14dc263e70e/workflows/IC-3097]

 

!image-2026-08-31-18-43-15-814.png|width=502,height=93!

!image-2026-08-31-18-43-46-301.png|width=501,height=117!
### Vikas Chauhan - 2026-09-09T06:49:01.104+0000

 CLM-390: https://docs.google.com/spreadsheets/d/1CH69vMCi-GpJ6Qv_Fg4WBr0cZRd6yoARnwnvbH0ldMY/edit?usp=sharing
