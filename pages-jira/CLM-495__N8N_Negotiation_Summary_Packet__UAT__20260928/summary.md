---
title: "N8N Negotiation Summary Packet"
jira_key: "CLM-495"
jira_project: "CLM"
jira_project_name: "IronClad CLM"
jira_issue_type: "Task"
jira_status: "UAT"
jira_priority: "Medium"
jira_url: "https://jira.cs.sys/browse/CLM-495"
jira_assignee: "Jitesh Bhatia"
jira_reporter: "Jitesh Bhatia"
jira_created: "2026-08-25T17:45:43.300+0000"
jira_updated: "2026-09-28T16:08:55.878+0000"
pulled_at: "2026-09-28T16:44:04.320079+00:00"
attachment_count: 0
attachment_failures: 0
---

# CLM-495: N8N Negotiation Summary Packet

**Type**: Task
**Status**: UAT
**Priority**: Medium
**Assignee**: Jitesh Bhatia
**Reporter**: Jitesh Bhatia
**Created**: 2026-08-25T17:45:43.300+0000
**Updated**: 2026-09-28T16:08:55.878+0000
**URL**: https://jira.cs.sys/browse/CLM-495

**Labels**: Legal
**Components**: Salesforce

## Description

 
{panel:title=Background|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
The Legal team requires automated document generation when a Legal Request (Questionnaire_Request_Form__c) is assigned to an individual for MPA (Master Purchase Agreement) Review. When an MPA review is assigned, an n8n workflow must be triggered to generate the appropriate review documents and automatically attach them to the Legal Request record. This eliminates manual document creation and ensures reviewers have the necessary materials immediately upon assignment.
{panel}
{panel:title=User Story|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
As a Legal Operations team member
I want Salesforce to publish a platform event when a Legal Request is assigned to a reviewer for MPA Review
So that n8n can automatically generate and attach the required review documents to the Legal Request record
{panel}
{panel:title=Acceptance Criteria|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
 * Event Publishing
 ** System publishes a platform event when a Questionnaire_Request_Form__c record meets MPA Review assignment criteria
 ** Event is triggered ONLY when assignment is for "MPA Review" stage/type
 ** Event is NOT triggered for other review types or stages
 * Event Payload
 ** Event contains the Legal Request record ID (Questionnaire_Request_Form__c 18-character ID)
 ** Event payload is consumable by Mulesoft MQ and routable to n8n
 * Assignment Detection
 ** System detects when Legal Request is newly assigned to an individual user for MPA Review
 ** System distinguishes MPA Review assignments from other assignment types
 ** Re-assignments to the same user do NOT trigger duplicate events unless explicitly required{panel}
{panel:title=Tech Notes|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
 * Trigger SFDC Event when Legal Request object is assigned to an individual for MPA Review only
 ** Salesforce Event > Mulesoft MQ > n8n Webhook
 ** Event should contain Legal Request ID {panel}
{panel:title=Testing Notes|borderStyle=dashed|borderColor=#cccccc|titleBGColor=#eeeeee}
 *  {panel}

## All Fields

| Field ID | Display Name | Value |
|----------|--------------|-------|
| `aggregateprogress` | Σ Progress | ['progress', 'total'] |
| `creator` | Creator | jbhatia |
| `customfield_10003` | Story Points | 2.0 |
| `customfield_10005` | Rank (Obsolete) | "9223372036854775807" |
| `customfield_10300` | Sprint | ['com.atlassian.greenhopper.service.sprint.Sprint@7294d430[activatedDate=2026-08-20T12:41:50.648Z,autoStartStop=false,completeDate=2026-09-09T19:30:35.515Z,endDate=2026-09-09T20:53:00.000Z,goal=<null>,id=19319,incompleteIssuesDestinationId=<null>,name=CLM Sprint 20,rapidViewId=9801,sequence=19319,startDate=2026-08-19T20:53:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@4379d07a[activatedDate=2026-09-09T19:44:48.939Z,autoStartStop=false,completeDate=2026-09-28T16:08:39.653Z,endDate=2026-09-23T21:29:00.000Z,goal=,id=19670,incompleteIssuesDestinationId=<null>,name=CLM Sprint 21,rapidViewId=9801,sequence=19670,startDate=2026-09-09T21:29:00.000Z,state=CLOSED,synced=false]', 'com.atlassian.greenhopper.service.sprint.Sprint@53bdc220[activatedDate=2026-09-28T16:09:10.118Z,autoStartStop=false,completeDate=<null>,endDate=2026-10-07T22:22:00.000Z,goal=,id=19811,incompleteIssuesDestinationId=<null>,name=CLM Sprint 22,rapidViewId=9801,sequence=19811,startDate=2026-09-23T22:22:00.000Z,state=ACTIVE,synced=false]'] |
| `customfield_11300` | Rank | "2|ifv3yg:" |
| `customfield_11701` | Date of First Response | "2026-08-29T00:01:39.958+0000" |
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
| `customfield_17641` | Last Comment | "[Jitesh Bhatia|https://gitlab.cs.sys/jitesh.bhatia] mentioned this issue in [a merge request|https://gitlab.cs.sys/CrowdStrike/gtm/sfdc/commercial/-/merge_requests/8214] of [CrowdStrike / GTM / SFDC / Commercial|https://gitlab.cs.sys/CrowdStrike/gtm/sfdc/commercial] on branch [feature/US-0040855|https://gitlab.cs.sys/CrowdStrike/gtm/sfdc/commercial/-/tree/feature/US-0040855]:{quote}US-0040855 [CLM-495] - N8N Negotiation Summary Packet{quote}" |
| `customfield_20217` | [CHART] Date of First Response | "2026-08-29T00:01:39.958+0000" |
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
| `customfield_22604` | originId | "4304400" |
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
| `customfield_23601` | Deployment Date | "2026-09-29" |
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
### svc_it_gitlab_jira - 2026-08-29T00:01:39.958+0000

[Jitesh Bhatia|https://gitlab.cs.sys/jitesh.bhatia] mentioned this issue in [a merge request|https://gitlab.cs.sys/CrowdStrike/gtm/sfdc/commercial/-/merge_requests/8103] of [CrowdStrike / GTM / SFDC / Commercial|https://gitlab.cs.sys/CrowdStrike/gtm/sfdc/commercial] on branch [feature/US-0040855|https://gitlab.cs.sys/CrowdStrike/gtm/sfdc/commercial/-/tree/feature/US-0040855]:{quote}US-0040855 [CLM-495] - N8N Negotiation Summary Packet{quote}
### svc_it_gitlab_jira - 2026-09-03T05:27:59.659+0000

[Jitesh Bhatia|https://gitlab.cs.sys/jitesh.bhatia] mentioned this issue in [a merge request|https://gitlab.cs.sys/CrowdStrike/gtm/sfdc/commercial/-/merge_requests/8214] of [CrowdStrike / GTM / SFDC / Commercial|https://gitlab.cs.sys/CrowdStrike/gtm/sfdc/commercial] on branch [feature/US-0040855|https://gitlab.cs.sys/CrowdStrike/gtm/sfdc/commercial/-/tree/feature/US-0040855]:{quote}US-0040855 [CLM-495] - N8N Negotiation Summary Packet{quote}
