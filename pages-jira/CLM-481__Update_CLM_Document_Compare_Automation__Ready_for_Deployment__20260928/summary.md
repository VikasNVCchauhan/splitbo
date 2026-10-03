---
title: "Update CLM Document Compare Automation User Names and Dashboard Filters"
jira_key: "CLM-481"
jira_project: "CLM"
jira_project_name: "IronClad CLM"
jira_issue_type: "Task"
jira_status: "Ready for Deployment"
jira_priority: "High"
jira_url: "https://jira.cs.sys/browse/CLM-481"
jira_assignee: "Vikas Chauhan"
jira_reporter: "Andrew Yoder"
jira_created: "2026-08-18T20:37:43.478+0000"
jira_updated: "2026-09-28T16:08:53.107+0000"
pulled_at: "2026-09-28T16:44:04.929906+00:00"
attachment_count: 0
attachment_failures: 0
---

# CLM-481: Update CLM Document Compare Automation User Names and Dashboard Filters

**Type**: Task
**Status**: Ready for Deployment
**Priority**: High
**Assignee**: Vikas Chauhan
**Reporter**: Andrew Yoder
**Created**: 2026-08-18T20:37:43.478+0000
**Updated**: 2026-09-28T16:08:53.107+0000
**URL**: https://jira.cs.sys/browse/CLM-481

**Labels**: ProServ_Ops
**Components**: Ironclad

## Description

