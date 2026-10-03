---
title: "Ironclad Sailpoint App"
jira_key: "CLM-455"
jira_project: "CLM"
jira_project_name: "IronClad CLM"
jira_issue_type: "Task"
jira_status: "UAT"
jira_priority: "Medium"
jira_url: "https://jira.cs.sys/browse/CLM-455"
jira_assignee: "Jitesh Bhatia"
jira_reporter: "Jitesh Bhatia"
jira_created: "2026-07-28T17:28:28.964+0000"
jira_updated: "2026-09-28T16:08:45.700+0000"
pulled_at: "2026-09-28T16:44:04.970584+00:00"
attachment_count: 0
attachment_failures: 0
---

# CLM-455: Ironclad Sailpoint App

**Type**: Task
**Status**: UAT
**Priority**: Medium
**Assignee**: Jitesh Bhatia
**Reporter**: Jitesh Bhatia
**Created**: 2026-07-28T17:28:28.964+0000
**Updated**: 2026-09-28T16:08:45.700+0000
**URL**: https://jira.cs.sys/browse/CLM-455

**Labels**: legal
**Components**: Ironclad

## Description

 
{panel:title=Background|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
Sailpoint is our identity governance platform that manages user access and provisioning across enterprise systems. To effectively manage user lifecycle and access controls for Ironclad users, Sailpoint needs the ability to connect to Ironclad's API and read user data. This integration will enable automated user provisioning, deprovisioning, and access reviews for Ironclad accounts.
{panel}
{panel:title=User Story|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
As a Security Administrator, I need Sailpoint to connect to Ironclad and read user data so that I can manage user access governance, perform automated access reviews, and ensure proper user lifecycle management across our contract management platform.
{panel}
{panel:title=Acceptance Criteria|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
1. App Creation
    - An application is created in Ironclad with appropriate API credentials (API key/token)
    - App is configured with read-only permissions for user data
    - App credentials are securely stored and accessible to the integration team
  2. API Access
    - Sailpoint can successfully authenticate to Ironclad using the app credentials
    - The app has permission to read the following user data:
        - User ID
      - Email address
      - Full name
      - User status (active/inactive)
      - Role/permission assignments
      - Last login date
    - API responses return data in a format compatible with Sailpoint ingestion
  3. Security & Compliance
    - API access is restricted to read-only operations (no write/update/delete permissions)
    - Credentials follow principle of least privilege
  4. Testing
    - Successful test connection from Sailpoint to Ironclad
    - User data retrieval validated with sample queries
{panel}
{panel:title=Tech Notes|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
 
{panel}
{panel:title=Testing Notes|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
 
{panel}

## All Fields

| Field ID | Display Name | Value |
|----------|--------------|-------|
| `aggregateprogress` | Σ Progress | ['progress', 'total'] |
| `creator` | Creator | jbhatia |
| `customfield_10003` | Story Points | 2.0 |
| `customfield_10005` | Rank (Obsolete) | "9223372036854775807" |
| `customfield_10300` | Sprint | ['com.atlassian.greenhopper.service.sprint.Sprint@47d50f61[activatedDate=2026-07-23T15:46:21.488Z,autoStartStop=false,completeDate=2026-08-03T20:59:14.090Z,endDate=2026-07-29T20:53:00.000Z,goal=,id=18852,incompleteIssuesDestinationId=<null>,name=CLM Sprint 18,rapidViewId=9801,sequence=18852,startDate=2026-07-15T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@3b15b0b3[activatedDate=2026-08-03T21:00:06.384Z,autoStartStop=false,completeDate=2026-08-20T12:35:48.048Z,endDate=2026-08-19T20:53:00.000Z,goal=<null>,id=18853,incompleteIssuesDestinationId=<null>,name=CLM Sprint 19,rapidViewId=9801,sequence=18853,startDate=2026-07-29T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@7294d430[activatedDate=2026-08-20T12:41:50.648Z,autoStartStop=false,completeDate=2026-09-09T19:30:35.515Z,endDate=2026-09-09T20:53:00.000Z,goal=<null>,id=19319,incompleteIssuesDestinationId=<null>,name=CLM Sprint 20,rapidViewId=9801,sequence=19319,startDate=2026-08-19T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@4379d07a[activatedDate=2026-09-09T19:44:48.939Z,autoStartStop=false,completeDate=2026-09-28T16:08:39.653Z,endDate=2026-09-23T21:29:00.000Z,goal=,id=19670,incompleteIssuesDestinationId=<null>,name=CLM Sprint 21,rapidViewId=9801,sequence=19670,startDate=2026-09-09T21:29:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@53bdc220[activatedDate=2026-09-28T16:09:10.118Z,autoStartStop=false,completeDate=<null>,endDate=2026-10-07T22:22:00.000Z,goal=,id=19811,incompleteIssuesDestinationId=<null>,name=CLM Sprint 22,rapidViewId=9801,sequence=19811,startDate=2026-09-23T22:22:00.000Z,state=ACTIVE,synced=false]'] |
| `customfield_11300` | Rank | "2|hypevc:07c3n1xg" |
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
| `customfield_17641` | Last Comment | "Created app in Demo, QAT, and UAT, so should be good to create in Prod too once Sailpoint team signs off" |
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
| `customfield_22604` | originId | "4224152" |
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
| `customfield_23601` | Deployment Date | "2026-10-13" |
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
| `votes` | Votes | ['self', 'votes', 'hasVoted'] |
| `watches` | Watchers | ['self', 'watchCount', 'isWatching'] |
| `worklog` | Log Work | ['startAt', 'maxResults', 'total'] |
| `workratio` | Work Ratio | -1 |

## Comments
### Jitesh Bhatia - 2026-08-21T18:39:21.003+0000

Created app in Demo, QAT, and UAT, so should be good to create in Prod too once Sailpoint team signs off