_Release Note Summary_
Configure CLM Document Compare automation user names and dashboard filters in UAT and Prod.
{panel:title=Background|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
The CLM Document Compare automation requires properly named accounts and a dashboard filter update to correctly route documents through the compare workflow.
{panel}
{panel:title=User Story|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
As a CLM administrator,
I want the document compare service accounts named clearly and the dashboard filter configured,
So that the automation correctly identifies input and output users.
{panel}
{panel:title=Acceptance Criteria|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
Given the Ironclad dashboard "CLM Document Automation Compare view",
When I view the filter configuration,
Then Needs Signature is filtered on "CLM Document Compare Input".

Given each environment (UAT and Prod),
When I view the input and output service account display names,
Then they read "CLM Document Compare Input" and "CLM Document Compare Output" respectively.

Given the output user IDs for UAT and Prod,
When provisioning is complete,
Then both IDs have been shared with Fredy Martinez.
{panel}
{panel:title=Tech Notes|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
To change a user's display name, you must login as that user and update via profile settings.

_UAT:_
 * Input user: [clm_document_compare_input_uat@crowdstrike.com|mailto:dl_clm_document_compare_input_uat@crowdstrike.com]

 * 
 ** DL requested on [RITM0515837|https://crowdstrike.service-now.com/esc?id=ticket&table=sc_req_item&sys_id=6ec88d1b2f768350afd9e4ed4ea4e393&view=sp]
 ** Create Ironclad user with name "CLM Document Compare Input"
 * Output user: [dl_ps_document_compare_uat@crowdstrike.com|mailto:dl_ps_document_compare_uat@crowdstrike.com]
 -- Create Ironclad user with name "CLM Document Compare Output"
 -- Share user ID with [~fmartinez] 
 * Update "CLM Document Automation Compare view" filter: Needs Signature = "CLM Document Compare Input"
 -- Dashboard: [https://demo.ironcladapp.com/c/685c32c77c4d31f24b3efb1c/dashboard]
 * Update Signers - PS Ops Workflows - Document Validation
 ** Replace [dl_ps_document_compare@crowdstrike.com|mailto:dl_ps_document_compare_uat@crowdstrike.com] with [dl_clm_document_compare_input_uat@crowdstrike.com|mailto:dl_clm_document_compare_input_uat@crowdstrike.com] and set to the default user for the group

_Prod:_
 * Input user: [clm_document_compare_input@crowdstrike.com|mailto:dl_clm_document_compare_input_uat@crowdstrike.com]
 ** DL requested on [RITM0515841|https://crowdstrike.service-now.com/esc?id=ticket&table=sc_req_item&sys_id=36494d9b2f768350afd9e4ed4ea4e39b&view=sp]
 ** Create Ironclad user with name "CLM Document Compare Input"
 * Service Account: [clmdoccompare@crowdstrike.com|mailto:clmdoccompare@crowdstrike.com]
 ** Create user in prod
 * Output user: [DL_PS_Document_Compare@crowdstrike.com|mailto:DL_PS_Document_Compare@crowdstrike.com]
 ** Rename to "CLM Document Compare Output", share user ID with Fredy Martinez
 * Create "CLM Document Automation Compare view", matching UAT filter
 ** Share Dashboard URL with [~fmartinez] 
 * Update Signers - PS Ops Workflows - Document Validation
 ** Replace [dl_ps_document_compare_uat@crowdstrike.com|mailto:dl_ps_document_compare_uat@crowdstrike.com] with [clmdoccompare@crowdstrike.com|mailto:clmdoccompare@crowdstrike.com] and set to the default user for the group{panel}
{panel:title=Testing Notes|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
Verify display names are correct for input/output users in both UAT and Prod
Verify the dashboard filter returns only documents needing signature from "CLM Document Compare Input"
Confirm Fredy Martinez has received the output user IDs for both environments
{panel}

## All Fields

| Field ID | Display Name | Value |
|----------|--------------|-------|
| `aggregateprogress` | Σ Progress | ['progress', 'total'] |
| `creator` | Creator | ayoder |
| `customfield_10003` | Story Points | 2.0 |
| `customfield_10005` | Rank (Obsolete) | "9223372036854775807" |
| `customfield_10300` | Sprint | ['com.atlassian.greenhopper.service.sprint.Sprint@63704bd0[activatedDate=2026-08-20T12:41:50.648Z,autoStartStop=false,completeDate=2026-09-09T19:30:35.515Z,endDate=2026-09-09T20:53:00.000Z,goal=<null>,id=19319,incompleteIssuesDestinationId=<null>,name=CLM Sprint 20,rapidViewId=9801,sequence=19319,startDate=2026-08-19T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@5dd73602[activatedDate=2026-09-09T19:44:48.939Z,autoStartStop=false,completeDate=2026-09-28T16:08:39.653Z,endDate=2026-09-23T21:29:00.000Z,goal=,id=19670,incompleteIssuesDestinationId=<null>,name=CLM Sprint 21,rapidViewId=9801,sequence=19670,startDate=2026-09-09T21:29:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@2ba3461f[activatedDate=2026-09-28T16:09:10.118Z,autoStartStop=false,completeDate=<null>,endDate=2026-10-07T22:22:00.000Z,goal=,id=19811,incompleteIssuesDestinationId=<null>,name=CLM Sprint 22,rapidViewId=9801,sequence=19811,startDate=2026-09-23T22:22:00.000Z,state=ACTIVE,synced=false]'] |
| `customfield_11300` | Rank | "2|ifs5u8:" |
| `customfield_11700` | Time in Status | "null" |
| `customfield_11701` | Date of First Response | "2026-08-25T15:08:30.475+0000" |
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
| `customfield_17641` | Last Comment | "Work on PROD is put on hold until the Go live date." |
| `customfield_20217` | [CHART] Date of First Response | "2026-08-25T15:08:30.475+0000" |
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
| `customfield_22604` | originId | "4286969" |
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
| `lastViewed` | Last Viewed | "2026-09-27T12:46:55.944+0000" |
| `progress` | Progress | ['progress', 'total'] |
| `resolution` | Resolution | Done |
| `votes` | Votes | ['self', 'votes', 'hasVoted'] |
| `watches` | Watchers | ['self', 'watchCount', 'isWatching'] |
| `worklog` | Log Work | ['startAt', 'maxResults', 'total'] |
| `workratio` | Work Ratio | -1 |

## Comments
### Vikas Chauhan - 2026-08-25T15:08:30.475+0000

*UAT:* Invitation has been sent to the users (DL) to join the Ironclad UAT

*PROD:* Not started yet.
### Vikas Chauhan - 2026-08-26T10:49:36.574+0000

UAT Filter View URL: https://demo.ironcladapp.com/c/685c32c77c4d31f24b3efb1c/dashboard?shareView=eJyVVE1z2kAM%2FSvMnjmAAWN8I3BhJiWdCeXSyWHt1ZId1mt3P6BMhv9eyTYkaWniHDz2ytLTk55WL0wq7cE%2Beu6BpS%2FMnyp8M27Eg2X99l2f8aTcGo4slVw76LP8WWlhwbD05zXOggQ05bDlOsCiLCpulSsNBh%2FIgr4st0DJ%2Buh8UIjXZ07tyINbhDwAe6JfLQ5xMrwg7GNp91KXxyV4rrRD8EwZEEh9R2gtg4tXYz4jzVcSKYNfaPoS25gnIptFIgZ6RoPpQMYyiWVHliszr6pHrA%2BseyUZHFB3hXKV5qd1E7kGEK5HvtwHe5v7Expdaf3diVJKBVq8Ua2yZQXWnxD68vmd%2B%2Bd%2FWd1z5%2Be5VweFzghZWoGEUibA5WCEMrsmuw6FcVvlVKY0uZLSjZWy7gEtTd3Xyq4UMP5AgRqt3gacl6MSxGU0GZAEf8N0U%2Fe%2F8F0gg0Wx%2FCZYswQaOe5VrfVH2O2st9yjj7kT9MbyfI8NXIciA%2FsgyfZG%2BQ5JhtGkQzV3uqzz%2FMBRWonPMrxTIBrcrAInDduzooveGWqYdBHz3bh9ZVRuE72gL%2BpFIpbNNunOeTo54%2BVt7%2Bvi%2FltvWeahwNp78%2BDLoh6LXrMNoHdZUUDbaQO%2FPUtN0JrA4YjNSlkeHEZt8RjF8XgiZmLI42gsRJ4l2TiajuQwyWciiSQ7%2FwGJeuV0
### Vikas Chauhan - 2026-08-26T11:05:09.445+0000

*_UAT:_*
 * Input user: [clm_document_compare_input_uat@crowdstrike.com|mailto:dl_clm_document_compare_input_uat@crowdstrike.com]
 ** DL requested on [RITM0515837{color:#00875a}*- DONE*{color}|https://crowdstrike.service-now.com/esc?id=ticket&table=sc_req_item&sys_id=6ec88d1b2f768350afd9e4ed4ea4e393&view=sp]
 ** Create Ironclad user with name "CLM Document Compare Input" {color:#00875a}*- DONE*{color}
 * Output user: [dl_ps_document_compare_uat@crowdstrike.com|mailto:dl_ps_document_compare_uat@crowdstrike.com]
 ** Create Ironclad user with name "CLM Document Compare Output"{color:#00875a}*- DONE*{color}
 ** Share user ID with [~fmartinez] {color:#00875a}*- DONE*{color}
 * Update "CLM Document Automation Compare view" filter: Needs Signature = "CLM Document Compare Input"
 -- Dashboard: [https://demo.ironcladapp.com/c/685c32c77c4d31f24b3efb1c/dashboard {color:#00875a}*- DONE*{color}|https://demo.ironcladapp.com/c/685c32c77c4d31f24b3efb1c/dashboard]
 * Update Signers - PS Ops Workflows - Document Validation
 ** Replace [dl_ps_document_compare@crowdstrike.com|mailto:dl_ps_document_compare_uat@crowdstrike.com] with [dl_clm_document_compare_input_uat@crowdstrike.com|mailto:dl_clm_document_compare_input_uat@crowdstrike.com] and set to the default user for the group {color:#00875a}*- DONE*{color}

*_Prod:_*
 * Input user: [clm_document_compare_input@crowdstrike.com|mailto:dl_clm_document_compare_input_uat@crowdstrike.com]
 ** DL requested on [RITM0515841 |https://crowdstrike.service-now.com/esc?id=ticket&table=sc_req_item&sys_id=36494d9b2f768350afd9e4ed4ea4e39b&view=sp]{color:#00875a}*- DONE*{color}
 ** Create Ironclad user with name "CLM Document Compare Input" {color:#00875a}*- DONE*{color}
 * Service Account: [clmdoccompare@crowdstrike.com|mailto:clmdoccompare@crowdstrike.com]
 ** Create user in prod {color:#ff8b00}*- Invite Sent to Andrew (InProgress)*{color}
 * Output user: [DL_PS_Document_Compare@crowdstrike.com|mailto:DL_PS_Document_Compare@crowdstrike.com]
 ** Rename to "CLM Document Compare Output", share user ID with Fredy Martinez {color:#ff8b00}*- Person with Ironclad credential of this user can rename this need Andrew's help.* {color} 
 * Create "CLM Document Automation Compare view", matching UAT filter {color:#00875a}*- DONE*{color} 
 ** Share Dashboard URL with [~fmartinez]  -{color:#ff8b00} *Yet to be shared (waiting Andrew to verify the invited user)*{color}
 * Update Signers - PS Ops Workflows - Document Validation
 ** Replace [dl_ps_document_compare_uat@crowdstrike.com|mailto:dl_ps_document_compare_uat@crowdstrike.com] with [clmdoccompare@crowdstrike.com|mailto:clmdoccompare@crowdstrike.com] and set to the default user for the group - *{color:#ff8b00}Dependency on above{color}*

 

*PROD Filter view URL:* [https://ironcladapp.com/c/67903967a48bfd963bb426e8/dashboard?shareView=eJyVlE1z4jAMhv8K4zOHNCQBcqNwYaZLd6Ysl50ejK1QD46T9Qcs0%2BG%2Fr5QA7e7SNpyChfTqkSXrlRVKe7BPnntg%2BSvzhxq%2FjBv5aFn%2F9G3OeFJuAXuWF1w76DPxorS0YFj%2B8xJnoQA0CVhxHWBalTW3ylUGg3dkQV8mLFCyPjrvFOr1mVMb8uAWJXfAnumvkw4xGV6S9r6y20JX%2Bxl4rrRD8bUyIBF9Q2ongrNXaz4i5htEzuAXmm6izfgIRJpFg8E4iQqRjcYQpVEcdaScm0ldP2F9YN0bZHBAtyuVqzU%2FLNrIBYB0PfLlPtjr7M9odJX19wdKWSjQ8l3XalvVYP0Bpc8%2Fv3P%2F8j%2FVA3d%2BIrzaKXRGycpKBMqZBCfASGU2bXYdSuNWyqm10uRKnW6tlHULaGnrvlR2QcD4HQVqtHobcF72ShLLII2oBf%2FKdOvuh%2FJdJIPFZvllsGYGNHLcq6bXndHjz9FJeWm52OL9LUK5BvtYkO1d47%2FOcRenHWq511WT5gcO0lzelCCOrhaBc4aXM6dn3p111KWVfw3bLYNyHfSsPm3WiJy1u6Q78zA94tM9vdbpw7ferBKhxNp7k%2BCrshmKXrsLoHdeUEC7aQm%2FPctN0JrEYY%2BXlTMRHEat8CiSbJzIYTzM4iiRAvjdOorHSQJZEqcxH7DjH4HK42w%3D]

CC: [~ayoder] 
### Vikas Chauhan - 2026-08-31T05:15:41.119+0000

Work on PROD is put on hold until the Go live date.
